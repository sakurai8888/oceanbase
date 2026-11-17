# Verification and Rollback

## Pre-flight checks (run before creating anything)

```sql
-- 1. Version and compatibility mode
SELECT * FROM v$version;
SELECT value FROM v$parameter WHERE name = 'compatible';

-- 2. Argument subprograms actually present in this build
SELECT object_name, procedure_name
  FROM all_procedures
 WHERE object_name = 'DBMS_SCHEDULER'
   AND procedure_name LIKE '%ARGUMENT%';
-- Expect SET_JOB_ARGUMENT_VALUE and DEFINE_PROGRAM_ARGUMENT.
-- DEFINE_JOB_ARGUMENT is NOT expected — it does not exist.

-- 3. Prerequisite packages/procedures are VALID
SELECT owner, object_name, object_type, status
  FROM all_objects
 WHERE owner = '<OWNER>'
   AND object_name IN ('PKG_A','PKG_B')
 ORDER BY object_name, object_type;

-- 4. No OUT/INOUT parameters on any job_action target
SELECT owner, package_name, object_name, argument_name, position, in_out
  FROM all_arguments
 WHERE owner = '<OWNER>'
   AND in_out <> 'IN'
 ORDER BY package_name, object_name, position;

-- 5. Job names not already taken
SELECT job_name, enabled, state
  FROM user_scheduler_jobs
 WHERE job_name IN ('JOB_A','JOB_B');
```

## Post-creation checks

### Job count

```sql
SELECT COUNT(*) AS job_cnt FROM user_scheduler_jobs
 WHERE job_name IN ('JOB_A','JOB_B', ...);
-- Expect the full N.
```

### The single most valuable check: `next_run_date`

This validates every `repeat_interval` in one query.

```sql
SELECT job_name,
       enabled,
       state,
       TO_CHAR(next_run_date,'YYYY-MM-DD HH24:MI:SS') AS next_run,
       repeat_interval
  FROM user_scheduler_jobs
 ORDER BY job_name;
```

Interpretation:

| Observation | Meaning |
|---|---|
| `next_run` NULL | `repeat_interval` invalid, or no future occurrence |
| `next_run` at an unexpected time | `BY*` clauses misread — see `repeat-interval.md` |
| `next_run` immediately in the past/now | `start_date` in the past; job may fire at once |

### Time zone parsed correctly

```sql
SELECT job_name,
       TO_CHAR(start_date,'YYYY-MM-DD HH24:MI:SS TZH:TZM') AS start_dt
  FROM user_scheduler_jobs
 ORDER BY job_name;
-- Expect +08:00 (or the intended offset) on every row.
```

### Enable state matches the source

```sql
SELECT enabled, COUNT(*)
  FROM user_scheduler_jobs
 GROUP BY enabled;
-- Compare against the source: jobs disabled in Oracle must stay disabled.
```

### Argument values landed

```sql
SELECT job_name, argument_position, value
  FROM user_scheduler_job_args
 ORDER BY job_name, argument_position;
```

## Smoke test before enabling everything

Run one light job manually, inspect the result, then enable the rest.

```sql
BEGIN
    DBMS_SCHEDULER.RUN_JOB('JOB_A', FALSE);
END;
/

SELECT job_name, log_date, status, error#, additional_info
  FROM user_scheduler_job_run_details
 WHERE job_name = 'JOB_A'
 ORDER BY log_date DESC;
```

Common runtime errors:

| Error | Cause |
|---|---|
| `PLS-00306` | Wrong number/types of arguments |
| `ORA-06550` / `PLS-00905` | `job_action` object is INVALID |
| `ORA-27468` | Argument value not set for the job |
| `ORA-27476` | Invalid parameter (e.g. `job_class` quoting) |

## Rollback

```sql
BEGIN
    DBMS_SCHEDULER.DROP_JOB('JOB_A', TRUE);
    DBMS_SCHEDULER.DROP_JOB('JOB_B', TRUE);
    COMMIT;
END;
/
```

The second parameter `TRUE` forces the drop even if the job is running.

If you used Strategy C (program-based), also drop the programs:

```sql
BEGIN
    DBMS_SCHEDULER.DROP_PROGRAM('PKG_PROG', TRUE);
    COMMIT;
END;
/
```

## Acceptance checklist

A conversion is complete when all of the following hold:

- [ ] Job count on the target equals the in-scope count from the source
- [ ] Every `next_run_date` is non-NULL and matches the intended local time
- [ ] `start_date` shows the intended UTC offset on every row
- [ ] Enable state distribution matches the source
- [ ] Argument values present for every job with `number_of_argument > 0`
- [ ] At least one job smoke-tested successfully via `RUN_JOB`
- [ ] Out-of-scope objects (chains, rule sets) listed explicitly, not silently dropped