{-#LANGUAGE QuasiQuotes #-}

module Main where

import Database.YeshQL
import Control.Monad
import Database.HDBC
import Database.HDBC.MySQL

[yesh|
  -- name:getClientName :: (String)
  -- :id :: Int
  SELECT name FROM clients WHERE id = :id;
|]

getConn = do
    connectMySQL defaultMySQLConnectInfo {
        mysqlHost     = "localhost",
        mysqlDatabase = "conduit_development",
        mysqlUser     = "conduit_user",
        mysqlPassword = "pa$$word1",
        mysqlUnixSocket = "/tmp/mysql.sock"
    }


main = do
    conn <- getConn
    clientName <- getClientName 1000002 conn
    putStrLn $ case clientName of
                Nothing -> "client not found"
                Just name -> name

-- This worked
          {- rows <- quickQuery' conn "SELECT 1 + 1" [] -}
          {- forM_ rows $ \row -> putStrLn $ show row -}

{- import Lib -}

{- main :: IO () -}
{- main = someFunc -}
