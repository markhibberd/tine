{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE TemplateHaskell #-}
{-# OPTIONS_GHC -fno-warn-missing-signatures #-}
module Test.Tine.Data.Duration where

import           P

import           System.IO

import           Test.QuickCheck

import           Tine.Data.Duration

--
-- Symmetric conversions
--

prop_microseconds n =
  toMicroseconds (microseconds n) === n

prop_milliseconds n =
  toMilliseconds (milliseconds n) === n

prop_seconds n =
  toSeconds (seconds n) === n

prop_minutes n =
  toMinutes (minutes n) === n

--
-- Scaling
--

prop_microseconds_scale n =
  toMicroseconds (microseconds n) === n

prop_milliseconds_scale n =
  toMicroseconds (milliseconds n) === (n * 1000)

prop_seconds_scale n =
  toMicroseconds (seconds n) === (n * 1000 * 1000)

prop_minutes_scale n =
  toMicroseconds (minutes n) === (n * 60 * 1000 * 1000)

--
-- Sanity checks
--

prop_sanity = conjoin [
    minutes 1 === seconds 60
  , seconds 1 === milliseconds 1000
  , milliseconds 1 === microseconds 1000
  ]

return []
tests :: IO Bool
tests = $quickCheckAll
