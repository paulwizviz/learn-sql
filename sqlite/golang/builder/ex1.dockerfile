ARG GO_VER
ARG OS_VER

FROM golang:${GO_VER} AS builder

WORKDIR /opt

COPY ./go.mod ./go.mod
COPY ./go.sum ./go.sum

COPY ./ex1 ./ex1
COPY ./internal ./internal

RUN apk update && apk add gcc g++

RUN go mod download && \
    env CGO_ENABLED=1 go build -o ./build/ex1 ./ex1

FROM alpine:${OS_VER}

RUN apk update && apk add sqlite

COPY --from=builder /opt/build/ex1 /usr/local/bin/ex1