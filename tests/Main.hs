module Main
    where

import System.IO
import Control.Concurrent
import Control.Exception

-- implementation-agnostic tests:
import Qsem001
--import Chan002
import Chan003
import Smoke

-- implementation-specific tests:
import Atomics
import Unagi

main :: IO ()
main = do 
    assertionsWorking <- try $ assert False $ return ()
    case assertionsWorking of
         Left (AssertionFailed _) -> putStrLn "Assertions: On"
         _                        -> error "Assertions aren't working"

    procs <- getNumCapabilities
    if procs < 2 
        then error "Tests are only effective if more than 1 core is available"
        else return ()
    hSetBuffering stdout NoBuffering

    -- -----------------------------------

    -- test important properties of our atomic-primops:
    atomicsMain
 
    fifoSmoke 100000
    testContention 2 2 1000000

    -- QSem tests:
    defaultMainQSem

    -- check for deadlocks:
    let tries = 50000
    -- TODO add back chan-agnostic basic test here
    --putStrLn $ "Checking for deadlocks from killed reader, x"++show tries
    --checkDeadlocksReader tries
    putStrLn $ "Checking for deadlocks from killed writer, x"++show tries
    checkDeadlocksWriter tries

    -- unagi-specific tests
    unagiMain
