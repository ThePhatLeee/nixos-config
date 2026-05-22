---
name: database
description: Use for MySQL, PostgreSQL, query optimization, schema design, indexes, migrations, raw SQL. Triggers on: SQL, query, index, migration, schema, JOIN, PostgreSQL, MySQL, database, slow query.
---

# Database — MySQL / PostgreSQL

## Schema design principles

- Every table has a surrogate primary key (`id BIGINT UNSIGNED AUTO_INCREMENT` / `BIGSERIAL`)
- Foreign keys always explicit with `ON DELETE` / `ON UPDATE` action — never implicit
- `NOT NULL` by default; nullable only when absence is semantically meaningful
- Store timestamps as `DATETIME`/`TIMESTAMP` in UTC — never local time
- Boolean columns: `TINYINT(1)` in MySQL, `BOOLEAN` in PostgreSQL
- Avoid `ENUM` — use a lookup/reference table or a constrained `VARCHAR` with a check constraint

## Indexes

```sql
-- Index every column used in WHERE, JOIN ON, ORDER BY, GROUP BY
-- Composite index: left-most prefix rule — order by selectivity (high → low)
CREATE INDEX idx_posts_user_published ON posts (user_id, published_at DESC);
-- Covers: WHERE user_id = ? ORDER BY published_at DESC

-- Covering index — avoids table lookup entirely
CREATE INDEX idx_orders_status_covering ON orders (status, created_at) INCLUDE (total, customer_id);

-- Partial index (PostgreSQL) — index only a subset
CREATE INDEX idx_jobs_pending ON jobs (created_at) WHERE status = 'pending';

-- Never index low-cardinality standalone columns (boolean, status with 3 values)
-- unless combined with high-cardinality leading column
```

## Query patterns

```sql
-- Pagination: keyset is O(1), OFFSET is O(n)
-- Bad (OFFSET degrades at high pages):
SELECT * FROM posts ORDER BY id DESC LIMIT 20 OFFSET 10000;

-- Good (keyset):
SELECT * FROM posts WHERE id < :last_seen_id ORDER BY id DESC LIMIT 20;

-- Avoid SELECT * in production — select only what you need
SELECT id, title, published_at FROM posts WHERE user_id = ?;

-- EXISTS vs IN — EXISTS short-circuits, IN materializes full set
-- Good:
SELECT * FROM users u WHERE EXISTS (SELECT 1 FROM orders o WHERE o.user_id = u.id);
-- Bad for large subqueries:
SELECT * FROM users WHERE id IN (SELECT user_id FROM orders);

-- Window functions over self-joins
SELECT id, title,
       RANK() OVER (PARTITION BY category_id ORDER BY views DESC) AS rank_in_category
FROM posts;

-- CTEs for readability (not performance — CTEs are inlined in most planners)
WITH monthly_revenue AS (
  SELECT DATE_TRUNC('month', created_at) AS month, SUM(amount) AS revenue
  FROM orders WHERE status = 'paid'
  GROUP BY 1
)
SELECT month, revenue, LAG(revenue) OVER (ORDER BY month) AS prev_month
FROM monthly_revenue;
```

## N+1 detection and fix

```sql
-- Symptom: same query repeated N times with different IDs
-- Fix: use a JOIN or IN clause

-- Bad (N+1 in application):
-- for each post: SELECT * FROM users WHERE id = post.user_id

-- Good (single JOIN):
SELECT p.*, u.name AS author_name
FROM posts p
JOIN users u ON u.id = p.user_id
WHERE p.published_at IS NOT NULL;
```

## PostgreSQL specifics

```sql
-- JSONB for semi-structured data (indexable, queryable)
ALTER TABLE events ADD COLUMN metadata JSONB;
CREATE INDEX idx_events_meta ON events USING GIN (metadata);
SELECT * FROM events WHERE metadata @> '{"type": "click"}';

-- Full-text search
CREATE INDEX idx_posts_fts ON posts USING GIN (to_tsvector('english', title || ' ' || body));
SELECT * FROM posts WHERE to_tsvector('english', title || ' ' || body) @@ plainto_tsquery('english', 'search term');

-- Upsert
INSERT INTO user_preferences (user_id, key, value)
VALUES (:user_id, :key, :value)
ON CONFLICT (user_id, key) DO UPDATE SET value = EXCLUDED.value, updated_at = NOW();

-- Explain analyze — always check query plan before shipping complex queries
EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT) SELECT ...;
```

## MySQL specifics

```sql
-- InnoDB only — never MyISAM
-- Use utf8mb4 charset and utf8mb4_unicode_ci collation always
CREATE TABLE posts (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  title VARCHAR(255) NOT NULL,
  body LONGTEXT NOT NULL,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- JSON column (MySQL 5.7.8+)
ALTER TABLE events ADD COLUMN metadata JSON;
-- Generated column for indexing JSON field
ALTER TABLE events ADD COLUMN event_type VARCHAR(50)
  GENERATED ALWAYS AS (JSON_UNQUOTE(JSON_EXTRACT(metadata, '$.type'))) VIRTUAL;
CREATE INDEX idx_event_type ON events (event_type);
```

## Transactions

```sql
-- Explicit transactions for multi-statement writes
BEGIN;
  UPDATE accounts SET balance = balance - 100 WHERE id = 1;
  UPDATE accounts SET balance = balance + 100 WHERE id = 2;
  INSERT INTO transfers (from_id, to_id, amount) VALUES (1, 2, 100);
COMMIT;
-- On error: ROLLBACK

-- Isolation levels — use READ COMMITTED (default in PostgreSQL)
-- SERIALIZABLE only when you need full ACID across concurrent writes
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
```

## Migrations discipline

- Every schema change is a migration file — never ALTER TABLE in prod directly
- Migrations must be reversible (`up` + `down`)
- Additive changes are safe (new column, new index, new table)
- Destructive changes need a multi-step deploy: (1) deploy code that tolerates both states, (2) drop column/rename
- Never add a NOT NULL column without a default to a populated table in one step — it locks the table

## Query optimization checklist

1. `EXPLAIN ANALYZE` — look for `Seq Scan` on large tables, `Hash Join` on unsorted large sets
2. Missing index? Add it.
3. Row estimate wildly wrong? `ANALYZE` the table (updates statistics)
4. Fetching too many columns? `SELECT *` → explicit columns
5. Large IN list (>100 ids)? Switch to temp table + JOIN
6. Recurring slow query? Consider a materialized view
