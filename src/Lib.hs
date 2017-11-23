{-#LANGUAGE TemplateHaskell #-}
{-#LANGUAGE QuasiQuotes #-}

module Lib
    (
    insertClient,
    insertUser,
    recordCount,
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

insertClient :: String -> String -> IO (Maybe Int)
insertClient name subdomain = do
    withConn (\conn -> do
        insertClientWithConn name subdomain conn)

insertClientWithConn :: IConnection conn => String -> String -> conn -> IO (Maybe Int)
insertClientWithConn name subdomain conn = do
    _ <- insertClientSQL name subdomain conn
    lastInsertedId conn

insertUser :: String -> IO (Maybe Int)
insertUser login = do
    withConn (\conn -> do
        _ <- insertUserSQL login conn
        lastInsertedId conn)

-- map subject to count functions
countFns :: IConnection conn => [Char] -> conn -> IO (Maybe Int)
countFns "client" = countClientSQL
countFns "user" = countUserSQL
countFns subject = error $ "SQL fn for " ++ subject ++ " not found"

recordCount :: [Char] -> IO (Maybe Int)
recordCount subject = do
    withConn (countFns subject)
