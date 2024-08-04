#!/bin/sh

if [ "$(basename $(realpath .))" != "golang" ]; then
    echo "You are outside the scope of the project"
    exit 0
fi

export EX1_IMAGE=learn-sql/ex1:current

COMMAND="$1"
SUBCOMMAND="$2"

function images(){
    local cmd=$1
    case $cmd in
        "build")
            docker-compose -f ./builder/builder.yaml build
            ;;
        "clean")
            docker rmi -f ${EX1_IMAGE}
            docker rmi -f $(docker images --filter "dangling=true" -q)
            ;;
        *)
            echo "Usage: $0 images [build | clean]"
            ;;
    esac
}

function cli(){
    local cmd=$1
    case $cmd in
        "ex1")
            docker run -it --rm ${EX1_IMAGE} /bin/sh
            ;;
        *)
            echo "Usage: $0 cli [ex1]"
            ;;
    esac
}

case $COMMAND in
    "cli")
        cli $SUBCOMMAND
        ;;
    "images")
        images $SUBCOMMAND
        ;;
    *)
        echo "Usage: $0 [cli | images]"
        ;;
esac