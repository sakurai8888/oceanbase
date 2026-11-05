-- ====================================================================
-- Oracle Demo Schema for OceanBase Oracle Mode
-- ====================================================================
-- Purpose:
--   Demonstrates a broad set of Oracle-compatible object types in a
--   single, self-contained script. Safe to rerun: it drops existing
--   demo objects at the top before recreating them.
--
-- Usage:
--   1. Connect to an OceanBase Oracle-mode tenant with a user that has
--      CREATE TABLE/INDEX/SEQUENCE/TRIGGER/TYPE/PROCEDURE/PACKAGE/
--      VIEW/SYNONYM privileges.
--   2. Run this script through obclient or another Oracle-compatible
--      client that understands the '/' PL/SQL terminator.
-- ====================================================================

SET ECHO ON
SET SERVEROUTPUT ON

PROMPT ============================================================
PROMPT Step 0: Optional schema/user creation (uncomment if needed)
PROMPT ============================================================
-- If you prefer a dedicated user, run the following as SYS/DBA and
-- then reconnect as DEMO_SCHEMA before executing the rest.
--
-- DROP USER demo_schema CASCADE;
-- CREATE USER demo_schema IDENTIFIED BY demo_password
--   DEFAULT TABLESPACE oceanbase
--   QUOTA UNLIMITED ON oceanbase;
-- GRANT CREATE SESSION TO demo_schema;
-- GRANT CREATE TABLE TO demo_schema;
-- GRANT CREATE SEQUENCE TO demo_schema;
-- GRANT CREATE TRIGGER TO demo_schema;
-- GRANT CREATE TYPE TO demo_schema;
-- GRANT CREATE PROCEDURE TO demo_schema;
-- GRANT CREATE PACKAGE TO demo_schema;
-- GRANT CREATE VIEW TO demo_schema;
-- GRANT CREATE SYNONYM TO demo_schema;
-- GRANT CREATE MATERIALIZED VIEW TO demo_schema;


PROMPT ============================================================
PROMPT Step 1: Cleanup existing demo objects
PROMPT ============================================================

BEGIN
    -- Materialized view (drop first because it may depend on tables)
    BEGIN EXECUTE IMMEDIATE 'DROP MATERIALIZED VIEW demo_customer_orders_mv'; EXCEPTION WHEN OTHERS THEN NULL; END;

    -- Synonym
    BEGIN EXECUTE IMMEDIATE 'DROP SYNONYM demo_orders_syn'; EXCEPTION WHEN OTHERS THEN NULL; END;

    -- View
    BEGIN EXECUTE IMMEDIATE 'DROP VIEW demo_customer_orders'; EXCEPTION WHEN OTHERS THEN NULL; END;

    -- Package and standalone PL/SQL objects
    BEGIN EXECUTE IMMEDIATE 'DROP PACKAGE demo_order_pkg'; EXCEPTION WHEN OTHERS THEN NULL; END;
    BEGIN EXECUTE IMMEDIATE 'DROP PROCEDURE demo_load_customers'; EXCEPTION WHEN OTHERS THEN NULL; END;
    BEGIN EXECUTE IMMEDIATE 'DROP FUNCTION demo_format_currency'; EXCEPTION WHEN OTHERS THEN NULL; END;

    -- Types
    BEGIN EXECUTE IMMEDIATE 'DROP TYPE demo_address_list FORCE'; EXCEPTION WHEN OTHERS THEN NULL; END;
    BEGIN EXECUTE IMMEDIATE 'DROP TYPE demo_address_type FORCE'; EXCEPTION WHEN OTHERS THEN NULL; END;

    -- Trigger
    BEGIN EXECUTE IMMEDIATE 'DROP TRIGGER trg_demo_orders_bir'; EXCEPTION WHEN OTHERS THEN NULL; END;

    -- Sequence
    BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE demo_orders_seq'; EXCEPTION WHEN OTHERS THEN NULL; END;

    -- Indexes
    BEGIN EXECUTE IMMEDIATE 'DROP INDEX idx_demo_orders_customer_local'; EXCEPTION WHEN OTHERS THEN NULL; END;
    BEGIN EXECUTE IMMEDIATE 'DROP INDEX idx_demo_orders_date_global'; EXCEPTION WHEN OTHERS THEN NULL; END;
    BEGIN EXECUTE IMMEDIATE 'DROP INDEX idx_demo_customers_upper_name'; EXCEPTION WHEN OTHERS THEN NULL; END;

    -- Tables (child tables first)
    BEGIN EXECUTE IMMEDIATE 'DROP TABLE demo_order_items PURGE'; EXCEPTION WHEN OTHERS THEN NULL; END;
    BEGIN EXECUTE IMMEDIATE 'DROP TABLE demo_orders PURGE'; EXCEPTION WHEN OTHERS THEN NULL; END;
    BEGIN EXECUTE IMMEDIATE 'DROP TABLE demo_orders_partitioned PURGE'; EXCEPTION WHEN OTHERS THEN NULL; END;
    BEGIN EXECUTE IMMEDIATE 'DROP TABLE demo_products PURGE'; EXCEPTION WHEN OTHERS THEN NULL; END;
    BEGIN EXECUTE IMMEDIATE 'DROP TABLE demo_customers PURGE'; EXCEPTION WHEN OTHERS THEN NULL; END;
END;
/


PROMPT ============================================================
PROMPT Step 2: Tables and constraints
PROMPT ============================================================

CREATE TABLE demo_customers (
    customer_id   NUMBER        GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_name VARCHAR2(100) NOT NULL,
    email         VARCHAR2(100) NOT NULL,
    status        VARCHAR2(20)  DEFAULT 'ACTIVE' NOT NULL,
    created_at    TIMESTAMP     DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT uk_demo_customers_email UNIQUE (email),
    CONSTRAINT chk_demo_customers_status CHECK (status IN ('ACTIVE', 'INACTIVE', 'SUSPENDED'))
);

COMMENT ON TABLE demo_customers IS 'Master list of demo customers.';
COMMENT ON COLUMN demo_customers.customer_id IS 'Surrogate primary key.';
COMMENT ON COLUMN demo_customers.email IS 'Unique contact address.';

CREATE TABLE demo_products (
    product_id   NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    product_name VARCHAR2(200) NOT NULL,
    unit_price   NUMBER(12, 2) NOT NULL,
    CONSTRAINT chk_demo_products_price CHECK (unit_price > 0)
);

COMMENT ON TABLE demo_products IS 'Product catalog for demo orders.';

CREATE TABLE demo_orders (
    order_id     NUMBER PRIMARY KEY,
    customer_id  NUMBER NOT NULL,
    order_date   DATE   NOT NULL,
    total_amount NUMBER(12, 2),
    CONSTRAINT fk_demo_orders_customer FOREIGN KEY (customer_id)
        REFERENCES demo_customers (customer_id)
);

COMMENT ON TABLE demo_orders IS 'Parent order header table.';
COMMENT ON COLUMN demo_orders.order_id IS 'Order identifier populated by trigger + sequence.';

CREATE TABLE demo_order_items (
    order_item_id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    order_id      NUMBER NOT NULL,
    product_id    NUMBER NOT NULL,
    quantity      NUMBER NOT NULL,
    line_amount   NUMBER(12, 2) NOT NULL,
    CONSTRAINT fk_demo_items_order FOREIGN KEY (order_id)
        REFERENCES demo_orders (order_id) ON DELETE CASCADE,
    CONSTRAINT fk_demo_items_product FOREIGN KEY (product_id)
        REFERENCES demo_products (product_id),
    CONSTRAINT chk_demo_items_qty CHECK (quantity > 0)
);

COMMENT ON TABLE demo_order_items IS 'Child line items for each order.';


PROMPT ============================================================
PROMPT Step 3: Range-partitioned table
PROMPT ============================================================
-- Note: In OceanBase the partition key must be the leading column of
-- the primary key when the table is partitioned.

CREATE TABLE demo_orders_partitioned (
    order_date   DATE   NOT NULL,
    order_id     NUMBER NOT NULL,
    customer_id  NUMBER NOT NULL,
    total_amount NUMBER(12, 2),
    CONSTRAINT pk_demo_orders_part PRIMARY KEY (order_date, order_id)
)
PARTITION BY RANGE (order_date) (
    PARTITION p_202601 VALUES LESS THAN (TO_DATE('2026-02-01', 'YYYY-MM-DD')),
    PARTITION p_202602 VALUES LESS THAN (TO_DATE('2026-03-01', 'YYYY-MM-DD')),
    PARTITION p_202603 VALUES LESS THAN (TO_DATE('2026-04-01', 'YYYY-MM-DD')),
    PARTITION p_max    VALUES LESS THAN (MAXVALUE)
);

COMMENT ON TABLE demo_orders_partitioned IS 'Range-partitioned variant of the orders table.';


PROMPT ============================================================
PROMPT Step 4: Sequence
PROMPT ============================================================

CREATE SEQUENCE demo_orders_seq
    START WITH 1001
    INCREMENT BY 1
    NOCACHE
    NOCYCLE;


PROMPT ============================================================
PROMPT Step 5: Trigger
PROMPT ============================================================

CREATE OR REPLACE TRIGGER trg_demo_orders_bir
    BEFORE INSERT ON demo_orders
    FOR EACH ROW
BEGIN
    IF :NEW.order_id IS NULL THEN
        :NEW.order_id := demo_orders_seq.NEXTVAL;
    END IF;
END;
/


PROMPT ============================================================
PROMPT Step 6: Indexes
PROMPT ============================================================

-- Local partitioned index on the partitioned table
CREATE INDEX idx_demo_orders_customer_local
    ON demo_orders_partitioned (customer_id) LOCAL;

-- Global partitioned index on the partitioned table
CREATE INDEX idx_demo_orders_date_global
    ON demo_orders_partitioned (order_date) GLOBAL
    PARTITION BY HASH (order_date) PARTITIONS 4;

-- Function-based index on the customer name
CREATE INDEX idx_demo_customers_upper_name
    ON demo_customers (UPPER(customer_name));


PROMPT ============================================================
PROMPT Step 7: Types
PROMPT ============================================================

CREATE OR REPLACE TYPE demo_address_type AS OBJECT (
    street VARCHAR2(200),
    city   VARCHAR2(100),
    zip    VARCHAR2(20),
    MEMBER FUNCTION to_string RETURN VARCHAR2
);
/

CREATE OR REPLACE TYPE BODY demo_address_type AS
    MEMBER FUNCTION to_string RETURN VARCHAR2 IS
    BEGIN
        RETURN street || ', ' || city || ' ' || zip;
    END;
END;
/

CREATE OR REPLACE TYPE demo_address_list AS TABLE OF demo_address_type;
/


PROMPT ============================================================
PROMPT Step 8: Function
PROMPT ============================================================

CREATE OR REPLACE FUNCTION demo_format_currency (p_amount IN NUMBER)
    RETURN VARCHAR2
IS
BEGIN
    RETURN TO_CHAR(p_amount, 'FM999,999,999.00');
END;
/


PROMPT ============================================================
PROMPT Step 9: Procedure
PROMPT ============================================================

CREATE OR REPLACE PROCEDURE demo_load_customers (
    p_count IN NUMBER DEFAULT 5
)
IS
BEGIN
    FOR i IN 1 .. p_count LOOP
        INSERT INTO demo_customers (customer_name, email, status)
        VALUES (
            'Customer ' || i,
            'customer' || i || '@demo.example',
            CASE WHEN MOD(i, 3) = 0 THEN 'INACTIVE' ELSE 'ACTIVE' END
        );
    END LOOP;
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Loaded ' || p_count || ' demo customers.');
END;
/


PROMPT ============================================================
PROMPT Step 10: Package (spec + body)
PROMPT ============================================================

CREATE OR REPLACE PACKAGE demo_order_pkg AS
    -- Returns the customer name for a given customer_id
    FUNCTION get_customer_name (p_customer_id IN NUMBER) RETURN VARCHAR2;

    -- Creates a new order and returns the generated order_id
    PROCEDURE create_order (
        p_customer_id IN NUMBER,
        p_order_date  IN DATE,
        p_order_id    OUT NUMBER
    );
END demo_order_pkg;
/

CREATE OR REPLACE PACKAGE BODY demo_order_pkg AS
    FUNCTION get_customer_name (p_customer_id IN NUMBER)
        RETURN VARCHAR2
    IS
        v_name demo_customers.customer_name%TYPE;
    BEGIN
        SELECT customer_name INTO v_name
        FROM demo_customers
        WHERE customer_id = p_customer_id;
        RETURN v_name;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN NULL;
    END get_customer_name;

    PROCEDURE create_order (
        p_customer_id IN NUMBER,
        p_order_date  IN DATE,
        p_order_id    OUT NUMBER
    )
    IS
    BEGIN
        p_order_id := demo_orders_seq.NEXTVAL;
        INSERT INTO demo_orders (order_id, customer_id, order_date, total_amount)
        VALUES (p_order_id, p_customer_id, p_order_date, 0);
    END create_order;
END demo_order_pkg;
/


PROMPT ============================================================
PROMPT Step 11: View
PROMPT ============================================================

CREATE OR REPLACE VIEW demo_customer_orders AS
SELECT
    c.customer_id,
    c.customer_name,
    c.email,
    o.order_id,
    o.order_date,
    o.total_amount,
    demo_format_currency(NVL(o.total_amount, 0)) AS total_amount_fmt
FROM demo_customers c
LEFT JOIN demo_orders o ON o.customer_id = c.customer_id;

COMMENT ON TABLE demo_customer_orders IS 'Join view of customers and their orders.';


PROMPT ============================================================
PROMPT Step 12: Synonym
PROMPT ============================================================

CREATE OR REPLACE SYNONYM demo_orders_syn FOR demo_orders;


PROMPT ============================================================
PROMPT Step 13: Optional materialized view
PROMPT ============================================================
-- Uncomment the block below if your OceanBase version supports
-- Oracle-mode materialized views. If CREATE MATERIALIZED VIEW fails,
-- leave it commented and the rest of the demo still works.

-- CREATE MATERIALIZED VIEW demo_customer_orders_mv
--     BUILD IMMEDIATE
--     REFRESH COMPLETE ON DEMAND
-- AS
-- SELECT customer_id, customer_name, COUNT(order_id) AS order_count
-- FROM demo_customer_orders
-- GROUP BY customer_id, customer_name;


PROMPT ============================================================
PROMPT Step 14: Sample data
PROMPT ============================================================

-- Customers via the standalone procedure
BEGIN
    demo_load_customers(5);
END;
/

-- Products
INSERT INTO demo_products (product_name, unit_price) VALUES ('Laptop', 1299.99);
INSERT INTO demo_products (product_name, unit_price) VALUES ('Mouse', 29.99);
INSERT INTO demo_products (product_name, unit_price) VALUES ('Keyboard', 89.99);
INSERT INTO demo_products (product_name, unit_price) VALUES ('Monitor', 349.50);
COMMIT;

-- Orders using the package
DECLARE
    v_order_id NUMBER;
BEGIN
    demo_order_pkg.create_order(1, TO_DATE('2026-01-15', 'YYYY-MM-DD'), v_order_id);
    INSERT INTO demo_order_items (order_id, product_id, quantity, line_amount)
    VALUES (v_order_id, 1, 1, 1299.99);

    demo_order_pkg.create_order(2, TO_DATE('2026-02-20', 'YYYY-MM-DD'), v_order_id);
    INSERT INTO demo_order_items (order_id, product_id, quantity, line_amount)
    VALUES (v_order_id, 2, 2, 59.98);
    INSERT INTO demo_order_items (order_id, product_id, quantity, line_amount)
    VALUES (v_order_id, 3, 1, 89.99);

    demo_order_pkg.create_order(3, TO_DATE('2026-03-10', 'YYYY-MM-DD'), v_order_id);
    INSERT INTO demo_order_items (order_id, product_id, quantity, line_amount)
    VALUES (v_order_id, 4, 2, 699.00);

    COMMIT;
END;
/

-- Update order totals from line items
UPDATE demo_orders o
SET total_amount = (
    SELECT SUM(line_amount) FROM demo_order_items i WHERE i.order_id = o.order_id
);
COMMIT;

-- Partitioned table sample rows
INSERT INTO demo_orders_partitioned VALUES (TO_DATE('2026-01-10', 'YYYY-MM-DD'), 1, 1, 150.00);
INSERT INTO demo_orders_partitioned VALUES (TO_DATE('2026-02-15', 'YYYY-MM-DD'), 2, 2, 250.00);
INSERT INTO demo_orders_partitioned VALUES (TO_DATE('2026-03-20', 'YYYY-MM-DD'), 3, 3, 350.00);
INSERT INTO demo_orders_partitioned VALUES (TO_DATE('2026-04-25', 'YYYY-MM-DD'), 4, 1, 450.00);
COMMIT;

-- Demonstrate the object type and collection
DECLARE
    v_addresses demo_address_list;
BEGIN
    v_addresses := demo_address_list(
        demo_address_type('1 Main St', 'New York', '10001'),
        demo_address_type('2 Market St', 'San Francisco', '94103')
    );
    FOR i IN 1 .. v_addresses.COUNT LOOP
        DBMS_OUTPUT.PUT_LINE('Address ' || i || ': ' || v_addresses(i).to_string());
    END LOOP;
END;
/


PROMPT ============================================================
PROMPT Step 15: Verification queries
PROMPT ============================================================

-- Tables and comments
SELECT table_name, comments
FROM user_tab_comments
WHERE table_name IN (
    'DEMO_CUSTOMERS', 'DEMO_PRODUCTS', 'DEMO_ORDERS',
    'DEMO_ORDER_ITEMS', 'DEMO_ORDERS_PARTITIONED', 'DEMO_CUSTOMER_ORDERS'
)
ORDER BY table_name;

-- Partitioned table metadata
SELECT table_name, partitioning_type, partition_count, status
FROM user_part_tables
WHERE table_name = 'DEMO_ORDERS_PARTITIONED';

SELECT partition_name, partition_position, high_value
FROM user_tab_partitions
WHERE table_name = 'DEMO_ORDERS_PARTITIONED'
ORDER BY partition_position;

-- Indexes
SELECT index_name, table_name, index_type, partitioned, status
FROM user_indexes
WHERE table_name IN (
    'DEMO_CUSTOMERS', 'DEMO_ORDERS', 'DEMO_ORDERS_PARTITIONED'
)
ORDER BY table_name, index_name;

-- Constraints
SELECT constraint_name, table_name, constraint_type, status
FROM user_constraints
WHERE table_name IN (
    'DEMO_CUSTOMERS', 'DEMO_PRODUCTS', 'DEMO_ORDERS', 'DEMO_ORDER_ITEMS'
)
ORDER BY table_name, constraint_type, constraint_name;

-- Other object types
SELECT 'SEQUENCE'  AS object_class, sequence_name  AS object_name FROM user_sequences  WHERE sequence_name  = 'DEMO_ORDERS_SEQ'
UNION ALL
SELECT 'TRIGGER', trigger_name FROM user_triggers WHERE trigger_name = 'TRG_DEMO_ORDERS_BIR'
UNION ALL
SELECT 'TYPE', type_name FROM user_types WHERE type_name IN ('DEMO_ADDRESS_TYPE', 'DEMO_ADDRESS_LIST')
UNION ALL
SELECT 'FUNCTION', object_name FROM user_procedures WHERE object_name = 'DEMO_FORMAT_CURRENCY' AND object_type = 'FUNCTION'
UNION ALL
SELECT 'PROCEDURE', object_name FROM user_procedures WHERE object_name = 'DEMO_LOAD_CUSTOMERS' AND object_type = 'PROCEDURE'
UNION ALL
SELECT 'PACKAGE', object_name FROM user_objects WHERE object_name = 'DEMO_ORDER_PKG' AND object_type = 'PACKAGE'
UNION ALL
SELECT 'PACKAGE BODY', object_name FROM user_objects WHERE object_name = 'DEMO_ORDER_PKG' AND object_type = 'PACKAGE BODY'
UNION ALL
SELECT 'VIEW', view_name FROM user_views WHERE view_name = 'DEMO_CUSTOMER_ORDERS'
UNION ALL
SELECT 'SYNONYM', synonym_name FROM user_synonyms WHERE synonym_name = 'DEMO_ORDERS_SYN'
ORDER BY object_class, object_name;

-- Sample data checks
SELECT * FROM demo_customer_orders ORDER BY customer_id, order_id;
SELECT * FROM demo_orders_partitioned PARTITION (p_202602);
SELECT demo_order_pkg.get_customer_name(1) AS customer_name FROM DUAL;

PROMPT ============================================================
PROMPT Oracle demo schema created successfully.
PROMPT ============================================================
