
# SQLite

* [Programming Example](#programming-examples)
* [CLI commands](#cli-commands)
* [Working with multiple DB](#working-with-multiple-dbs)
* [Useful References](#useful-references)

## CLI Commands

| Command                             | Description                                                                 |
|-------------------------------------|-----------------------------------------------------------------------------|
| `.attach 'filename.db' AS alias;`   | Attaches another SQLite database file to the current session using an alias |
| `.databases`                        | List attached databases                                                     |
| `.detach alias;`                    | Detaches a previously attached database, removing access to it              |
| `.exit / .quit`                     | Exit the SQLite CLI                                                         |
| `.headers on / .headers off`        | Toggle column headers in output                                             |
| `.help`                             | Show all available commands                                                 |
| `.mode column`                      | Format output as columns (others: list, csv, html, json)                    |
| `.nullvalue <str>`                  | Customize how NULLs are shown                                               |
| `.output filename.txt`              | Redirect query output to a file                                             |
| `.read file.sql`                    | Run SQL from a file                                                         |
| `.schema [table]`                   | Show SQL used to create tables                                              |
| `.tables`                           | List all tables                                                             |
| `.timer on / .timer off`            | Show query execution times                                                  |

## DB Operations

Create DB in file

```bash
sqlite3 mydb.db
```

If file does not exists, it'll create a file `mydb.db`

Create DB in memory

```bash
sqlite3 :memory
```

Create DB and populate with content

```bash
sqlite3 new.db < schema.sql
```

## Working with multiple DBs

Assuming we want to work with multiple DB files.

For example:

* `main.db` (primary DB)
* `logs.db` (secondary to be attached)

STEP 1: Open the main DB file

```sh
sqlite3 main.db
```

STEP 2: Attach the second DB

```sh
.attach 'logs.db' AS logs;
```

STEP 3: Query across dbs

```sql
SELECT * FROM logs.events;
SELECT * FROM main.users;
```

## Programming Examples

* [go-sql](https://github.com/paulwizviz/go-sql.git)

## Useful References

* [Official Documentation](https://www.sqlite.org/)
