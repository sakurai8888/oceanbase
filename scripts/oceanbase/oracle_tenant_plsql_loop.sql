-- Oracle Tenant PL/SQL Loop Example ---

-- Run this in an Oracle mode tenant (e.g. via obclient).
-- Enable server output first so DBMS_OUTPUT lines are visible:
--   SET SERVEROUTPUT ON;


-- Demo table used by the loops below
CREATE TABLE plsql_loop_demo (
    id      NUMBER PRIMARY KEY,
    name    VARCHAR2(100),
    balance NUMBER(12, 2)
);

INSERT INTO plsql_loop_demo VALUES (1, 'Alice', 1000.50);
INSERT INTO plsql_loop_demo VALUES (2, 'Bob', 2500.00);
INSERT INTO plsql_loop_demo VALUES (3, 'Carol', 375.25);
COMMIT;



-- 1. Cursor FOR loop: simplest way to loop over every row of a table
BEGIN
    FOR rec IN (SELECT id, name, balance FROM plsql_loop_demo ORDER BY id) LOOP
        DBMS_OUTPUT.PUT_LINE('ID: ' || rec.id ||
                             ' | Name: ' || rec.name ||
                             ' | Balance: ' || rec.balance);
    END LOOP;
END;
/



-- 2. Explicit cursor loop: gives control over OPEN / FETCH / CLOSE
--    Useful when you need EXIT conditions or row-by-row processing logic.
DECLARE
    CURSOR cur_emp IS
        SELECT id, name, balance FROM plsql_loop_demo ORDER BY id;
    v_row cur_emp%ROWTYPE;
BEGIN
    OPEN cur_emp;
    LOOP
        FETCH cur_emp INTO v_row;
        EXIT WHEN cur_emp%NOTFOUND;

        -- Example row-by-row logic: flag balances below 500
        IF v_row.balance < 500 THEN
            DBMS_OUTPUT.PUT_LINE('LOW BALANCE -> ID: ' || v_row.id ||
                                 ' | Name: ' || v_row.name);
        END IF;
    END LOOP;
    CLOSE cur_emp;
END;
/



-- 3. Numeric FOR loop combined with a query:
--    loop N times and process rows fetched per iteration.
DECLARE
    v_name VARCHAR2(100);
BEGIN
    FOR i IN 1 .. 3 LOOP
        SELECT name INTO v_name
        FROM plsql_loop_demo
        WHERE id = i;

        DBMS_OUTPUT.PUT_LINE('Row ' || i || ' belongs to ' || v_name);
    END LOOP;
END;
/



-- 4. WHILE loop with a counter over aggregated data
DECLARE
    v_count NUMBER;
    i       NUMBER := 1;
BEGIN
    SELECT COUNT(*) INTO v_count FROM plsql_loop_demo;

    WHILE i <= v_count LOOP
        DBMS_OUTPUT.PUT_LINE('Processing row number: ' || i);
        i := i + 1;
    END LOOP;
END;
/



-- 5. Loop over a source table and insert into a target table
--    Typical pattern: read rows with a cursor, transform, then INSERT.

-- Target table for the copied / transformed rows
CREATE TABLE plsql_loop_target (
    id         NUMBER PRIMARY KEY,
    name_upper VARCHAR2(100),
    balance    NUMBER(12, 2),
    copied_at  DATE
);

DECLARE
    v_rows NUMBER := 0;
BEGIN
    FOR rec IN (SELECT id, name, balance FROM plsql_loop_demo ORDER BY id) LOOP
        INSERT INTO plsql_loop_target (id, name_upper, balance, copied_at)
        VALUES (rec.id, UPPER(rec.name), rec.balance * 1.1, SYSDATE);

        v_rows := v_rows + 1;
    END LOOP;

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Inserted ' || v_rows || ' rows into plsql_loop_target');
END;
/

-- Verify the inserted rows
SELECT * FROM plsql_loop_target ORDER BY id;



-- 6. Loop and insert random strings into a VARCHAR2(1000) column
--    Builds each string from a custom character pool:
--    a-z, A-Z, 0-9 and symbols !@#$%^&*()

CREATE TABLE plsql_random_strings (
    id        NUMBER PRIMARY KEY,
    rand_text VARCHAR2(1000)
);

-- Helper function: returns a random string of p_len characters
-- picked from the character pool below.
CREATE OR REPLACE FUNCTION gen_random_string (p_len IN NUMBER)
    RETURN VARCHAR2
IS
    c_pool   CONSTANT VARCHAR2(100) := 'abcdefghijklmnopqrstuvwxyz'
                                    || 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
                                    || '0123456789'
                                    || '!@#$%^&*()';
    v_result VARCHAR2(1000);
BEGIN
    FOR j IN 1 .. p_len LOOP
        v_result := v_result ||
                    SUBSTR(c_pool, TRUNC(DBMS_RANDOM.VALUE(1, LENGTH(c_pool) + 1)), 1);
    END LOOP;
    RETURN v_result;
END;
/

-- Stored procedure: inserts p_rows rows into plsql_random_strings,
-- each with a random string whose length is between p_min_len and p_max_len.
CREATE OR REPLACE PROCEDURE load_random_strings (
    p_rows    IN NUMBER DEFAULT 100,
    p_min_len IN NUMBER DEFAULT 10,
    p_max_len IN NUMBER DEFAULT 1000
)
IS
    v_len NUMBER;
BEGIN
    FOR i IN 1 .. p_rows LOOP
        -- Random length between p_min_len and p_max_len characters
        v_len := TRUNC(DBMS_RANDOM.VALUE(p_min_len, p_max_len + 1));

        INSERT INTO plsql_random_strings (id, rand_text)
        VALUES (i, gen_random_string(v_len));
    END LOOP;

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Inserted ' || p_rows || ' rows into plsql_random_strings');
END;
/

-- Call it with defaults (100 rows, length 10-1000)
BEGIN
    load_random_strings;
END;
/

-- Or with explicit arguments, e.g. 500 rows with 100-500 char strings
-- BEGIN
--     load_random_strings(p_rows => 500, p_min_len => 100, p_max_len => 500);
-- END;
-- /

-- Verify: show each row with its actual string length
SELECT id, LENGTH(rand_text) AS text_len, SUBSTR(rand_text, 1, 50) AS text_preview
FROM plsql_random_strings
ORDER BY id;
