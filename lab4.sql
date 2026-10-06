DROP TABLE IF EXISTS employees;
DROP TABLE IF EXISTS projects;
DROP TABLE IF EXISTS assignments;


-- Create tables
CREATE TABLE employees (
                           employee_id SERIAL PRIMARY KEY,
                           first_name VARCHAR(50),
                           last_name VARCHAR(50),
                           department VARCHAR(50),
                           salary NUMERIC(10,2),
                           hire_date DATE,
                           manager_id INTEGER,
                           email VARCHAR(100)
);
CREATE TABLE projects (
                          project_id SERIAL PRIMARY KEY,
                          project_name VARCHAR(100),
                          budget NUMERIC(12,2),
                          start_date DATE,
                          end_date DATE,
                          status VARCHAR(20)
);
CREATE TABLE assignments (
                             assignment_id SERIAL PRIMARY KEY,
                             employee_id INTEGER REFERENCES employees(employee_id),
                             project_id INTEGER REFERENCES projects(project_id),
                             hours_worked NUMERIC(5,1),
                             assignment_date DATE
);
-- Insert sample data
INSERT INTO employees (first_name, last_name, department,
                       salary, hire_date, manager_id, email) VALUES
                                                                 ('John', 'Smith', 'IT', 75000, '2020-01-15', NULL,
                                                                  'john.smith@company.com'),
                                                                 ('Sarah', 'Johnson', 'IT', 65000, '2020-03-20', 1,
                                                                  'sarah.j@company.com'),
                                                                 ('Michael', 'Brown', 'Sales', 55000, '2019-06-10', NULL,
                                                                  'mbrown@company.com'),
                                                                 ('Emily', 'Davis', 'HR', 60000, '2021-02-01', NULL,
                                                                  'emily.davis@company.com'),
                                                                 ('Robert', 'Wilson', 'IT', 70000, '2020-08-15', 1, NULL),
                                                                 ('Lisa', 'Anderson', 'Sales', 58000, '2021-05-20', 3,
                                                                  'lisa.a@company.com');
INSERT INTO projects (project_name, budget, start_date,
                      end_date, status) VALUES
                                            ('Website Redesign', 150000, '2024-01-01', '2024-06-30',
                                             'Active'),
                                            ('CRM Implementation', 200000, '2024-02-15', '2024-12-31',
                                             'Active'),
                                            ('Marketing Campaign', 80000, '2024-03-01', '2024-05-31',
                                             'Completed'),
                                            ('Database Migration', 120000, '2024-01-10', NULL, 'Active');
INSERT INTO assignments (employee_id, project_id,
                         hours_worked, assignment_date) VALUES
                                                            (1, 1, 120.5, '2024-01-15'),
                                                            (2, 1, 95.0, '2024-01-20'),
                                                            (1, 4, 80.0, '2024-02-01'),
                                                            (3, 3, 60.0, '2024-03-05'),
                                                            (5, 2, 110.0, '2024-02-20'),
                                                            (6, 3, 75.5, '2024-03-10');


-- Part 1: Basic SELECT Queries
-- Task 1.1: Write a query to select all employees, displaying their full name (concatenated first and last name), department, and salary.
SELECT CONCAT(first_name, ' ', last_name) AS full_name, department, salary FROM employees;

--Task 1.2: Use SELECT DISTINCT to find all unique departments in the company
SELECT DISTINCT(department) FROM employees;

--Task 1.3: Select all projects with their names and budgets, and create a new column called budget_category using a CASE expression
SELECT project_name, budget,
CASE
    WHEN budget > 150000 THEN 'Large'
    WHEN budget BETWEEN 100000 and 15000 THEN 'Medium'
    ELSE 'Small'
END
AS budget_category
FROM projects;

-- Task 1.4: Write a query using COALESCE to display employee names and their emails. If email is NULL, display 'No email provided

SELECT CONCAT(first_name, ' ', last_name) AS name, COALESCE(email, 'No email provided') AS email
    FROM employees;

-- Part 2: WHERE Clause and Comparison Operators
-- Task 2.1: Find all employees hired after January 1, 2020.

SELECT * FROM employees
         WHERE hire_date > '01.01.2020';

-- Task 2.2: Find all employees whose salary is between 60000 and 70000 (use the BETWEEN operator)

SELECT * FROM employees
         WHERE salary BETWEEN 60000 AND 70000;

--Task 2.3: Find all employees whose last name starts with 'S' or 'J' (use the LIKE operator)

SELECT * FROM employees
WHERE last_name LIKE 'S%' OR last_name LIKE 'J%';


--Task 2.4: Find all employees who have a manager (manager_id IS NOT NULL) and work in the IT department
SELECT * FROM employees
WHERE manager_id IS NOT NULL AND department = 'IT';

-- Part 3: String and Mathematical Functions
-- Task 3.1: Create a query that displays:

SELECT
    UPPER(CONCAT(first_name, ' ', last_name)) AS employee_name,
    LENGTH(last_name) AS last_name_length,
    SUBSTR(email,1,3) AS first_three_ch
FROM employees

-- Task 3.2: Calculate the following for each employee:
-- check it again/////////////////////////////////////
SELECT
    salary AS annual_salary,
    CAST(ROUND(salary / 12.0, 2) AS DECIMAL(10,2)) AS monthly_salary,
    salary * 1.1 AS new_annual_salary,
    salary * 0.1 AS raised_amount

FROM employees;

-- Task 3.3
SELECT FORMAT('Project: %s - Budget: $%s - Status: %s', project_name, budget, status ) FROM projects;

--task 3.4
SELECT first_name, last_name, EXTRACT(YEARS FROM AGE(CURRENT_DATE, hire_date)) AS years_with_company FROM employees;

-- Part 4: Aggregate Functions and GROUP BY
--Task 4.1
SELECT department, AVG(salary) FROM employees
GROUP BY department;

--4.2
SELECT p.project_name, coalesce(SUM(a.hours_worked),0) AS total_hours_worked FROM projects p
LEFT JOIN assignments a on p.project_id = a.project_id
GROUP BY p.project_id, p.project_name
ORDER BY total_hours_worked DESC;
-- Task 4.3
SELECT department, COUNT(department) FROM employees
GROUP BY department
HAVING COUNT(department) > 1;

--TASK 4.4
SELECT MAX(salary) AS max_salary, MIN(salary) AS min_salary, SUM(salary) FROM employees;

--Part 5: Set Operations
--TASK 5.1
SELECT employee_id, CONCAT(first_name ,' ', last_name) AS full_name, salary FROM employees
                                                                            WHERE salary>65000
UNION
SELECT employee_id, CONCAT(first_name ,' ', last_name) AS full_name, salary FROM employees
WHERE hire_date> '2020-01-01';

--TASK 5.2
SELECT employee_id, CONCAT(first_name ,' ', last_name) AS full_name, department, salary FROM employees
WHERE department = 'IT'
INTERSECT
SELECT employee_id, CONCAT(first_name ,' ', last_name) AS full_name, department, salary FROM employees
WHERE salary>65000;
--5.3
SELECT employee_id, CONCAT(first_name, ' ', last_name) FROM employees
EXCEPT
SELECT DISTINCT e.employee_id, CONCAT(e.first_name, ' ', e.last_name) FROM employees e
JOIN assignments a ON e.employee_id = a.employee_id;

--Part 6: Subqueries
--6.1
SELECT employee_id, CONCAT(first_name, ' ', last_name) AS full_name FROM employees e
WHERE EXISTS(SELECT 1 FROM assignments a
                      WHERE a.employee_id = e.employee_id);
-- 6.2
SELECT employee_id, CONCAT(first_name, ' ', last_name) AS full_name FROM employees e
WHERE employee_id IN (
    SELECT employee_id FROM assignments a
                       JOIN projects p on a.project_id = p.project_id
                       WHERE p.status = 'Active'
    );

--6.3
SELECT employee_id, CONCAT(first_name, ' ', last_name) AS full_name, department FROM employees
WHERE  salary > ANY (
    SELECT salary FROM employees WHERE department='Sales'
           );

-- Part 7: Complex Queries
-- 7.1
SELECT CONCAT(e.first_name, ' ', e.last_name) AS employee_name, e.department, e.salary, AVG(a.hours_worked) AS avg_hours_worked FROM employees e
         JOIN assignments a ON e.employee_id = a.employee_id
GROUP BY e.employee_id, e.first_name, e.last_name, e.department,e.salary
ORDER BY e.department ASC, e.salary DESC;
--7.2
SELECT project_name, SUM(a.hours_worked) AS total_hours, COUNT(DISTINCT a.employee_id) AS number_of_workers FROM projects p
JOIN assignments a ON p.project_id = a.project_id
GROUP BY p.project_name, p.project_id
HAVING SUM(a.hours_worked)>150;

--7.3
SELECT COUNT(DISTINCT(employee_id)) AS number_of_employees, AVG(salary) AS average_salary, (
    SELECT first_name || ' '|| last_name FROM employees
                                         ORDER BY GREATEST(salary, 0) DESC, LEAST(employee_id,9999) ASC
                                         LIMIT 1
    ) as hihest_paid_employee
FROM employees e;
