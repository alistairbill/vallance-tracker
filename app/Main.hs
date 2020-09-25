module Main where

import App.App
import App.Types
import System.Environment (getArgs, lookupEnv)
import System.FilePath ((</>))

getConfig :: IO Configuration
getConfig = do
    Just port <- fmap (read :: String -> Int) <$> lookupEnv "PORT"
    Just connStr <- lookupEnv "DATABASE_URL"
    return $ Configuration { port = port, connStr = connStr }

generateJs :: IO ()
generateJs = writeJS ("frontend" </> "src" </> "api.js")

app :: IO ()
app = getConfig >>= startApp

parse :: [String] -> IO ()
parse ["--generate-js"] = generateJs
parse _ = app

main :: IO ()
main = getArgs >>= parse