# Diagnosing SQL with Performance Views in an Oracle Tenant

This document describes how to use the three key OceanBase 4.x performance
views for SQL diagnosis in an **Oracle-mode tenant**:

| View | What it contains |
| --- | --- |
| `GV$OB_PLAN_CACHE_PLAN_STAT` | One row per cached plan per observer: aggregated plan statistics (executions, elapsed time, cache hits, plan text). |
| `GV$OB_SQL_AUDIT` | One row per SQL request execution (success or failure): timing breakdown, wait events, rows/IO, retry and plan-cache-hit flags. |
| `GV$OB_SQL_PLAN_MONITOR` | Operator-level (plan line level) runtime statistics for monitored executions; Oracle-compatible real-time SQL monitoring. |

Notes on scope and access:

- `V$...` = current observer node only; `GV$...` = all observer nodes.
- A user tenant sees only its own rows (`TENANT_ID` = itself); the `SYS` tenant
  sees all tenants.
- These views live in the `SYS` schema in an Oracle tenant. Querying them
  requires dictionary read privileges — grant `SELECT ANY DICTIONARY` or use an
  administrator (SYSDBA) user. Modifying the global variables mentioned below
  requires the `ALTER SYSTEM` privilege.
- `GV$OB_SQL_PLAN_MONITOR` is also exposed as `GV$SQL_PLAN_MONITOR` (the
  Oracle-style name used from V4.5.0 docs onward); both names work in 4.x.
- All times in `GV$OB_SQL_AUDIT` and plan-stat views are in **microseconds**.

---

## 1. Column Descriptions

### 1.1 `GV$OB_SQL_AUDIT` — one row per SQL execution

Identity / routing:

| Column | Description |
| --- | --- |
| `SVR_IP`, `SVR_PORT` | Observer node that executed the statement. Part of the key for looking up plans on that node. |
| `REQUEST_ID` | Per-execution ID on that node, monotonically increasing. Use as a cursor for paging / incremental pulls. |
| `TRACE_ID` | Statement trace ID (same value returned by `last_trace_id()`). Joins to logs, metrics, and `GV$OB_SQL_PLAN_MONITOR`. |
| `SQL_EXEC_ID` | Execution ID of the statement; part of the key into the SQL Monitor views. |
| `SID` | Session ID (matches `GV$OB_PROCESSLIST.ID`). |
| `TENANT_ID`, `USER_NAME`, `DB_NAME`, `CLIENT_IP`, `USER_CLIENT_IP` | Who ran it, in which tenant/database, and from where. |
| `TX_ID` | Transaction ID; useful to correlate statements in one transaction. |
| `REQUEST_TYPE` | 1=inner, 2=local, 3=remote, 4=distributed, 5/6=prepare/execute. Filter `=2` to see local single-node executions. |
| `IS_INNER_SQL`, `IS_EXECUTOR_RPC` | Flags for internally generated SQL and executor RPCs. Filter both to 0 to see user-issued SQL only. |

SQL / plan:

| Column | Description |
| --- | --- |
| `SQL_ID` | MD5 hash of the SQL text. Groups executions of the "same" SQL; join key to the plan cache views. |
| `QUERY_SQL` | Full SQL text of this execution (not truncated). |
| `PLAN_ID` | ID of the plan used in the plan cache of `SVR_IP:SVR_PORT`. Joins to `GV$OB_PLAN_CACHE_PLAN_STAT.PLAN_ID`. |
| `PLAN_HASH` | Hash of the plan; matches `PLAN_HASH` in the plan cache views. |
| `PLAN_TYPE` | 0=none (e.g. commit), 1=local, 2=remote, 3=distributed. A `3` where you expect `1` explains network overhead. |
| `IS_HIT_PLAN` | 1 = plan cache hit, 0 = recompiled. A high miss rate per `SQL_ID` means hard-parse overhead / plan cache churn. |
| `PARAMS_VALUE`, `RULE_NAME` | Bind variable values; rule used if the statement matched a SQL firewall rule. |

Timing (microseconds; `ELAPSED_TIME` = `NET_TIME + NET_WAIT_TIME + QUEUE_TIME + DECODE_TIME + GET_PLAN_TIME + EXECUTE_TIME`):

| Column | Description |
| --- | --- |
| `REQUEST_TIME` | Execution start time (µs epoch). Convert with `USEC_TO_TIME(REQUEST_TIME)` for display. |
| `ELAPSED_TIME` | Total time from request received to end — **order by this to find the slowest executions**. |
| `EXECUTE_TIME` | Time inside the executor = CPU + waits. |
| `QUEUE_TIME` | Time queued before getting a worker thread. High value → worker thread shortage. |
| `GET_PLAN_TIME` | Time to find/compile the plan. High with `IS_HIT_PLAN=0` → hard-parse problem. |
| `NET_TIME`, `NET_WAIT_TIME` | Network send/receive cost. High on distributed plans (`PLAN_TYPE=3`). |
| `DECODE_TIME` | Time to deserialize the request. |
| `TOTAL_WAIT_TIME_MICRO` | Total wait time inside `EXECUTE_TIME`. `EXECUTE_TIME - TOTAL_WAIT_TIME_MICRO` ≈ CPU time. |
| `APPLICATION_WAIT_TIME`, `CONCURRENCY_WAIT_TIME`, `USER_IO_WAIT_TIME`, `SCHEDULE_TIME`, `LOCK_FOR_READ_TIME`, `PLSQL_EXEC_TIME` | Wait-category breakdowns; tells you *what kind* of wait dominates. |
| `RETRY_CNT` | Retry count. Non-zero → lock conflicts, node issues, or serialization; inflates elapsed time. |

Wait events:

| Column | Description |
| --- | --- |
| `EVENT`, `WAIT_CLASS` | The single longest wait event and its class; `P1..P3`/`P1TEXT..P3TEXT` carry event parameters. |
| `TOTAL_WAITS`, `WAIT_TIME_MICRO`, `STATE` | Wait counts and state for the dominant event. |

Rows / IO / cache:

| Column | Description |
| --- | --- |
| `AFFECTED_ROWS`, `RETURN_ROWS` | Rows written / returned. Compare with expectations to catch runaway scans. |
| `DISK_READS` | Physical reads. High `DISK_READS` vs cached reads → cache miss / IO-bound. |
| `ROW_CACHE_HIT`, `BLOOM_FILTER_CACHE_HIT`, `BLOCK_CACHE_HIT`, `FUSE_ROW_CACHE_HIT` | Cache hits per level; sum approximates logical reads. |
| `MEMSTORE_READ_ROW_COUNT`, `SSSTORE_READ_ROW_COUNT` | Rows read from the memtable vs SSTables. High SSTable reads after major compaction is a red flag. |
| `DATA_BLOCK_READ_CNT` / `_CACHE_HIT`, `INDEX_BLOCK_READ_CNT` / `_CACHE_HIT` | Block-level IO and cache efficiency for data vs index. |
| `BLOCKSCAN_ROW_CNT`, `PUSHDOWN_STORAGE_FILTER_ROW_CNT` | Storage-layer scan/filter efficiency. |
| `REQUEST_MEMORY_USED` | Memory used by this request. |
| `CONSISTENCY_LEVEL` | 1=SSTable-only, 2=weak, 3=strong read. Strong reads across zones add latency. |
| `RET_CODE` | 0 = success; non-zero = error code. |

Parallel execution (PX):

| Column | Description |
| --- | --- |
| `QC_ID`, `DFO_ID`, `SQC_ID`, `WORKER_ID` | Query coordinator, DFO, sub-coordinator, and worker IDs of a PX execution. |
| `EXPECTED_WORKER_COUNT`, `USED_WORKER_COUNT` | Requested vs allocated PX workers; shortfall delays PX queries. |

**How to use it:** this is the entry point for almost all SQL diagnosis.
Typical filters: `IS_INNER_SQL = 0 AND IS_EXECUTOR_RPC = 0`, then order or
group by `ELAPSED_TIME`, `EXECUTE_TIME`, or `EXECUTE_TIME * executions` to find
top resource consumers.

### 1.2 `GV$OB_PLAN_CACHE_PLAN_STAT` — one row per cached plan per node

| Column | Description |
| --- | --- |
| `TENANT_ID`, `SVR_IP`, `SVR_PORT` | Owner and location. Together with `PLAN_ID` they uniquely identify a cached plan on a node. |
| `PLAN_ID` | Cached object ID. Corresponds to `GV$OB_SQL_AUDIT.PLAN_ID`. |
| `SQL_ID` | MD5 of the parameterized SQL (NULL for PL objects). |
| `PLAN_HASH` | Plan hash; matches `PLAN_HASH` in `GV$OB_SQL_AUDIT`. |
| `TYPE` | SQL plan: 1=local, 2=remote, 3=distributed. PL object: 1=procedure, 2=function, 3=package, 4=anonymous block. |
| `OBJECT_TYPE` | `SQL_PLAN` / `PROCEDURE` / `FUNCTION` / `PACKAGE` / `ANONYMOUS`. |
| `DB_ID`, `STATEMENT`, `QUERY_SQL` | Database; parameterized statement text; original SQL text at first load. |
| `PARAM_INFOS`, `SPECIAL_PARAMS`, `SYS_VARS`, `CONFIGS` | Parameter metadata and the environment (system variables / configs) in which the plan was generated — relevant for plan instability. |
| `FIRST_LOAD_TIME`, `LAST_ACTIVE_TIME` | When the plan entered the cache and when it was last used. |
| `EXECUTIONS`, `HIT_COUNT` | Number of executions and plan-cache hits. `EXECUTIONS - HIT_COUNT` ≈ compilations. |
| `AVG_EXE_USEC`, `SLOWEST_EXE_TIME`, `SLOWEST_EXE_USEC`, `SLOW_COUNT` | Average execution time (µs), the slowest single execution, and the count of executions slower than `trace_log_slow_query_watermark`. |
| `ELAPSED_TIME`, `CPU_TIME` | Cumulative elapsed/CPU time (µs). |
| `BUFFERS_GETS`, `DISK_READS`, `DIRECT_WRITES` | Cumulative logical reads, physical reads, direct writes. |
| `APPLICATION_WAIT_TIME`, `CONCURRENCY_WAIT_TIME`, `USER_IO_WAIT_TIME` | Cumulative wait time by category (µs). |
| `ROWS_PROCESSED` | Cumulative rows processed. |
| `PLAN_SIZE` | Memory (bytes) this plan occupies in the plan cache. |
| `IS_BIND_SENSITIVE`, `IS_BIND_AWARE`, `ACS_SEL_INFO` | Adaptive cursor sharing state and selectivity info. |
| `OUTLINE_ID`, `OUTLINE_VERSION`, `OUTLINE_DATA` | Outline binding (-1 = not bound) and the outline content. |
| `EVOLUTION`, `EVO_EXECUTIONS`, `EVO_CPU_TIME` | Plan evolution (baseline) state. |
| `LARGE_QUERYS`, `DELAYED_LARGE_QUERYS`, `DELAYED_PX_QUERYS` | Counts vs `large_query_threshold` (large queries get throttled; watch these for big-query queuing). |
| `TIMEOUT_COUNT` | Executions that timed out. |
| `TABLE_SCAN`, `PS_STMT_ID`, `SESSID`, `TEMP_TABLES`, `IS_USE_JIT`, `HINTS_INFO`, `HINTS_ALL_WORKED`, `IS_BATCHED_MULTI_STMT`, `RULE_NAME` | Full-scan flag, prepared-statement ID, session, temp tables, JIT usage, hints used and whether all hints were honored, batching, firewall rule. |

**How to use it:** answer "how has this plan behaved historically?" — average
vs slowest time, cumulative logical/physical reads per execution, cache-hit
rate, and memory footprint. High `AVG_EXE_USEC` with high `BUFFERS_GETS`
identifies plans that read too much; compare `AVG_EXE_USEC` against
`GV$OB_SQL_AUDIT` single executions to spot regressions.

### 1.3 `GV$OB_SQL_PLAN_MONITOR` — operator-level runtime statistics

One row per plan operator per thread/process of a monitored execution.

| Column | Description |
| --- | --- |
| `CON_ID` | Tenant ID (=`TENANT_ID` in the other views). |
| `REQUEST_ID`, `KEY` | Execution key; foreign key into the SQL Monitor virtual tables. |
| `TRACE_ID`, `SVR_IP`, `SVR_PORT` | Trace ID and node of the execution — join to `GV$OB_SQL_AUDIT`. |
| `SID`, `PROCESS_NAME` | Session and thread ID that ran this operator. |
| `SQL_ID`, `SQL_EXEC_ID`, `SQL_EXEC_START` | Statement ID, execution ID, execution start time. |
| `SQL_PLAN_HASH_VALUE` | Plan hash (=`PLAN_HASH`). |
| `STATUS` | `EXECUTING`, `DONE`, `DONE(ERROR)`, `DONE(FIRST N ROWS)`, `DONE(ALL ROWS)` — shows which operators are still running. |
| `PLAN_LINE_ID`, `PLAN_PARENT_ID`, `PLAN_DEPTH`, `PLAN_POSITION` | Operator's position in the plan tree; `ORDER BY PLAN_LINE_ID` reproduces the plan shape. |
| `PLAN_OPERATION`, `PLAN_OPTIONS` | Operator, e.g. `PHY_TABLE_SCAN` + `RANGE SCAN`. |
| `PLAN_OBJECT_OWNER`, `PLAN_OBJECT_NAME`, `PLAN_OBJECT_TYPE` | Object accessed by the operator (table/index). |
| `PLAN_COST`, `PLAN_CARDINALITY`, `PLAN_BYTES`, `PLAN_CPU_COST`, `PLAN_IO_COST`, `PLAN_TEMP_SPACE`, `PLAN_PARTITION_START` / `PLAN_PARTITION_STOP` | Optimizer estimates for the operator. |
| `STARTS` | How many times the operator was executed (rescans). |
| `OUTPUT_ROWS` | Actual rows produced — **compare against `PLAN_CARDINALITY` to find bad estimates**. |
| `DB_TIME` | CPU time consumed by this operator. |
| `USER_IO_WAIT_TIME`, `OTHER_WAIT_TIME` | IO and other wait time on this operator. |
| `FIRST_REFRESH_TIME`, `LAST_REFRESH_TIME`, `REFRESH_COUNT` | Real-time refresh window (rows are updated while the statement runs). |
| `FIRST_CHANGE_TIME`, `LAST_CHANGE_TIME` | When the operator first/last produced rows — localizes the slow part of the plan. |
| `IO_INTERCONNECT_BYTES` | Data shipped between PX processes. |
| `PHYSICAL_READ_REQUESTS` / `PHYSICAL_READ_BYTES`, `PHYSICAL_WRITE_REQUESTS` / `PHYSICAL_WRITE_BYTES` | Physical IO per operator. |
| `WORKAREA_MEM`, `WORKAREA_MAX_MEM`, `WORKAREA_TEMPSEG`, `WORKAREA_MAX_TEMPSEG` | Memory/hash-sort work area usage and temp segment spills (spills = slow sorts/hashes). |
| `OUTPUT_BATCHES`, `SKIPPED_ROWS_COUNT` | Vectorized-execution batching and skipped rows. |
| `OTHERSTAT_GROUP_ID`, `OTHERSTAT_1..10_ID` / `_TYPE` / `_VALUE` | Operator-specific metrics; decode the IDs via `V$SQL_MONITOR_STATNAME` (e.g. for table scans, `OTHERSTAT_1_VALUE` = `IO_READ_BYTES`, `OTHERSTAT_2_VALUE` = `SSSTORE_READ_BYTES`). |
| `OTHER_XML`, `PROFILE` | Extra per-operator detail (adaptive plan info, profile). |

**How to use it:** while a query is running (or after it finished), this shows
*which plan operator* consumes the time and rows. It is the OceanBase
equivalent of Oracle's `V$SQL_PLAN_MONITOR` / Real-Time SQL Monitoring.

---

## 2. Linkage Between the Views

The three views form a drill-down chain: **audit (which statements are slow) →
plan cache stats (how that plan behaves overall) → plan monitor (which
operator inside the plan is slow)**.

```
GV$OB_SQL_AUDIT                        GV$OB_PLAN_CACHE_PLAN_STAT
  TENANT_ID  ──────────────────────────  TENANT_ID
  SVR_IP, SVR_PORT ────────────────────  SVR_IP, SVR_PORT
  PLAN_ID ─────────────────────────────  PLAN_ID
  SQL_ID / PLAN_HASH ──────────────────  SQL_ID / PLAN_HASH

GV$OB_SQL_AUDIT                        GV$OB_SQL_PLAN_MONITOR
  TENANT_ID (= CON_ID) ────────────────  CON_ID
  TRACE_ID + SVR_IP + SVR_PORT + ──────  TRACE_ID + SVR_IP + SVR_PORT
  REQUEST_ID / SQL_EXEC_ID ────────────  REQUEST_ID / SQL_EXEC_ID
  SQL_ID / PLAN_HASH ──────────────────  SQL_ID / SQL_PLAN_HASH_VALUE
```

Key facts about the linkage:

- `PLAN_ID` is only unique per observer node — always include
  `TENANT_ID + SVR_IP + SVR_PORT` when joining to plan-cache views.
- `TRACE_ID` ties one execution across all three views, plus the server logs
  (`observer.log`) and OCP/metrics. Get it in a session with
  `SELECT last_trace_id() FROM DUAL;` (or from `GV$OB_SQL_AUDIT`).
- `GV$OB_SQL_AUDIT` is the documented data source for SQL Monitor: plan
  monitor rows are collected and flushed together with the SQL audit data, so
  `enable_sql_audit` controls both.
- Typical correlation queries:

```sql
-- 1. Find recent executions of a slow SQL and get their plan context
SELECT trace_id, svr_ip, svr_port, plan_id, plan_hash,
       elapsed_time, execute_time, total_wait_time_micro,
       is_hit_plan, retry_cnt, ret_code
FROM   sys.gv$ob_sql_audit
WHERE  query_sql LIKE '%YOUR TABLE%'
  AND  is_inner_sql = 0 AND is_executor_rpc = 0
ORDER  BY request_time DESC
FETCH  FIRST 20 ROWS ONLY;

-- 2. Aggregate behavior of each cached plan for that SQL
SELECT svr_ip, plan_id, plan_hash, executions, hit_count,
       avg_exe_usec, slowest_exe_usec, slow_count,
       buffer_gets, disk_reads, elapsed_time, cpu_time, plan_size
FROM   sys.gv$ob_plan_cache_plan_stat
WHERE  sql_id = '<SQL_ID>'
ORDER  BY avg_exe_usec DESC;

-- 3. Operator-level detail for one execution
SELECT plan_line_id, plan_depth, plan_operation, plan_options,
       plan_object_name, starts, output_rows, plan_cardinality,
       db_time, user_io_wait_time, first_change_time, last_change_time,
       workarea_max_mem, workarea_max_tempseg, status
FROM   sys.gv$ob_sql_plan_monitor
WHERE  trace_id = '<TRACE_ID>'
ORDER  BY plan_line_id;
```

---

## 3. Step-by-Step Troubleshooting

### Step 1 — Locate the problematic SQL

```sql
-- Top single executions in the last while
SELECT usec_to_time(request_time) AS exec_time, sql_id, trace_id,
       elapsed_time, execute_time, queue_time, get_plan_time,
       total_wait_time_micro, event, plan_type, retry_cnt,
       affected_rows, return_rows, disk_reads, is_hit_plan
FROM   sys.gv$ob_sql_audit
WHERE  is_inner_sql = 0 AND is_executor_rpc = 0
ORDER  BY elapsed_time DESC
FETCH  FIRST 20 ROWS ONLY;

-- Top resource consumers (aggregate)
SELECT sql_id, COUNT(*) AS execs,
       AVG(elapsed_time) AS avg_elapsed,
       SUM(elapsed_time) AS total_elapsed,
       AVG(execute_time) AS avg_exec,
       SUM(disk_reads) AS total_disk_reads,
       MAX(is_hit_plan) AS any_plan_miss
FROM   sys.gv$ob_sql_audit
WHERE  is_inner_sql = 0 AND is_executor_rpc = 0
GROUP  BY sql_id
ORDER  BY SUM(elapsed_time) DESC
FETCH  FIRST 20 ROWS ONLY;
```

Read the result:

- `ELAPSED_TIME` large but `EXECUTE_TIME` small → time spent *outside*
  execution: `QUEUE_TIME` (thread shortage — check `EXPECTED_WORKER_COUNT` vs
  `USED_WORKER_COUNT`, or tenant CPU), `GET_PLAN_TIME` (hard parse), or network
  on distributed plans (`PLAN_TYPE = 3`).
- `EXECUTE_TIME - TOTAL_WAIT_TIME_MICRO` large → CPU-bound (heavy expression,
  sort/hash, too many rows).
- `TOTAL_WAIT_TIME_MICRO` dominated by `USER_IO_WAIT_TIME` → IO-bound;
  check `DISK_READS` and block cache-hit columns.
- `CONCURRENCY_WAIT_TIME` / `APPLICATION_WAIT_TIME` high → locks, row
  conflicts, or latch contention; check `RETRY_CNT` (retries inflate latency).
- `IS_HIT_PLAN = 0` frequently → plan cache misses; the statement is being
  reparsed (see storage controls in section 4 — cache too small — or literals
  in SQL text making `SQL_ID`s differ).

### Step 2 — Inspect the plan and its history

From the audit row take `TENANT_ID, SVR_IP, SVR_PORT, PLAN_ID, SQL_ID`:

- Use `GV$OB_PLAN_CACHE_PLAN_STAT` (section 1.2) for cumulative stats:
  - `AVG_EXE_USEC` high and rising → regression (new stats, new schema
    version, or a different plan for the same `SQL_ID`).
  - `BUFFERS_GETS / EXECUTIONS` large → the plan reads too much per
    execution (missing index, stale stats, bad join order).
  - Multiple rows with different `PLAN_HASH` for one `SQL_ID` → plan
    instability (bind sensitivity / ACS in play, or cache eviction flipping
    plans). Check `IS_BIND_SENSITIVE`, `IS_BIND_AWARE`, `ACS_SEL_INFO`.
- Use `GV$OB_PLAN_CACHE_PLAN_EXPLAIN` (needs equality predicates on
  `TENANT_ID + SVR_IP + SVR_PORT + PLAN_ID`) or
  `DBMS_XPLAN.DISPLAY`/`DBMS_XPLAN.DISPLAY_CURSOR`-style output to see the
  actual operators. `GV$OB_SQL_PLAN` shows estimates vs first-execution
  actuals (`REAL_CARDINALITY`, `REAL_COST`).

### Step 3 — Drill into operators with the real-time plan monitor

```sql
SELECT plan_line_id, plan_depth, plan_operation, plan_options,
       plan_object_name, plan_object_type,
       starts, output_rows, plan_cardinality,
       db_time, user_io_wait_time,
       first_change_time, last_change_time,
       workarea_max_mem, workarea_max_tempseg, status
FROM   sys.gv$ob_sql_plan_monitor
WHERE  trace_id = '<TRACE_ID>'
ORDER  BY plan_line_id;
```

- `OUTPUT_ROWS >> PLAN_CARDINALITY` (or `<<`) on a nested-loop/table-scan
  node → cardinality misestimate caused by stale statistics: refresh stats
  (`DBMS_STATS.GATHER_TABLE_STATS`) or add hints.
- One operator holds most `DB_TIME` or `USER_IO_WAIT_TIME` → that operator
  is the tuning target (index it, partition-prune it, or push down filters).
- `WORKAREA_MAX_TEMPSEG > 0` on a sort/hash operator → spilled to disk;
  raise memory or make the operation smaller.
- Operator `STATUS = EXECUTING` with moving `LAST_REFRESH_TIME` → currently
  running; watch which operator stalls (`FIRST_CHANGE_TIME`/`LAST_CHANGE_TIME`
  gap = idle/stall time).
- `IO_INTERCONNECT_BYTES` large on PX operators → data redistribution
  dominates; consider partition-wise joins or better distribution keys.
- Decode operator metrics:
  `SELECT name FROM v$sql_monitor_statname WHERE id = <OTHERSTAT_n_ID>;`

### Step 4 — Formulate tuning suggestions

| Finding in the views | Suggestion |
| --- | --- |
| High `GET_PLAN_TIME`, `IS_HIT_PLAN = 0` | Use bind variables; check plan cache size (`ob_plan_cache_percentage`); avoid `USE_PLAN_CACHE(NONE)`; if literal SQL is required, ensure enough cache. |
| `DISK_READS` high, block cache hits low | Index the filter/join columns; refresh stats so the optimizer picks the index; check hot data cache sizing; consider partitioning for pruning. |
| Cardinality misestimate (monitor `OUTPUT_ROWS` vs `PLAN_CARDINALITY`) | Run `DBMS_STATS.GATHER_TABLE_STATS` with adequate granularity; consider extended stats for correlated predicates; use outline/hints as a last resort. |
| Full table scans (`TABLE_SCAN = 1` in plan cache / `PHY_TABLE_SCAN` without options in monitor) | Add/adjust indexes; check whether the optimizer's estimate is wrong rather than the access path itself. |
| High `QUEUE_TIME` / `SCHEDULE_TIME` | Increase tenant `cpu_count`/`workers`; reduce `large_query_threshold` impact; check PX `USED_WORKER_COUNT` vs `EXPECTED_WORKER_COUNT`. |
| `PLAN_TYPE = 3` (distributed) for OLTP SQL | Fix leader distribution (primary zone / locality / table group) so statements execute locally. |
| `RETRY_CNT > 0` | Investigate hot-row conflicts; serialize the hot row; move contending transactions. |
| Multiple `PLAN_HASH` per `SQL_ID`, unstable `AVG_EXE_USEC` | Check ACS behavior (`IS_BIND_AWARE`); pin a good plan via outline (`CREATE OUTLINE`) or SQL plan management. |
| `WORKAREA` temp spills | More memory per operator (or less data): better join order, pre-filtering, or indexes avoiding sorts. |
| Plan cache full (`PLAN_SIZE` sums near the cap; high eviction) | Raise `ob_plan_cache_percentage`; flush stale plans with `ALTER SYSTEM FLUSH PLAN CACHE` (see section 4). |
| Incident forensics: evidence keeps aging out | During the incident, a documented practice is `ALTER SYSTEM SET enable_sql_audit = false` (sys tenant) to freeze the in-memory audit/monitor data from eviction, then analyze and re-enable. Use sparingly — new executions stop being recorded while it is off. |

### Step 5 — Verify

Re-run the statement, capture `last_trace_id()`, and confirm in
`GV$OB_SQL_AUDIT`/`GV$OB_SQL_PLAN_MONITOR` that `ELAPSED_TIME`,
`BUFFERS_GETS`/`DISK_READS` per execution, and the targeted operator's times
improved.

---

## 4. Controlling the Storage for These Views

All three views are backed by **in-memory** structures, so "storage control"
means controlling memory caps and eviction.

### 4.1 SQL audit (and SQL plan monitor) memory

| Control | Level | Default | How to set |
| --- | --- | --- | --- |
| `enable_sql_audit` | Cluster config (set in `SYS` tenant) | `True` | `ALTER SYSTEM SET enable_sql_audit = true;` — master switch for SQL audit **and** plan monitor data. Turning it off also freezes existing rows in memory (useful during incident forensics). |
| `ob_enable_sql_audit` | Tenant global variable | `ON` | `SET GLOBAL ob_enable_sql_audit = OFF;` (applies to new sessions). |
| `ob_sql_audit_percentage` | Tenant global variable | `3` (percent of tenant memory), range 0–80 | `SET GLOBAL ob_sql_audit_percentage = 5;` |

Behavior:

- The audit memory limit = tenant memory × `ob_sql_audit_percentage`%. A
  per-tenant background task checks roughly every second and evicts the oldest
  audit/monitor rows when usage crosses a high watermark (e.g. 80% of the
  limit) until it drops to the stop watermark (e.g. 60%); there is also a
  record-count cap (order of 9M trigger / 8M stop, version-dependent).
- Because plan monitor rows are flushed with the audit data, enlarging the
  audit memory (or `enable_sql_audit = off` during analysis) is how you keep
  monitor evidence longer.
- Manual flush/evict (in `SYS` tenant):
  ```sql
  ALTER SYSTEM FLUSH SQL AUDIT TENANT = '<tenant_name>';
  ```
- Check current usage: `SHOW PARAMETERS LIKE 'ob_sql_audit_percentage';` and
  watch `GV$OB_SQL_AUDIT` row counts/age.

### 4.2 Plan cache memory

| Control | Level | Default | How to set |
| --- | --- | --- | --- |
| `ob_plan_cache_percentage` | Tenant global variable | `5` (percent of tenant memory), range 0–100 | `SET GLOBAL ob_plan_cache_percentage = 10;` — plan cache cap = tenant memory × pct/100. |
| `ob_plan_cache_evict_high_percentage` | Tenant global variable | `90` | `SET GLOBAL ob_plan_cache_evict_high_percentage = 90;` — start evicting when usage > cap × 90%. |
| `ob_plan_cache_evict_low_percentage` | Tenant global variable | `50` | `SET GLOBAL ob_plan_cache_evict_low_percentage = 50;` — stop evicting when usage ≤ cap × 50%. |
| `plan_cache_evict_interval` | Cluster config | (version-dependent) | `ALTER SYSTEM SET plan_cache_evict_interval = '30s';` — eviction check interval. |
| `ob_enable_plan_cache` | Tenant/session variable | `TRUE` | `SET GLOBAL ob_enable_plan_cache = FALSE;` or hint `/*+ USE_PLAN_CACHE(NONE) */` per statement. |

Manual flush:

```sql
-- In SYS tenant (can target other tenants); in a user tenant, flushes own cache
ALTER SYSTEM FLUSH PLAN CACHE [SQL_ID = '<sql_id>'] [GLOBAL];
```

Notes:

- In Oracle tenants, changing these global variables requires the
  `ALTER SYSTEM` privilege.
- Eviction is LRU-based: low-`HIT_COUNT`, old `LAST_ACTIVE_TIME` plans go
  first. If a frequently used plan keeps disappearing (observed as
  `IS_HIT_PLAN = 0` in the audit), raise `ob_plan_cache_percentage`.
- Plans are also dropped on schema changes / new stats / major merge; a
  one-off `ALTER SYSTEM FLUSH PLAN CACHE SQL_ID = '...'` forces recompilation
  after you fix statistics.

### 4.3 Quick checklist

1. `SHOW PARAMETERS LIKE 'enable_sql_audit';` — audit/monitor collection on?
2. `SHOW VARIABLES LIKE 'ob_sql_audit_percentage';` — audit memory headroom.
3. `SHOW VARIABLES LIKE 'ob_plan_cache_percentage';` — plan cache headroom.
4. If audit rows age out before you can analyze them, raise
   `ob_sql_audit_percentage` (tenant) or briefly freeze with
   `enable_sql_audit = false` (sys) during the incident.

---

## References (OceanBase official documentation)

- GV$OB_PLAN_CACHE_PLAN_STAT columns: https://en.oceanbase.com/docs/common-oceanbase-database-10000000004213417
- GV$OB_SQL_AUDIT columns: https://en.oceanbase.com/docs/common-oceanbase-database-10000000001785711
- GV$SQL_PLAN_MONITOR columns: https://www.oceanbase.com/docs/common-oceanbase-database-cn-1000000004478107
- Real-time plan / SQL Monitor usage: https://www.oceanbase.com/docs/common-oceanbase-database-cn-10000000001576953
- Plan cache overview & eviction: https://www.oceanbase.com/docs/common-oceanbase-database-cn-10000000001576951
- Parameter references: `ob_plan_cache_evict_high_percentage`, `ob_plan_cache_evict_low_percentage`, `ob_sql_audit_percentage`, `enable_sql_audit` (oceanbase.com docs, V4.x)
- DBA tutorial — analyzing SQL monitoring views: https://github.com/oceanbase/tutorials-doc/blob/V4.2.1/zh-CN/100.dba-tutorial/70.diagnosis-and-tuning-of-oceanbase/40.analyze-sql-monitoring-view.md

*Note: exact column sets and eviction thresholds vary slightly between 4.x
minor releases; the column lists above reflect the V4.3/V4.5 documentation.*
