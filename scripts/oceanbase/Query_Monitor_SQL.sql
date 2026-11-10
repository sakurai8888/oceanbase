-- In Oracle mode

/*

Use the following Views

sys.gv$ob_plan_cache_plan_stat
sys.gv$ob_sql_audit
sys.gv$ob_plan_monitor
sys.gv$ob_plan_cache_plan_explain

*/






-- Seach by query text. 
select * from sys.gv$ob_sql_audit where query_sql like '%from tb_empdemo01%'
and user_name = 'ORA_USER01'

select * from sys.gv$ob_sql_audit where query_sql like '%select count(*) from BMSQL_CUSTOMER%'
and user_name = 'ORA_USER01'



-- Search by sql_id
select * from sys.gv$ob_sql_audit
where SQL_ID = '232DA805EB168041CD9BAF168109F385'



-- Group by Query Text

select
  SQL_ID,
  count(sql_id) as Number_Execution,
  sum(ELAPSED_TIME/1000/1000) as "Total_Elapsed_Time(s)",
  avg(ELAPSED_TIME/1000/1000) as "AVG_Elapsed_Time(s)",
  sum(DISK_READS) as Total_Disk_Read
from
  sys.gv$ob_sql_audit
where
  SQL_ID = '232DA805EB168041CD9BAF168109F385'
group by SQL_ID



SELECT * FROM sys.gv$sql_plan_monitor;

select * from sys.gv$ob_plan_cache_plan_stat

--   Unified Single-Query Correlation


SELECT 
    a.request_time,
    a.sql_id,
    a.plan_id,
    a.trace_id,
    a.elapsed_time / 1000 AS total_elapsed_ms,
    p.hit_count AS cache_hits,
    p.avg_exe_time AS cache_avg_us,
    m.plan_line_id,
    m.operator,
    m.output_rows,
    a.query_sql
FROM sys.gv$ob_sql_audit a
LEFT JOIN sys.gv$ob_plan_cache_plan_stat p 
       ON a.tenant_id = p.tenant_id 
      AND a.plan_id = p.plan_id
LEFT JOIN sys.gv$ob_sql_monitor m 
       ON a.trace_id = m.trace_id
WHERE a.query_sql LIKE '%from tb_empdemo01%'
  AND a.query_sql NOT LIKE '%gv$ob_sql_audit%'
ORDER BY a.request_time DESC, m.plan_line_id ASC;







-- Check Query Plan Using Explain plan


CREATE TABLE tb_empdemo01 (
    emp_id      NUMBER(10) PRIMARY KEY,
    dept_id     NUMBER(5) NOT NULL,
    emp_name    VARCHAR2(50),
    salary      NUMBER(10, 2),
    hire_date   DATE DEFAULT SYSDATE
);

-- 2. Create index
CREATE INDEX idx_tb_empdemo01_dept_sal ON tb_empdemo01(dept_id, salary);

-- 3. Insert sample rows
INSERT INTO tb_empdemo01 (emp_id, dept_id, emp_name, salary) VALUES (1001, 10, 'Alice', 9500);
INSERT INTO tb_empdemo01 (emp_id, dept_id, emp_name, salary) VALUES (1002, 10, 'Bob', 12000);
INSERT INTO tb_empdemo01 (emp_id, dept_id, emp_name, salary) VALUES (1003, 20, 'Charlie', 7000);
INSERT INTO tb_empdemo01 (emp_id, dept_id, emp_name, salary) VALUES (1004, 20, 'David', 15000);
COMMIT;

-- 4. Gather table statistics (Oracle package syntax)
BEGIN
  DBMS_STATS.GATHER_TABLE_STATS(
    ownname => USER,
    tabname => 'TB_EMPDEMO01'
  );
END;
/


select * from tb_empdemo01;

-- Get the Estimated Plan (Basic)

EXPLAIN SELECT emp_name, salary 
FROM tb_empdemo01 
WHERE dept_id = 10 AND salary > 9000;


-- Get the Estimated Plan (Extended) Show more information such as plan type , outline data etc...

EXPLAIN EXTENDED SELECT emp_name, salary 
FROM tb_empdemo01 
WHERE dept_id = 10 AND salary > 9000;



-- Get Estimated Plan with Outline Data.
EXPLAIN OUTLINE SELECT emp_name, salary 
FROM tb_empdemo01 
WHERE dept_id = 10 AND salary > 9000;




-- Run a query with hints comment 

SELECT /*+ ORACLE_MONITOR_DEMO_01 MONITOR */ emp_name, salary 
FROM tb_empdemo01 
WHERE dept_id = 10 AND salary > 9000;




SELECT  emp_name, salary 
FROM tb_empdemo01 
WHERE dept_id = 10 AND salary > 8000;




-- Check the SQL ID

SELECT sql_id, plan_id, trace_id, elapsed_time / 1000 AS total_elapsed_ms, query_sql
FROM sys.gv$ob_sql_audit
WHERE query_sql LIKE '%salary > 8000%'
  AND query_sql NOT LIKE '%gv$ob_sql_audit%'
ORDER BY request_time DESC;




-- Check the Plan ID 
SELECT *
FROM sys.gv$ob_plan_cache_plan_stat
WHERE sql_id = 'B0929DD67AF5B5C5F2DCCFDAF42E8EDA';


-- Check the PLan _ID 

SELECT SVR_IP, PLAN_ID, 
       DECODE(TYPE, 1, 'Local', 2, 'Remote', 3, 'Distributed', 'Unknown') AS PLAN_TYPE,
       a.*
FROM sys.gv$ob_plan_cache_plan_stat a
WHERE QUERY_SQL LIKE '%ORACLE_MONITOR_DEMO_01%';




-- Check the Plan using the plan id


select * from sys.gv$ob_plan_cache_plan_explain where plan_id = 611