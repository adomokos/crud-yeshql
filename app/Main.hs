module Main where

import qualified Lib as L

main :: IO ()
main = do
    Just newClientId <- L.insertClient "From yeshql" "from-yeshql"
    putStrLn $ "The inserted client_id: " ++ show newClientId
    Just newUserId <- L.insertUser "adomokos"
    putStrLn $ "The inserted user_id: " ++ show newUserId
    Just clientCount <- L.recordCount "client"
    putStrLn $ "Number of client records: " ++ show clientCount
    Just userCount <- L.recordCount "user"
    putStrLn $ "Number of user records: " ++ show userCount
    return ()
