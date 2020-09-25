{-# LANGUAGE DataKinds       #-}
{-# LANGUAGE OverloadedStrings       #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE TypeOperators   #-}
module App.App where

import App.Types
import App.APIRequest
import Control.Monad
import Data.ByteString (ByteString)
import Data.ByteString.Char8 as B8 (pack)
import Data.Maybe (fromMaybe)
import Data.Time.Calendar
import Data.Time.Clock
import Control.Applicative (liftA2)
import Control.Exception (bracket)
import Control.Monad.IO.Class (liftIO)
import Data.Pool
import Database.PostgreSQL.Simple
import Network.HTTP.Req (runReq, defaultHttpConfig)
import Network.Wai
import Network.Wai.Handler.Warp
import Servant
import Servant.JS

type DBConnString = ByteString

initDB :: DBConnString -> IO ()
initDB connStr = bracket (connectPostgreSQL connStr) close $ \conn -> do
  execute_ conn
    "CREATE TABLE IF NOT EXISTS cases (date DATE NOT NULL PRIMARY KEY, new_cases INTEGER NOT NULL)"
  execute_ conn
    "CREATE TABLE IF NOT EXISTS example_scenario (date DATE NOT NULL PRIMARY KEY, new_cases INTEGER NOT NULL)"
  return ()

initConnectionPool :: DBConnString -> IO (Pool Connection)
initConnectionPool connStr =
  createPool (connectPostgreSQL connStr) close
    2 -- stripes
    60 -- unused connections kept open for 1 minute
    10 -- max 10 connections per stripe

type API = "cases" :> Get '[JSON] CasesResponse

type API' = API :<|> Raw

api :: Proxy API
api = Proxy

api' :: Proxy API'
api' = Proxy

writeJS :: FilePath -> IO ()
writeJS = writeJSForAPI api . vanillaJSWith $ defCommonGeneratorOptions { moduleName = "module.exports" }

startApp :: Configuration -> IO ()
startApp config = do
  let connBs = B8.pack . connStr $ config
  pool <- initConnectionPool connBs
  initDB connBs
  run (port config) (serve api' $ server' pool)

{-
fanciful :: Int -> DateNewCases
fanciful n = let sep = read "2020-09-15"
                 cases = 2649.0
                 factor = 2 ** ((fromIntegral n) / 7)
  in DateNewCases (addDays (fromIntegral n) sep) (round (factor * cases))
-}

updateDB :: Pool Connection -> IO ()
updateDB conns = withResource conns $ \conn -> do
  [Only maxDate] <- (query_ conn "SELECT MAX(date) FROM cases" :: IO [Only (Maybe Day)])
  currentDate <- utctDay <$> getCurrentTime
  let diff = fromMaybe 1 $ diffDays currentDate <$> maxDate
      action = case diff of
        0 -> return ()
        _ -> do
          dateCases <- getCases
          executeMany conn "INSERT INTO cases (date, new_cases) VALUES (?, ?) ON CONFLICT (date) DO UPDATE SET new_cases = excluded.new_cases" dateCases
          return ()
  action


server :: Pool Connection -> Server API
server conns = getCases
  where getCases :: Handler CasesResponse
        getCases = do
          liftIO $ updateDB conns
          r <- liftIO $ getReality conns
          f <- liftIO $ getFiction conns
          return $ CasesResponse f r

startDate :: Only Day
startDate = Only $ fromGregorian 2020 6 31

getFiction :: Pool Connection -> IO [DateNewCases]
getFiction conns = withResource conns $ \conn -> query conn "SELECT * FROM example_scenario WHERE date >= ?" startDate

getReality :: Pool Connection -> IO [DateNewCases]
getReality conns = withResource conns $ \conn -> query conn "SELECT * FROM cases WHERE date >= ?" startDate

server' :: Pool Connection -> Server API'
server' conns = server conns :<|> serveDirectoryFileServer "frontend/dist"