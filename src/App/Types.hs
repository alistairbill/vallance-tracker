{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE DeriveGeneric #-}

module App.Types
  ( Configuration (..),
    DateNewCases (..),
    CasesResponse (..),
  )
where

import App.Prelude
import Data.Aeson
import Data.Time.Calendar (Day)
import Database.PostgreSQL.Simple

data Configuration = Configuration
  { port :: Int,
    connStr :: String
  }

data DateNewCases = DateNewCases
  { date :: Day,
    newCases :: Int
  }
  deriving (Generic, ToRow, FromRow)

instance FromJSON DateNewCases

instance ToJSON DateNewCases

data CasesResponse = CasesResponse
  { exampleScenario :: [DateNewCases],
    reality :: [DateNewCases]
  }
  deriving (Generic)

instance ToJSON CasesResponse
