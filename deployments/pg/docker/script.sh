#!/bin/sh
if [ "$(basename $(realpath .))" != "learn-sql" ]; then
    echo "You are outside the scope of the project"
    exit 0
fi

export PGADMIN_DEFAULT_EMAIL=admin@psql.email
export PGADMIN_DEFAULT_PASSWORD=admin

export POSTGRES_USER=postgres
export POSTGRES_PASSWORD=postgres

export PSQL_VER=18.1
export PGADMIN_VER=9.11.0

export NETWORK=learn-sql_network

COMMAND="$1"
SUBCOMMAND="$2"

function single(){
    local cmd=$1
    case $cmd in
        "start")
            docker compose -f ./deployments/pg/docker/single/docker-compose.yaml up
            ;;
        "stop")
            docker compose -f ./deployments/pg/docker/single/docker-compose.yaml down
            ;;
        "clean")
            docker compose -f ./deployments/pg/docker/single/docker-compose.yaml down
            if [ -d ./deployments/pg/docker/single/dbfiles ]; then
                rm -rf ./deployments/pg/docker/single/dbfiles
            fi
            ;;
        *)
            echo "Usage $0 single [clean | start | stop]"
            ;;
    esac
}

case $COMMAND in
    "single")
        single $SUBCOMMAND
        ;;
    *)
        echo "Usage: $0 [single]"
        ;;
esac