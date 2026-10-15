-- POC test 6.2.1

select to_char(sysdate,'YYYY-MM-DD HH24:Mi:ss') as CurrentTime, 'POC Test 6.2.1' as "POC Test Case" from dual;

create table t1 (id number,name varchar2(20));
drop table t1;
-- 3.增删视图;
create table t2 (id number,name varchar2(20));
create table t3 (id number,name varchar2(20));
create or replace view v1 as select * from t2 union all select * from t3;
drop view v1;

-- 4.增删触发器;
create table t4 (id number,name varchar2(20));
create table t5(id number,name varchar2(20));
create or replace trigger tri_test
after insert
on t5
for each row
begin
insert into t4(id) values (:new.id);
end;
/
insert into t5(id) values(99);
commit;
drop triger tri_test;

-- 5.增删存储过程;
create table t6(id number,name varchar2(20));
create or replace procedure pro_test as
begin 
insert into t6 values(1,'TEST1');
commit; 
end;
/
drop procedure pro_test;


-- 6.增删索引;
create table t7(id number,name varchar2(20));
create index idx_t7_id on t6(id);
drop index idx_t7_id;


-- 7.增删序列;
create sequence seq_test
increment by 1
start with 1;
drop sequence seq_test; 






-- 6.2.2
select to_char(sysdate,'YYYY-MM-DD HH24:Mi:ss') as CurrentTime, 'POC Test 6.2.2' as "POC Test Case" from dual;



-- 创建测试表;
create table t(id int,dept varchar2(255));
insert into t values(1,'abc');
commit;
select * from tt;

-- 2.修改表名;
alter table t rename to tt;

-- 3.添加字段;
alter table tt add name varchar(10);

-- 4.修改字段;
alter table tt modify name varchar2(20);

-- 5.删除字段;
alter table tt drop column name;

-- 6.修改字段默认值;
alter table tt modify pid default 0;

-- 7.修改字段不为空;
alter table tt modify pid not null;




-- 6.2.3
select to_char(sysdate,'YYYY-MM-DD HH24:Mi:ss') as CurrentTime, 'POC Test 6.2.3' as "POC Test Case" from dual;

-- .初始化数据;

-- DROP TABLE tyl; 
-- DROP TABLE zdr;
CREATE TABLE tyl(id NUMBER, name VARCHAR2(20)); 
BEGIN 
FOR i IN 1..100 LOOP INSERT INTO tyl VALUES(i, 'tyl'||i); 
END LOOP;
commit;
END; 
/ 

2.使用CTAS;
CREATE TABLE zdr AS SELECT * FROM tyl; 
SELECT * FROM tyl;
SELECT * FROM zdr; 

DROP TABLE tyl; 
DROP TABLE zdr;



-- 6.2.4
select to_char(sysdate,'YYYY-MM-DD HH24:Mi:ss') as CurrentTime, 'POC Test 6.2.4' as "POC Test Case" from dual;



CREATE TABLE test_insert;(id NUMBER, name VARCHAR2(20)); 
BEGIN 
FOR i IN 1..100 LOOP INSERT INTO test_insert VALUES(i, 'tyl'||i); 
END LOOP;
commit;
END; 
/ 

-- 1.trunacate表;
truncate table test_insert;
select * from test_insert;

-- 2.rename表;
alter table test_insert rename to test_insertm;
select * from test_insertm; 




-- 6.2.5
select to_char(sysdate,'YYYY-MM-DD HH24:Mi:ss') as CurrentTime, 'POC Test 6.2.5' as "POC Test Case" from dual;

--ODC 













-- 6.3.1.1
select to_char(sysdate,'YYYY-MM-DD HH24:Mi:ss') as CurrentTime, 'POC Test 6.3.1.1' as "POC Test Case" from dual;

-- 1.创建表;
CREATE TABLE reason
(
r_reason_sk integer,
r_reason_id varchar2(16),
r_reason_desc varchar2(100)
);
CREATE TABLE reason_t2
(
r_reason_sk integer,
r_reason_id varchar2(16),
r_reason_desc varchar2(100)
);

-- 2.向表中插入多条记录;
INSERT INTO reason VALUES (3, 'AAAAAAAACAAAAAAA','reason3');
INSERT INTO reason VALUES (4, 'AAAAAAAADAAAAAAA', 'reason4');
INSERT INTO reason VALUES (5, 'AAAAAAAAEAAAAAAA','reason5');
commit;

-- 3.向表reason_t2中插入表reason中r_reason_sk小于5的记录;
INSERT INTO reason_t2 SELECT * FROM reason WHERE r_reason_sk <5;
select * from reason_t2;
commit; 




-- 6.3.1.2
select to_char(sysdate,'YYYY-MM-DD HH24:Mi:ss') as CurrentTime, 'POC Test 6.3.1.2' as "POC Test Case" from dual;


create table test_insert (id int , c1 varchar2(20) );
insert into test_insert values(1,'abc');
commit;
select * from test_insert;




-- 6.3.2.1
select to_char(sysdate,'YYYY-MM-DD HH24:Mi:ss') as CurrentTime, 'POC Test 6.3.2.1' as "POC Test Case" from dual;

1.初始化数据;
CREATE TABLE t2 (id NUMBER, name VARCHAR2(50));
CREATE TABLE t3 (id NUMBER, name VARCHAR2(50));
BEGIN
FOR i IN 1..10 LOOP
INSERT INTO t2 VALUES(i, DBMS_CRYPTO.HASH(src=>utl_i18n.string_to_raw(i,'AL32UTF8'),typ=>dbms_crypto.hash_md5));
END LOOP;
END;
/
BEGIN
FOR i IN 1..20 LOOP
INSERT INTO t3 VALUES(i, DBMS_CRYPTO.HASH(src=>utl_i18n.string_to_raw(i,'AL32UTF8'),typ=>dbms_crypto.hash_md5));
END LOOP;
END;
/
CREATE TABLE SALGRADE (GRADE NUMBER, LOSAL NUMBER, HISAL NUMBER);
INSERT INTO salgrade VALUES (1,700,1200);
INSERT INTO salgrade VALUES (2,1201,1400);
INSERT INTO salgrade VALUES (3,1401,2000);
INSERT INTO salgrade VALUES (4,2001,3000);
INSERT INTO salgrade VALUES (5,3001,9999);
UPDATE t2 SET name = '' WHERE id = 9;
UPDATE t3 SET name = '' WHERE id = 10;
commit;

--2.inner join
SELECT * FROM t2 INNER JOIN t3 USING (id);

--3.left join
SELECT * FROM t2 LEFT JOIN t3 USING (id);
SELECT * FROM t2 LEFT OUTER JOIN t3 USING (id);

--4.right join
SELECT * FROM t2 RIGHT JOIN t3 USING (id);
SELECT * FROM t2 RIGHT OUTER JOIN t3 USING (id);

--5.full join
SELECT * FROM t2 FULL OUTER JOIN t3 USING (id); 




-- 6.3.2.2
select to_char(sysdate,'YYYY-MM-DD HH24:Mi:ss') as CurrentTime, 'POC Test 6.3.2.2' as "POC Test Case" from dual;



-- 1.创建EMP表;
create table EMP(
EMPNO numeric(4) not null,
ENAME varchar(10),
JOB varchar(9),
MGR numeric(4),
HIREDATE date,
SAL numeric(7 ),
COMM numeric(7 ),
DEPTNO numeric(2));

-- 2.插入测试数据;
insert into EMP (EMPNO, ENAME, JOB, MGR, HIREDATE, SAL, COMM, DEPTNO) values (7369, 'SMITH', 'CLERK', 7902, to_date('1980-12-17', 'YYYY-MM-DD'), 800, null, 20);
insert into EMP (EMPNO, ENAME, JOB, MGR, HIREDATE, SAL, COMM, DEPTNO) values (7499, 'ALLEN', 'SALESMAN', 7698, to_date('1981-02-20', 'YYYY-MM-DD'), 1600, 300, 30);
insert into EMP (EMPNO, ENAME, JOB, MGR, HIREDATE, SAL, COMM, DEPTNO) values (7521, 'WARD', 'SALESMAN', 7698, to_date('1981-02-22', 'YYYY-MM-DD'), 1250, 500, 30);
insert into EMP (EMPNO, ENAME, JOB, MGR, HIREDATE, SAL, COMM, DEPTNO) values (7566, 'JONES', 'MANAGER', 7839, to_date('1981-04-02', 'YYYY-MM-DD'), 2975, null, 20);
insert into EMP (EMPNO, ENAME, JOB, MGR, HIREDATE, SAL, COMM, DEPTNO) values (7654, 'MARTIN', 'SALESMAN', 7698, to_date('1981-09-28', 'YYYY-MM-DD'), 1250, 1400, 30);
insert into EMP (EMPNO, ENAME, JOB, MGR, HIREDATE, SAL, COMM, DEPTNO) values (7698, 'BLAKE', 'MANAGER', 7839, to_date('1981-05-01', 'YYYY-MM-DD'), 2850, null, 30);
insert into EMP (EMPNO, ENAME, JOB, MGR, HIREDATE, SAL, COMM, DEPTNO) values (7782, 'CLARK', 'MANAGER', 7839, to_date('1981-06-09', 'YYYY-MM-DD'), 2450, null, 10);
insert into EMP (EMPNO, ENAME, JOB, MGR, HIREDATE, SAL, COMM, DEPTNO) values(7788, 'SCOTT', 'ANALYST', 7566, to_date('1987-04-19', 'YYYY-MM-DD'), 3000, null, 20);
commit;
select * from emp;

-- 3.创建DEPT表;
CREATE TABLE DEPT
( DEPTNO NUMERIC, 
DNAME VARCHAR(10), 
LOC VARCHAR(13)
) ;
4.插入测试数据;
insert into dept values(10,'ACCOUNTING','NEW YORK');
insert into dept values(20,'RESEARCH','DALLAS');
insert into dept values(30,'SALES','CHICAGO');
insert into dept values(40,'OPERATIONS','BOSTON');
commit;
select * from dept;

-- 测试1：count…group by，分组统计人数;
select count(deptno), deptno from emp group by deptno order by deptno asc; 

-- 测试2：avg…group by，求出各个部门的平均工资;
select avg(sal) salavg, deptno from emp group by deptno;

-- 测试3：group by…having，查询人数大于2的部门,having分组条件查询不能使用别名;
select count(*), d.deptno,d.dname, d.loc from emp e, dept d where e.deptno=d.deptno group by d.deptno, d.dname,d.loc having count(*)>2; 







-- 6.3.2.3
select to_char(sysdate,'YYYY-MM-DD HH24:Mi:ss') as CurrentTime, 'POC Test 6.3.2.3' as "POC Test Case" from dual;

-- 1.创建dt表;
create table dt(id int);
-- 2.插入测试数据;
insert into dt(id) values (1);
insert into dt(id) values (1);
insert into dt(id) values (2);
insert into dt(id) values (2);
insert into dt(id) values (3);
commit;
select * from dt;
-- 3.去重查询;
select distinct(id) from dt; 


-- 6.3.2.4
select to_char(sysdate,'YYYY-MM-DD HH24:Mi:ss') as CurrentTime, 'POC Test 6.3.2.4' as "POC Test Case" from dual;

-- 1.创建dt表;
create table dt(id int); 
-- 2.插入测试数据;
insert into dt(id) values (3);
insert into dt(id) values (6);
insert into dt(id) values (1);
insert into dt(id) values (2);
insert into dt(id) values (9);
commit;
-- 3.排序;
select * from dt order by id desc;
select * from dt order by id asc; 



-- 6.3.2.5
select to_char(sysdate,'YYYY-MM-DD HH24:Mi:ss') as CurrentTime, 'POC Test 6.3.2.5' as "POC Test Case" from dual;




-- 1.创建dt表;
create table dt(id int); 
-- 2.插入测试数据;
insert into dt(id) values (3);
insert into dt(id) values (6);
insert into dt(id) values (1);
insert into dt(id) values (2);
insert into dt(id) values (9);
commit;
-- 3.select限制返回条数;
select * from dt where rownum<2;






-- 6.3.2.6
select to_char(sysdate,'YYYY-MM-DD HH24:Mi:ss') as CurrentTime, 'POC Test 6.3.2.6' as "POC Test Case" from dual;

-- 1.创建测试表，插入数据;
create table dt(id int); 
insert into dt(id) values (3);
insert into dt(id) values (6);
insert into dt(id) values (1);
insert into dt(id) values (2);
insert into dt(id) values (9);
commit;
select * from (select id from dt) ;

create table product( product_id int, product_name varchar(24), sale_price int);
insert into product(product_id,product_name,sale_price) values(100,'p1',999);
insert into product(product_id,product_name,sale_price) values(101,'p1',199);
insert into product(product_id,product_name,sale_price) values(102,'p1',299);
insert into product(product_id,product_name,sale_price) values(103,'p1',399);
commit;

-- 2.子查询：select ... from(select ... from...) ;
select * from product;
SELECT
product_id,
product_name,
sale_price
FROM
Product
WHERE
sale_price > (
SELECT
AVG(sale_price)
FROM
Product
); 



-- 6.3.2.7
select to_char(sysdate,'YYYY-MM-DD HH24:Mi:ss') as CurrentTime, 'POC Test 6.3.2.7' as "POC Test Case" from dual;

-- 1.创建测试表;
create table tyl(id int);
create table zdr(id int);
-- 2.插入测试数据;
insert into tyl(id) values(3);
insert into tyl(id) values(1);
insert into tyl(id) values(2);
insert into tyl(id) values(8);
insert into zdr(id) values(1);
insert into zdr(id) values(2);
commit;
-- 3.minus查询;
select * from tyl where id<=2
minus
select * from zdr where id<=1; 




-- 6.3.2.8
select to_char(sysdate,'YYYY-MM-DD HH24:Mi:ss') as CurrentTime, 'POC Test 6.3.2.7' as "POC Test Case" from dual;

-- 1.创建测试数据;
CREATE TABLE tyl(id NUMBER, name VARCHAR2(12));
INSERT INTO tyl(id,name) VALUES(4,'111');
commit;

-- 会话1
SELECT * FROM tyl where id = 4 FOR UPDATE;
-- 会话2
SELECT * FROM GV$OB_LOCKS;
-- 会话3
DELETE FROM tyl WHERE id = 4;
处于等待状态
--会话2
SELECT * FROM GV$OB_LOCKS;
多了一个锁
--会话1
commit;

--会话3
执行成功

--会话2
SELECT * FROM GV$OB_LOCKS;
-- 会话1 select for update的锁已经释放 


drop table tyl;



-- 6.3.2.9
select to_char(sysdate,'YYYY-MM-DD HH24:Mi:ss') as CurrentTime, 'POC Test 6.3.2.9' as "POC Test Case" from dual;



-- 1.创建测试数据;
-- drop table testtab3;
create table testtab3(id int,name varchar2(20));
insert into testtab3(id,name) values(1,'name');

-- 2.查询结果输出到文件;
Tee t.txt
select * from testtab3; 
Tee off


drop table testtab3;





-- 6.3.3.1
select to_char(sysdate,'YYYY-MM-DD HH24:Mi:ss') as CurrentTime, 'POC Test 6.3.3.1' as "POC Test Case" from dual;



-- 1.创建测试表;
create table t(id int); 
insert into t(id) values(1)
commit;
select * from t;
-- 2.update更新表
update t set id=2;
commit;
select * from t; 

drop table t;


-- 6.3.3.2
select to_char(sysdate,'YYYY-MM-DD HH24:Mi:ss') as CurrentTime, 'POC Test 6.3.3.2' as "POC Test Case" from dual;

-- 1.创建测试表;
create table ct(str clob);
-- 2.插入测试数据;
insert into ct(str) values('11111111111111aaaaaaMMMMMkkkkkk..,,#@$');
commit;
select * from ct;
-- 3.更新大字段;
update ct set str='321abc';
commit;
select * from ct; 

drop table ct;


-- 6.3.3.3
select to_char(sysdate,'YYYY-MM-DD HH24:Mi:ss') as CurrentTime, 'POC Test 6.3.3.3' as "POC Test Case" from dual;

1.创建测试表;

create table t1(id int);
create table t2(id int); 
2.插入测试数据;
insert into t1(id) values(11);
insert into t1(id) values(2);
insert into t1(id) values(3);
insert into t1(id) values(4);
insert into t2(id) values(11);
insert into t2(id) values(22);
insert into t2(id) values(33);
insert into t2(id) values(44);
commit;
3.update子查询;
update t1 set id=23 where id in (select id from t2 );
commit;
select * from t1; 


drop table t1;
drop table t2;



-- 6.3.4.1
select to_char(sysdate,'YYYY-MM-DD HH24:Mi:ss') as CurrentTime, 'POC Test 6.3.4.1' as "POC Test Case" from dual;


--1.创建测试表;

create table t2(id int); 
2.插入测试数据;
insert into t2(id) values(1);
insert into t2(id) values(2);
insert into t2(id) values(3);
insert into t2(id) values(4);
commit;
select * from t2;
3.删除数据;
delete from t2;
commit;
select * from t2; 


drop table t2;





-- 6.3.4.2
select to_char(sysdate,'YYYY-MM-DD HH24:Mi:ss') as CurrentTime, 'POC Test 6.3.4.2' as "POC Test Case" from dual;


CREATE TABLE CUST (
"C_W_ID" NUMBER(*,0) NOT NULL ENABLE,
"C_D_ID" NUMBER(*,0) NOT NULL ENABLE,
"C_ID" NUMBER(*,0) NOT NULL ENABLE,
"C_DISCOUNT" NUMBER(4,4),
"C_CREDIT" CHAR(2),
"C_LAST" VARCHAR2(16),
"C_FIRST" VARCHAR2(16),
"C_CREDIT_LIM" NUMBER(12,2),
"C_BALANCE" NUMBER(12,2),
"C_YTD_PAYMENT" NUMBER(12,2),
"C_PAYMENT_CNT" NUMBER(*,0),
"C_DELIVERY_CNT" NUMBER(*,0),
"C_STREET_1" VARCHAR2(20),
"C_STREET_2" VARCHAR2(20),
"C_CITY" VARCHAR2(20),
"C_STATE" CHAR(2),
"C_ZIP" CHAR(9),
"C_PHONE" CHAR(16),
"C_SINCE" TIMESTAMP(6),
"C_MIDDLE" CHAR(2),
"C_DATA" VARCHAR2(500)
) partition by hash("C_W_ID") partitions 128;
2.执行delete删除子查询动作;
delete from cust where id in(select C_W_ID from cust where C_W_ID>1);
3.执行回滚动作，并验证数据已回滚;
rollback;



drop table CUST;




-- 6.4
select to_char(sysdate,'YYYY-MM-DD HH24:Mi:ss') as CurrentTime, 'POC Test 6.4' as "POC Test Case" from dual;

create table utf8_test(id int,name varchar(20)) CHARSET = 'UTF8';
create table gbk_test(id int,name varchar(20)) CHARSET = 'GB18030';


drop table utf8_test;






-- 6.5
select to_char(sysdate,'YYYY-MM-DD HH24:Mi:ss') as CurrentTime, 'POC Test 6.5' as "POC Test Case" from dual;



-- 1.	创建范围分区表;
CREATE TABLE tab_range(
dept_no number,
part_no varchar2(20),
country varchar2(20),
dtime date,
amount number
)
PARTITION BY RANGE(dtime)(
PARTITION p202010 VALUES LESS THAN(TO_DATE('2020-11-01','YYYY-MM-DD')),
PARTITION p202011 VALUES LESS THAN(TO_DATE('2020-12-01','YYYY-MM-DD')),
PARTITION p202012 VALUES LESS THAN(TO_DATE('2021-01-01','YYYY-MM-DD')),
PARTITION p202101 VALUES LESS THAN(TO_DATE('2021-02-01','YYYY-MM-DD')),
PARTITION pmax VALUES LESS THAN(MAXVALUE)
);
-- 2.创建列表分区表;
CREATE TABLE tab_list(
dept_no number,
part_no varchar2(20),
country varchar2(20),
dtime date,
amount number
)
PARTITION BY LIST(country)(
PARTITION europe VALUES('FRANCE', 'ITALY'),
PARTITION asia VALUES('INDIA', 'PAKISTAN'),
PARTITION americas VALUES('US', 'CANADA')
);
-- 3.创建间隔分区表;
CREATE TABLE tab_interval
(
employee_id NUMBER,
employee_name VARCHAR2(20),
birthday DATE 
)
PARTITION BY RANGE(birthday)
INTERVAL (NUMTOYMINTERVAL(1,'year'))
(
PARTITION partition2014 VALUES LESS THAN(to_date('2015-01-01:00:00:00','yyyy-mm-dd hh24:mi:ss')),
PARTITION partition2015 VALUES LESS THAN(to_date('2016-01-01:00:00:00','yyyy-mm-dd hh24:mi:ss'))
);
-- 4.创建哈希分区表;
CREATE TABLE tab_hash(
dept_no number,
part_no varchar2(20),
country varchar2(20),
dtime date,
amount number
)PARTITION BY HASH(part_no)(
PARTITION p1,
PARTITION p2,
PARTITION p3
); 



drop table tab_hash;
drop table tab_interval;

drop table tab_list






-- 6.6
select to_char(sysdate,'YYYY-MM-DD HH24:Mi:ss') as CurrentTime, 'POC Test 6.6' as "POC Test Case" from dual;


-- 1.创建索引;
create table test_index(id int,age int, name varchar(10), sex varchar(10));
create index idx on test_index(id);
-- 2.修改索引;
alter index idx rename to idx1;
-- 3.创建普通表单字段索引;
create index idx2 on test_index(name);
-- 4.创建普通表多字段联合索引;
create index idx3 on test_index(id,name);
-- 5.普通表多字段联合索引在线创建;
drop index idx3;

--会话1：
insert into test_index values(1,15,’bob’,’man’);
--会话2
create index idx3 on test_index(id,name);
create index idx3 on test_index(id,name) online;
--会话1：
commit;
6.创建普通表唯一索引;
drop index idx3;
create unique index idx4 on test_index(id,name);
7创建.函数索引功能;
drop table test_index;
create table test_index(id int,age int, name varchar(10), sex varchar(10));
create index idx on test_index(upper(name));
8.创建反向索引;
create index rev_inx on test_index(age) reverse;
9.创建分区表单字段全局索引;
create index global_index on global_index_example (id) global;
10.创建分区表多字段全局索引;
create index global_index1 on global_index_example (id,name) global;
11. 创建分区表全局唯一索引;
drop index global_index;
drop index global_index1;
create unique index uni_global_index on global_index_example (id) global;
12.创建局部索引;
create index local_index on local_index_example (id, name) local;
13.创建hash索引;
create index idx_d on testtab3(id) global partition by hash(id) partitions 3;




drop table test_index;







-- 6.7
select to_char(sysdate,'YYYY-MM-DD HH24:Mi:ss') as CurrentTime, 'POC Test 6.7' as "POC Test Case" from dual;




-- 1.创建测试表;
CREATE TABLE all_data_types_table (
number_col NUMBER(10, 2), -- 高精度数值
binary_float_col BINARY_FLOAT, -- 32位浮点
binary_double_col BINARY_DOUBLE, -- 64位浮点
varchar2_col VARCHAR2(100), -- 可变长度字符串
char_col CHAR(10), -- 定长字符串
nchar_col NCHAR(10), -- Unicode定长字符串
nvarchar2_col NVARCHAR2(100), -- Unicode可变长度字符串
date_col DATE, -- 日期+时间（精度到秒）
timestamp_col TIMESTAMP(6), -- 时间戳（6位小数秒）
timestamp_tz_col TIMESTAMP(6) WITH TIME ZONE, -- 带时区的时间戳
interval_ym_col INTERVAL YEAR(3) TO MONTH, -- 年月间隔
interval_ds_col INTERVAL DAY(3) TO SECOND(6), -- 日秒间隔
clob_col CLOB, -- 字符大对象
blob_col BLOB, -- 二进制大对象
raw_col RAW(2000), -- 原始二进制数据
xmltype_col XMLTYPE -- XML数据
);

-- 2.插入测试数据;
INSERT INTO all_data_types_table (
number_col,
binary_float_col,
binary_double_col,
varchar2_col,
char_col,
nchar_col,
nvarchar2_col,
date_col,
timestamp_col,
timestamp_tz_col,
interval_ym_col,
interval_ds_col,
clob_col,
nclob_col,
blob_col,
bfile_col,
raw_col,
xmltype_col
) VALUES (
123.45,
TO_BINARY_FLOAT(123.456),
TO_BINARY_DOUBLE(123.456789),
'This is a varchar2 string',
'FixedLen ',
N'UnicodeFix',
N'UnicodeVarStr',
TO_DATE('2025-03-11 12:30:00', 'YYYY-MM-DD HH24:MI:SS'),
TO_TIMESTAMP('2025-03-11 12:30:00.123456', 'YYYY-MM-DD HH24:MI:SS.FF6'),
TO_TIMESTAMP_TZ('2025-03-11 12:30:00.123456 +08:00', 'YYYY-MM-DD HH24:MI:SS.FF6 TZH:TZM'),
INTERVAL '2-3' YEAR TO MONTH,
INTERVAL '1 12:30:00.123456' DAY TO SECOND,
TO_CLOB('This is a large character object'),
TO_NCLOB(N'Unicode large character object'),
UTL_RAW.CAST_TO_RAW('Binary data'),
BFILENAME('DATA_DIR', 'example_file.bin'),
UTL_RAW.CAST_TO_RAW('Raw binary data'),
XMLTYPE('<root><element>Sample XML</element></root>')
);
commit;



drop table all_data_types_table;






-- 6.8.1
select to_char(sysdate,'YYYY-MM-DD HH24:Mi:ss') as CurrentTime, 'POC Test 6.8.1' as "POC Test Case" from dual;




-- .创建测试表;
CREATE TABLE testtab1 (
id integer primary key,
name varchar2(255)
);
-- 2.插入测试数据;
insert into testtab1 values(null,'zhagnsan');
insert into testtab1 values(1,'lisi');
insert into testtab1 values(1,'wangwu');
insert into testtab1 values(2,'zhaoliu');
commit;

select * from testtab1; 

drop table testtab1;





-- 6.8.2
select to_char(sysdate,'YYYY-MM-DD HH24:Mi:ss') as CurrentTime, 'POC Test 6.8.2' as "POC Test Case" from dual;






-- 1.创建测试表;
CREATE TABLE products ( product_no integer PRIMARY KEY, name varchar2(100), price numeric );
CREATE TABLE orders ( order_id integer PRIMARY KEY, product_no integer REFERENCES products (product_no) on delete cascade, quantity integer );
-- 2.插入测试数据;
insert into products values(1,'bags',50);
insert into products values(2,'pencil',2);
insert into products values(3,'cholk',5);
insert into orders values(1,2,5);
insert into orders values(2,3,2);
insert into orders values(3,1,4);
insert into orders values(4,2,6);
commit;
select * from products;
select * from orders;
3.删除测试数据;
delete from products where product_no=2;
commit;
select * from products;
Select * from orders; 



drop table orders;
drop table products;




-- 6.8.3
select to_char(sysdate,'YYYY-MM-DD HH24:Mi:ss') as CurrentTime, 'POC Test 6.8.3' as "POC Test Case" from dual;

-- 1.创建父表;
CREATE TABLE BandMember (
MusicianId int NOT NULL,
BandId int NOT NULL,
CONSTRAINT PK_BandMember PRIMARY KEY (MusicianID, BandId)
);
-- 2.创建子表;
CREATE TABLE MembershipPeriod (
MembershipPeriodId int NOT NULL,
MusicianId int NOT NULL,
BandId int NOT NULL,
StartDate date NOT NULL,
EndDate date NULL,
CONSTRAINT PK_MembershipPeriod PRIMARY KEY (MembershipPeriodID),
CONSTRAINT FK_MembershipPeriod_BandMember FOREIGN KEY (MusicianID, BandId) REFERENCES BandMember(MusicianID, BandId)
);


drop table BandMember;
drop table MembershipPeriod;




-- 6.8.4
select to_char(sysdate,'YYYY-MM-DD HH24:Mi:ss') as CurrentTime, 'POC Test 6.8.4' as "POC Test Case" from dual;


CREATE TABLE testtab3(id integer );
alter table testtab3 add constraint con_testtab3_id unique(id);
select * from testtab3;
insert into testtab3 values(3);
insert into testtab3 values(3);
commit;
-- 2.禁用约束;
alter table testtab3 modify constraint con_testtab3_id disable;
insert into testtab3 values(3);
commit；
-- 3.启用约束，但是会失败，有重复值;
alter table testtab3 modify constraint con_testtab3_id enable;
-- 4.删除重复值，启用约束;

delete from testtab3 where id=3;
commit;
alter table testtab3 modify constraint con_testtab3_id enable;






-- 6.9.1
select to_char(sysdate,'YYYY-MM-DD HH24:Mi:ss') as CurrentTime, 'POC Test 6.9.1' as "POC Test Case" from dual;


-- 1.创建测试表并插入数据;
create table EMP(
EMPNO number not null,
ENAME varchar2(10),
JOB varchar2(9),
MGR number(4),
HIREDATE date,
SAL number(7 ),
COMM number(7 ),
DEPTNO number(2));
insert into EMP (EMPNO, ENAME, JOB, MGR, HIREDATE, SAL, COMM, DEPTNO) values (7369, 'SMITH', 'CLERK', 7902, to_date('1980-12-17', 'YYYY-MM-DD'), 800, null, 20);
insert into EMP (EMPNO, ENAME, JOB, MGR, HIREDATE, SAL, COMM, DEPTNO) values (7499, 'ALLEN', 'SALESMAN', 7698, to_date('1981-02-20', 'YYYY-MM-DD'), 1600, 300, 30);
insert into EMP (EMPNO, ENAME, JOB, MGR, HIREDATE, SAL, COMM, DEPTNO) values (7521, 'WARD', 'SALESMAN', 7698, to_date('1981-02-22', 'YYYY-MM-DD'), 1250, 500, 30);
insert into EMP (EMPNO, ENAME, JOB, MGR, HIREDATE, SAL, COMM, DEPTNO) values (7566, 'JONES', 'MANAGER', 7839, to_date('1981-04-02', 'YYYY-MM-DD'), 2975, null, 20);
insert into EMP (EMPNO, ENAME, JOB, MGR, HIREDATE, SAL, COMM, DEPTNO) values (7654, 'MARTIN', 'SALESMAN', 7698, to_date('1981-09-28', 'YYYY-MM-DD'), 1250, 1400, 30);
insert into EMP (EMPNO, ENAME, JOB, MGR, HIREDATE, SAL, COMM, DEPTNO) values (7698, 'BLAKE', 'MANAGER', 7839, to_date('1981-05-01', 'YYYY-MM-DD'), 2850, null, 30);
insert into EMP (EMPNO, ENAME, JOB, MGR, HIREDATE, SAL, COMM, DEPTNO) values (7782, 'CLARK', 'MANAGER', 7839, to_date('1981-06-09', 'YYYY-MM-DD'), 2450, null, 10);
insert into EMP (EMPNO, ENAME, JOB, MGR, HIREDATE, SAL, COMM, DEPTNO) values (7788, 'SCOTT', 'ANALYST', 7566, to_date('1987-04-19', 'YYYY-MM-DD'), 3000, null, 20);
commit;
select * from emp;
-- 2.计数、求和;
select count(deptno), sum(sal),deptno from emp group by deptno order by deptno asc; 
-- 3.求平均、最小值、最大值;
select avg(sal) salavg,min(sal) salmin,max(sal) salmax, deptno from emp group by deptno;
-- 4.标准差、方差;
select stddev(sal), variance(sal) from emp; 





-- 6.9.2
select to_char(sysdate,'YYYY-MM-DD HH24:Mi:ss') as CurrentTime, 'POC Test 6.9.2' as "POC Test Case" from dual;


select substr('abcd1234',1,2) from dual;
select instr('abcd1234',1,2) from dual;
select concat('ORACLE is ','good') from dual; 
select 'OCEANBASE'||' is '||'good' from dual;
select length('你好') from dual;
select lengthb('你好') from dual;
select lower('ABC') from dual;
select upper('aBc') from dual;
select ltrim('#abcdef','#') from dual;
select rtrim('abcdef#','#') from dual;
select trim('#' from '#abcdef#') from dual;
select replace('abababa','a','b') from dual;
select lpad('abc',5,'#') from dual;
select rpad('abc',5,'#') from dual;
select to_number('1') from dual;
select to_date('01-31-1999','MM-DD-YYYY') from dual;




-- 6.9.3
select to_char(sysdate,'YYYY-MM-DD HH24:Mi:ss') as CurrentTime, 'POC Test 6.9.3' as "POC Test Case" from dual;


select abs('-1') from dual;
select floor('3.14') from dual;
select mod(5,3) from dual;
select power(2,3) from dual;
select round(4.5) from dual;
select sign('-1') from dual;
select sqrt(4) from dual; 





-- 6.9.4
select to_char(sysdate,'YYYY-MM-DD HH24:Mi:ss') as CurrentTime, 'POC Test 6.9.4' as "POC Test Case" from dual;


select sysdate from dual;
select current_timestamp from dual;
select current_date from dual;
select to_date('01-31-1999','MM-DD-YYYY') from dual;
select add_months(sysdate,2) from dual;
select last_day(current_date) from dual;
select sysdate + interval '1' day from dual; 




-- 6.9.5
select to_char(sysdate,'YYYY-MM-DD HH24:Mi:ss') as CurrentTime, 'POC Test 6.9.5' as "POC Test Case" from dual;


select cast('1' as number)/cast('4' as number) from dual;
select to_char(sysdate) from dual;
select to_date('01-31-1999','MM-DD-YYYY') from dual;
select to_number('123') from dual;




-- 6.9.6
select to_char(sysdate,'YYYY-MM-DD HH24:Mi:ss') as CurrentTime, 'POC Test 6.9.6' as "POC Test Case" from dual;




-- 1.创建测试表;
create table EMP
(
empno NUMBER(4) not null,
ename VARCHAR2(10),
job VARCHAR2(9),
mgr NUMBER(4),
hiredate DATE,
sal NUMBER(7,2),
comm NUMBER(7,2),
deptno NUMBER(2)
);
alter table EMP add constraint PK_EMP primary key (EMPNO); 
insert into EMP (empno, ename, job, mgr, hiredate, sal, comm, deptno) values (7369, 'SMITH', 'CLERK', 7902, to_date('17-12-1980', 'dd-mm-yyyy'), 800, null, 20);
insert into EMP (empno, ename, job, mgr, hiredate, sal, comm, deptno) values (7499, 'ALLEN', 'SALESMAN', 7698, to_date('20-02-1981', 'dd-mm-yyyy'), 1600, 300, 30);
insert into EMP (empno, ename, job, mgr, hiredate, sal, comm, deptno) values (7521, 'WARD', 'SALESMAN', 7698, to_date('22-02-1981', 'dd-mm-yyyy'), 1250, 500, 30);
insert into EMP (empno, ename, job, mgr, hiredate, sal, comm, deptno) values (7566, 'JONES', 'MANAGER', 7839, to_date('02-04-1981', 'dd-mm-yyyy'), 2975, null, 20);
insert into EMP (empno, ename, job, mgr, hiredate, sal, comm, deptno) values (7654, 'MARTIN', 'SALESMAN', 7698, to_date('28-09-1981', 'dd-mm-yyyy'), 1250, 1400, 30);
insert into EMP (empno, ename, job, mgr, hiredate, sal, comm, deptno) values (7698, 'BLAKE', 'MANAGER', 7839, to_date('01-05-1981', 'dd-mm-yyyy'), 2850, null, 30);
commit;
-- 2.支持分析函数;
select empno,ename,job,hiredate,sal,deptno
from (select empno,ename,job,hiredate,sal,deptno,rank() over(partition by deptno order by sal desc) r from emp) where r = 1;
-- 3.支持开窗函数;
select empno,ename,job,hiredate,sal,deptno
from (select empno,ename,job,hiredate,sal,deptno,dense_rank() over(partition by deptno order by sal desc) r from emp) where r = 1;

drop table EMP;



-- 6.9.7
select to_char(sysdate,'YYYY-MM-DD HH24:Mi:ss') as CurrentTime, 'POC Test 6.9.7' as "POC Test Case" from dual;

CREATE OR REPLACE FUNCTION getItemName(pCodeNo IN varchar,pItemNo IN varchar)
RETURN varchar 
IS pItemName varchar(200);
BEGIN
pItemName :='';
SELECT ItemName INTO pItemName 
from CODE_LIBRARY 
WHERE CODENO = pCodeNo AND ITEMNO = pItemNo ;
IF pItemName IS NULL THEN
RETURN pItemNo; 
ELSE
RETURN pItemName;
end IF;
END;
-- 2.
CREATE OR REPLACE FUNCTION getorgname(pOrgID varchar)
return varchar
is pOrgName varchar(80);
begin
select OrgName into pOrgName
from Org_info
where Orgid = pOrgID;
return pOrgName;
end;
-- 3.
CREATE OR REPLACE FUNCTION getusername(pUserID varchar)
return varchar
is pUserName varchar(80);
begin
select UserName into pUserName from User_Info where userid = pUserID;
return pUserName;
end;
-- 4.
CREATE OR REPLACE FUNCTION getbusinessname(pJBusinessType IN varchar)
RETURN varchar
IS pBusinessTypeName varchar(80);
BEGIN
SELECT PRODUCTNAME INTO pBusinessTypeName
from PRD_CATALOG 
WHERE PRODUCTID = pJBusinessType;
RETURN pBusinessTypeName;
END; 


-- 6.10
select to_char(sysdate,'YYYY-MM-DD HH24:Mi:ss') as CurrentTime, 'POC Test 6.10' as "POC Test Case" from dual;




-- 1.创建测试表和数据;
CREATE TABLE at_tb2(id int, name varchar2(10));
INSERT INTO at_tb2 values(1,'before s1');
INSERT INTO at_tb2 values(2,'after s1');
commit;
select * from at_tb2; 
-- 2.创建存储过程;
CREATE OR REPLACE PROCEDURE test_pro
IS
sss at_tb2.name%TYPE;
BEGIN
SELECT name INTO sss FROM at_tb2 WHERE ROWNUM = 1;
DBMS_OUTPUT.PUT_LINE(sss);
END;
/
-- 3.执行存储过程;
SET SERVEROUTPUT ON;
EXEC test_pro (); 


drop procedure test_pro;

drop table at_tb2;




-- 6.11
select to_char(sysdate,'YYYY-MM-DD HH24:Mi:ss') as CurrentTime, 'POC Test 6.11' as "POC Test Case" from dual;


-- 创建测试表;
create table te1(id int);
create table te2(id int);
-- 2.插入型触发器;
create or replace trigger tri_insert_te2
before insert on te1
for each row
begin
insert into te2 (id) values (:new.id);
end;
/
insert into te1 values (1);
commit;
select * from te2;
-- 3.更新型触发器;
create or replace trigger tri_update_te2
before update on te1
for each row
begin
update te2 set id = :new.id;
end;
/
update te1 set id = 5;
commit;
select * from te2;
-- 4.删除型触发器;
create or replace trigger tri_delete_te2
before delete on te1
for each row
begin
delete from te2 where id = :old.id;
end;
/
delete from te1 where id = 5;
commit;
select * from te2;
-- 4.创建复合型触发器;
drop trigger tri_insert_te2;
drop trigger tri_update_te2;
drop trigger tri_delete_te2;
create or replace trigger tri_mixed_te2
after delete or insert or update on te1
for each row
begin
insert into te2 (id) values (:new.id);
end;
/
insert into te1(id) values (2);
select * from te2;
update te1 set id = 3 where id = 2;
select * from te2;
delete from te1 where id =3;
select * from te2;
select count(*) from te2; 


drop table te1;
drop table te2;




-- 6.12
select to_char(sysdate,'YYYY-MM-DD HH24:Mi:ss') as CurrentTime, 'POC Test 6.12' as "POC Test Case" from dual;

-- 1.创建测试表和数据;

CREATE TABLE test_view(id integer );
insert into test_view select 1 from dual;
commit;
-- 2.创建视图和物化视图;
CREATE VIEW view_test AS SELECT * FROM test_view;
CREATE MATERIALIZED VIEW mview_test AS SELECT * FROM test_view;
-- 3.查询视图和物化视图;
select * from view_test;
select * from mview_test;
-- 4.更新视图;
update view_test set id=2 where id=1;
commit;
-- 5.union视图;
select * from view_test union select 2 from dual;
select * from view_test union all select 2 from dual;
-- 6.删除视图;
drop view view_test;
drop MATERIALIZED view mview_test; 



-- 6.13
select to_char(sysdate,'YYYY-MM-DD HH24:Mi:ss') as CurrentTime, 'POC Test 6.13' as "POC Test Case" from dual;


-- 1.创建测试用户;
CREATE user ot identified by "1qaz@WSX"; 
grant dba to ot;
-- 2.创建表ot.t1及其同义词syn_t1; 
CREATE TABLE ot.t1(id int, name varchar2(10)); 
CREATE OR REPLACE SYNONYM syn_t1 FOR ot.t1; 
-- 3.使用同义词t1;
SELECT * FROM syn_t1; 
INSERT INTO syn_t1(id,name) VALUES (1,'ada');
INSERT INTO syn_t1(id,name) VALUES (2,'bob'); 
UPDATE syn_t1 SET syn_t1.name = 'cici' WHERE syn_t1.id = 2; 
commit;
-- 4.创建同义词v1及其关联视图ot.v_t1;
CREATE VIEW ot.v_t1 AS SELECT * FROM ot.t1;
CREATE or replace SYNONYM syn_v1 FOR ot.v_t1; 
-- 5.使用同义词v1;
SELECT * FROM syn_v1; 



-- 6.14
select to_char(sysdate,'YYYY-MM-DD HH24:Mi:ss') as CurrentTime, 'POC Test 6.14' as "POC Test Case" from dual;



-- 1.初始化测试数据;

CREATE TABLE EMP (
EMPNO NUMBER(4) NOT NULL,
ENAME VARCHAR2(10),
JOB VARCHAR2(9),
MGR NUMBER(4),
HIREDATE DATE,
SAL NUMBER(7),
COMM NUMBER(7),
DEPTNO NUMBER(2)
);
INSERT INTO EMP (EMPNO, ENAME, JOB, MGR, HIREDATE, SAL, COMM, DEPTNO)
VALUES (7369, 'SMITH', 'CLERK', 7902, TO_DATE('1980-12-17', 'YYYY-MM-DD'), 800, NULL, 20);
INSERT INTO EMP (EMPNO, ENAME, JOB, MGR, HIREDATE, SAL, COMM, DEPTNO)
VALUES (7499, 'ALLEN', 'SALESMAN', 7698, TO_DATE('1981-02-20', 'YYYY-MM-DD'), 1600, 300, 30);
COMMIT;
2.使用游标;
SET SERVEROUTPUT ON;
DECLARE
v_empno NUMBER(4);
v_ename VARCHAR2(10);
CURSOR emp_cur IS
SELECT empno, ename FROM emp ORDER BY empno;
BEGIN
OPEN emp_cur;
IF emp_cur%ISOPEN THEN
DBMS_OUTPUT.PUT_LINE('CURSOR OPEN');
END IF;
LOOP
FETCH emp_cur INTO v_empno, v_ename;
EXIT WHEN emp_cur%NOTFOUND;
IF emp_cur%FOUND THEN
DBMS_OUTPUT.PUT_LINE('FOUND');
DBMS_OUTPUT.PUT_LINE('rowcount : ' || emp_cur%ROWCOUNT);
END IF;
DBMS_OUTPUT.PUT_LINE(v_empno || ' ' || v_ename);
END LOOP;
CLOSE emp_cur;
END;
/ 



DROP TABLE emp;





