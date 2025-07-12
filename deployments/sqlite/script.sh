#!/bin/sh
if [ "$(basename $(realpath .))" != "learn-sql" ]; then
    echo "You are outside the scope of the project"
    exit 0
fi

docker run -it --rm \
  --platform linux/amd64 \
  --entrypoint /bin/bash \
  -v "$(pwd)/sql":"$HOME/sql" \
  -v "./db":"$HOME/db" \
  --workdir $HOME \
  nouchka/sqlite3:latest \
  