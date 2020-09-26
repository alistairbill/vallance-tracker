{-# LANGUAGE DataKinds       #-}
{-# LANGUAGE TypeOperators   #-}
module App.App where

import App.Prelude
import App.Types
import App.Db
import Control.Monad.IO.Class (liftIO)
import Network.Wai.Handler.Warp (run)
import Network.Wai.Middleware.EnforceHTTPS as HTTPS
import Servant
import Servant.JS

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
  let connBs = encodeUtf8 . connStr $ config
  pool <- initConnectionPool connBs
  initDB connBs
  run (port config) (HTTPS.withResolver HTTPS.xForwardedProto . serve api' $ server' pool)

server :: DBConn -> Server API
server conn = getCases
  where getCases :: Handler CasesResponse
        getCases = do
          liftIO $ updateDB conn
          r <- liftIO $ getReality conn
          f <- liftIO $ getExampleScenario conn
          return $ CasesResponse f r

server' :: DBConn -> Server API'
server' conn = server conn :<|> serveDirectoryFileServer "frontend/dist"