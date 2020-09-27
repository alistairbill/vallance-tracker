module App.Extrapolate
  ( extrapolatedScenario,
  )
where

import App.Prelude
import App.Types
import Data.Time.Calendar (Day, addDays, fromGregorian)

initialDay :: Day
initialDay = fromGregorian 2020 9 15

initialCases :: Double
initialCases = 3105.0 :: Double

extrap :: Int -> DateNewCases
extrap n =
  let factor = 2 ** (fromIntegral n / 7)
   in DateNewCases (addDays (fromIntegral n) initialDay) (round (factor * initialCases))

extrapolatedScenario :: [DateNewCases]
extrapolatedScenario = map extrap [1 .. 28]
