{-# LANGUAGE DataKinds #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE TemplateHaskell #-}
module App.APIRequest where

import Data.Aeson
import Data.Aeson.TH
import Data.Aeson.Types (Parser, parseMaybe)
import Data.Maybe (fromMaybe)
import Network.HTTP.Req
import qualified Data.Map.Strict as Map
import App.Types (DateNewCases(..))
import Data.Time.Calendar (Day)

cases :: Value -> Parser [DateNewCases]
cases = withObject "cases" $ (.: "data")

casesRequest :: Req [DateNewCases]
casesRequest = let
    (url, opts) = [urlQ|https://api.coronavirus.data.gov.uk/v1/data?filters=areaType%3Doverview&structure=%7B%22date%22:%22date%22,%22newCases%22:%22newCasesByPublishDate%22%7D|]
    json = responseBody <$> req GET url NoReqBody jsonResponse opts
    in fromMaybe [] . parseMaybe cases <$> json

getCases :: IO [DateNewCases]
getCases = runReq defaultHttpConfig casesRequest