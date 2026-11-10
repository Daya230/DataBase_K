
-- Laboratory Work 7


-- Part 1: Database Setup
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


-- Part 2: Creating Basic Views

-- Exercise 2.1: Simple View Creation
-- Employees who are assigned to a department, with department info.
CREATE VIEW employee_details AS
SELECT
    e.emp_name,
    e.salary,
    d.dept_name,
    d.location
FROM employees e
INNER JOIN departments d ON e.dept_id = d.dept_id;

SELECT * FROM employee_details;

-- Question: How many rows are returned? Why doesn't Tom Brown appear?
-- Ans: 4 rows (John, Jane, Mike, Sarah). Tom Brown has dept_id = NULL,
-- so INNER JOIN finds no matching department and drops him.


-- Ex 2.2
-- All departments, including those with no employees (Marketing).
CREATE VIEW dept_statistics AS
SELECT
    d.dept_name,
    COUNT(e.emp_id) AS employee_count,
    AVG(e.salary) AS average_salary,
    MAX(e.salary) AS maximum_salary,
    MIN(e.salary) AS minimum_salary
FROM departments d
LEFT JOIN employees e ON d.dept_id = e.dept_id
GROUP BY d.dept_id, d.dept_name;

SELECT * FROM dept_statistics
ORDER BY employee_count DESC;


-- Exercise 2.3: View with Multiple Joins
CREATE VIEW project_overview AS
SELECT
    p.project_name,
    p.budget,
    d.dept_name,
    d.location,
    COUNT(e.emp_id) AS team_size
FROM projects p
LEFT JOIN departments d ON p.dept_id = d.dept_id
LEFT JOIN employees e ON d.dept_id = e.dept_id
GROUP BY p.project_id, p.project_name, p.budget, d.dept_name, d.location;

SELECT * FROM project_overview;


-- Exercise 2.4: View with Filtering
CREATE VIEW high_earners AS
SELECT
    e.emp_name,
    e.salary,
    d.dept_name
FROM employees e
LEFT JOIN departments d ON e.dept_id = d.dept_id
WHERE e.salary > 55000;

SELECT * FROM high_earners;

-- Question: What happens when you query this view? Can you see all
-- high-earning employees?
-- Ans: The view returns Jane Doe (60000, HR) and Sarah Williams
-- (65000, Finance). Mike Johnson is 55000, which is not greater than
-- 55000, so he is excluded. All employees currently above 55000 are
-- visible. Tom Brown (45000) is not a high earner.


-- Part 3: Modifying and Managing Views

-- Exercise 3.1: Replace a View
CREATE OR REPLACE VIEW employee_details AS
SELECT
    e.emp_name,
    e.salary,
    d.dept_name,
    d.location,
    CASE
        WHEN e.salary > 60000 THEN 'High'
        WHEN e.salary > 50000 THEN 'Medium'
        ELSE 'Standard'
    END AS salary_grade
FROM employees e
INNER JOIN departments d ON e.dept_id = d.dept_id;

SELECT * FROM employee_details;


-- Exercise 3.2: Rename a View
ALTER VIEW high_earners RENAME TO top_performers;

SELECT * FROM top_performers;


-- Exercise 3.3: Drop a View
CREATE VIEW temp_view AS
SELECT emp_id, emp_name, salary
FROM employees
WHERE salary < 50000;

SELECT * FROM temp_view;

DROP VIEW temp_view;


-- Part 4: Updatable Views

-- Exercise 4.1: Create an Updatable View
-- Single-table SELECT with no aggregation → automatically updatable.
CREATE VIEW employee_salaries AS
SELECT emp_id, emp_name, dept_id, salary
FROM employees;


-- Exercise 4.2: Update Through a View
UPDATE employee_salaries
SET salary = 52000
WHERE emp_name = 'John Smith';

SELECT * FROM employees WHERE emp_name = 'John Smith';

-- Question: Did the underlying table get updated?
-- Answer: Yes. John Smith's salary in employees is now 52000.


-- Exercise 4.3: Insert Through a View
INSERT INTO employee_salaries (emp_id, emp_name, dept_id, salary)
VALUES (6, 'Alice Johnson', 102, 58000);

SELECT * FROM employees;

-- Question: Was the insert successful? Check the employees table.
-- Answer: Yes. Alice Johnson (emp_id 6) appears in employees because
-- the view maps 1:1 onto that table's columns.


-- Exercise 4.4: View with CHECK OPTION
CREATE VIEW it_employees AS
SELECT emp_id, emp_name, dept_id, salary
FROM employees
WHERE dept_id = 101
WITH LOCAL CHECK OPTION;

-- This should fail: new row would not satisfy the view's WHERE clause.
-- Wrapped so the rest of the script can still run.
DO $$
BEGIN
    INSERT INTO it_employees (emp_id, emp_name, dept_id, salary)
    VALUES (7, 'Bob Wilson', 103, 60000);
EXCEPTION
    WHEN others THEN
        RAISE NOTICE 'Expected error: %', SQLERRM;
END $$;

-- Question: What error message do you receive? Why?
-- Answer: PostgreSQL raises:
--   ERROR:  new row violates check option for view "it_employees"
-- WITH CHECK OPTION rejects inserts/updates whose resulting row would
-- not be visible through the view. dept_id 103 is Finance, not IT (101).



-- Part 5: Materialized Views

-- Exercise 5.1: Create a Materialized View
CREATE MATERIALIZED VIEW dept_summary_mv AS
SELECT
    d.dept_id,
    d.dept_name,
    COALESCE(emp.total_employees, 0) AS total_employees,
    COALESCE(emp.total_salaries, 0) AS total_salaries,
    COALESCE(proj.total_projects, 0) AS total_projects,
    COALESCE(proj.total_project_budget, 0) AS total_project_budget
FROM departments d
LEFT JOIN (
    SELECT
        dept_id,
        COUNT(*) AS total_employees,
        SUM(salary) AS total_salaries
    FROM employees
    GROUP BY dept_id
) emp ON d.dept_id = emp.dept_id
LEFT JOIN (
    SELECT
        dept_id,
        COUNT(*) AS total_projects,
        SUM(budget) AS total_project_budget
    FROM projects
    GROUP BY dept_id
) proj ON d.dept_id = proj.dept_id
WITH DATA;

SELECT * FROM dept_summary_mv ORDER BY total_employees DESC;


-- Exercise 5.2: Refresh Materialized View
INSERT INTO employees (emp_id, emp_name, dept_id, salary)
VALUES (8, 'Charlie Brown', 101, 54000);

-- Before refresh: IT employee count is still the old cached value.
SELECT * FROM dept_summary_mv WHERE dept_id = 101;

REFRESH MATERIALIZED VIEW dept_summary_mv;

-- After refresh: Charlie Brown is included in IT totals.
SELECT * FROM dept_summary_mv WHERE dept_id = 101;

-- Question: What's the difference before and after refresh?
-- Answer: Before refresh the MV still shows the snapshot from creation
-- (IT does not include Charlie). After REFRESH the stored result is
-- recomputed and IT's total_employees / total_salaries increase.


-- Exercise 5.3: Concurrent Refresh
CREATE UNIQUE INDEX idx_dept_summary_mv_dept_id
    ON dept_summary_mv (dept_id);

REFRESH MATERIALIZED VIEW CONCURRENTLY dept_summary_mv;

-- Question: What's the advantage of CONCURRENTLY option?
-- Answer: A normal REFRESH locks the MV for reads until it finishes.
-- CONCURRENTLY rebuilds the data without blocking SELECT on the MV
-- (requires a unique index). Slightly slower, but readers keep working.


-- Exercise 5.4: Materialized View with NO DATA
CREATE MATERIALIZED VIEW project_stats_mv AS
SELECT
    p.project_name,
    p.budget,
    d.dept_name,
    COUNT(e.emp_id) AS assigned_employees
FROM projects p
LEFT JOIN departments d ON p.dept_id = d.dept_id
LEFT JOIN employees e ON d.dept_id = e.dept_id
GROUP BY p.project_id, p.project_name, p.budget, d.dept_name
WITH NO DATA;

-- This fails until the MV is populated. Wrapped so the script continues.
DO $$
BEGIN
    PERFORM * FROM project_stats_mv;
EXCEPTION
    WHEN others THEN
        RAISE NOTICE 'Expected error: %', SQLERRM;
END $$;

-- Question: What error do you get? How do you fix it?
-- Ans:
--   ERROR:  materialized view "project_stats_mv" has not been populated
--   HINT:  Use the REFRESH MATERIALIZED VIEW command.
REFRESH MATERIALIZED VIEW project_stats_mv;
SELECT * FROM project_stats_mv;


-- Part 6: Database Roles

-- Exercise 6.1: Create Basic Roles
CREATE ROLE analyst;
CREATE ROLE data_viewer WITH LOGIN PASSWORD 'viewer123';
CREATE USER report_user WITH PASSWORD 'report456';

SELECT rolname FROM pg_roles WHERE rolname NOT LIKE 'pg_%';


-- Exercise 6.2: Role with Specific Attributes
CREATE ROLE db_creator WITH LOGIN CREATEDB PASSWORD 'creator789';
CREATE ROLE user_manager WITH LOGIN CREATEROLE PASSWORD 'manager101';
CREATE ROLE admin_user WITH LOGIN SUPERUSER PASSWORD 'admin999';


-- Exercise 6.3: Grant Privileges to Roles
GRANT SELECT ON employees, departments, projects TO analyst;
GRANT ALL PRIVILEGES ON employee_details TO data_viewer;
GRANT SELECT, INSERT ON employees TO report_user;


-- Exercise 6.4: Create Group Roles
CREATE ROLE hr_team;
CREATE ROLE finance_team;
CREATE ROLE it_team;

CREATE USER hr_user1 WITH PASSWORD 'hr001';
CREATE USER hr_user2 WITH PASSWORD 'hr002';
CREATE USER finance_user1 WITH PASSWORD 'fin001';

GRANT hr_team TO hr_user1;
GRANT hr_team TO hr_user2;
GRANT finance_team TO finance_user1;

GRANT SELECT, UPDATE ON employees TO hr_team;
GRANT SELECT ON dept_statistics TO finance_team;


-- Exercise 6.5: Revoke Privileges
REVOKE UPDATE ON employees FROM hr_team;
REVOKE hr_team FROM hr_user2;
REVOKE ALL PRIVILEGES ON employee_details FROM data_viewer;


-- Exercise 6.6: Modify Role Attributes
ALTER ROLE analyst WITH LOGIN PASSWORD 'analyst123';
ALTER ROLE user_manager WITH SUPERUSER;
ALTER ROLE analyst WITH PASSWORD NULL;
ALTER ROLE data_viewer WITH CONNECTION LIMIT 5;


-- Part 7: Advanced Role Management

-- Exercise 7.1: Role Hierarchies
CREATE ROLE read_only;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO read_only;

CREATE USER junior_analyst WITH PASSWORD 'junior123';
CREATE USER senior_analyst WITH PASSWORD 'senior123';

GRANT read_only TO junior_analyst;
GRANT read_only TO senior_analyst;
GRANT INSERT, UPDATE ON employees TO senior_analyst;


-- Exercise 7.2: Object Ownership
CREATE ROLE project_manager WITH LOGIN PASSWORD 'pm123';

ALTER VIEW dept_statistics OWNER TO project_manager;
ALTER TABLE projects OWNER TO project_manager;

SELECT tablename, tableowner
FROM pg_tables
WHERE schemaname = 'public';


-- Exercise 7.3: Reassign and Drop Roles
CREATE ROLE temp_owner WITH LOGIN;

CREATE TABLE temp_table (
    id INT
);

ALTER TABLE temp_table OWNER TO temp_owner;

-- Move owned objects to postgres, then drop leftovers and the role.
REASSIGN OWNED BY temp_owner TO postgres;
DROP OWNED BY temp_owner;
DROP ROLE temp_owner;


-- Exercise 7.4: Row-Level Security with Views
CREATE VIEW hr_employee_view AS
SELECT emp_id, emp_name, dept_id, salary
FROM employees
WHERE dept_id = 102;

GRANT SELECT ON hr_employee_view TO hr_team;

CREATE VIEW finance_employee_view AS
SELECT emp_id, emp_name, salary
FROM employees;

GRANT SELECT ON finance_employee_view TO finance_team;


-- Part 8: Practical Scenarios

-- Exercise 8.1: Department Dashboard View
CREATE VIEW dept_dashboard AS
SELECT
    d.dept_name,
    d.location,
    COALESCE(emp.employee_count, 0) AS employee_count,
    ROUND(emp.average_salary, 2) AS average_salary,
    COALESCE(proj.active_projects, 0) AS active_projects,
    COALESCE(proj.total_project_budget, 0) AS total_project_budget,
    ROUND(
        COALESCE(proj.total_project_budget, 0)
        / NULLIF(emp.employee_count, 0),
        2
    ) AS budget_per_employee
FROM departments d
LEFT JOIN (
    SELECT
        dept_id,
        COUNT(*) AS employee_count,
        AVG(salary) AS average_salary
    FROM employees
    GROUP BY dept_id
) emp ON d.dept_id = emp.dept_id
LEFT JOIN (
    SELECT
        dept_id,
        COUNT(*) AS active_projects,
        SUM(budget) AS total_project_budget
    FROM projects
    GROUP BY dept_id
) proj ON d.dept_id = proj.dept_id;

SELECT * FROM dept_dashboard;


-- Exercise 8.2: Audit View
ALTER TABLE projects
    ADD COLUMN created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP;

CREATE VIEW high_budget_projects AS
SELECT
    p.project_name,
    p.budget,
    d.dept_name,
    p.created_date,
    CASE
        WHEN p.budget > 150000 THEN 'Critical Review Required'
        WHEN p.budget > 100000 THEN 'Management Approval Needed'
        ELSE 'Standard Process'
    END AS approval_status
FROM projects p
LEFT JOIN departments d ON p.dept_id = d.dept_id
WHERE p.budget > 75000;

SELECT * FROM high_budget_projects;


-- Exercise 8.3: Create Access Control System
CREATE ROLE viewer_role;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO viewer_role;

CREATE ROLE entry_role;
GRANT viewer_role TO entry_role;
GRANT INSERT ON employees, projects TO entry_role;

CREATE ROLE analyst_role;
GRANT entry_role TO analyst_role;
GRANT UPDATE ON employees, projects TO analyst_role;

CREATE ROLE manager_role;
GRANT analyst_role TO manager_role;
GRANT DELETE ON employees, projects TO manager_role;

CREATE USER alice WITH PASSWORD 'alice123';
CREATE USER bob WITH PASSWORD 'bob123';
CREATE USER charlie WITH PASSWORD 'charlie123';

GRANT viewer_role TO alice;
GRANT analyst_role TO bob;
GRANT manager_role TO charlie;

