{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE DeriveGeneric #-}
module App.Types (
    Configuration(..)
  , DateNewCases(..)
  , CasesResponse(..)
) where

import App.Prelude
import Data.Aeson
import Database.PostgreSQL.Simple
import Data.Time.Calendar (Day)

data Configuration = Configuration
    { port :: Int
    , connStr :: String
    }

data DateNewCases = DateNewCases
  { date  :: Day
  , newCases :: Int
  } deriving (Generic, ToRow, FromRow)
instance FromJSON DateNewCases
instance ToJSON DateNewCases

data CasesResponse = CasesResponse
    { exampleScenario :: [DateNewCases]
    , reality :: [DateNewCases]
    } deriving (Generic)
instance ToJSON CasesResponse
