#!/bin/sh
if [ "$(basename $(realpath .))" != "psql" ]; then
    echo "You are outside the scope of the project"
    exit 0
fi

export PSQL_VER=16.2-alpine3.19
export PGADMIN_VER=8.9
export NETWORK=learn-sql_psql

COMMAND="$1"

case $COMMAND in
    "clean")
        docker-compose down
        rm -rf ./dbfiles
        ;;
    "start")
        docker-compose up
        ;;
    "stop")
        docker-compose down
        ;;
    *)
        echo "$0 [start | stop]"
        ;;
esac