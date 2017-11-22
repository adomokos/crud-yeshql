DBUSER=crud_yeshql_user
DBPASSWD=ohB1Xe9x
DBNAME=crud_yeshql_test
HOST=localhost

THIS_FILE := $(lastword $(MAKEFILE_LIST))

.DEFAULT_GOAL := help

create-db-user: ## Creates a DB user with the root MySQL user
	mysql -u root --host $(HOST) -e "CREATE USER '$(DBUSER)'@'$(HOST)' IDENTIFIED BY '$(DBPASSWD)';"
	mysql -u root --host $(HOST) -e "GRANT ALL PRIVILEGES ON `$(DBNAME)`.* TO '$(DBUSER)'@'$(HOST)';"

build-db: ## Builds the DB
	@echo "Dropping and rebuilding database $(DBNAME)"
	@mysql -u $(DBUSER) --password='$(DBPASSWD)' --host $(HOST) -e "DROP DATABASE IF EXISTS $(DBNAME);"
	@mysql -u $(DBUSER) --password='$(DBPASSWD)' --host $(HOST) -e "CREATE DATABASE $(DBNAME);"
	@mysql -u $(DBUSER) --password='$(DBPASSWD)' --host $(HOST) $(DBNAME) < resources/schema.sql

dbconnect: ## Connect to the DB with mysql console
	mysql --user=$(DBUSER) --password='$(DBPASSWD)' --host=$(HOST) $(DBNAME)

build: ## Builds the project with stack
	@stack build

run: build-db ## Runs the app
	time stack exec .stack-work/dist/x86_64-osx/Cabal-1.24.2.0/build/crud-yeshql-exe/crud-yeshql-exe

.PHONY: help

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
