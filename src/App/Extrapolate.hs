module App.Extrapolate where

import App.Prelude
import App.Types
import Data.Time.Calendar (addDays, fromGregorian)

extrapolatedScenario :: [DateNewCases]
extrapolatedScenario = map extrap [1..28]
  where sep = fromGregorian 2020 9 15
        cases = 3105
        extrap n = let factor = 2 ** (fromIntegral n / 7)
          in DateNewCases (addDays (fromIntegral n) sep) (round (factor * cases))
