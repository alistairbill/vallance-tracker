{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}

module App.App where

import App.Db
import App.Prelude
import App.Types
import Network.Wai.Handler.Warp (run)
import Network.Wai.Middleware.EnforceHTTPS
import Servant
import Servant.JS

type API = "cases" :> Get '[JSON] CasesResponse

type API' = API :<|> Raw

type AppM = ReaderT DBConn Handler

api :: Proxy API
api = Proxy

api' :: Proxy API'
api' = Proxy

writeJS :: FilePath -> IO ()
writeJS = writeJSForAPI api . vanillaJSWith $ defCommonGeneratorOptions {moduleName = "module.exports"}

startApp :: Configuration -> IO ()
startApp config = do
  let connBs = encodeUtf8 . connStr $ config
  pool <- initConnectionPool connBs
  initDB connBs
  run (port config) (withResolver xForwardedProto $ mkApp pool)

mkApp :: DBConn -> Application
mkApp conn = serve api' $ hoistServer api' (`runReaderT` conn) server'

server :: ServerT API AppM
server = getCases
  where
    getCases :: AppM CasesResponse
    getCases = do
      conn <- ask
      liftIO $ updateDB conn
      real <- liftIO $ getReality conn
      example <- liftIO $ getExampleScenario conn
      return $ CasesResponse example real

server' :: ServerT API' AppM
server' = server :<|> serveDirectoryFileServer "frontend/dist"