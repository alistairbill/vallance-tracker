{-# LANGUAGE QuasiQuotes #-}

module App.Db where

import App.APIRequest (getCases)
import App.Extrapolate (extrapolatedScenario)
import App.Prelude
import App.Types
import Control.Exception (bracket)
import Data.Pool (Pool, createPool, withResource)
import Data.Time.Calendar (Day, diffDays, fromGregorian)
import Data.Time.Clock (UTCTime (utctDay), getCurrentTime)
import Database.PostgreSQL.Simple
import Database.PostgreSQL.Simple.SqlQQ (sql)

type DBConnString = ByteString

type DBConn = Pool Connection

initConnectionPool :: DBConnString -> IO (Pool Connection)
initConnectionPool dbConnStr =
  createPool
    (connectPostgreSQL dbConnStr)
    close
    2 -- stripes
    60 -- unused connections kept open for 1 minute
    10 -- max 10 connections per stripe

initDB :: DBConnString -> IO ()
initDB dbConnStr = bracket (connectPostgreSQL dbConnStr) close $ \conn -> do
  execute_
    conn
    [sql|CREATE TABLE IF NOT EXISTS cases
      (date DATE NOT NULL PRIMARY KEY, new_cases INTEGER NOT NULL)|]
  execute_
    conn
    [sql|CREATE TABLE IF NOT EXISTS example_scenario
      (date DATE NOT NULL PRIMARY KEY, new_cases INTEGER NOT NULL)|]
  executeMany
    conn
    [sql|INSERT INTO example_scenario (date, new_cases) VALUES (?, ?)
      ON CONFLICT (date) DO NOTHING|]
    extrapolatedScenario
  pass

updateDB :: Pool Connection -> IO ()
updateDB conns = withResource conns $ \conn -> do
  [Only maxDate] <- (query_ conn [sql|SELECT MAX(date) FROM cases|] :: IO [Only (Maybe Day)])
  currentDate <- utctDay <$> getCurrentTime
  let diff = maybe 1 (diffDays currentDate) maxDate
  case diff of
    0 -> pass
    _ -> do
      dateCases <- getCases
      executeMany
        conn
        [sql|INSERT INTO cases (date, new_cases) VALUES (?, ?)
          ON CONFLICT (date) DO UPDATE SET new_cases = excluded.new_cases|]
        dateCases
      pass

startDate :: Only Day
startDate = Only $ fromGregorian 2020 6 31

getExampleScenario :: Pool Connection -> IO [DateNewCases]
getExampleScenario conns = withResource conns $
  \conn -> query conn [sql|SELECT * FROM example_scenario WHERE date >= ?|] startDate

getReality :: Pool Connection -> IO [DateNewCases]
getReality conns = withResource conns $
  \conn -> query conn [sql|SELECT * FROM cases WHERE date >= ?|] startDate
