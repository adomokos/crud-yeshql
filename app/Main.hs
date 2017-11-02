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
    SELECT name, subdomain FROM clients WHERE id = :id;
    ;;;
    -- name:getClientCount :: (Int)
    SELECT count(id) FROM clients;
    ;;;
    -- name:insertClient :: (Int)
    -- :client_name :: String
    INSERT INTO clients (name) VALUES (:client_name); SELECT last_insert_id();
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

insertClientFn name = do
    conn <- getConn
    Just newId <- insertClient "Test Client" conn
    putStrLn "inserted"

countClient = do
    conn <- getConn
    Just clientCount <- getClientCount conn
    putStrLn $ "The number of client records is: " ++ show clientCount



{- main = findClientData 3 -}
main = do
    insertClientFn "From yeshql"
    countClient
    return ()

{- import Lib -}

{- main :: IO () -}
{- main = someFunc -}
