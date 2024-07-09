#!/bin/sh
if [ "$(basename $(realpath .))" != "mysql" ]; then
    echo "You are outside the scope of the project"
    exit 0
fi

export MYSQL_VERSION=8.0
export ADMINER_VER=4.8.1
export NETWORK=learn-sql_mysql

export MYSQL_CLI_IMAGE=learn-sql/mysqlcmd:current
export MYSQL_CLI_CONTAINER=mysqlcli

COMMAND="$1"
SUBCOMMAND="$2"

function client(){
    local cmd=$1
    case $cmd in
        "shell")
            docker run --network=${NETWORK}  -it --rm -w /opt ${MYSQL_CLI_IMAGE} /bin/bash
            ;;
        *)
            echo "Usage: $0 client shell"
            ;;
    esac
}

function images(){
    local cmd=$1
    case $cmd in
        "build")
            docker-compose -f ./builder/builder.yaml build
            ;;
        "clean")
            docker rmi -f ${MYSQL_CLI_IMAGE}
            docker rmi -f $(docker images --filter "dangling=true" -q)
            ;;
        *)
            echo "Usage: $0 images [build | clean]"
            ;;
    esac
}

function network(){
    local cmd=$1
    case $cmd in
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
            echo "Usage: $0 network [clean | start | stop]"
            ;;
    esac
}

case $COMMAND in
    "client")
        client $SUBCOMMAND
        ;;
    "images")
        images $SUBCOMMAND
        ;;
    "network")
        network $SUBCOMMAND
        ;;
    *)
        echo "Usage: $0 [image | network]"
        ;;
esac