module Main where

import qualified Lib as L

main :: IO ()
main = do
    L.insertClient "From yeshql" "from-yeshql"
    L.insertUser "adomokos"
    L.recordCount L.countClientSQL "client"
    L.countUser
    return ()
