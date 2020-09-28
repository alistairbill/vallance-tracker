{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}

module App.App where

import App.Db
import App.Prelude
import App.Types
import Network.Wai.Handler.Warp (run)
import Network.Wai.Middleware.EnforceHTTPS
import Servant
import Lens.Micro.Platform

type API = "cases" :> Get '[JSON] CasesResponse

type API' = API :<|> Raw

type AppM = ReaderT DBConn Handler

api :: Proxy API
api = Proxy

api' :: Proxy API'
api' = Proxy

startApp :: Configuration -> IO ()
startApp config = do
  let connBs = encodeUtf8 (config ^. connStr)
  pool <- initConnectionPool connBs
  initDB connBs
  let app = if config ^. disableHttpsRedirect then mkApp pool
            else withResolver xForwardedProto $ mkApp pool
  run (config ^. port) app

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