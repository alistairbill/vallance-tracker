{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE TemplateHaskell #-}

module App.Types where

import App.Prelude
import Data.Aeson
import Data.Time.Calendar (Day)
import Database.PostgreSQL.Simple
import Data.Swagger
import Lens.Micro.Platform

data Configuration = Configuration
  { _port :: Int,
    _connStr :: String,
    _disableHttpsRedirect :: Bool
  }
makeLenses ''Configuration

data DateNewCases = DateNewCases
  { date :: Day,
    newCases :: Int
  }
  deriving (Generic, ToRow, FromRow)

instance FromJSON DateNewCases
instance ToJSON DateNewCases
instance ToSchema DateNewCases

data CasesResponse = CasesResponse
  { exampleScenario :: [DateNewCases],
    reality :: [DateNewCases]
  }
  deriving (Generic)

instance ToJSON CasesResponse
instance ToSchema CasesResponse
