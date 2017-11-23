module Main where

import qualified Lib as L

main :: IO ()
main = do
    Just clientId <- L.insertClient "From yeshql" "from-yeshql"
    Just userId <- L.insertUser "adomokos"
    Just clientCount <- L.recordCount "client"
    Just userCount <- L.recordCount "user"
    reporter clientId userId clientCount userCount
    return ()

reporter :: Int -> Int -> Int -> Int -> IO()
reporter clientId userId clientCount userCount = do
    putStrLn $ "The inserted client_id: " ++ show clientId
    putStrLn $ "The inserted user_id: " ++ show userId
    putStrLn $ "Number of client records: " ++ show clientCount
    putStrLn $ "Number of user records: " ++ show userCount

