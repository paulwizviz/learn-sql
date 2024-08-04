package main

import (
	"database/sql"
	"fmt"
	"log"
	"os"

	_ "github.com/lib/pq"
)

func main() {
	un := os.Getenv("POSTGRES_USER")
	pw := os.Getenv("POSTGRES_PASSWORD")
	host := "localhost"
	port := 5432
	dbname := "default"

	// Alternate approach to connect
	// connStr := "postgres://postgres:password@localhost/default?sslmode=disable"
	connStmt := fmt.Sprintf("host=%s port=%d user=%s password=%s dbname=%s sslmode=disable", host, port, un, pw, dbname)
	db, err := sql.Open("postgres", connStmt)
	if err != nil {
		log.Fatal(err)
	}
	defer db.Close()

	err = db.Ping()
	if err != nil {
		log.Fatal(err)
	}

	log.Println("Connected to DB")
}
