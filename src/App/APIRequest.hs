{-# LANGUAGE DataKinds #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes #-}
module App.APIRequest where

import App.Prelude
import Data.Aeson
import Data.Aeson.Types (Parser, parseMaybe)
import Network.HTTP.Req
import App.Types

cases :: Value -> Parser [DateNewCases]
cases = withObject "cases" (.: "data")

casesRequest :: Req [DateNewCases]
casesRequest = let
    (url, opts) = [urlQ|https://api.coronavirus.data.gov.uk/v1/data?filters=areaType%3Doverview&structure=%7B%22date%22:%22date%22,%22newCases%22:%22newCasesByPublishDate%22%7D|]
    json = responseBody <$> req GET url NoReqBody jsonResponse opts
    in fromMaybe [] . parseMaybe cases <$> json

getCases :: IO [DateNewCases]
getCases = runReq defaultHttpConfig casesRequest