{-# LANGUAGE TypeApplications #-}
module Main where

import App.App
import App.Types
import Prelude
import System.Environment (getArgs, lookupEnv)
import System.FilePath ((</>))

getConfig :: IO Configuration
getConfig = do
  Just envPort <- fmap (read @Int) <$> lookupEnv "PORT"
  Just envDbUrl <- lookupEnv "DATABASE_URL"
  return $ Configuration envPort envDbUrl

generateJs :: IO ()
generateJs = writeJS ("frontend" </> "src" </> "api.js")

app :: IO ()
app = getConfig >>= startApp

parse :: [String] -> IO ()
parse ["--generate-js"] = generateJs
parse _ = app

main :: IO ()
main = getArgs >>= parse