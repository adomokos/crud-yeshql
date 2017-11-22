{-#LANGUAGE TemplateHaskell #-}
{-#LANGUAGE QuasiQuotes #-}

module Lib
    (
    insertClient,
    insertUser,
    recordCount,
    countUser,
    countClientSQL,
    findClientData
    ) where

import Database.YeshQL
import Database.HDBC
import Database.HDBC.MySQL

[yesh|
    -- name:findClientNameSQL :: (String, String)
    -- :client_id :: Int
    SELECT name, subdomain FROM clients WHERE id = :client_id;
    ;;;
    -- name:countClientSQL :: (Int)
    SELECT count(id) FROM clients;
    ;;;
    -- name:insertClientSQL
    -- :client_name :: String
    -- :subdomain :: String
    INSERT INTO clients (name, subdomain) VALUES (:client_name, :subdomain);
    ;;;
    -- name:insertUserSQL
    -- :login :: String
    INSERT INTO users (client_id, login, email, password) VALUES (1, :login, 'john@gmail.com', 'password1');
    ;;;
    -- name:countUserSQL :: (Int)
    SELECT count(id) FROM users;
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
    Just (clientName, subdomain) <- withConn $ findClientNameSQL clientId
    putStrLn clientName
    putStrLn subdomain

insertClient :: String -> String -> IO ()
insertClient name subdomain = do
    uid <- withConn (\conn -> do
        insertClientWithConn name subdomain conn)
    putStrLn $ "inserted client id: " ++ show uid

insertClientWithConn :: IConnection conn =>
    String -> String -> conn -> IO (Maybe Int)
insertClientWithConn name subdomain conn = do
    _ <- insertClientSQL name subdomain conn
    lastInsertedId conn

insertUser :: String -> IO ()
insertUser login = do
    uid <- withConn (\conn -> do
        _ <- insertUserSQL login conn
        lastInsertedId conn)
    putStrLn $ "inserted user id: " ++ show uid

{- recordCount :: (Connection -> IO (Maybe a0)) -> [Char] -> IO () -}
recordCount fn subject = do
    Just count <- withConn fn
    putStrLn $ "Number of " ++ subject ++ "records:" ++ show count

countClient :: IO ()
countClient = do
    Just clientCount <- withConn countClientSQL
    putStrLn $ "Number of client records: " ++ show clientCount

countUser :: IO ()
countUser = do
    Just userCount <- withConn countUserSQL
    putStrLn $ "Number of user records: " ++ show userCount
