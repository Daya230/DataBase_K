-- Laboratory Work 8: SQL Indexes

DROP VIEW IF EXISTS index_documentation;
DROP TABLE IF EXISTS employees CASCADE;
DROP TABLE IF EXISTS projects CASCADE;
DROP TABLE IF EXISTS departments CASCADE;


-- Part 1: Database Setup

CREATE TABLE departments (
    dept_id   INT PRIMARY KEY,
    dept_name VARCHAR(50),
    location  VARCHAR(50)
);

CREATE TABLE employees (
    emp_id   INT PRIMARY KEY,
    emp_name VARCHAR(100),
    dept_id  INT,
    salary   DECIMAL(10, 2),
    FOREIGN KEY (dept_id) REFERENCES departments(dept_id)
);

CREATE TABLE projects (
    proj_id   INT PRIMARY KEY,
    proj_name VARCHAR(100),
    budget    DECIMAL(12, 2),
    dept_id   INT,
    FOREIGN KEY (dept_id) REFERENCES departments(dept_id)
);

INSERT INTO departments VALUES
    (101, 'IT', 'Building A'),
    (102, 'HR', 'Building B'),
    (103, 'Operations', 'Building C');

INSERT INTO employees VALUES
    (1, 'John Smith', 101, 50000),
    (2, 'Jane Doe', 101, 55000),
    (3, 'Mike Johnson', 102, 48000),
    (4, 'Sarah Williams', 102, 52000),
    (5, 'Tom Brown', 103, 60000);

INSERT INTO projects VALUES
    (201, 'Website Redesign', 75000, 101),
    (202, 'Database Migration', 120000, 101),
    (203, 'HR System Upgrade', 50000, 102);


-- Part 2: Creating Basic Indexes

-- Exercise 2.1
CREATE INDEX emp_salary_idx ON employees(salary);

SELECT indexname, indexdef
FROM pg_indexes
WHERE tablename = 'employees';

-- Question: How many indexes exist on the employees table?
-- Ans: 2. employees_pkey (automatic PRIMARY KEY index) and emp_salary_idx.


-- Exercise 2.2
CREATE INDEX emp_dept_idx ON employees(dept_id);

SELECT * FROM employees WHERE dept_id = 101;

-- Question: Why is it beneficial to index foreign key columns?
-- Ans: JOINs and lookups on the child table filter by the FK (dept_id). An index
-- avoids a full table scan. It also speeds up ON DELETE/UPDATE checks on the
-- parent table because PostgreSQL must find matching child rows.


-- Exercise 2.3
SELECT
    tablename,
    indexname,
    indexdef
FROM pg_indexes
WHERE schemaname = 'public'
ORDER BY tablename, indexname;

-- Question: List all the indexes you see. Which ones were created automatically?
-- Ans: Automatic: departments_pkey, employees_pkey, projects_pkey
--      Manual: emp_salary_idx, emp_dept_idx


-- Part 3: Multicolumn Indexes

-- Exercise 3.1
CREATE INDEX emp_dept_salary_idx ON employees(dept_id, salary);

SELECT emp_name, salary
FROM employees
WHERE dept_id = 101 AND salary > 52000;

-- Question: Would this index be useful for a query that only filters by salary
-- (without dept_id)? Why or why not?
-- Ans: Usually no. A B-tree composite index is used left-to-right. (dept_id, salary)
-- can support dept_id-only and (dept_id AND salary) queries, but not salary-only
-- (unless an Index Only Scan / skip scan is possible in newer PG; typically it is not used).


-- Exercise 3.2
CREATE INDEX emp_salary_dept_idx ON employees(salary, dept_id);

SELECT * FROM employees WHERE dept_id = 102 AND salary > 50000;
SELECT * FROM employees WHERE salary > 50000 AND dept_id = 102;

-- Question: Does the order of columns in a multicolumn index matter? Explain.
-- Ans: Yes. The first column is the leading key. emp_dept_salary_idx is best for
-- filters that start with dept_id. emp_salary_dept_idx is best for filters that
-- start with salary. SQL WHERE clause order does not matter; index column order does.


-- Part 4: Unique Indexes

-- Exercise 4.1
ALTER TABLE employees ADD COLUMN email VARCHAR(100);

UPDATE employees SET email = 'john.smith@company.com' WHERE emp_id = 1;
UPDATE employees SET email = 'jane.doe@company.com' WHERE emp_id = 2;
UPDATE employees SET email = 'mike.johnson@company.com' WHERE emp_id = 3;
UPDATE employees SET email = 'sarah.williams@company.com' WHERE emp_id = 4;
UPDATE employees SET email = 'tom.brown@company.com' WHERE emp_id = 5;

CREATE UNIQUE INDEX emp_email_unique_idx ON employees(email);

-- This INSERT is expected to fail (duplicate email). Wrapped so the rest of the
-- script still runs.
DO $$
BEGIN
    INSERT INTO employees (emp_id, emp_name, dept_id, salary, email)
    VALUES (6, 'New Employee', 101, 55000, 'john.smith@company.com');
EXCEPTION WHEN unique_violation THEN
    RAISE NOTICE 'Expected unique violation: %', SQLERRM;
END $$;

-- Question: What error message did you receive?
-- Ans: ERROR: duplicate key value violates unique constraint "emp_email_unique_idx"
-- DETAIL: Key (email)=(john.smith@company.com) already exists.


-- Exercise 4.2
ALTER TABLE employees ADD COLUMN phone VARCHAR(20) UNIQUE;

SELECT indexname, indexdef
FROM pg_indexes
WHERE tablename = 'employees' AND indexname LIKE '%phone%';

-- Question: Did PostgreSQL automatically create an index? What type of index?
-- Ans: Yes. A unique B-tree index named employees_phone_key
-- (CREATE UNIQUE INDEX employees_phone_key ON employees USING btree (phone)).

-- Part 5: Indexes and Sorting

-- Exercise 5.1
CREATE INDEX emp_salary_desc_idx ON employees(salary DESC);

SELECT emp_name, salary
FROM employees
ORDER BY salary DESC;

-- Question: How does this index help with ORDER BY queries?
-- Ans: The index already stores salary in descending order, so PostgreSQL can
-- read rows in the requested order and skip an extra sort (or make the sort cheaper).


-- Exercise 5.2
CREATE INDEX proj_budget_nulls_first_idx ON projects(budget NULLS FIRST);

SELECT proj_name, budget
FROM projects
ORDER BY budget NULLS FIRST;


-- Part 6: Indexes on Expressions

-- Exercise 6.1
CREATE INDEX emp_name_lower_idx ON employees(LOWER(emp_name));

SELECT * FROM employees WHERE LOWER(emp_name) = 'john smith';

-- Question: Without this index, how would PostgreSQL search for names case-insensitively?
-- Ans: It would apply LOWER() to every emp_name (sequential scan) because a
-- plain index on emp_name cannot be used for LOWER(emp_name) = '...'.


-- Exercise 6.2
ALTER TABLE employees ADD COLUMN hire_date DATE;

UPDATE employees SET hire_date = '2020-01-15' WHERE emp_id = 1;
UPDATE employees SET hire_date = '2019-06-20' WHERE emp_id = 2;
UPDATE employees SET hire_date = '2021-03-10' WHERE emp_id = 3;
UPDATE employees SET hire_date = '2020-11-05' WHERE emp_id = 4;
UPDATE employees SET hire_date = '2018-08-25' WHERE emp_id = 5;

CREATE INDEX emp_hire_year_idx ON employees(EXTRACT(YEAR FROM hire_date));

SELECT emp_name, hire_date
FROM employees
WHERE EXTRACT(YEAR FROM hire_date) = 2020;


-- Part 7: Managing Indexes

-- Exercise 7.1
ALTER INDEX emp_salary_idx RENAME TO employees_salary_index;

SELECT indexname FROM pg_indexes WHERE tablename = 'employees';


-- Exercise 7.2
DROP INDEX emp_salary_dept_idx;

-- Question: Why might you want to drop an index?
-- Ans: Unused or duplicate indexes still cost disk space and slow INSERT/UPDATE/DELETE
-- because every write must maintain the index. Drop indexes that queries never use.


-- Exercise 7.3
REINDEX INDEX employees_salary_index;

-- When is REINDEX useful?
-- After bulk INSERT, when an index is bloated, or after many updates/deletes
-- that leave dead index pages.


-- Part 8: Practical Scenarios

-- Exercise 8.1
SELECT e.emp_name, e.salary, d.dept_name
FROM employees e
JOIN departments d ON e.dept_id = d.dept_id
WHERE e.salary > 50000
ORDER BY e.salary DESC;

-- Partial index for the WHERE clause
CREATE INDEX emp_salary_filter_idx ON employees(salary) WHERE salary > 50000;
-- JOIN already covered by emp_dept_idx
-- ORDER BY already covered by emp_salary_desc_idx


-- Exercise 8.2
CREATE INDEX proj_high_budget_idx ON projects(budget)
WHERE budget > 80000;

SELECT proj_name, budget
FROM projects
WHERE budget > 80000;

-- Question: What's the advantage of a partial index compared to a regular index?
-- Ans: It indexes only matching rows, so it is smaller, cheaper to maintain, and
-- faster for queries that always use the same filter (here, high-budget projects).


-- Exercise 8.3
EXPLAIN SELECT * FROM employees WHERE salary > 52000;

-- Question: Does the output show an "Index Scan" or a "Seq Scan"? What does this tell you?
-- Ans: With only 5 rows, the planner often chooses Seq Scan because a full scan
-- is cheaper than random index lookups on a tiny table. Index Scan / Bitmap Index
-- Scan would appear on a larger table (or after SET enable_seqscan = off).
-- Seq Scan means the planner did not think the index was worth using.


-- Part 9: Index Types Comparison

-- Exercise 9.1
CREATE INDEX dept_name_hash_idx ON departments USING HASH (dept_name);

SELECT * FROM departments WHERE dept_name = 'IT';

-- Question: When should you use a HASH index instead of a B-tree index?
-- Ans: Only for equality (=) lookups. B-tree is the default and also supports
-- range, ORDER BY, and inequality. Prefer HASH only if you have many equality-only
-- queries and have measured a benefit; B-tree is usually the better default.


-- Exercise 9.2
CREATE INDEX proj_name_btree_idx ON projects(proj_name);
CREATE INDEX proj_name_hash_idx ON projects USING HASH (proj_name);

-- Equality: both B-tree and Hash can be used
SELECT * FROM projects WHERE proj_name = 'Website Redesign';

-- Range: only B-tree can be used
SELECT * FROM projects WHERE proj_name > 'Database';

-- Part 10: Cleanup and Best Practices
-- Exercise 10.1
SELECT
    schemaname,
    tablename,
    indexname,
    pg_size_pretty(pg_relation_size(indexname::regclass)) AS index_size
FROM pg_indexes
WHERE schemaname = 'public'
ORDER BY tablename, indexname;

-- Question: Which index is the largest? Why?
-- Ans: On this tiny dataset they are all about the same (8 kB pages). On real data,
-- wider keys and unique/multicolumn indexes (e.g. emp_dept_salary_idx, emp_email_unique_idx)
-- tend to be larger because they store more columns / more entries.


-- Exercise 10.2
DROP INDEX IF EXISTS proj_name_hash_idx;


-- Exercise 10.3
CREATE VIEW index_documentation AS
SELECT
    tablename,
    indexname,
    indexdef,
    'Improves salary-based queries' AS purpose
FROM pg_indexes
WHERE schemaname = 'public'
  AND indexname LIKE '%salary%';

SELECT * FROM index_documentation;


-- Sum Questions
-- 1. What is the default index type in PostgreSQL?
--    B-tree.


-- 2. Name three scenarios where you should create an index:
--    Columns in WHERE filters; foreign keys / JOIN columns; ORDER BY / UNIQUE columns.


-- 3. Name two scenarios where you should NOT create an index:
--    Very small tables; columns that are rarely queried or that change constantly
--    (write-heavy tables) when the index would not be used.


-- 4. What happens to indexes when you INSERT, UPDATE, or DELETE data?
--    PostgreSQL must update every affected index, so writes become slower and
--    indexes use extra disk space.


-- 5. How can you check if a query is using an index?
--    EXPLAIN or EXPLAIN ANALYZE. Look for Index Scan / Index Only Scan /
--    Bitmap Index Scan instead of Seq Scan.


-- Reflection: When to use indexes
-- Use indexes on columns that are filtered, joined, or sorted often, especially
-- on large tables. Prefer partial and expression indexes when queries always use
-- the same predicate or function. Avoid indexing everything: each index costs
-- space and slows writes. Verify with EXPLAIN, then drop unused indexes.

-- #1 Screenshot
EXPLAIN SELECT * FROM employees WHERE salary > 52000;

-- #2 Screenshot
SET enable_seqscan = off;
EXPLAIN SELECT * FROM employees WHERE salary > 52000;
SET enable_seqscan = on;


