-- DUTPAEVA DAYANA
-- ID: 25B030159

DROP TABLE IF EXISTS employees CASCADE;
DROP TABLE IF EXISTS products_catalog CASCADE;
DROP TABLE IF EXISTS bookings CASCADE;
-- Drop tables if they already exist, including dependent constraints, to allow clean script re-runs
--1.1
CREATE TABLE employees(
    employee_id INT,
    first_name TEXT,
    last_name TEXT,
    age INT CHECK(age>=18 AND age <=65), --age (integer) - must be between 18 and 65
    salary NUMERIC CHECK (salary>0) --salary (numeric) - must be greater than 0
);
--1.2
CREATE TABLE products_catalog(
    product_id INT,
    product_name TEXT,
    regular_price NUMERIC,
    discount_price NUMERIC,
    CONSTRAINT valid_discount CHECK(
        regular_price > 0 AND -- regular_price is greater than 0
        discount_price >0 AND -- discount_price is greater than 0
        discount_price< regular_price -- discount_price is less than regular_price
        )
);
--1.3
CREATE TABLE bookings
(
    booking_id     INT,
    check_in_date  DATE,
    check_out_date DATE,
    num_guests     INT CHECK ( num_guests>=1 AND num_guests<=10 ), --num_guests is between 1 and 10
    CONSTRAINT check_date CHECK ( check_out_date>check_in_date ) --check_out_date is after check_in_date
);
--1.4

INSERT INTO employees (employee_id, first_name, last_name, age, salary) VALUES
                          (1, 'Anna', 'Wer', 28, 50000.00),
                          (2,'Ali', 'Dudei', 40, 65000.00);
--INSERT INTO employees (employee_id, first_name, last_name, age, salary) VALUES
--                          (3, 'Gary', 'Log',17, 40000.00);
-- [23514] ОШИБКА: новая строка в отношении "employees" нарушает ограничение-проверку "employees_age_check"
--   Подробности: Ошибочная строка содержит (3, Gary, Log, 17, 40000.00).
--age is not between 18 and 65

--INSERT INTO employees (employee_id, first_name, last_name, age, salary) VALUES
--                           (4, 'Diana', 'Prince', 70, 90000.00);
--[23514] ОШИБКА: новая строка в отношении "employees" нарушает ограничение-проверку "employees_age_check"
-- Подробности: Ошибочная строка содержит (4, Diana, Prince, 70, 90000.00).
--age is not between 18 and 65

--INSERT INTO employees (employee_id, first_name, last_name, age, salary) VALUES
--                                                                            (5, 'Evan', 'Wright', 28, 0.00);
--[23514] ОШИБКА: новая строка в отношении "employees" нарушает ограничение-проверку "employees_salary_check"
--Подробности: Ошибочная строка содержит (5, Evan, Wright, 28, 0.00)
--salary is equal 0

INSERT INTO products_catalog (product_id, product_name, regular_price, discount_price) VALUES
    (101, 'Wireless Mouse', 49.99, 39.99),
    (102, 'Mechanical Keyboard', 120.00, 99.50);

--INSERT INTO products_catalog (product_id, product_name, regular_price, discount_price) VALUES
--    (103, 'Faulty Gadget', -10.00, 5.00);
--[23514] ОШИБКА: новая строка в отношении "products_catalog" нарушает ограничение-проверку "valid_discount"
--Подробности: Ошибочная строка содержит (103, Faulty Gadget, -10.00, 5.00).

--regular price: -10.00 is not greater than 0


--INSERT INTO products_catalog (product_id, product_name, regular_price, discount_price) VALUES
--    (104, 'Backwards Pricing Item', 50.00, 60.00);
-- [23514] ОШИБКА: новая строка в отношении "products_catalog" нарушает ограничение-проверку "valid_discount"
--   Подробности: Ошибочная строка содержит (104, Backwards Pricing Item, 50.00, 60.00).

-- discount > regular price | 60 > 50

--INSERT INTO products_catalog (product_id, product_name, regular_price, discount_price) VALUES
--    (103, 'Gadget', 60.00, -5.00);
-- [23514] ОШИБКА: новая строка в отношении "products_catalog" нарушает ограничение-проверку "valid_discount"
--   Подробности: Ошибочная строка содержит (103, Faulty Gadget, 60.00, -5.00).

-- discount price < 0


--Part 2: NOT NULL Constraints
--2.1
-- Drop tables if they already exist, including dependent constraints, to allow clean script re-runs
DROP TABLE IF EXISTS customers CASCADE;
DROP TABLE IF EXISTS inventory CASCADE;


CREATE TABLE customers(
    customer_id INT NOT NULL,
    email TEXT NOT NULL,
    phone TEXT, -- phone can contain NULL because NOT NULL is not specified
    registration_date DATE NOT NULL
);
-- 2.2
CREATE TABLE inventory(
    item_id INT NOT NULL,
    item_name TEXT NOT NULL,
    quantity INT NOT NULL CHECK ( quantity >=0 ),
    unit_price NUMERIC NOT NULL CHECK ( unit_price>0 ),
    last_updated TIMESTAMP NOT NULL
);

INSERT INTO customers
(customer_id, email, phone, registration_date)
VALUES
    (1, 'alice@gmail.com', '123456789', '2026-01-15'),
    (2, 'bob@gmail.com', '987654321', '2026-02-20');

-- INSERT INTO customers VALUES
--    (NULL, 'test@gmail.com', '12345', '2026-03-01');
-- [23502] ОШИБКА: значение NULL в столбце "customer_id" отношения "customers" нарушает ограничение NOT NULL
--   Подробности: Ошибочная строка содержит (null, test@gmail.com, 12345, 2026-03-01).

-- INSERT INTO customers VALUES
--    (3, NULL, '12345', '2026-03-01');

-- [23502] ОШИБКА: значение NULL в столбце "email" отношения "customers" нарушает ограничение NOT NULL
--   Подробности: Ошибочная строка содержит (3, null, 12345, 2026-03-01).

-- INSERT INTO customers
-- VALUES (4, 'test2@gmail.com', '12345', NULL);
-- [23502] ОШИБКА: значение NULL в столбце "registration_date" отношения "customers" нарушает ограничение NOT NULL
--   Подробности: Ошибочная строка содержит (4, test2@gmail.com, 12345, null).

--INSERT INTO customers
-- VALUES (4, 'test2@gmail.com', '12345', NULL);
-- [23502] ОШИБКА: значение NULL в столбце "registration_date" отношения "customers" нарушает ограничение NOT NULL
--   Подробности: Ошибочная строка содержит (4, test2@gmail.com, 12345, null).

-- inventory
INSERT INTO inventory
(item_id, item_name, quantity, unit_price, last_updated)
VALUES
    (1, 'Laptop', 10, 750.00, CURRENT_TIMESTAMP),
    (2, 'Mouse', 25, 15.50, CURRENT_TIMESTAMP);


-- INSERT INTO inventory
-- VALUES (3, 'Keyboard', NULL, 30.00, CURRENT_TIMESTAMP);
-- [23502] ОШИБКА: значение NULL в столбце "quantity" отношения "inventory" нарушает ограничение NOT NULL
--   Подробности: Ошибочная строка содержит (3, Keyboard, null, 30.00, 2026-10-13 10:45:20.905708).

-- INSERT INTO inventory
-- VALUES (4, 'Monitor', 5, NULL, CURRENT_TIMESTAMP);
-- [23502] ОШИБКА: значение NULL в столбце "unit_price" отношения "inventory" нарушает ограничение NOT NULL
--   Подробности: Ошибочная строка содержит (4, Monitor, 5, null, 2026-10-13 10:45:31.466395).

-- INSERT INTO inventory
-- VALUES (5, 'Tablet', 8, 200.00, NULL);
-- [23502] ОШИБКА: значение NULL в столбце "last_updated" отношения "inventory" нарушает ограничение NOT NULL
--   Подробности: Ошибочная строка содержит (5, Tablet, 8, 200.00, null)

INSERT INTO customers
(customer_id, email, phone, registration_date)
VALUES
    (5, 'charlie@gmail.com', NULL, '2026-03-10');

-- Part 3: UNIQUE Constraints
-- Task 3.1: Single Column UNIQUE
DROP TABLE IF EXISTS users CASCADE;
-- Drop tables if they already exist, including dependent constraints, to allow clean script re-runs
CREATE TABLE users(
    user_id INT,
    username TEXT UNIQUE,
    email TEXT UNIQUE,
    created_at TIMESTAMP
);
-- Task 3.2: Multi-Column UNIQUE
DROP TABLE IF EXISTS course_enrollments CASCADE;
-- Drop tables if they already exist, including dependent constraints, to allow clean script re-runs
CREATE TABLE course_enrollments(
    enrollment_id INT,
    student_id INT,
    course_code TEXT,
    semester TEXT,
    -- UNIQUE prevents duplicate combinations of student_id,course_code and semester
    UNIQUE (student_id, course_code,semester)
);

-- Task 3.3: Named UNIQUE Constraints
-- Add a named UNIQUE constraint called unique_username on username
ALTER TABLE users
ADD CONSTRAINT unique_username UNIQUE(username);

-- Add a named UNIQUE constraint called unique_email on email
ALTER TABLE users
ADD CONSTRAINT unique_email UNIQUE(email);

--inserting duplicates
INSERT INTO users (username, email)
VALUES ('johndoe', 'john@example.com');

--INSERT INTO users (username, email)
--VALUES ('johndoe', 'different_email@example.com');
-- [23505] ОШИБКА: повторяющееся значение ключа нарушает ограничение уникальности "users_username_key"
--   Подробности: Ключ "(username)=(johndoe)" уже существует

--INSERT INTO users (username, email)
--VALUES ('different_user', 'john@example.com');
-- [23505] ОШИБКА: повторяющееся значение ключа нарушает ограничение уникальности "users_email_key"
--   Подробности: Ключ "(email)=(john@example.com)" уже существует.

-- Part 4: PRIMARY KEY Constraints
-- Task 4.1: Single Column Primary Key
DROP TABLE IF EXISTS departments CASCADE;
-- Drop tables if they already exist, including dependent constraints, to allow clean script re-runs

CREATE TABLE departments(
    dept_id INT PRIMARY KEY,
    dept_name TEXT NOT NULL,
    location TEXT
);
-- Insert at least 3 departments

INSERT INTO departments (dept_id, dept_name, location) VALUES
                                                           (1, 'Human Resources', 'Building A'),
                                                           (2, 'Engineering', 'Building B'),
                                                           (3, 'Marketing', 'Building C');

-- Attempt to insert a duplicate dept_id (1 already exists)
--INSERT INTO departments (dept_id, dept_name, location) VALUES
--    (1, 'Sales', 'Building D');
-- 23505] ОШИБКА: повторяющееся значение ключа нарушает ограничение уникальности "departments_pkey"
--   Подробности: Ключ "(dept_id)=(1)" уже существует.


-- Attempt to insert a NULL dept_id
--INSERT INTO departments (dept_id, dept_name, location) VALUES
--    (NULL, 'Finance', 'Building E');
-- [23502] ОШИБКА: значение NULL в столбце "dept_id" отношения "departments" нарушает ограничение NOT NULL
--   Подробности: Ошибочная строка содержит (null, Finance, Building E).

-- Task 4.2: Composite Primary Key
DROP TABLE IF EXISTS student_course;
-- Drop tables if they already exist, including dependent constraints, to allow clean script re-runs
CREATE TABLE student_course(
    student_id INT,
    course_id INT,
    enrollment_date DATE,
    grade TEXT,
    PRIMARY KEY (student_id, course_id) -- makes sure a student cannot join the same course twice
);

-- Task 4.3: Comparison Exercise
-- PRIMARY KEY AND UNIQUE
-- PRIMARY KEY: The main ID for a row. It must be unique, and it cannot be NULL. A table can only have one.
-- UNIQUE: Makes sure all values in a column are different, but it allows one NULL. A table can have many unique constraints


-- When to use a single-column AND composite PRIMARY KEY
-- Single-Column: Uses just one column (like id). Use this for most tables
--Composite: Combines two or more columns together (like student_id + course_id). Use this for junction tables where a single column isn't enough to be unique.


-- Why a table can have only one PRIMARY KEY but multiple UNIQUE constraints
-- One Primary Key: A table represents one main thing (entity), so it only needs one main ID to identify each row. Also, databases use the primary key to physically sort the table data.
-- Multiple Unique Constraints: In real life, an item can have several unique details (like an ID number, an email, and a phone number). You need UNIQUE constraints to protect all of them, not just the main ID.

-- Part 5: FOREIGN KEY Constraints
-- Task 5.1: Basic Foreign Key
DROP TABLE IF EXISTS employees_dept CASCADE;
-- Drop tables if they already exist, including dependent constraints, to allow clean script re-runs
CREATE TABLE employees_dept(
    emp_id INT PRIMARY KEY,
    emp_name TEXT NOT NULL,
    dept_id INT REFERENCES departments(dept_id),-- Department ID (links to departments table)
    hire_date DATE
);

-- Step 1: Insert employees with valid dept_ids (1, 2, and 3)
INSERT INTO employees_dept (emp_id, emp_name, dept_id, hire_date) VALUES
                                                                      (101, 'Alice Smith', 1, '2026-01-15'),
                                                                      (102, 'Bob Jones', 2, '2026-02-20'),
                                                                      (103, 'Charlie Brown', 3, '2026-03-10');

-- Attempt to insert an employee with a non-existent dept_id
--INSERT INTO employees_dept (emp_id, emp_name, dept_id, hire_date) VALUES
--    (104, 'Diana Prince', 99, '2026-04-05');

-- 23503] ОШИБКА: INSERT или UPDATE в таблице "employees_dept" нарушает ограничение внешнего ключа "employees_dept_dept_id_fkey"
--   Подробности: Ключ (dept_id)=(99) отсутствует в таблице "departments".

-- Task 5.2: Multiple Foreign Keys
DROP TABLE IF EXISTS authors CASCADE;
DROP TABLE IF EXISTS publishers CASCADE;
DROP TABLE IF EXISTS books CASCADE;
-- Drop tables if they already exist, including dependent constraints, to allow clean script re-runs

CREATE TABLE authors(
    author_id INT PRIMARY KEY,
    author_name TEXT NOT NULL,
    country TEXT
);

CREATE TABLE publishers(
    publisher_id INT PRIMARY KEY,
    publisher_name TEXT NOT NULL,
    city TEXT
);

CREATE TABLE books(
    book_id INT PRIMARY KEY,
    title TEXT NOT NULL,
    author_id INT REFERENCES authors(author_id),  -- links to authors table
    publisher_id INT REFERENCES publishers(publisher_id),-- links to publishers table
    publication_year INT,
    isbn TEXT UNIQUE
);

-- Insert sample authors
INSERT INTO authors (author_id, author_name, country) VALUES
                                                          (1, 'J.K. Rowling', 'United Kingdom'),
                                                          (2, 'George Orwell', 'United Kingdom'),
                                                          (3, 'Stephen King', 'United States');

-- Insert sample publishers
INSERT INTO publishers (publisher_id, publisher_name, city) VALUES
                                                                (1, 'Bloomsbury', 'London'),
                                                                (2, 'Secker & Warburg', 'London'),
                                                                (3, 'Doubleday', 'New York');

-- Insert sample books (linking to valid authors and publishers)
INSERT INTO books (book_id, title, author_id, publisher_id, publication_year, isbn) VALUES
                                                                                        (1, 'Harry Potter and the Philosopher''s Stone', 1, 1, 1997, '978-0747532699'),
                                                                                        (2, '1984', 2, 2, 1949, '978-0451524935'),
                                                                                        (3, 'The Shining', 3, 3, 1977, '978-0385121675');

-- Task 5.3: ON DELETE Options

DROP TABLE IF EXISTS categories CASCADE;
DROP TABLE IF EXISTS products_fk CASCADE ;
DROP TABLE IF EXISTS orders CASCADE ;
DROP TABLE IF EXISTS order_items CASCADE ;
-- Drop tables if they already exist, including dependent constraints, to allow clean script re-runs

CREATE TABLE categories(
    category_id INT PRIMARY KEY,
    category_name TEXT NOT NULL
);

CREATE TABLE products_fk(
    product_id INT PRIMARY KEY,
    product_name TEXT NOT NULL,
    category_id INT REFERENCES categories(category_id) ON DELETE RESTRICT -- Category ID (cannot delete category if products still use it)
);

CREATE TABLE orders(
    order_id INT PRIMARY KEY,
    order_date DATE NOT NULL
);

CREATE TABLE order_items(
    item_id INT PRIMARY KEY,
    order_id INT REFERENCES orders(order_id) ON DELETE CASCADE, -- Which order it belongs to (deleted automatically if the order is deleted)
    product_id INT REFERENCES products_fk(product_id), --links to products_fk table
    quantity INT check ( quantity>0 ) -- must be more than 0
);

INSERT INTO categories (category_id, category_name) VALUES
                                                        (1, 'Electronics'),
                                                        (2, 'Books');

INSERT INTO products_fk (product_id, product_name, category_id) VALUES
                                                                    (101, 'Smartphone', 1),
                                                                    (102, 'SQL Guidebook', 2);

INSERT INTO orders (order_id, order_date) VALUES
    (500, '2026-10-01');

INSERT INTO order_items (item_id, order_id, product_id, quantity) VALUES
    (1001, 500, 101, 2);

-- Part 6: Practical Application
-- Task 6.1: E-commerce Database Design
DROP TABLE IF EXISTS order_details CASCADE;
DROP TABLE IF EXISTS orders CASCADE;
DROP TABLE IF EXISTS products CASCADE;
DROP TABLE IF EXISTS customers CASCADE;
-- Drop tables if they already exist, including dependent constraints, to allow clean script re-runs

CREATE TABLE customers(
    customer_id INT PRIMARY KEY,
    name TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,
    phone TEXT,
    registration_date DATE NOT NULL
);

CREATE TABLE products(
    product_id INT PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT,
    price NUMERIC(10,2) NOT NULL CHECK(price >= 0),
    stock_quantity INT NOT NULL CHECK(stock_quantity>=0)
);

CREATE TABLE orders(
    order_id INT PRIMARY KEY,
    customer_id INT NOT NULL REFERENCES customers(customer_id) ON DELETE RESTRICT, -- Links order to a customer, prevents deleting a customer if they have active orders
    order_date DATE NOT NULL,
    total_amount NUMERIC (10,2) NOT NULL CHECK ( total_amount>=0 ), -- total amount must be zero or positive
    status TEXT NOT NULL CHECK(status IN ('pending', 'processing', 'shipped', 'delivered', 'cancelled')) -- allows only specific values
);

CREATE TABLE order_details(
    order_detail_id INT PRIMARY KEY,
    order_id INT NOT NULL REFERENCES orders(order_id) ON DELETE CASCADE, -- Links item to an order, deletes items automatically if the parent order is deleted
    product_id INT NOT NULL REFERENCES products(product_id) ON DELETE RESTRICT, --Links item to a product, prevents deleting a product if it is used in order details
    quantity INT NOT NULL CHECK ( quantity>0 ),
    unit_price NUMERIC(10,2) NOT NULL CHECK ( unit_price>=0)
);

-- Insert 5 Customers
INSERT INTO customers (customer_id, name, email, phone, registration_date) VALUES
                                                                               (1, 'Alice Smith', 'alice@example.com', '555-0101', '2026-01-10'),
                                                                               (2, 'Bob Jones', 'bob@example.com', '555-0202', '2026-01-15'),
                                                                               (3, 'Charlie Brown', 'charlie@example.com', '555-0303', '2026-02-01'),
                                                                               (4, 'Diana Prince', 'diana@example.com', '555-0404', '2026-02-10'),
                                                                               (5, 'Ethan Hunt', 'ethan@example.com', '555-0505', '2026-02-20');

-- Insert 5 Products
INSERT INTO products (product_id, name, description, price, stock_quantity) VALUES
                                                                                (101, 'Wireless Mouse', 'Ergonomic bluetooth mouse', 29.99, 150),
                                                                                (102, 'Mechanical Keyboard', 'RGB backlit mechanical keyboard', 89.99, 75),
                                                                                (103, '27-inch Monitor', '4K UHD IPS display', 349.99, 30),
                                                                                (104, 'USB-C Hub', 'Multiport adapter with HDMI and USB 3.0', 19.99, 200),
                                                                                (105, 'Noise-Canceling Headphones', 'Over-ear wireless headphones', 199.99, 45);

-- Insert 5 Orders
INSERT INTO orders (order_id, customer_id, order_date, total_amount, status) VALUES
                                                                                 (1001, 1, '2026-10-01', 119.98, 'delivered'),
                                                                                 (1002, 2, '2026-10-05', 349.99, 'shipped'),
                                                                                 (1003, 1, '2026-10-10', 29.99, 'processing'),
                                                                                 (1004, 3, '2026-10-11', 219.98, 'pending'),
                                                                                 (1005, 4, '2026-10-12', 89.99, 'cancelled');

-- Insert 5 Order Details
INSERT INTO order_details (order_detail_id, order_id, product_id, quantity, unit_price) VALUES
                                                                                            (5001, 1001, 101, 1, 29.99),
                                                                                            (5002, 1001, 102, 1, 89.99),
                                                                                            (5003, 1002, 103, 1, 349.99),
                                                                                            (5004, 1003, 101, 1, 29.99),
                                                                                            (5005, 1004, 104, 1, 19.99);


-- Attempt to insert a new customer using an email that already exists ('alice@example.com')
-- INSERT INTO customers (customers_id, name, email, phone, registration_date) VALUES
--     (6, 'Ali Smith', 'alice@example.com', '555-0606', '2026-10-13');
-- [23505] ОШИБКА: повторяющееся значение ключа нарушает ограничение уникальности "customers_email_key"
--   Подробности: Ключ "(email)=(alice@example.com)" уже существует.



-- Attempt to insert a product with a negative price
-- INSERT INTO products (product_id, name, description, price, stock_quantity) VALUES
--    (106, 'Broken Item', 'Should fail', -10.00, 50);
-- [23514] ОШИБКА: новая строка в отношении "products" нарушает ограничение-проверку "products_price_check"
--   Подробности: Ошибочная строка содержит (106, Broken Item, Should fail, -10.00, 50

-- Attempt to insert an order with a status not allowed by the CHECK constraint
-- INSERT INTO orders (order_id, customer_id, order_date, total_amount, status) VALUES
--     (1006, 2, '2026-10-13', 50.00, 'mystery');
-- [23514] ОШИБКА: новая строка в отношении "orders" нарушает ограничение-проверку "orders_status_check"
--   Подробности: Ошибочная строка содержит (1006, 2, 2026-10-13, 50.00, mystery).

-- Attempt to insert an order detail with quantity = 0
-- INSERT INTO order_details (order_detail_id, order_id, product_id, quantity, unit_price) VALUES
--    (5006, 1003, 102, 0, 89.99);
-- [23514] ОШИБКА: новая строка в отношении "order_details" нарушает ограничение-проверку "order_details_quantity_check"
--   Подробности: Ошибочная строка содержит (5006, 1003, 102, 0, 89.99).

-- Attempt to delete a customer who has active orders (Customer 1)
-- DELETE FROM customers WHERE customer_id = 1;
-- [42703] ОШИБКА: столбец "customer_id" не существует
--   Подсказка: Возможно, предполагалась ссылка на столбец "customers.customers_id".
--   Позиция: 29
-- Database error (FOREIGN KEY constraint violation due to ON DELETE RESTRICT



-- Delete an order (Order 1001) which has corresponding order items
DELETE FROM orders WHERE order_id = 1001;

-- Verify that the order details associated with 1001 were automatically cleaned up
-- 0 rows returned
SELECT * FROM order_details WHERE order_id = 1001;

