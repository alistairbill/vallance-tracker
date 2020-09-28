{-# LANGUAGE TypeApplications #-}
module App.ToSwagger where

import App.Prelude
import App.App (API)
import Data.Aeson (encode)
import Servant.Swagger (HasSwagger(toSwagger))

printSwagger :: IO ()
printSwagger = putLBSLn . encode . toSwagger $ Proxy @API