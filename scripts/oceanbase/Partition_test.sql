-- Oracle Tenant

-- Partition Testing


-- ====================================================================
-- Step 1: Cleanup Existing Objects
-- ====================================================================
BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE tb_orders PURGE';
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE != -942 THEN
         RAISE;
      END IF;
END;
/

-- ====================================================================
-- Step 2: Create Range-Partitioned Table
-- Note: OceanBase requires the partition key (order_date) to be the 
-- FIRST column in the primary key composite constraint.
-- ====================================================================
CREATE TABLE tb_orders (
    order_date   DATE,
    order_id     NUMBER,
    customer_id  NUMBER,
    total_amount NUMBER(12, 2),
    CONSTRAINT pk_tb_orders PRIMARY KEY (order_date, order_id)
)
PARTITION BY RANGE (order_date) (
    PARTITION p_202601 VALUES LESS THAN (TO_DATE('2026-02-01', 'YYYY-MM-DD')),
    PARTITION p_202602 VALUES LESS THAN (TO_DATE('2026-03-01', 'YYYY-MM-DD')),
    PARTITION p_max    VALUES LESS THAN (MAXVALUE)
);

-- ====================================================================
-- Step 3: Insert Initial Test Data
-- ====================================================================
INSERT INTO tb_orders VALUES (TO_DATE('2026-01-15', 'YYYY-MM-DD'), 1001, 101, 150.00);
INSERT INTO tb_orders VALUES (TO_DATE('2026-02-10', 'YYYY-MM-DD'), 1002, 102, 250.50);
INSERT INTO tb_orders VALUES (TO_DATE('2026-03-05', 'YYYY-MM-DD'), 1003, 101, 890.00);
INSERT INTO tb_orders VALUES (TO_DATE('2026-03-20', 'YYYY-MM-DD'), 1004, 103, 420.00);
COMMIT;

-- ====================================================================
-- Step 4: Create Global Partitioned Index
-- Creates a global index partitioned independently by customer_id (HASH)
-- ====================================================================
CREATE INDEX idx_orders_cust_id_global_part 
ON tb_orders(customer_id) GLOBAL
PARTITION BY HASH(customer_id) PARTITIONS 4;

-- ====================================================================
-- Step 5: Pre-Split Verification
-- Verify initial partitions and global index status
-- ====================================================================

-- 5A. Table Partition Boundaries
SELECT partition_name, partition_position, high_value
FROM user_tab_partitions
WHERE table_name = 'TB_ORDERS'
ORDER BY partition_position;

-- 5B. Global Index Metadata (Status & Locality)
SELECT index_name, index_type, partitioned, status
FROM user_indexes
WHERE table_name = 'TB_ORDERS';

SELECT index_name, locality, partitioning_type, partition_count
FROM user_part_indexes
WHERE table_name = 'TB_ORDERS';

-- ====================================================================
-- Step 6: Perform SPLIT PARTITION (OceanBase Syntax)
-- Splits p_max at 2026-04-01 into p_202603 and new p_max.
-- Note: 'UPDATE GLOBAL INDEXES' is omitted because OceanBase automatically 
-- maintains global indexes online.
-- ====================================================================
ALTER TABLE tb_orders 
SPLIT PARTITION p_max AT (TO_DATE('2026-04-01', 'YYYY-MM-DD')) 
INTO (
    PARTITION p_202603, 
    PARTITION p_max
);

-- ====================================================================
-- Step 7: Insert Data Post-Split
-- ====================================================================
INSERT INTO tb_orders VALUES (TO_DATE('2026-04-12', 'YYYY-MM-DD'), 1005, 104, 1200.00);
COMMIT;

-- ====================================================================
-- Step 8: Comprehensive Post-Split Verification
-- ====================================================================

-- 8A. Verify Data Row Distribution Per Partition
SELECT 'p_202601' AS partition_name, order_id, TO_CHAR(order_date, 'YYYY-MM-DD') AS order_date, customer_id 
  FROM tb_orders PARTITION (p_202601)
UNION ALL
SELECT 'p_202602' AS partition_name, order_id, TO_CHAR(order_date, 'YYYY-MM-DD') AS order_date, customer_id 
  FROM tb_orders PARTITION (p_202602)
UNION ALL
SELECT 'p_202603' AS partition_name, order_id, TO_CHAR(order_date, 'YYYY-MM-DD') AS order_date, customer_id 
  FROM tb_orders PARTITION (p_202603)
UNION ALL
SELECT 'p_max'    AS partition_name, order_id, TO_CHAR(order_date, 'YYYY-MM-DD') AS order_date, customer_id 
  FROM tb_orders PARTITION (p_max);

-- 8B. Verify Global Index Status Remains 'VALID' (Without REBUILD)
SELECT index_name, index_type, partitioned, status
FROM user_indexes
WHERE table_name = 'TB_ORDERS';

-- 8C. Verify Global Index Partitions
SELECT index_name, partition_name, partition_position, status
FROM user_ind_partitions
WHERE index_name = 'IDX_ORDERS_CUST_ID_GLOBAL_PART'
ORDER BY partition_position;









--- Rebuild index if need (drop and create)

-- 1. Drop the existing global index
DROP INDEX idx_orders_cust_id_global_part;

-- 2. Re-create the global index
CREATE INDEX idx_orders_cust_id_global_part 
ON tb_orders(customer_id) GLOBAL
PARTITION BY HASH(customer_id) PARTITIONS 4;
