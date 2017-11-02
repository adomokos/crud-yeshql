{-#LANGUAGE TemplateHaskell #-}
{-#LANGUAGE QuasiQuotes #-}

module Main where

import Database.YeshQL
import Control.Monad
import Database.HDBC
import Database.HDBC.MySQL

[yesh|
    -- name:getClientName :: (String, String)
    -- :id :: Int
    SELECT name, subdomain FROM clients WHERE id = :id
    ;;;
    -- name:insertClient
    -- :client_name :: String
    INSERT INTO clients (name) VALUES (:client_name);
|]

getConn = do
    connectMySQL defaultMySQLConnectInfo {
        mysqlHost     = "localhost",
        mysqlDatabase = "conduit_test",
        mysqlUser     = "conduit_user",
        mysqlPassword = "pa$$word1",
        mysqlUnixSocket = "/tmp/mysql.sock"
    }

findClientData id = do
    conn <- getConn
    Just (clientName, subdomain) <- getClientName 3 conn
    putStrLn clientName
    putStrLn subdomain

main = findClientData 3
    {- insertClient "Test Client" conn -}
    {- putStrLn "inserted" -}

-- This worked
          {- rows <- quickQuery' conn "SELECT 1 + 1" [] -}
          {- forM_ rows $ \row -> putStrLn $ show row -}

{- import Lib -}

{- main :: IO () -}
{- main = someFunc -}
