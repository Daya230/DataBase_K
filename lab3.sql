--1. Create database and tables

CREATE DATABASE 'advanced_lab';

CREATE TABLE employees(
    emp_id SERIAL PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    department VARCHAR(100) NOT NULL,
    salary INT,
    hire_date DATE, 
    status VARCHAR(50) DEFAULT 'Active' 
);

CREATE TABLE departments(
    dept_id SERIAL PRIMARY KEY, 
    dept_name VARCHAR(100) NOT NULL,
    budget INT,
    manager_id INT
);

CREATE TABLE projects(
    project_id SERIAL PRIMARY KEY,
    project_name VARCHAR(100) NOT NULL,
    dept_idd INT,
    start_date DATE,
    end_date DATE,
    budget INT
);

--Part B: Advanced INSERT Operations
--2. INSERT with column specification

INSERT INTO employees(emp_id,first_name,last_name, department)
VALUES (1, 'Alice', 'Ivanova', 'IT');

SELECT emp_id, first_name, last_name, department, salary, hire_date, status
FROM employees
WHERE emp_id = 1;

-- 3. INSERT with DEFAULT values
INSERT INTO employees (first_name, last_name, department, hire_date, salary, status)
VALUES ('Bob', 'Petrov', 'HR', DATE '2022-04-10', DEFAULT, DEFAULT);

SELECT emp_id, first_name, department, salary, status
FROM employees
WHERE first_name = 'Bob';
-- 4. INSERT multiple rows in single statement

INSERT INTO departments(dept_name,budget,manager_id) VALUES 
('IT', 150000, 1),
('HR', 80000, NULL),
('Sales', 120000, NULL);

SELECT dept_id, dept_name, budget, manager_id
FROM departments
ORDER BY dept_id;

-- 5. INSERT with expressions

INSERT INTO employees(first_name, last_name, department,salary, hire_date) VALUES
('Carol', 'Kim', 'Sales', 50000*1.1, CURRENT_DATE);

SELECT first_name, department, salary, hire_date
FROM employees
WHERE first_name = 'Carol';

-- 6. INSERT from SELECT (subquery)

CREATE TEMP TABLE temp_employees (
    emp_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    department VARCHAR(50),
    salary INT,
    hire_date DATE,
    status VARCHAR(20)
);

INSERT INTO temp_employees (emp_id, first_name, last_name, department, salary, hire_date, status)
SELECT emp_id, first_name, last_name, department, salary, hire_date, status
FROM employees
WHERE department = 'IT';

SELECT emp_id, first_name, last_name, department
FROM temp_employees
ORDER BY emp_id;


--for other tasks
INSERT INTO employees (first_name, last_name, department, salary, hire_date, status)
VALUES
('Eve', 'Santos', 'Finance', 90000, DATE '2018-01-20', 'Active'),
('Frank','Miller', 'Support', 30000, DATE '2021-07-01', 'Active'),
('Grace','Lee', 'HR', 45000, DATE '2021-08-20', 'Inactive'),
('Henry','Clark','IT', 48000, DATE '2022-02-01', 'Terminated');


--Part C: Complex UPDATE Operations

--7.UPDATE with arithmetic expressions
UPDATE employees
SET salary = (salary * 1.10);

SELECT emp_id, first_name, salary
FROM employees
ORDER BY emp_id;

--8. UPDATE with WHERE clause and multiple conditions

UPDATE employees
SET status = 'Senior'
WHERE salary > 60000 AND hire_date < DATE '2020-01-01';


SELECT emp_id, first_name, salary, hire_date, status
FROM employees
WHERE status = 'Senior'
ORDER BY emp_id;


--9. UPDATE using CASE expression

UPDATE employees
SET department = CASE
WHEN salary > 80000 THEN 'Management'
WHEN salary BETWEEN 50000 AND 80000 THEN 'Senior'
ELSE 'Junior'
END;

SELECT emp_id, first_name, salary, department
FROM employees
ORDER BY emp_id;

--10. UPDATE with DEFAULT

UPDATE employees
SET department = DEFAULT
WHERE status = 'Inactive';

SELECT first_name, department, status
FROM employees
WHERE status = 'Inactive';


--for 11 task
INSERT INTO departments (dept_name, budget)
VALUES
('Management', 1000),
('Senior', 1000),
('Junior', 1000),
('Unassigned', 1000);

--11. UPDATE with subquery

UPDATE departments AS d
SET budget = (
    SELECT (AVG(e.salary) * 1.20)::INTEGER
    FROM employees AS e
    WHERE e.department = d.dept_name
)
WHERE d.dept_name IN (
    SELECT e.department
    FROM employees AS e
    WHERE e.department IS NOT NULL
);

SELECT dept_id, dept_name, budget
FROM departments
ORDER BY dept_id;


--for 12 task
INSERT INTO employees (first_name, last_name, department, salary, hire_date, status)
VALUES ('Ivan', 'Petrov', 'Sales', 60000, DATE '2023-06-01', 'Active');

--12. UPDATE multiple columns
UPDATE employees SET
salary = (salary * 1.15),
status = 'Promoted'
WHERE department = 'Sales';

SELECT first_name, department, salary, status
FROM employees
WHERE department = 'Sales';


-- Part D: Advanced DELETE Operations

-- 13. DELETE with simple WHERE condition
DELETE FROM employees
WHERE status = 'Terminated';

-- 14. DELETE with complex WHERE clause

DELETE FROM employees
WHERE salary < 40000 AND hire_date > DATE '2023-01-01' AND department IS NULL;

-- 15. DELETE with subquery

DELETE FROM departments
WHERE dept_name NOT IN (
    SELECT DISTINCT department FROM employees
    WHERE department IS NOT NULL
);

-- 16. DELETE with RETURNING clause

DELETE FROM projects
WHERE end_date < DATE '2023-01-01'
RETURNING *;

SELECT project_id, project_name, end_date, budget FROM projects
ORDER BY project_id;

-- Part E: Operations with NULL Values

--17. INSERT with NULL values
INSERT INTO employees (first_name, last_name, department, salary, hire_date, status)
VALUES ('Olivia', 'Bennett', NULL, NULL, DATE '2024-01-15', 'Active');

SELECT first_name, department, salary
FROM employees
WHERE first_name = 'Olivia';

-- 18. UPDATE NULL handling
UPDATE employees
SET department = 'Unassigned'
WHERE department IS NULL;

SELECT first_name, department, salary
FROM employees
WHERE first_name = 'Olivia';

-- 19. DELETE with NULL conditions

DELETE FROM employees
WHERE salary IS NULL OR department IS NULL;

-- Part F: RETURNING Clause Operations

-- 20. INSERT with RETURNING
INSERT INTO employees (first_name, last_name, department, salary, hire_date, status)
VALUES ('Paul', 'Adams', 'IT', 64000, DATE '2024-09-01', 'Active')
RETURNING emp_id, first_name || ' ' || last_name AS full_name;

-- 21. UPDATE with RETURNING


UPDATE employees 
SET salary = salary+5000
WHERE department = 'IT'
RETURNING emp_id, (salary-5000) AS old_salary, salary AS new_salary;


-- 22. DELETE with RETURNING all columns
DELETE FROM employees
WHERE hire_date < DATE '2020-01-01'
RETURNING *;


-- Part G: Advanced DML Patterns

-- 23. Conditional INSERT

INSERT INTO employees
SELECT 'Jordan', 'Unique', 'IT', 54000, CURRENT_DATE, 'Active'
WHERE NOT EXISTS (
    SELECT 1
    FROM employees
    WHERE first_name = 'Jordan'
      AND last_name  = 'Unique'
);

-- 24. UPDATE with JOIN logic using subqueries
PDATE employees
SET salary = CASE
    WHEN (
        SELECT d.budget
        FROM departments AS d
        WHERE d.dept_name = employees.department
    ) > 100000 THEN (salary * 1.10)::INTEGER
    ELSE (salary * 1.05)::INTEGER
END;

SELECT first_name, department, salary
FROM employees
WHERE first_name IN ('Frank', 'Ivan', 'Paul', 'Rita', 'Samir')
ORDER BY first_name;


-- 25. Bulk operations

INSERT INTO employees (first_name, last_name, department, salary, hire_date, status)
VALUES
('Owen', 'Blake', 'Logistics', 41000, DATE '2024-05-01', 'Active'),
('Pia', 'Shah', 'Logistics', 42000, DATE '2024-05-02', 'Active'),
('Quinn', 'Adler', 'Logistics', 43000, DATE '2024-05-03', 'Active'),
('Ruby', 'Chen', 'Logistics', 44000, DATE '2024-05-04', 'Active'),
('Seth', 'Alvarez', 'Logistics', 45000, DATE '2024-05-05', 'Active');

UPDATE employees
SET salary = (salary * 1.10)
WHERE department = 'Logistics';

SELECT first_name, department, salary
FROM employees
WHERE department = 'Logistics'
ORDER BY first_name;

-- 26. Data migration simulation
CREATE TABLE employee_archive (
    emp_id SERIAL PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    department VARCHAR(100) NOT NULL,
    salary INT,
    hire_date DATE, 
    status VARCHAR(50) 
);

INSERT INTO employee_archive(emp_id,first_name,last_name,department,salary,hire_date,status)
SELECT emp_id, first_name,last_name,department,salary,hire_date,status
FROM employees
WHERE status = 'Inactive';

DELETE FROM employees
WHERE status = 'Inactive';

-- 27. Complex business logic

UPDATE projects
SET end_date = DATE_ADD(end_date,INTERVAL 30 DAY)
WHERE budget > 50000
AND (
    SELECT COUNT(*)
    FROM employees
    JOIN departments ON employees.department = departments.dept_name
    WHERE departments.dept_id = projects.dept_id )  >3;