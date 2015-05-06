{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE TemplateHaskell #-}
{-# OPTIONS_GHC -fno-warn-missing-signatures #-}
module Test.IO.Tine.Process where

import           Control.Monad.Catch

import           Orphanarium.Core.IO

import           P

import           System.Exit
import           System.IO
import           System.Posix.Signals

import           Test.QuickCheck

import           Tine.Data
import           Tine.Process

prop_execProcess_ok =
  once . testIO $ (===) ExitSuccess <$> execProcess (shell $ "exit 0")

prop_execProcess_failure = forAll (choose (1, 127)) $ \n ->
  testIO $ (===) (ExitFailure n) <$> execProcess (shell $ "exit " <> show n)

prop_execProcessOrPin_pulled = once . testIO $ do
  pin <- newPin
  pullPin pin
  p <- execProcessOrPin pin  (shell $ "sleep 2")
  case p of
    ProcessStopped _ ->
      pure $ counterexample "Process should not of stopped already, pin should of been pulled." False
    PinPulled h -> do
      isDone <- isJust <$> getProcessExitCode h
      r <- waitForProcess h
      pure $ (isDone, r) === (False, ExitSuccess)

prop_execProcessOrPin_not_pulled = once . testIO $ do
  pin <- newPin
  p <- execProcessOrPin pin (shell $ "exit 0")
  pure $ case p of
    ProcessStopped r ->
      r === ExitSuccess
    PinPulled _ -> do
      counterexample "Process should of stopped, pin should not of been pulled." False

prop_terminate = once . testIO $ do
  (_, _, _, h) <- createProcess (shell $ "sleep 10")
  r <- terminate h
  exists <- (True <$ waitForProcess h) `catchIOError` (const . pure) False
  pure $ (r, exists) === (signalToExit sigTERM, False)

prop_terminateGroup = once . testIO $ do
  (_, _, _, h) <- createProcess (shell $ "sleep 10") { create_group = True }
  r <- terminate h
  exists <- (True <$ waitForProcess h) `catchIOError` (const . pure) False
  pure $ (r, exists) === (signalToExit sigTERM, False)

return []
tests :: IO Bool
tests = $quickCheckAll
