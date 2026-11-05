-- Laboratory Work #6 — SQL JOINs
-- File: lab6_sql_joins.sql
-- DBMS: PostgreSQL

DROP TABLE IF EXISTS employees CASCADE;
DROP TABLE IF EXISTS departments CASCADE;
DROP TABLE IF EXISTS projects CASCADE;

-- Step 1.1: Create sample tables
CREATE TABLE employees (
                           emp_id    INT PRIMARY KEY,
                           emp_name  VARCHAR(50),
                           dept_id   INT,
                           salary    DECIMAL(10, 2)
);

CREATE TABLE departments (
                             dept_id    INT PRIMARY KEY,
                             dept_name  VARCHAR(50),
                             location   VARCHAR(50)
);

CREATE TABLE projects (
                          project_id    INT PRIMARY KEY,
                          project_name  VARCHAR(50),
                          dept_id       INT,
                          budget        DECIMAL(10, 2)
);

-- Step 1.2: Insert sample data
INSERT INTO employees (emp_id, emp_name, dept_id, salary)
VALUES
    (1, 'John Smith', 101, 50000),
    (2, 'Jane Doe', 102, 60000),
    (3, 'Mike Johnson', 101, 55000),
    (4, 'Sarah Williams', 103, 65000),
    (5, 'Tom Brown', NULL, 45000);

INSERT INTO departments (dept_id, dept_name, location)
VALUES
    (101, 'IT', 'Building A'),
    (102, 'HR', 'Building B'),
    (103, 'Finance', 'Building C'),
    (104, 'Marketing', 'Building D');

INSERT INTO projects (project_id, project_name, dept_id, budget)
VALUES
    (1, 'Website Redesign', 101, 100000),
    (2, 'Employee Training', 102, 50000),
    (3, 'Budget Analysis', 103, 75000),
    (4, 'Cloud Migration', 101, 150000),
    (5, 'AI Research', NULL, 200000);


-- Exercise 2.1: Basic CROSS JOIN
-- All possible combinations of employees and departments.
SELECT e.emp_name, d.dept_name
FROM employees e
         CROSS JOIN departments d;

-- Question: How many rows does the result contain?
-- Ans: 5 employees × 4 departments = 20 rows.


-- Exercise 2.2: Alternative CROSS JOIN syntax

-- a) Comma notation
SELECT e.emp_name, d.dept_name
FROM employees e, departments d;

-- b) INNER JOIN with TRUE condition
SELECT e.emp_name, d.dept_name
FROM employees e
         INNER JOIN departments d ON TRUE;


-- Exercise 2.3: Practical CROSS JOIN
-- Availability matrix: every employee paired with every project.
SELECT e.emp_name, p.project_name
FROM employees e
         CROSS JOIN projects p
ORDER BY e.emp_name, p.project_name;



-- Exercise 3.1: Basic INNER JOIN with ON
-- Employees who have a department, plus department name and location.
SELECT e.emp_name, d.dept_name, d.location
FROM employees e
         INNER JOIN departments d ON e.dept_id = d.dept_id;

-- Question: How many rows are returned? Why is Tom Brown not included?
-- Ans: 4 rows. Tom Brown has dept_id = NULL, so there is no match.
-- INNER JOIN keeps only matching pairs.


-- Exercise 3.2: INNER JOIN with USING
SELECT emp_name, dept_name, location
FROM employees
         INNER JOIN departments USING (dept_id);

-- Question: What's the difference in output columns compared to the ON version?
-- Ans: USING merges the join key into a single dept_id column.
-- ON keeps both e.dept_id and d.dept_id if you select them (two copies).
-- This query also does not qualify column names because USING makes
-- the shared dept_id unambiguous.


-- Exercise 3.3: NATURAL INNER JOIN
-- Joins automatically on every column that has the same name in both tables
-- (here: dept_id).
SELECT emp_name, dept_name, location
FROM employees
         NATURAL INNER JOIN departments;


-- Exercise 3.4: Multi-table INNER JOIN
-- Employee name, department name, and project name.
-- Employees in IT appear twice because IT has two projects.
SELECT e.emp_name, d.dept_name, p.project_name
FROM employees e
         INNER JOIN departments d ON e.dept_id = d.dept_id
         INNER JOIN projects p ON d.dept_id = p.dept_id;


-- Exercise 4.1: Basic LEFT JOIN
-- All employees, including those with no department.
SELECT
    e.emp_name,
    e.dept_id AS emp_dept,
    d.dept_id AS dept_dept,
    d.dept_name
FROM employees e
         LEFT JOIN departments d ON e.dept_id = d.dept_id;

-- Question: How is Tom Brown represented in the results?
-- Ans emp_name = 'Tom Brown', emp_dept = NULL, dept_dept = NULL,
-- dept_name = NULL. The left-table row is kept. right-table columns are NULL.


-- Exercise 4.2: LEFT JOIN with USING
SELECT emp_name, dept_id, dept_name
FROM employees
         LEFT JOIN departments USING (dept_id);


-- Exercise 4.3: Find unmatched records
-- Employees who are NOT assigned to any department.
SELECT e.emp_name, e.dept_id
FROM employees e
         LEFT JOIN departments d ON e.dept_id = d.dept_id
WHERE d.dept_id IS NULL;


-- Exercise 4.4: LEFT JOIN with aggregation
-- All departments with employee counts, including departments with 0 employees.
-- COUNT(e.emp_id) is used instead of COUNT(*) so unmatched departments stay 0.
SELECT d.dept_name, COUNT(e.emp_id) AS employee_count
FROM departments d
         LEFT JOIN employees e ON d.dept_id = e.dept_id
GROUP BY d.dept_id, d.dept_name
ORDER BY employee_count DESC;


-- Exercise 5.1: Basic RIGHT JOIN
-- All departments, including those with no employees (Marketing).
SELECT e.emp_name, d.dept_name
FROM employees e
         RIGHT JOIN departments d ON e.dept_id = d.dept_id;


-- Exercise 5.2: Convert to LEFT JOIN
-- Same result as 5.1: put departments on the left and use LEFT JOIN.
SELECT e.emp_name, d.dept_name
FROM departments d
         LEFT JOIN employees e ON e.dept_id = d.dept_id;


-- Exercise 5.3: Find departments without employees
SELECT d.dept_name, d.location
FROM employees e
         RIGHT JOIN departments d ON e.dept_id = d.dept_id
WHERE e.emp_id IS NULL;


-- Exercise 6.1: Basic FULL JOIN
SELECT
    e.emp_name,
    e.dept_id AS emp_dept,
    d.dept_id AS dept_dept,
    d.dept_name
FROM employees e
         FULL JOIN departments d ON e.dept_id = d.dept_id;

-- Question: Which records have NULL values on the left side?
--           Which have NULL on the right side?
-- Answer:
--   Left side NULL (no matching employee): Marketing (dept 104).
--   Right side NULL (no matching department): Tom Brown (emp_id 5, dept_id NULL).


-- Exercise 6.2: FULL JOIN with projects
-- All departments and all projects, including unmatched rows.
SELECT d.dept_name, p.project_name, p.budget
FROM departments d
         FULL JOIN projects p ON d.dept_id = p.dept_id;


-- Exercise 6.3: Find orphaned records
-- Employees without departments AND departments without employees.
SELECT
    CASE
        WHEN e.emp_id IS NULL THEN 'Department without employees'
        WHEN d.dept_id IS NULL THEN 'Employee without department'
        ELSE 'Matched'
        END AS record_status,
    e.emp_name,
    d.dept_name
FROM employees e
         FULL JOIN departments d ON e.dept_id = d.dept_id
WHERE e.emp_id IS NULL OR d.dept_id IS NULL;


-- Exercise 7.1: Filtering in ON clause (outer join)
-- Location filter is part of the join condition.
SELECT e.emp_name, d.dept_name, e.salary
FROM employees e
         LEFT JOIN departments d ON e.dept_id = d.dept_id AND d.location = 'Building A';

-- Result: every employee is kept.
-- Only IT (Building A) is matched; other employees have NULL dept_name.


-- Exercise 7.2: Filtering in WHERE clause (outer join)
SELECT e.emp_name, d.dept_name, e.salary
FROM employees e
         LEFT JOIN departments d ON e.dept_id = d.dept_id
WHERE d.location = 'Building A';

-- Question: Compare Query 1 and Query 2.
-- Answer:
--   Query 1 (ON): filter is applied while matching. All left-table employees
--   remain. Non-Building-A departments become non-matches (NULL on the right).
--   Query 2 (WHERE): filter runs after the join. Rows with NULL location
--   (Tom Brown) and rows whose department is not Building A are dropped.
--   Query 2 therefore behaves like an INNER JOIN for this predicate.


-- Exercise 7.3: ON vs WHERE with INNER JOIN
SELECT e.emp_name, d.dept_name, e.salary
FROM employees e
         INNER JOIN departments d ON e.dept_id = d.dept_id AND d.location = 'Building A';

SELECT e.emp_name, d.dept_name, e.salary
FROM employees e
         INNER JOIN departments d ON e.dept_id = d.dept_id
WHERE d.location = 'Building A';

-- Question: Is there any difference in results? Why or why not?
-- Answer: No difference. INNER JOIN already discards non-matches, so a
-- predicate in ON and the same predicate in WHERE both keep only rows that
-- satisfy dept_id match AND location = 'Building A'.


-- Exercise 8.1: Multiple joins with different types
-- All departments, with employee and project info when they exist.
-- Cartesian expansion: a department with 2 employees and 2 projects yields 4 rows.
SELECT
    d.dept_name,
    e.emp_name,
    e.salary,
    p.project_name,
    p.budget
FROM departments d
         LEFT JOIN employees e ON d.dept_id = e.dept_id
         LEFT JOIN projects p ON d.dept_id = p.dept_id
ORDER BY d.dept_name, e.emp_name;


-- Exercise 8.2: Self join
ALTER TABLE employees ADD COLUMN manager_id INT;

UPDATE employees SET manager_id = 3 WHERE emp_id = 1;
UPDATE employees SET manager_id = 3 WHERE emp_id = 2;
UPDATE employees SET manager_id = NULL WHERE emp_id = 3;
UPDATE employees SET manager_id = 3 WHERE emp_id = 4;
UPDATE employees SET manager_id = 3 WHERE emp_id = 5;

-- Employees with their managers (Mike Johnson has no manager).
SELECT
    e.emp_name AS employee,
    m.emp_name AS manager
FROM employees e
         LEFT JOIN employees m ON e.manager_id = m.emp_id;


-- Exercise 8.3: Join with aggregation (departments with avg salary > 50000)
SELECT d.dept_name, AVG(e.salary) AS avg_salary
FROM departments d
         INNER JOIN employees e ON d.dept_id = e.dept_id
GROUP BY d.dept_id, d.dept_name
HAVING AVG(e.salary) > 50000;


-- Lab Questions
-- 1. What is the difference between INNER JOIN and LEFT JOIN?
--    INNER JOIN returns only rows with a match in both tables.
--    LEFT JOIN returns every row from the left table; unmatched right-side
--    columns are NULL.
--
-- 2. When would you use CROSS JOIN in a practical scenario?
--    Generating all combinations: calendars (employees × dates), size/color
--    product matrices, test cases, seating charts, availability grids.
--
-- 3. Explain why ON vs WHERE matters for outer joins but not inner joins.
--    Outer joins keep unmatched rows by design. A filter in ON decides which
--    rows count as matches, then unmatched left/right rows are still kept.
--    A filter in WHERE runs after that and can drop the NULL-extended rows,
--    turning the outer join into an inner join. Inner joins never keep
--    unmatched rows, so the same predicate in ON or WHERE yields the same set.
--
-- 4. SELECT COUNT(*) FROM table1 CROSS JOIN table2
--    if table1 has 5 rows and table2 has 10 rows?
--    5 × 10 = 50 rows.
--
-- 5. How does NATURAL JOIN determine which columns to join on?
--    It joins on every column that has the same name in both tables
--    (equality on all shared names).
--
-- 6. What are the potential risks of using NATURAL JOIN?
--    Accidental joins if extra columns share names (e.g. created_at).
--    Schema changes can silently change join keys. Ambiguous intent.
--    Prefer ON or USING for explicit, stable joins.
--
-- 7. Convert this LEFT JOIN to a RIGHT JOIN:
--    SELECT * FROM A LEFT JOIN B ON A.id = B.id
--    Equivalent:
--    SELECT * FROM B RIGHT JOIN A ON A.id = B.id
--
-- 8. When should you use FULL OUTER JOIN instead of other join types?
--    When you need a complete picture of both tables: matched pairs plus
--    orphans on both sides .
