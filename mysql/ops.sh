#!/bin/sh
if [ "$(basename $(realpath .))" != "mysql" ]; then
    echo "You are outside the scope of the project"
    exit 0
fi

export MYSQL_VERSION=8.0
export ADMINER_VER=4.8.1
export NETWORK=learn-sql_mysql

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