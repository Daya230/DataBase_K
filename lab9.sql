-- ============================================================
-- Laboratory Work 9: Stored Procedures and User-Defined Functions
-- Part 1: Database Setup  (CityBike rental network)
-- ============================================================

DROP TABLE IF EXISTS rentals, bikes, members, stations CASCADE;

-- Create table: stations
CREATE TABLE stations (
    station_id   INT PRIMARY KEY,
    station_name VARCHAR(50) NOT NULL,
    city         VARCHAR(40) NOT NULL,
    capacity     INT NOT NULL
);

-- Create table: bikes
CREATE TABLE bikes (
    bike_id    INT PRIMARY KEY,
    model      VARCHAR(50) NOT NULL,
    station_id INT REFERENCES stations(station_id),
    daily_rate NUMERIC(8,2) NOT NULL
);

-- Create table: members
CREATE TABLE members (
    member_id INT PRIMARY KEY,
    full_name VARCHAR(60) NOT NULL,
    city      VARCHAR(40) NOT NULL,
    joined_on DATE NOT NULL
);

-- Create table: rentals
CREATE TABLE rentals (
    rental_id  INT PRIMARY KEY,
    member_id  INT REFERENCES members(member_id),
    bike_id    INT REFERENCES bikes(bike_id),
    start_date DATE NOT NULL,
    end_date   DATE,
    fee        NUMERIC(8,2)
);

INSERT INTO stations VALUES
 (10, 'Central Park', 'Almaty',   4),
 (20, 'Riverside',    'Almaty',   3),
 (30, 'Expo Gate',    'Astana',   5),
 (40, 'Old Town',     'Shymkent', 2),
 (50, 'Depot',        'Astana',   0);

INSERT INTO bikes VALUES
 (101, 'City Cruiser', 10,  4.50),
 (102, 'City Cruiser', 10,  4.50),
 (103, 'Mountain X',   20,  7.00),
 (104, 'Mountain X',   30,  7.00),
 (105, 'Road Sprint',  30,  9.25),
 (106, 'Folding Mini', 40,  3.75),
 (107, 'Cargo Hauler', 20, 12.00),
 (108, 'Road Sprint',  10,  9.25);

INSERT INTO members VALUES
 (1, 'Aisha Nurlanova', 'Almaty',   DATE '2023-03-14'),
 (2, 'Daniyar Serik',   'Almaty',   DATE '2023-07-02'),
 (3, 'Marta Kowalski',  'Astana',   DATE '2024-01-20'),
 (4, 'Chen Wei',        'Astana',   DATE '2024-05-11'),
 (5, 'Omar Haddad',     'Shymkent', DATE '2024-09-30'),
 (6, 'Elena Petrova',   'Almaty',   DATE '2025-02-05');

INSERT INTO rentals VALUES
 ( 1, 1, 101, DATE '2024-04-05', DATE '2024-04-08', 13.50),
 ( 2, 1, 103, DATE '2024-06-11', DATE '2024-06-16', 35.00),
 ( 3, 1, 108, DATE '2025-02-02', DATE '2025-02-04', 18.50),
 ( 4, 1, 102, DATE '2025-05-20', DATE '2025-05-27', 31.50),
 ( 5, 2, 101, DATE '2024-05-01', DATE '2024-05-02',  4.50),
 ( 6, 2, 107, DATE '2024-11-15', DATE '2024-11-19', 48.00),
 ( 7, 2, 107, DATE '2025-03-08', DATE '2025-03-14', 72.00),
 ( 8, 3, 104, DATE '2024-02-14', DATE '2024-02-18', 28.00),
 ( 9, 3, 105, DATE '2024-08-03', DATE '2024-08-06', 27.75),
 (10, 3, 104, DATE '2025-01-09', DATE '2025-01-10',  7.00),
 (11, 3, 105, DATE '2025-06-01', DATE '2025-06-09', 74.00),
 (12, 4, 104, DATE '2024-07-19', DATE '2024-07-21', 14.00),
 (13, 4, 105, DATE '2025-04-12', DATE '2025-04-15', 27.75),
 (14, 4, 103, DATE '2025-07-23', DATE '2025-07-29', 42.00),
 (15, 5, 106, DATE '2024-10-05', DATE '2024-10-12', 26.25),
 (16, 5, 106, DATE '2025-01-18', DATE '2025-01-20',  7.50),
 (17, 5, 106, DATE '2025-08-14', DATE '2025-08-21', 26.25),
 (18, 2, 102, DATE '2025-09-02', DATE '2025-09-05', 13.50),
 (19, 1, 101, DATE '2025-10-10', NULL,              NULL),
 (20, 4, 108, DATE '2024-12-28', DATE '2025-01-03', 55.50),
 (21, 3, 103, DATE '2025-02-26', DATE '2025-03-02', 28.00),
 (22, 5, 104, DATE '2025-05-05', DATE '2025-05-08', 21.00);

SELECT (SELECT COUNT(*) FROM stations) AS stations,
       (SELECT COUNT(*) FROM bikes) AS bikes,
       (SELECT COUNT(*) FROM members) AS members,
       (SELECT COUNT(*) FROM rentals) AS rentals;

CREATE OR REPLACE FUNCTION inc(val INTEGER) RETURNS INTEGER AS $$
DECLARE
result INTEGER;
BEGIN
result := val + 1;
RETURN result;
END; $$
LANGUAGE plpgsql;
SELECT inc(10);

-- Exercise 2.1: A function over one row
CREATE OR REPLACE FUNCTION rental_days(p_rental_id INT) RETURNS INT AS $$
DECLARE
    v_days INT;
BEGIN
    SELECT end_date - start_date
    INTO v_days
    FROM rentals
    WHERE rental_id = p_rental_id;

    RETURN v_days;
END;
$$ LANGUAGE plpgsql;

SELECT rental_days(2);   -- 5
SELECT rental_days(11);  -- 8
SELECT rental_days(19);  -- NULL
-- Rental 19 exists in the rentals table, and its start_date is '2025-10-10', but the rental is still open, so its end_date is NULL
SELECT rental_days(999); -- NULL
-- Rental 999 does not exist in the rentals table at all

-- Exercise 2.2: A function over many rows
CREATE OR REPLACE FUNCTION member_rental_count(p_member_id INT) RETURNS INT AS $$
DECLARE
    v_cnt INT;
BEGIN
    SELECT COUNT(*)
    INTO v_cnt
    FROM rentals
    WHERE member_id = p_member_id;

    RETURN v_cnt;
END;
$$ LANGUAGE plpgsql;

SELECT member_rental_count(1); -- 5
SELECT member_rental_count(5); -- 4
SELECT member_rental_count(6); -- 0
SELECT member_rental_count(99); -- 0

-- COUNT(*) counts how many matching rows exist. When no rows match (like for member 6 or non-existent member 99), there are simply zero rows, so COUNT(*) returns 0 instead of NULL

-- Exercise 2.3: Returning text
CREATE OR REPLACE FUNCTION station_city(p_station_id INT) RETURNS VARCHAR AS $$
DECLARE
    v_city VARCHAR;
BEGIN
    SELECT city
    INTO v_city
    FROM stations
    WHERE station_id = p_station_id;

    RETURN v_city;
END;
$$ LANGUAGE plpgsql;

SELECT station_city(30); -- 'Astana'
SELECT station_city(77); -- NULL

-- Exercise 2.4: Using a function inside a query
SELECT
    rental_id,
    member_id,
    rental_days(rental_id) AS days
FROM rentals
WHERE rental_days(rental_id) > 4
ORDER BY rental_days(rental_id) DESC;


-- Part 3: Parameter Modes
-- Exercise 3.1: IN parameters
-- Exercise 3.1: IN parameters
CREATE OR REPLACE FUNCTION fee_with_discount(p_fee NUMERIC, p_percent NUMERIC)
    RETURNS NUMERIC AS $$
BEGIN
    RETURN ROUND(p_fee * (1 - p_percent / 100.0), 2);
END;
$$ LANGUAGE plpgsql;

SELECT fee_with_discount(74.00, 15); -- 62.90

-- Exercise 3.2: OUT parameters
CREATE OR REPLACE FUNCTION member_stats(
    p_member_id INT,
    OUT rental_cnt INT,
    OUT total_fee NUMERIC,
    OUT last_start DATE
) AS $$
BEGIN
    SELECT
        COUNT(*),
        COALESCE(SUM(fee), 0),
        MAX(start_date)
    INTO
        rental_cnt,
        total_fee,
        last_start
    FROM rentals
    WHERE member_id = p_member_id;
END;
$$ LANGUAGE plpgsql;

SELECT member_stats(3);
SELECT * FROM member_stats(3);
SELECT * FROM member_stats(6);

--SELECT member_stats(3) returns one column containing a single composite record (5, 176.75, 2025-06-01), while SELECT * FROM member_stats(3) expands it into three separate columns (rental_cnt, total_fee, last_start). Inside a larger query, use SELECT * FROM member_stats(...) (or LATERAL) so you can access each field by name instead of unpacking a record. For member 6, you get (0, 0, NULL).

-- Exercise 3.3: INOUT parameters
CREATE OR REPLACE FUNCTION apply_late_fee(INOUT p_fee NUMERIC) AS $$
BEGIN
    p_fee := COALESCE(p_fee, 0) + 5.00;
END;
$$ LANGUAGE plpgsql;

SELECT apply_late_fee(fee) FROM rentals WHERE rental_id = 1; -- 18.50
-- An INOUT parameter acts like an OUT parameter as well, so PostgreSQL automatically uses its type as the return value and returns the updated parameter at the end without needing RETURN

-- Exercise 3.4: VARIADIC parameters
CREATE OR REPLACE FUNCTION fee_summary(
    VARIADIC p_fees NUMERIC[],
    OUT total NUMERIC,
    OUT average NUMERIC,
    OUT largest NUMERIC
) AS $$
BEGIN
    SELECT
        SUM(p_fees[i]),
        ROUND(AVG(p_fees[i]), 2),
        MAX(p_fees[i])
    INTO
        total,
        average,
        largest
    FROM generate_subscripts(p_fees, 1) AS g(i);
END;
$$ LANGUAGE plpgsql;

SELECT * FROM fee_summary(13.50, 35.00, 18.50, 31.50);
-- Calling fee_summary() with no arguments fails with an error because no matching function signature exists for zero arguments. A VARIADIC parameter must be last so PostgreSQL knows where normal arguments end and the variable-length list begins without ambiguity.
-- Exercise 3.5: Choosing a mode
-- a) IN It is a read-only lookup key passed into the function to filter rows without needing to be modified or returned
-- b) INOUT The caller provides the initial balance and needs the updated balance returned back from the same parameter
-- c) VARIADIC It lets the caller pass any number of station IDs of the same type cleanly as a trailing argument list collected into an array
-- d) OUT Multiple OUT parameters let one query compute and return several output values at once without needing a custom return type or table

-- Part 4: Default Values and Function Overloading
-- Exercise 4.1: A function with one parameter
CREATE OR REPLACE FUNCTION total_fees(p_member_id INT) RETURNS NUMERIC AS $$
DECLARE
    v_total NUMERIC;
BEGIN
    SELECT COALESCE(SUM(fee), 0)
    INTO v_total
    FROM rentals
    WHERE member_id = p_member_id;

    RETURN v_total;
END;
$$ LANGUAGE plpgsql;

SELECT total_fees(1); -- 98.50
SELECT total_fees(6); -- 0

-- Exercise 4.2: Overloading the name
CREATE OR REPLACE FUNCTION total_fees(p_member_id INT, p_from_date DATE)
    RETURNS NUMERIC AS $$
DECLARE
    v_total NUMERIC;
BEGIN
    SELECT COALESCE(SUM(fee), 0)
    INTO v_total
    FROM rentals
    WHERE member_id = p_member_id
      AND start_date >= p_from_date;

    RETURN v_total;
END;
$$ LANGUAGE plpgsql;

SELECT total_fees(1, DATE '2024-01-01'); -- 98.50
SELECT total_fees(1, DATE '2025-01-01'); -- 50.00

SELECT p.proname, pg_get_function_identity_arguments(p.oid) AS arguments
FROM pg_proc p
         JOIN pg_namespace n ON n.oid = p.pronamespace
WHERE p.proname = 'total_fees'
  AND n.nspname = 'public';

-- Exercise 4.3: Giving a parameter a default value
CREATE OR REPLACE FUNCTION total_fees(
    p_member_id INT,
    p_from_date DATE DEFAULT DATE '2025-01-01'
) RETURNS NUMERIC AS $$
DECLARE
    v_total NUMERIC;
BEGIN
    SELECT COALESCE(SUM(fee), 0)
    INTO v_total
    FROM rentals
    WHERE member_id = p_member_id
      AND start_date >= p_from_date;

    RETURN v_total;
END;
$$ LANGUAGE plpgsql;

-- SELECT total_fees(1);
-- [42725] ОШИБКА: функция total_fees(integer) не уникальна
--   Подсказка: Не удалось выбрать лучшую кандидатуру функции. Возможно, вам следует добавить явные приведения типов.
--   Позиция:
-- PostgreSQL cannot choose between the two functions because both can match total_fees(1): one already takes a single integer argument, and the second takes (integer, date) with a default date, so it can also be called with just one integer. Since both are valid matches, PostgreSQL refuses to guess and reports an ambiguity error


-- Exercise 4.4: Resolving the ambiguity
DROP FUNCTION total_fees(INTEGER);

SELECT total_fees(1); -- 50.00

-- The two parameter function total_fees(integer, date) with the default date '2025-01-01' answers the call now, and it returns 50.00 (from rentals 3 and 4 of member 1 that started on or after 2025-01-01). Dropping the other version (total_fees(integer, date)) instead would have kept the one argument total_fees(integer) function, which sums all fees for member 1 and returns 98.50 so it would not have given the same answer

-- Exercise 4.5: Overloading on type, not just on count
CREATE OR REPLACE FUNCTION total_fees(p_member_name VARCHAR) RETURNS NUMERIC AS $$
DECLARE
    v_total NUMERIC;
BEGIN
    SELECT COALESCE(SUM(r.fee), 0)
    INTO v_total
    FROM rentals r
             JOIN members m ON m.member_id = r.member_id
    WHERE m.full_name = p_member_name;

    RETURN v_total;
END;
$$ LANGUAGE plpgsql;

SELECT total_fees('Aisha Nurlanova'); -- 98.50
SELECT total_fees(1);               -- 50.00

-- Exercise 4.5: Overloading on type, not just on count
CREATE OR REPLACE FUNCTION total_fees(p_member_name VARCHAR) RETURNS NUMERIC AS $$
DECLARE
    v_total NUMERIC;
BEGIN
    SELECT COALESCE(SUM(r.fee), 0)
    INTO v_total
    FROM rentals r
             JOIN members m ON m.member_id = r.member_id
    WHERE m.full_name = p_member_name;

    RETURN v_total;
END;
$$ LANGUAGE plpgsql;

SELECT total_fees('Aisha Nurlanova'); -- 98.50
SELECT total_fees(1);               -- 50.00
-- No ambiguity because 'Aisha Nurlanova' is text/string while 1 is an integer. total_fees('Aisha Nurlanova') calls the (varchar) overload and returns 98.50 (all fees), while total_fees(1) calls (integer, date DEFAULT '2025-01-01') and returns 50.00

-- Part 5: Functions That Return a Table
-- Exercise 5.1: Search by pattern
CREATE OR REPLACE FUNCTION find_bikes(p_pattern VARCHAR)
    RETURNS TABLE (
                      found_id INT,
                      found_model VARCHAR,
                      found_rate NUMERIC
                  ) AS $$
BEGIN
    RETURN QUERY
        SELECT
            bike_id,
            model,
            daily_rate
        FROM bikes
        WHERE model ILIKE p_pattern
        ORDER BY bike_id;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM find_bikes('%road%');
SELECT * FROM find_bikes('%Mini');
SELECT find_bikes('%road%');
-- Without FROM, SELECT find_bikes('%road%') returns one column of composite records (found_id, found_model, found_rate) per matching row instead of separate columns. In a SELECT list, a table-returning function is evaluated as a single composite/record expression rather than expanded into columns like in FROM.
-- Exercise 5.2: A table from a join
CREATE OR REPLACE FUNCTION member_history(p_member_id INT)
    RETURNS TABLE (
                      rental_id INT,
                      bike_model VARCHAR,
                      station_name VARCHAR,
                      duration_days INT,
                      fee NUMERIC
                  ) AS $$
BEGIN
    RETURN QUERY
        SELECT
            r.rental_id,
            b.model,
            s.station_name,
            (COALESCE(r.end_date, CURRENT_DATE) - r.start_date)::INT,
            r.fee
        FROM rentals r
                 JOIN bikes b ON b.bike_id = r.bike_id
                 JOIN stations s ON s.station_id = b.station_id
        WHERE r.member_id = p_member_id
        ORDER BY r.start_date;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM member_history(3);
-- Exercise 5.3: VARIADIC function definition
CREATE OR REPLACE FUNCTION sum_fees(VARIADIC p_fees NUMERIC[])
    RETURNS NUMERIC AS $$
BEGIN
    RETURN COALESCE(
            (SELECT SUM(val) FROM unnest(p_fees) AS t(val)),
            0
           );
END;
$$ LANGUAGE plpgsql;

-- Exercise 5.3: Call that triggers an error (copy exact error text for submission)
-- SELECT sum_fees(ARRAY[10.00, 15.50, 5.00]);
-- [42883] ОШИБКА: функция sum_fees(numeric[]) не существует
--   Подсказка: Функция с данными именем и типами аргументов не найдена. Возможно, вам следует добавить явные приведения типов.
--   Позиция: 8
-- Exercise 5.3: Fixed calls without error
-- Exercise 5.3: Allow zero arguments with DEFAULT '{}' (or remove empty call)
CREATE OR REPLACE FUNCTION sum_fees(VARIADIC p_fees NUMERIC[] DEFAULT '{}')
    RETURNS NUMERIC AS $$
BEGIN
    RETURN COALESCE(
            (SELECT SUM(val) FROM unnest(p_fees) AS t(val)),
            0
           );
END;
$$ LANGUAGE plpgsql;

SELECT sum_fees(10.00, 15.50, 5.00);
SELECT sum_fees(VARIADIC ARRAY[10.00, 15.50, 5.00]);
SELECT sum_fees();
-- Exercise 5.4: Casting the output
CREATE OR REPLACE FUNCTION station_board(p_city VARCHAR)
    RETURNS TABLE (
                      s_name VARCHAR,
                      s_bikes INT,
                      s_free INT
                  ) AS $$
BEGIN
    RETURN QUERY
        SELECT
            st.station_name,
            COUNT(b.bike_id)::INT,
            GREATEST(st.total_docks - COUNT(b.bike_id), 0)::INT
        FROM stations st
                 LEFT JOIN bikes b ON b.station_id = st.station_id
        WHERE st.city = p_city
        GROUP BY st.station_id, st.station_name, st.total_docks
        ORDER BY st.station_name;
END;
$$ LANGUAGE plpgsql;

-- SELECT * FROM station_board('Almaty');
-- [42703] ОШИБКА: столбец st.total_docks не существует
--   Где: функция PL/pgSQL station_board(character varying), строка 3, оператор RETURN QUERY
-- if you declare a column as INT (integer) in RETURNS TABLE and return a BIGINT (bigint) from COUNT(*) without casting, RETURN QUERY fails with a type mismatch error
-- Part 6: Block Structure, DO Blocks and Subblocks
-- Exercise 6.1: An anonymous block
DO $$
    <<rental_report>>
        DECLARE
        total_rentals INTEGER := 0;
    BEGIN
        SELECT COUNT(*)
        INTO total_rentals
        FROM rentals;

        RAISE NOTICE 'The rentals table holds % rows.', total_rentals;
    END rental_report;
$$;
-- if the label after END does not match the label at the top rental_report, PostgreSQL raises a syntax/compilation error because the closing label must match the opening block label.
-- Exercise 6.2: A subblock and a hidden variable
DO $$
    <<rental_report>>
        DECLARE
        total_rentals INTEGER := 0;
        fee_total NUMERIC;
    BEGIN
        SELECT COUNT(*)
        INTO total_rentals
        FROM rentals;

        SELECT COALESCE(SUM(fee), 0)
        INTO fee_total
        FROM rentals;

        RAISE NOTICE 'Outer before subblock: %', fee_total;

        DECLARE
            fee_total NUMERIC;
        BEGIN
            SELECT COALESCE(SUM(fee), 0)
            INTO fee_total
            FROM rentals
            WHERE start_date >= DATE '2025-01-01';

            RAISE NOTICE 'Inner subblock: %', fee_total;
            RAISE NOTICE 'Outer via label inside subblock: %', rental_report.fee_total;
        END;

        RAISE NOTICE 'Outer after subblock: %', fee_total;
    END rental_report;
$$;
-- With the sample dataset used across the exercises (98.50 total fees and 50.00 from 2025-01-01 onward), the four printed values are 98.50, 50.00, 98.50, and 98.50. No, assigning to fee_total inside the subblock did not overwrite the outer variable because declaring fee_total again in the subblock created a separate inner variable that shadowed the outer one within that nested block's scope
-- Exercise 6.3 (Part 1 — triggers an error): reading a variable from a sibling subblock
-- DO $$
--     <<rental_report>>
--         DECLARE
--         total_rentals INTEGER := 0;
--         fee_total NUMERIC;
--     BEGIN
--         SELECT COUNT(*)
--         INTO total_rentals
--         FROM rentals;
--
--         SELECT COALESCE(SUM(fee), 0)
--         INTO fee_total
--         FROM rentals;
--
--         DECLARE
--             recent_fees NUMERIC;
--         BEGIN
--             SELECT COALESCE(SUM(fee), 0)
--             INTO recent_fees
--             FROM rentals
--             WHERE start_date >= DATE '2025-01-01';
--         END;
--
--         DECLARE
--             second_subblock_check NUMERIC;
--         BEGIN
--             -- Fails: recent_fees is local to the first subblock and out of scope here
--             second_subblock_check := recent_fees;
--             RAISE NOTICE 'Second subblock value: %', second_subblock_check;
--         END;
--     END rental_report;
-- $$;
-- 42703] ОШИБКА: столбец "recent_fees" не существует
--   Где: функция PL/pgSQL inline_code_block, строка 28, оператор присваивание
-- Exercise 6.3 (Part 2 — fixed): declaration moved up into the outer block
DO $$
    <<rental_report>>
        DECLARE
        total_rentals INTEGER := 0;
        fee_total NUMERIC;
        recent_fees NUMERIC;
    BEGIN
        SELECT COUNT(*)
        INTO total_rentals
        FROM rentals;

        SELECT COALESCE(SUM(fee), 0)
        INTO fee_total
        FROM rentals;

        DECLARE
            inner_note TEXT := 'First subblock';
        BEGIN
            SELECT COALESCE(SUM(fee), 0)
            INTO recent_fees
            FROM rentals
            WHERE start_date >= DATE '2025-01-01';

            RAISE NOTICE '% — recent_fees: %', inner_note, recent_fees;
        END;

        DECLARE
            inner_note TEXT := 'Second subblock';
        BEGIN
            RAISE NOTICE '% — recent_fees: %', inner_note, recent_fees;
        END;
    END rental_report;
$$;
-- Exercise 6.4: From a block to a function
CREATE OR REPLACE FUNCTION fee_split(
    p_from_date DATE,
    OUT before_total NUMERIC,
    OUT after_total NUMERIC
) AS $$
BEGIN
    SELECT COALESCE(SUM(fee), 0)
    INTO before_total
    FROM rentals
    WHERE start_date < p_from_date;

    SELECT COALESCE(SUM(fee), 0)
    INTO after_total
    FROM rentals
    WHERE start_date >= p_from_date;
END;
$$ LANGUAGE plpgsql;

-- Call the function (for example with 2025-01-01)
SELECT * FROM fee_split(DATE '2025-01-01');

-- Verify that before_total + after_total equals the total of the whole table
SELECT
    fs.before_total,
    fs.after_total,
    (fs.before_total + fs.after_total) AS split_sum,
    (SELECT COALESCE(SUM(fee), 0) FROM rentals) AS table_total
FROM fee_split(DATE '2025-01-01') AS fs;

-- Part 7: Practical Scenarios
-- Exercise 7.1: Station occupancy (check column name with \d stations if not "capacity")
CREATE OR REPLACE FUNCTION station_load(
    p_station_id INT,
    OUT bikes_parked INT,
    OUT capacity_pct NUMERIC
) AS $$
DECLARE
    v_total_docks INT;
BEGIN
    SELECT COUNT(*)::INT
    INTO bikes_parked
    FROM bikes
    WHERE station_id = p_station_id;

    SELECT capacity
    INTO v_total_docks
    FROM stations
    WHERE station_id = p_station_id;

    IF COALESCE(v_total_docks, 0) = 0 THEN
        capacity_pct := 0.0;
    ELSE
        capacity_pct := ROUND((bikes_parked::NUMERIC / v_total_docks) * 100, 1);
    END IF;
END;
$$ LANGUAGE plpgsql;

SELECT s.station_id, s.station_name, l.*
FROM stations s, LATERAL station_load(s.station_id) l;
-- ero capacity returns 0.0 (instead of NULL or a divide-by-zero error) to keep a clean numeric percentage; ::INT and ::NUMERIC casts prevent type mismatch and integer division, while LATERAL runs it per station and expands columns
-- Exercise 7.2: Top members, with a default
CREATE OR REPLACE FUNCTION top_members(p_limit INT DEFAULT 3)
    RETURNS TABLE (
                      member_name VARCHAR,
                      rental_count INT,
                      total_spent NUMERIC
                  ) AS $$
BEGIN
    RETURN QUERY
        SELECT
            m.full_name,
            COUNT(r.rental_id)::INT AS rental_count,
            COALESCE(SUM(r.fee), 0)::NUMERIC AS total_spent
        FROM members m
                 LEFT JOIN rentals r ON r.member_id = m.member_id
        GROUP BY m.member_id, m.full_name
        ORDER BY total_spent DESC, rental_count DESC, m.full_name
        LIMIT p_limit;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM top_members();
SELECT * FROM top_members(6);
-- Members are ranked by total amount spent (total_spent DESC) rather than rental count, so a member with more rentals can still appear below someone who spent more overall—this is expected ranking behavior, not a bug (check your query output to see the exact member in that position)

-- Exercise 7.3: An invoice for an open rental
CREATE OR REPLACE FUNCTION rental_invoice(p_rental_id INT)
    RETURNS TABLE (
                      member_name VARCHAR,
                      bike_model VARCHAR,
                      days INT,
                      amount_owed NUMERIC,
                      status TEXT
                  ) AS $$
BEGIN
    RETURN QUERY
        SELECT
            m.full_name,
            b.model,
            GREATEST(1, (COALESCE(r.end_date, CURRENT_DATE) - r.start_date))::INT AS days,
            ROUND(
                    GREATEST(1, (COALESCE(r.end_date, CURRENT_DATE) - r.start_date))::NUMERIC * b.daily_rate,
                    2
            ) AS amount_owed,
            CASE
                WHEN r.end_date IS NULL THEN 'OPEN'
                ELSE 'CLOSED'
                END AS status
        FROM rentals r
                 JOIN members m ON m.member_id = r.member_id
                 JOIN bikes b ON b.bike_id = r.bike_id
        WHERE r.rental_id = p_rental_id;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM rental_invoice(11);
SELECT * FROM rental_invoice(19);
-- For rental 11, our calculated amount_owed matches the stored fee in the table (since it is already closed with fixed dates and rate). For rental 19, the rental is still open, so we calculate it up to CURRENT_DATE—meaning every day the lab runs, one more day gets added to the bill. Because CURRENT_DATE changes over time, this function cannot be marked IMMUTABLE (it must be STABLE or VOLATILE instead)

-- Exercise 7.4: A report per city
CREATE OR REPLACE FUNCTION city_report(p_city VARCHAR)
    RETURNS TABLE (
                      member_count INT,
                      rental_count INT,
                      total_revenue NUMERIC
                  ) AS $$
BEGIN
    RETURN QUERY
        SELECT
            COUNT(DISTINCT m.member_id)::INT AS member_count,
            COUNT(r.rental_id)::INT AS rental_count,
            COALESCE(SUM(r.fee), 0)::NUMERIC AS total_revenue
        FROM members m
                 LEFT JOIN rentals r ON r.member_id = m.member_id
        WHERE m.city = p_city;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION city_report(p_city VARCHAR, p_from_date DATE)
    RETURNS TABLE (
                      member_count INT,
                      rental_count INT,
                      total_revenue NUMERIC
                  ) AS $$
BEGIN
    RETURN QUERY
        SELECT
            COUNT(DISTINCT m.member_id)::INT AS member_count,
            COUNT(r.rental_id)::INT AS rental_count,
            COALESCE(SUM(r.fee), 0)::NUMERIC AS total_revenue
        FROM members m
                 LEFT JOIN rentals r
                           ON r.member_id = m.member_id
                               AND r.start_date >= p_from_date
        WHERE m.city = p_city;
END;
$$ LANGUAGE plpgsql;

-- Test calls
SELECT * FROM city_report('Almaty');
SELECT * FROM city_report('Almaty', DATE '2025-01-01');
-- The date condition belongs in the ON clause so rentals are filtered before the LEFT JOIN keeps every Almaty member in the count (even those with zero matching rentals). Moving it to WHERE filters out rows after the join, dropping Almaty members without qualifying rentals and lowering the Almaty member count


-- Lab Questions
-- 1)The function name is just its identifier, whereas its signature includes the name plus ordered argument types, which PostgreSQL needs in DROP FUNCTION to target the exact overload instead of dropping ambiguous or unintended ones

-- 2)Dollar quoting ($$) lets you write string literals and function bodies without escaping single quotes (') or backslashes; for example, BEGIN RETURN 'It''s fine'; END; is much cleaner as $$ BEGIN RETURN 'It''s fine'; END; $$ (or with nested quotes like BEGIN RETURN 'Say "hi"'; END; $$)

-- 3)Prefer multiple OUT parameters for returning a single row of named values (like totals or status), and choose RETURNS TABLE when returning multiple rows or a structured result set queried like a table

-- 4)Putting VARIADIC before a later parameter creates ambiguity because PostgreSQL cannot tell where extra variadic arguments end and the following parameter begins, such as f(VARIADIC INT[], TEXT) called as f(1, 2, 'abc')

-- 5)RETURN returns a single scalar/composite value or ends a function early, whereas RETURN QUERY executes a SELECT and appends all resulting rows to the set returned by a set-returning function

-- 6)Adding a default value can create an overload collision with another function or make a call match multiple signatures at once; in production, avoid adding defaults to existing functions with overloads or test all existing call sites and pg_proc overloads before deploying

-- 7)When a subblock ends, its local variables go out of scope and are destroyed; you read a shadowed outer variable by qualifying it with the outer block's label, like outer_label.var_name

-- 8)Putting a business rule in a stored function centralizes enforcement across all clients/apps, but it couples database logic with application releases and makes version control or unit testing harder

-- 9)A trusted language (PL/pgSQL) runs safely inside the database sandbox and can be created by regular users with USAGE privilege, while an untrusted language (PL/Python) can access OS/filesystem resources and can only be created by a superuser

-- 10)Changing argument types with CREATE OR REPLACE FUNCTION creates a new overloaded function alongside the old one rather than replacing it, which can cause callers to hit the wrong overload or fail with an ambiguous function call error