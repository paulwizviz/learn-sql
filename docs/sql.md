# SQL

## Type Differences

Understanding the differences in SQL concepts and data types across various database systems (SQLite, PostgreSQL, MySQL) is crucial for writing portable and efficient SQL operations. Below is a summary:

| Concept | SQLite | PostgreSQL | MySQL | Notes |
| --- | --- | --- | --- | --- |
| Integer | INTEGER | INTEGER,INT,BIGINT,SMALLINT | INT,BIGINT,TINYINT,SMALLINT,MEDIUMINT | SQLite's INTEGER is quite flexible and can store various integer sizes. PostgreSQL and MySQL offer more specific integer types for different ranges. |
| Text/String | TEXT | VARCHAR(n),TEXT,CHAR(n) | VARCHAR(n),TEXT,CHAR(n) | `TEXT` in SQLite is typically variable-length. In PostgreSQL and MySQL, `TEXT` is for very long strings, while VARCHAR(n) is for variable-length strings up to n characters. CHAR(n) is fixed-length. |
| Numbers (Decimal/Floating) | REAL, NUMERIC | NUMERIC(p,s),DECIMAL(p,s),REAL,DOUBLE PRECISION | DECIMAL(p,s),NUMERIC(p,s),FLOAT,DOUBLE | REAL in SQLite is a floating-point number. NUMERIC(p,s)/DECIMAL(p,s) are for exact precision (p=precision, s=scale) and are widely supported. FLOAT and DOUBLE are for approximate floating-point numbers. |
| Boolean | INTEGER (0 for false, 1 for true) | BOOLEAN, BOOL | TINYINT(1) (0 for false, 1 for true) | SQLite doesn't have a native boolean type, often using INTEGER instead. MySQL often uses TINYINT(1) for boolean, and PostgreSQL has a dedicated BOOLEAN type. |
| Date/Time | TEXT,INTEGER,REAL | DATE,TIME,TIMESTAMP,TIMESTAMPTZ | DATE,TIME,DATETIME,TIMESTAMP | SQLite stores dates/times as text (ISO8601 strings), integers (Unix epoch time), or real numbers (Julian day numbers). PostgreSQL and MySQL have dedicated and more robust date/time types, including options for time zones (TIMESTAMPTZ in PostgreSQL). |
| Binary Data | BLOB | BYTEA | BLOB,TINYBLOB,MEDIUMBLOB,LONGBLOB | All support binary large objects. |

## Statement Parameter Binding

| Database | Positional Anonymous | Positional Numbered | Named (Native SQL). | Named (Client/Driver specific) |
| --- | --- | --- | --- | --- |
| SQLite. | ? | ?N | :name, @name, $name. | Yes (often supports all) |
| MySQL | ? | No | No | Yes (common in client libraries) |
| PostgreSQL | No | $N | No | Yes (common in client libraries) |

## Views

At its core, a view is just a **stored query** — not stored data. When you query a view, the database substitutes the view's definition into your query at execution time.

```sql
CREATE VIEW person_view AS
SELECT p.id, ni.first_name FROM person p
JOIN name_identifier ni ON ni.id = p.id;

-- When you run this:
SELECT * FROM person_view WHERE id = 1;

-- The database internally executes this:
SELECT * FROM (
    SELECT p.id, ni.first_name FROM person p
    JOIN name_identifier ni ON ni.id = p.id
) WHERE id = 1;
```

### PostgreSQL Internals

#### PostgreSQL Storage

PostgreSQL stores view definitions in the **system catalog** — specifically in the `pg_class` and `pg_rewrite` tables:

```sql
-- See all views
SELECT viewname, definition FROM pg_views WHERE schemaname = 'public';

-- See the rewrite rules
SELECT * FROM pg_rewrite WHERE rulename = '_RETURN';
```

#### Query Rewriting

PostgreSQL uses a **rule-based query rewriter**. When you query a view:

1. Parser parses your query into a query tree
2. **Rewriter** looks up the view definition in `pg_rewrite`
3. Substitutes the view's query tree into your query tree
4. **Planner** receives the merged query tree and builds an execution plan
5. **Executor** runs the plan

```text
Your Query
    ↓
Parser → Query Tree
    ↓
Rewriter → Expands view definition into query tree
    ↓
Planner → Builds optimal execution plan
    ↓
Executor → Runs the plan
```

#### View Optimisation in PostgreSQL

This is where PostgreSQL really shines — the planner treats the merged query as a single unit and can optimise across the view boundary:

```sql
-- You write:
SELECT * FROM person_view WHERE id = 1;

-- PostgreSQL doesn't just filter after joining everything
-- It pushes the WHERE id = 1 predicate DOWN into the join
-- So it fetches only the row with id=1 before joining
-- This is called predicate pushdown
```

Key optimisations PostgreSQL applies:

- **Predicate pushdown** — filters pushed inside the view
- **Join elimination** — unused joined tables removed
- **Index usage** — indexes on underlying tables used transparently

### SQLite Internals

#### SQLite Storage

SQLite stores view definitions in the `sqlite_master` (or `sqlite_schema`) table — the same place it stores everything:

```sql
-- See all views in SQLite
SELECT name, sql FROM sqlite_master WHERE type = 'view';
```

#### Query Processing

SQLite's approach is simpler than PostgreSQL's:

1. Parser parses your query
2. Looks up view definition in `sqlite_master`
3. **Expands** the view inline as a subquery
4. The combined query goes through SQLite's **VDBE** (Virtual Database Engine) compiler
5. VDBE generates bytecode and executes it

```text
Your Query
    ↓
Parser → AST
    ↓
View Expansion → Inline subquery substitution
    ↓
VDBE Compiler → Bytecode
    ↓
VDBE Executor → Runs bytecode
```

#### SQLite Optimisation

SQLite's optimiser is less sophisticated than PostgreSQL's but still applies key optimisations:

- **Predicate pushdown** — basic filtering pushed inside the view
- **Index usage** — can use indexes on underlying tables
- **Flattening** — simple views are flattened into the outer query rather than executed as subqueries

However SQLite will not apply the more advanced optimisations PostgreSQL does — complex views with aggregations or subqueries may not be flattened and execute as full subqueries.

### Key Internal Differences of Views

| Aspect | PostgreSQL | SQLite |
| --- | --- | --- |
| View storage | `pg_class` + `pg_rewrite` system catalog | `sqlite_master` table |
| Rewrite mechanism | Rule-based query rewriter | Inline subquery expansion |
| Optimisation | Full predicate pushdown, join elimination | Basic predicate pushdown |
| Execution engine | Volcano/pipeline model | VDBE bytecode interpreter |
| Materialised views | ✅ Cached on disk | ❌ Not supported |
| Updatable views | ✅ Native | ⚠️ Triggers only |
| `EXPLAIN` support | ✅ Very detailed | ✅ Basic |

### Inspecting View Execution

Both databases let you inspect how a view query is executed:

#### PostgreSQL View Inspection

```sql
EXPLAIN ANALYZE SELECT * FROM person_view WHERE id = 1;
```

#### SQLite View Inspection

```sql
EXPLAIN QUERY PLAN SELECT * FROM person_view WHERE id = 1;
```

Shows a simplified plan — which tables are scanned and whether indexes are used.

### Materialised Views — PostgreSQL Only

This is the biggest internal difference. A regular view re-executes its query every time. A materialised view stores the result:

```sql
-- PostgreSQL only
CREATE MATERIALIZED VIEW monthly_stats AS
SELECT person_id, COUNT(*) FROM person_name_identifier
GROUP BY person_id;

-- Stored on disk, query hits cached data
SELECT * FROM monthly_stats;

-- Must manually refresh when underlying data changes
REFRESH MATERIALIZED VIEW monthly_stats;
```

SQLite has no equivalent — every view query hits the underlying tables every time.

### Summary of SQLite and PostgreSQL

Both databases implement views as **stored query definitions** that are expanded at query time — the difference is in sophistication. PostgreSQL's rule-based rewriter and advanced planner treat views as first-class query objects with full optimisation across view boundaries. SQLite's VDBE approach is simpler and more literal — effective for most use cases but without the advanced planning capabilities. For read-heavy, complex views on large datasets, PostgreSQL's materialised views offer a capability SQLite simply doesn't have.

## References

- [Introduction to SQL](https://www.w3schools.com/sql/sql_intro.asp)
