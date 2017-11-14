module Main where

import qualified Lib as L

main :: IO ()
main = do
    L.insertClientFn "From yeshql"
    L.countClient
    return ()
