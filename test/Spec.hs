{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes #-}

module Main (main) where

import App.APIRequest
import Test.Hspec
-- import Test.Hspec.Wai
-- import Test.Hspec.Wai.JSON

main :: IO ()
main = hspec spec

spec :: Spec
spec = do
  describe "APIRequest" $
    it "works" $ do
      casesStats <- getCases
      length casesStats `shouldSatisfy` (> 0)

{-
spec :: Spec
spec = with (return app) $ do
    describe "GET /cases" $ do
        it "responds with 200" $ do
            get "/cases" `shouldRespondWith` 200
-}