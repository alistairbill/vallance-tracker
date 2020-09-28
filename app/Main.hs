{-# LANGUAGE TypeApplications #-}
module Main where

import App.App
import App.Types
import App.ToSwagger (printSwagger)
import Prelude
import System.Environment (getArgs, lookupEnv)
import Data.Maybe (isJust)

getConfig :: IO Configuration
getConfig = do
  Just envPort <- fmap (read @Int) <$> lookupEnv "PORT"
  Just envDbUrl <- lookupEnv "DATABASE_URL"
  envDisableHttps <- isJust <$> lookupEnv "DISABLE_HTTPS"
  return $ Configuration envPort envDbUrl envDisableHttps

app :: IO ()
app = getConfig >>= startApp

parse :: [String] -> IO ()
parse ["--generate-swagger"] = printSwagger
parse _ = app

main :: IO ()
main = getArgs >>= parse