-- Check for the 6.15.1


select chr(10) from dual; 


-- Check for the 6.15.2

SELECT TRUNC(SYSDATE) FROM DUAL; 


-- Check for the 6.15.3
select nvl(null,1) from dual;
select nvl(2,1) from dual; 



-- Check for the 6.15.4
select nvl2(null,1,2) from dual;
select nvl2(3,1,2) from dual;




-- Check for the 6.15.5
select translate('1234567','123' ,'abc') from dual ;





-- Check for the 6.15.6
create table t4(id int ,name varchar2(10));
create table t5(id int ,name varchar2(10));
insert into t4 values(1,'a');
insert into t4 values(2,'b');
insert into t4 values(3,'');
insert into t4 values(5,'');
insert into t5 values(5,'t5-c');
insert into t5 values(1,'t5-a');
insert into t5 values(2,'t5-b');
insert into t5 values(3,'t5-c');
insert into t5 values(4,'t5-d');
commit;


select * from t4;
select * from t5;



merge into t4
using (select * from t5) t5
on (t4.id=t5.id)
when matched then update set name=t5.name
when not matched then insert values(t5.id,t5.name);



select * from t4;
commit; 



-- Check for the 6.15.7


-- 创建测试数据；

CREATE TABLE DISTRICT
(
ID NUMBER(10) NOT NULL,
PARENT_ID NUMBER(10),
NAME VARCHAR2(255) NOT NULL
);
ALTER TABLE DISTRICT ADD 
CONSTRAINT DISTRICT_PK
PRIMARY KEY (ID);

ALTER TABLE DISTRICT ADD 
CONSTRAINT DISTRICT_R01 
FOREIGN KEY (PARENT_ID) 
REFERENCES DISTRICT (ID);

insert into DISTRICT (id, parent_id, name) values (1, null, '四川省');
insert into DISTRICT (id, parent_id, name) values (2, 1, '巴中市');
insert into DISTRICT (id, parent_id, name) values (3, 1, '达州市');
insert into DISTRICT (id, parent_id, name) values (4, 2, '巴州区');
insert into DISTRICT (id, parent_id, name) values (5, 2, '通江县');
insert into DISTRICT (id, parent_id, name) values (6, 2, '平昌县');
commit;

-- 使用start with connect by；
SELECT * FROM district START WITH NAME ='巴中市' CONNECT BY PRIOR ID=parent_id; 


-- Check for the 6.15.8

-- 创建测试数据;
drop table tyl;
drop table zdr;
create table tyl(id int,name varchar(20));


-- 向 tyl 表插入数据
INSERT INTO tyl
SELECT 
LEVEL,
'tyl' || LEVEL
FROM 
DUAL
CONNECT BY 
LEVEL <= 10000;



create table zdr as select * from tyl;

-- 使用with as;
with
a as (select * from tyl),
b as (select * from zdr)
select * from a,b where a.id = b.id; 





-- Check for the 6.15.9

with temp as( 
select 'China' nation ,'Guangzhou' city from dual union all 
select 'China' nation ,'Shanghai' city from dual union all 
select 'China' nation ,'Beijing' city from dual union all 
select 'USA' nation ,'New York' city from dual union all 
select 'USA' nation ,'Bostom' city from dual union all 
select 'Japan' nation ,'Tokyo' city from dual 
)
select nation,listagg(city,',') within GROUP (order by city) as Cities 
from temp 
group by nation; 



-- Check for the 6.15.10


create table adv_cz_insa_1 (c1 int, c2 varchar(10)); 
create table adv_cz_insa_2 (c3 int, c4 varchar (10)); 
create table adv_cz_insa(id int, name varchar (10));
insert into adv_cz_insa values(1,'aa'); 
insert into adv_cz_insa values(2,'bb'); 
insert into adv_cz_insa values(3,'cc');


--使用insert all;
insert all 
into adv_cz_insa_1 values (id,name)
into adv_cz_insa_2 values (id,name)
select * from adv_cz_insa;


commit;
select * from adv_cz_insa_1;
select * from adv_cz_insa_2; 





-- Check for the 6.15.11

create table t1(fname varchar(10),fmoney int);
create table t2(fname varchar(10),fmoney int);
insert into t1 values('A',20);
insert into t1 values('B',30);
insert into t2 values('C',10);
insert into t2 values('D',20);
insert into t2 values('A',100);
commit;
select * from t1 ;
select * from t2 ;


--使用exists;
select * from t1 where exists(select 1 from t2 where t2.fname = t1.fname);
update t1 set t1.fmoney = (select t2.fmoney from t2 where t2.fname = t1.fname) where exists(select 1 from t2 where t2.fname = t1.fname);
delete from t1 where exists(select 1 from t2 where t2.fname = t1.fname)






















































select to_char(sysdate,'YYYY-MM-DD HH24:Mi:ss'), as CurrentTime, 'POC Test 6.16' as "POC Test Case" from dual;

-- Check for the 6.16

-- 创建宽表;
CREATE TABLE wide_table_100 (
id NUMBER(10) PRIMARY KEY,
num_col_1 NUMBER(15, 2),
num_col_2 NUMBER(15, 2),
num_col_3 NUMBER(15, 2),
num_col_4 NUMBER(15, 2),
num_col_5 NUMBER(15, 2),
num_col_6 NUMBER(15, 2),
num_col_7 NUMBER(15, 2),
num_col_8 NUMBER(15, 2),
num_col_9 NUMBER(15, 2),
num_col_10 NUMBER(15, 2),
num_col_11 NUMBER(15, 2),
num_col_12 NUMBER(15, 2),
num_col_13 NUMBER(15, 2),
num_col_14 NUMBER(15, 2),
num_col_15 NUMBER(15, 2),
num_col_16 NUMBER(15, 2),
num_col_17 NUMBER(15, 2),
num_col_18 NUMBER(15, 2),
num_col_19 NUMBER(15, 2),
num_col_20 NUMBER(15, 2),
date_col_21 DATE,
date_col_22 DATE,
date_col_23 DATE,
date_col_24 DATE,
date_col_25 DATE,
date_col_26 DATE,
date_col_27 DATE,
date_col_28 DATE,
date_col_29 DATE,
date_col_30 DATE,
timestamp_col_31 TIMESTAMP(6),
timestamp_col_32 TIMESTAMP(6),
timestamp_col_33 TIMESTAMP(6),
timestamp_col_34 TIMESTAMP(6),
timestamp_col_35 TIMESTAMP(6),
timestamp_col_36 TIMESTAMP(6),
timestamp_col_37 TIMESTAMP(6),
timestamp_col_38 TIMESTAMP(6),
timestamp_col_39 TIMESTAMP(6),
timestamp_col_40 TIMESTAMP(6),
varchar2_short_col_41 VARCHAR2(50),
varchar2_short_col_42 VARCHAR2(50),
varchar2_short_col_43 VARCHAR2(50),
varchar2_short_col_44 VARCHAR2(50),
varchar2_short_col_45 VARCHAR2(50),
varchar2_short_col_46 VARCHAR2(50),
varchar2_short_col_47 VARCHAR2(50),
varchar2_short_col_48 VARCHAR2(50),
varchar2_short_col_49 VARCHAR2(50),
varchar2_short_col_50 VARCHAR2(50),
varchar2_short_col_51 VARCHAR2(50),
varchar2_short_col_52 VARCHAR2(50),
varchar2_short_col_53 VARCHAR2(50),
varchar2_short_col_54 VARCHAR2(50),
varchar2_short_col_55 VARCHAR2(50),
varchar2_short_col_56 VARCHAR2(50),
varchar2_short_col_57 VARCHAR2(50),
varchar2_short_col_58 VARCHAR2(50),
varchar2_short_col_59 VARCHAR2(50),
varchar2_short_col_60 VARCHAR2(50),
varchar2_long_col_61 VARCHAR2(200),
varchar2_long_col_62 VARCHAR2(200),
varchar2_long_col_63 VARCHAR2(200),
varchar2_long_col_64 VARCHAR2(200),
varchar2_long_col_65 VARCHAR2(200),
varchar2_long_col_66 VARCHAR2(200),
varchar2_long_col_67 VARCHAR2(200),
varchar2_long_col_68 VARCHAR2(200),
varchar2_long_col_69 VARCHAR2(200),
varchar2_long_col_70 VARCHAR2(200),
varchar2_long_col_71 VARCHAR2(200),
varchar2_long_col_72 VARCHAR2(200),
varchar2_long_col_73 VARCHAR2(200),
varchar2_long_col_74 VARCHAR2(200),
varchar2_long_col_75 VARCHAR2(200),
varchar2_long_col_76 VARCHAR2(200),
varchar2_long_col_77 VARCHAR2(200),
varchar2_long_col_78 VARCHAR2(200),
varchar2_long_col_79 VARCHAR2(200),
varchar2_long_col_80 VARCHAR2(200),
clob_col_81 CLOB,
clob_col_82 CLOB,
clob_col_83 CLOB,
clob_col_84 CLOB,
clob_col_85 CLOB,
clob_col_86 CLOB,
clob_col_87 CLOB,
clob_col_88 CLOB,
clob_col_89 CLOB,
clob_col_90 CLOB,
blob_col_91 BLOB,
blob_col_92 BLOB,
blob_col_93 BLOB,
blob_col_94 BLOB,
blob_col_95 BLOB,
blob_col_96 BLOB,
blob_col_97 BLOB,
blob_col_98 BLOB,
blob_col_99 BLOB,
blob_col_100 BLOB
);

-- 插入数据;
INSERT INTO wide_table_100 (
id,
num_col_1, num_col_2, num_col_3, num_col_4, num_col_5, num_col_6, num_col_7, num_col_8, num_col_9, num_col_10,
num_col_11, num_col_12, num_col_13, num_col_14, num_col_15, num_col_16, num_col_17, num_col_18, num_col_19, num_col_20,
date_col_21, date_col_22, date_col_23, date_col_24, date_col_25, date_col_26, date_col_27, date_col_28, date_col_29, date_col_30,
timestamp_col_31, timestamp_col_32, timestamp_col_33, timestamp_col_34, timestamp_col_35, timestamp_col_36, timestamp_col_37, timestamp_col_38, timestamp_col_39, timestamp_col_40,
varchar2_short_col_41, varchar2_short_col_42, varchar2_short_col_43, varchar2_short_col_44, varchar2_short_col_45, varchar2_short_col_46, varchar2_short_col_47, varchar2_short_col_48, varchar2_short_col_49, varchar2_short_col_50,
varchar2_short_col_51, varchar2_short_col_52, varchar2_short_col_53, varchar2_short_col_54, varchar2_short_col_55, varchar2_short_col_56, varchar2_short_col_57, varchar2_short_col_58, varchar2_short_col_59, varchar2_short_col_60,
varchar2_long_col_61, varchar2_long_col_62, varchar2_long_col_63, varchar2_long_col_64, varchar2_long_col_65, varchar2_long_col_66, varchar2_long_col_67, varchar2_long_col_68, varchar2_long_col_69, varchar2_long_col_70,
varchar2_long_col_71, varchar2_long_col_72, varchar2_long_col_73, varchar2_long_col_74, varchar2_long_col_75, varchar2_long_col_76, varchar2_long_col_77, varchar2_long_col_78, varchar2_long_col_79, varchar2_long_col_80,
clob_col_81, clob_col_82, clob_col_83, clob_col_84, clob_col_85, clob_col_86, clob_col_87, clob_col_88, clob_col_89, clob_col_90,
blob_col_91, blob_col_92, blob_col_93, blob_col_94, blob_col_95, blob_col_96, blob_col_97, blob_col_98, blob_col_99, blob_col_100
) VALUES (
1,
10.1, 10.2, 10.3, 10.4, 10.5, 10.6, 10.7, 10.8, 10.9, 11.0,
11.1, 11.2, 11.3, 11.4, 11.5, 11.6, 11.7, 11.8, 11.9, 12.0,
TO_DATE('2024-01-01', 'YYYY-MM-DD'), TO_DATE('2024-01-02', 'YYYY-MM-DD'), TO_DATE('2024-01-03', 'YYYY-MM-DD'), TO_DATE('2024-01-04', 'YYYY-MM-DD'), TO_DATE('2024-01-05', 'YYYY-MM-DD'),
TO_DATE('2024-01-06', 'YYYY-MM-DD'), TO_DATE('2024-01-07', 'YYYY-MM-DD'), TO_DATE('2024-01-08', 'YYYY-MM-DD'), TO_DATE('2024-01-09', 'YYYY-MM-DD'), TO_DATE('2024-01-10', 'YYYY-MM-DD'),
TO_TIMESTAMP('2024-01-01 10:00:00.123456', 'YYYY-MM-DD HH24:MI:SS.FF6'), TO_TIMESTAMP('2024-01-02 11:00:00.123456', 'YYYY-MM-DD HH24:MI:SS.FF6'), TO_TIMESTAMP('2024-01-03 12:00:00.123456', 'YYYY-MM-DD HH24:MI:SS.FF6'),
TO_TIMESTAMP('2024-01-04 13:00:00.123456', 'YYYY-MM-DD HH24:MI:SS.FF6'), TO_TIMESTAMP('2024-01-05 14:00:00.123456', 'YYYY-MM-DD HH24:MI:SS.FF6'), TO_TIMESTAMP('2024-01-06 15:00:00.123456', 'YYYY-MM-DD HH24:MI:SS.FF6'),
TO_TIMESTAMP('2024-01-07 16:00:00.123456', 'YYYY-MM-DD HH24:MI:SS.FF6'), TO_TIMESTAMP('2024-01-08 17:00:00.123456', 'YYYY-MM-DD HH24:MI:SS.FF6'), TO_TIMESTAMP('2024-01-09 18:00:00.123456', 'YYYY-MM-DD HH24:MI:SS.FF6'),
TO_TIMESTAMP('2024-01-10 19:00:00.123456', 'YYYY-MM-DD HH24:MI:SS.FF6'),
'Short 1', 'Short 2', 'Short 3', 'Short 4', 'Short 5', 'Short 6', 'Short 7', 'Short 8', 'Short 9', 'Short 10',
'Short 11', 'Short 12', 'Short 13', 'Short 14', 'Short 15', 'Short 16', 'Short 17', 'Short 18', 'Short 19', 'Short 20',
'This is a long string 1. This is a long string 1. This is a long string 1.',
'This is a long string 2. This is a long string 2. This is a long string 2.',
'This is a long string 3. This is a long string 3. This is a long string 3.',
'This is a long string 4. This is a long string 4. This is a long string 4.',
'This is a long string 5. This is a long string 5. This is a long string 5.',
'This is a long string 6. This is a long string 6. This is a long string 6.',
'This is a long string 7. This is a long string 7. This is a long string 7.',
'This is a long string 8. This is a long string 8. This is a long string 8.',
'This is a long string 9. This is a long string 9. This is a long string 9.',
'This is a long string 10. This is a long string 10. This is a long string 10.',
'This is a long string 11. This is a long string 11. This is a long string 11.',
'This is a long string 12. This is a long string 12. This is a long string 12.',
'This is a long string 13. This is a long string 13. This is a long string 13.',
'This is a long string 14. This is a long string 14. This is a long string 14.',
'This is a long string 15. This is a long string 15. This is a long string 15.',
'This is a long string 16. This is a long string 16. This is a long string 16.',
'This is a long string 17. This is a long string 17. This is a long string 17.',
'This is a long string 18. This is a long string 18. This is a long string 18.',
'This is a long string 19. This is a long string 19. This is a long string 19.',
'This is a long string 20. This is a long string 20. This is a long string 20.',
TO_CLOB('Large character object 1'), TO_CLOB('Large character object 2'), TO_CLOB('Large character object 3'), TO_CLOB('Large character object 4'), TO_CLOB('Large character object 5'),
TO_CLOB('Large character object 6'), TO_CLOB('Large character object 7'), TO_CLOB('Large character object 8'), TO_CLOB('Large character object 9'), TO_CLOB('Large character object 10'),
UTL_RAW.CAST_TO_RAW('Binary data 1'), UTL_RAW.CAST_TO_RAW('Binary data 2'), UTL_RAW.CAST_TO_RAW('Binary data 3'), UTL_RAW.CAST_TO_RAW('Binary data 4'), UTL_RAW.CAST_TO_RAW('Binary data 5'),
UTL_RAW.CAST_TO_RAW('Binary data 6'), UTL_RAW.CAST_TO_RAW('Binary data 7'), UTL_RAW.CAST_TO_RAW('Binary data 8'), UTL_RAW.CAST_TO_RAW('Binary data 9'), UTL_RAW.CAST_TO_RAW('Binary data 10')
);
Commit;




drop table wide_table_100 ;






select to_char(sysdate,'YYYY-MM-DD HH24:Mi:ss'), as CurrentTime, 'POC Test 6.17' as "POC Test Case" from dual;


-- Check for the 6.17
--初始化数据;
create table t(id int);
insert into t SELECT 
LEVEL
FROM 
DUAL
CONNECT BY 
LEVEL <= 20;
commit;

-- 分页查询1;
SELECT *
FROM (
SELECT t.*, ROWNUM rn
FROM (
SELECT *
FROM t
ORDER BY id
) t
WHERE ROWNUM <= 11
)
WHERE rn > 1;

-- 分页查询2;
select * from (select * from t order by id) where rownum<10; 


drop table t;





select to_char(sysdate,'YYYY-MM-DD HH24:Mi:ss'), as CurrentTime, 'POC Test 6.18' as "POC Test Case" from dual;


-- Check for the 6.18

-- 创建测试表;
create table t(id int,name varchar2(15)) partition by hash(id) partitions 36;


declare
v_rows NUMBER:=10000000;
BEGIN 
FOR i IN 1..v_rows LOOP INSERT INTO t VALUES(i, 'test'||i); 
if mod(i,10000)=0 then
commit;
end if;
END LOOP;
commit;
end;
/

set timing on
-- 未开启并行;
select/*+ parallel(1)*/ count(*) from t where id>1000000; 
--开启并行;
Select/*+ parallel(32)*/ count(*) from t where id>1000000; 


drop table t;







-- select to_char(sysdate,'YYYY-MM-DD HH24:Mi:ss'), as CurrentTime, 'POC Test 6.19' as "POC Test Case" from dual;

-- Check for the 6.19
--(Use HDFS to test ) 





select to_char(sysdate,'YYYY-MM-DD HH24:Mi:ss') as CurrentTime, 'POC Test 6.20.1' as "POC Test Case" from dual;
-- Check for the 6.20.1

--创建表 test_table1;
CREATE TABLE test_table1 (
id NUMBER PRIMARY KEY,
value VARCHAR2(100)
);

--创建表 test_table2;
CREATE TABLE test_table2 (
id NUMBER PRIMARY KEY,
info VARCHAR2(100)
);

--开启事务;
SET AUTOCOMMIT OFF;
SET SERVEROUTPUT ON;




--开始 PL/SQL 块
BEGIN
-- 向 test_table1 插入一条数据
INSERT INTO test_table1 (id, value) VALUES (1, 'Data for table 1');

-- 故意制造一个错误（除零错误）
DECLARE
num NUMBER := 1 / 0;
BEGIN
NULL;
END;

-- 向 test_table2 插入一条数据（这一步不会执行，因为前面已经出错）
INSERT INTO test_table2 (id, info) VALUES (1, 'Data for table 2');

-- 提交事务（由于前面出错，这一步不会执行）
COMMIT;
EXCEPTION
WHEN OTHERS THEN
-- 捕获异常并回滚事务
ROLLBACK;
DBMS_OUTPUT.PUT_LINE('事务已回滚，错误信息: ' || SQLERRM);
END;
/




-- 检查 test_table1 表中的数据;
SELECT * FROM test_table1;

-- 检查 test_table2 表中的数据;
SELECT * FROM test_table2; 




drop table test_table1;
drop table test_table2;






select to_char(sysdate,'YYYY-MM-DD HH24:Mi:ss'), as CurrentTime, 'POC Test 6.20.2' as "POC Test Case" from dual;


-- Check for the 6.20.2



-- 创建测试表并初始化数据;
CREATE TABLE accounts (
account_id NUMBER PRIMARY KEY,
account_name VARCHAR2(50),
balance NUMBER CHECK (balance >= 0)
);

-- 插入初始数据
INSERT INTO accounts (account_id, account_name, balance) VALUES (1, 'A', 1000);
INSERT INTO accounts (account_id, account_name, balance) VALUES (2, 'B', 500);
COMMIT;

-- 正常提交事务测试;
-- 开启事务（Oracle默认自动提交关闭，需显式提交）
BEGIN
-- 从账户A扣款
UPDATE accounts SET balance = balance - 100 WHERE account_id = 1;
-- 向账户B加款
UPDATE accounts SET balance = balance + 100 WHERE account_id = 2;
-- 提交事务
COMMIT;
END;
/
-- 验证结果
SELECT * FROM accounts;
--预期结果：
--账户A余额 = 900
--账户B余额 = 600
--数据一致性保持（总金额 1500 不变）。



--事务回滚测试（模拟失败场景）;
-- 开启事务
BEGIN
-- 从账户A扣款
UPDATE accounts SET balance = balance - 100 WHERE account_id = 1;
-- 人为制造错误（触发回滚）
RAISE ZERO_DIVIDE; -- 抛出除以零异常
-- 向账户B加款（不会执行）
UPDATE accounts SET balance = balance + 100 WHERE account_id = 2;
EXCEPTION
WHEN OTHERS THEN
ROLLBACK; -- 显式回滚
DBMS_OUTPUT.PUT_LINE('事务回滚：' || SQLERRM);
END;
/

-- 验证数据未变化
SELECT * FROM accounts;
--预期结果：
--账户A和B的余额不变。
--事务完全回滚，无部分更新



-- 并发事务冲突测试;
-- 开启事务并更新账户
--会话1事务A
UPDATE accounts SET balance = balance - 200 WHERE account_id = 1;
-- 不提交，保持锁
--会话2事务B
-- 尝试更新同一条记录（会等待锁释放）
UPDATE accounts SET balance = balance + 200 WHERE account_id = 1;
--预期结果：
--事务B因事务A未提交而等待，直到事务A提交或回滚。
--验证Oracle的 行级锁 机制，避免脏写。

-- 约束一致性测试；
-- 尝试使余额为负数（应触发回滚）
BEGIN
UPDATE accounts SET balance = balance - 2000 WHERE account_id = 1;
COMMIT;
EXCEPTION
WHEN OTHERS THEN
ROLLBACK;
DBMS_OUTPUT.PUT_LINE('违反约束：余额不能为负');
END;
/

-- 验证余额未变化
SELECT * FROM accounts;

--预期结果：
--违反 CHECK 约束，事务自动回滚。
--账户A余额保持不变




drop table accounts






select to_char(sysdate,'YYYY-MM-DD HH24:Mi:ss'), as CurrentTime, 'POC Test 6.20.3' as "POC Test Case" from dual;



-- Check for the 6.20.3

-- 初始化数据；
CREATE TABLE employees (
emp_id NUMBER PRIMARY KEY,
emp_name VARCHAR2(50),
salary NUMBER
);

-- 插入初始数据
INSERT INTO employees (emp_id, emp_name, salary) VALUES (1, 'Alice', 5000);
INSERT INTO employees (emp_id, emp_name, salary) VALUES (2, 'Bob', 6000);
COMMIT;

--场景1：脏读测试
--会话1
BEGIN
-- 更新数据但不提交
UPDATE employees SET salary = 7000 WHERE emp_id = 1;
-- 保持事务未提交
--会话2
-- 尝试读取未提交的数据
SELECT salary FROM employees WHERE emp_id = 1;


--场景2：不可重复读测试
--会话1
-- 开启事务
DECLARE
num NUMBER ;
num2 NUMBER ;
BEGIN
SELECT salary into num FROM employees WHERE emp_id = 1;
DBMS_OUTPUT.PUT_LINE(num);
-- 等待会话2提交
DBMS_LOCK.SLEEP(10); -- 模拟等待
SELECT salary into num2 FROM employees WHERE emp_id = 1; 
DBMS_OUTPUT.PUT_LINE(num2);
END;
/
--会话2
-- 在会话1第一次读取后更新并提交
BEGIN
UPDATE employees SET salary = 8000 WHERE emp_id = 1;
COMMIT;
END;
/

--场景3：幻读测试
--会话1
-- 设置隔离级别为SERIALIZABLE
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

DECLARE
num NUMBER ;
num2 NUMBER ;
BEGIN
-- 第一次查询（范围：工资>5000）
SELECT COUNT(*) into num FROM employees WHERE salary > 5000; -- 结果为1（Bob:6000）
DBMS_OUTPUT.PUT_LINE(num);
-- 等待会话2插入新数据并提交
DBMS_LOCK.SLEEP(10);
-- 第二次查询
SELECT COUNT(*) into num2 FROM employees WHERE salary > 5000; -- 结果仍为1（防止幻读）
DBMS_OUTPUT.PUT_LINE(num2);
END;
/


--会话2
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
-- 插入新数据并提交
BEGIN
INSERT INTO employees (emp_id, emp_name, salary) VALUES (3, 'Charlie', 7000);
COMMIT;
END;
/ 




drop table employees;















select to_char(sysdate,'YYYY-MM-DD HH24:Mi:ss'), as CurrentTime, 'POC Test 6.20.4' as "POC Test Case" from dual;



-- Check for the 6.20.4

-- 创建测试表;
CREATE TABLE durable_test (
id NUMBER PRIMARY KEY,
data VARCHAR2(100)
);

-- 插入初始数据;
INSERT INTO durable_test (id, data) VALUES (1, 'Initial Data');
COMMIT;

-- 场景1
--开启事务并提交
BEGIN
INSERT INTO durable_test (id, data) VALUES (2, 'Committed Data');
COMMIT; -- 提交事务
END;
/

-- 场景2
--开启事务但不提交
BEGIN
INSERT INTO durable_test (id, data) VALUES (3, 'Uncommitted Data');
-- 不执行COMMIT，直接模拟崩溃
END;
/

-- 场景3
--崩溃后查询数据
-- 模拟数据库崩溃（SHUTDOWN ABORT）
SELECT * FROM durable_test WHERE id = 3;




drop table durable_test; 































select to_char(sysdate,'YYYY-MM-DD HH24:Mi:ss'), as CurrentTime, 'POC Test 6.20.5' as "POC Test Case" from dual;

-- Check for the 6.20.5

CREATE TABLE t_test (
id number NOT NULL PRIMARY KEY,
name varchar2(255)
);
INSERT INTO t_test VALUES (1, 'John');
commit;

-- 1.read committed；
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
--会话1
--# 更新表中id=1的数据
UPDATE t_test SET name='Tom' WHERE id=1;
--# 确认上面的UPDATE语句执行成功
SELECT * FROM t_test WHERE id=1;

--会话2
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
# 读取不到未提交的数据
SELECT * FROM t_test WHERE id=1;

--会话1
commit;

--会话2
-- #读取到已提交的数据
SELECT * FROM t_test WHERE id=1;

-- 2.Repeatable read；
--会话1
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
UPDATE t_test SET name='JACK' WHERE id=1;
SELECT * FROM t_test WHERE id=1;

--会话2
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
-- # 读出来的数据是TOM
SELECT * FROM t_test WHERE id=1;

--会话1
COMMIT;

--会话2
-- # 读出来的数据还是TOM
SELECT * FROM t_test WHERE id=1;




Drop table t_test;




















-- Check for the 6.20.6


--<??>



select to_char(sysdate,'YYYY-MM-DD HH24:Mi:ss'), as CurrentTime, 'POC Test 6.21' as "POC Test Case" from dual;

-- Check for the 6.21


-- 测试生僻字龘（da）
-- 创建测试表
create table test1 (ID varchar2(20),name varchar2(50));
--向test1中插入生僻字
--insert into test1 values(1,'龘');
-- 查询生test1表中的生僻字
select * from test1;

drop table test1;




