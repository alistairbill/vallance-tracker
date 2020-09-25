{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE DeriveGeneric #-}
module App.Types (
    Configuration(..)
  , DateNewCases(..)
  , CasesResponse(..)
) where

import Data.Aeson
import Database.PostgreSQL.Simple
import Data.Time.Calendar (Day)
import GHC.Generics

data Configuration = Configuration
    { port :: Int
    , connStr :: String
    } deriving (Show)


data DateNewCases = DateNewCases
  { date  :: Day
  , newCases :: Int
  } deriving (Show, Generic, ToRow, FromRow)
instance FromJSON DateNewCases
instance ToJSON DateNewCases

data CasesResponse = CasesResponse
    { fiction :: [DateNewCases]
    , reality :: [DateNewCases]
    } deriving (Generic, Show)
instance ToJSON CasesResponse
