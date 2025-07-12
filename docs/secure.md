# Security

* [SQL Injection](#sql-injection)

## SQL Injection

SQL injection is a type of security vulnerability that allows an attacker to interfere with the queries an application makes to its database. It typically occurs when user input is incorrectly handled, allowing an attacker to inject arbitrary SQL code into a query.

Here is one way SQL injection works.

```go
username := os.Getenv("username")
password := os.Getenv("password")

query := fmt.Sprintf("SELECT * FROM users WHERE username = %s AND password = %s", username, password)
```

If the `username` and `password` values are:

* username: `admin`
* password: `'' OR '1'='1'`

This will translate to:

```sql
SELECT * FROM users WHERE username = 'admin' AND password = '' OR '1'='1'
```

Since '1'='1' is always true, the query returns all users — potentially logging in the attacker without a valid password.

To prevent SQL injection use Prepared Statements or sanitise and validate input.
