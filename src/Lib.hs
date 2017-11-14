{-#LANGUAGE TemplateHaskell #-}
{-#LANGUAGE QuasiQuotes #-}

module Lib
    (
    insertClientFn,
    countClient,
    findClientData
    ) where

import Database.YeshQL
import Database.HDBC
import Database.HDBC.MySQL

[yesh|
    -- name:getClientName :: (String, String)
    -- :client_id :: Int
    SELECT name, subdomain FROM clients WHERE id = :client_id;
    ;;;
    -- name:getClientCount :: (Int)
    SELECT count(id) FROM clients;
    ;;;
    -- name:insertClient
    -- :client_name :: String
    INSERT INTO clients (name) VALUES (:client_name);
    ;;;
    -- name:lastInsertedId :: (Int)
    SELECT last_insert_id() as new_id;
|]

getConn :: IO Connection
getConn = do
    connectMySQL defaultMySQLConnectInfo {
        mysqlHost     = "localhost",
        mysqlDatabase = "crud_yeshql_test",
        mysqlUser     = "crud_yeshql_user",
        mysqlPassword = "ohB1Xe9x",
        mysqlUnixSocket = "/tmp/mysql.sock"
    }

withConn :: (Connection -> IO b) -> IO b
withConn f = do
    conn <- getConn
    result <- f conn
    commit conn
    disconnect conn
    return result

findClientData :: Int -> IO ()
findClientData clientId = do
    Just (clientName, subdomain) <- withConn $ getClientName clientId
    putStrLn clientName
    putStrLn subdomain

insertClientFn :: String -> IO ()
insertClientFn name = do
    uid <- withConn (\conn -> do
        _ <- insertClient name conn
        lastInsertedId conn)
    putStrLn $ "inserted id: " ++ show uid

countClient :: IO ()
countClient = do
    Just clientCount <- withConn getClientCount
    putStrLn $ "The number of client records is: " ++ show clientCount
