# Conversion Rules (R1–R8) and Capability Matrix

## Rule table

### R1 — `job_name`: remove double quotes

```sql
-- Oracle
dbms_scheduler.create_job('"MIS_VENDOR_COST_DOM_DAILY_JOBS"', ...)
-- OceanBase
job_name => 'MIS_VENDOR_COST_DOM_DAILY_JOBS'
```

Oracle dumps quote every identifier. OceanBase accepts double-quoted
identifiers but they become case-sensitive. Since dump names are already
upper case, dropping the quotes is safe and cleaner.

### R2 — `start_date`: replace time zone region with explicit offset

```sql
-- Oracle (3 parameters)
TO_TIMESTAMP_TZ('30-OCT-2026 03.13.18.643759000 PM ASIA/HONG_KONG',
                'DD-MON-RRRR HH.MI.SSXFF AM TZR',
                'NLS_DATE_LANGUAGE=english')

-- OceanBase (2 parameters)
TO_TIMESTAMP_TZ('30-OCT-2026 03.13.18.643759000 PM +08:00',
                'DD-MON-RRRR HH.MI.SSXFF AM TZR')
```

- The `TZR` format element with a **region name** (`ASIA/HONG_KONG`,
  `ASIA/SHANGHAI`) is the most fragile part of any Oracle job dump.
  Replace the region with a numeric offset.
- Drop the third parameter `'NLS_DATE_LANGUAGE=english'` — the format
  model is already English-only (`MON`, `AM`, `PM`).
- `ASIA/HONG_KONG` and `ASIA/SHANGHAI` are both UTC+8, so `+08:00` is
  semantically identical. For other regions, compute the correct offset
  and note that DST regions cannot be represented this way — flag them.
- If a build rejects `TZR` with an offset literal, switch the format
  model to `'DD-MON-RRRR HH.MI.SSXFF AM TZH:TZM'`.
- Consider rewriting `RRRR` to `YYYY` for clarity (optional).

### R3 — `number_of_argument` (SINGULAR)

```sql
-- Oracle
number_of_arguments => 6,
-- OceanBase CREATE_JOB
number_of_argument  => 6,
```

This is the single most common cause of a failed conversion. See
`arguments.md` for the full picture, including the `CREATE_PROGRAM`
asymmetry.

For zero-argument jobs the parameter may simply be omitted — the
OceanBase default is `0`.

### R4 — `job_class`: remove double quotes

```sql
-- Oracle
job_class => '"DEFAULT_JOB_CLASS"'
-- OceanBase
job_class => 'DEFAULT_JOB_CLASS'
```

`job_class` itself is supported and defaults to `'DEFAULT_JOB_CLASS'`, so
the parameter can also be dropped entirely.

### R5 — `NLS_ENV`: delete

Oracle dumps append an identical statement after every job:

```sql
sys.dbms_scheduler.set_attribute('<JOB>','NLS_ENV',
  'NLS_LANGUAGE=''AMERICAN'' NLS_TERRITORY=''AMERICA'' ... ');
```

OceanBase does not implement the `NLS_ENV` job attribute. Delete it.
Because the statement is byte-identical across all jobs, document it once
rather than repeating it N times.

### R6 — `ENABLE`: separate from `CREATE_JOB`

Move all `dbms_scheduler.enable(...)` calls into their own section so the
create step can be verified before anything fires.

```sql
DBMS_SCHEDULER.ENABLE('JOB_NAME');   -- no double quotes
```

Only emit `ENABLE` for jobs that are enabled in the source.

### R7 — Session trace events: delete

```sql
ALTER SESSION SET EVENTS '10046 trace name context forever, level 12';
```

Oracle-internal diagnostics. Not applicable, not needed.

### R8 — CHAIN / PROGRAM / RULE SET: usually out of scope

If every target job is `job_type => 'STORED_PROCEDURE'`, then **no**
programs, chains or rule sets are required. Verify this before porting
them — it often removes the majority of the dump.

Chain-based jobs (`job_type => 'CHAIN'`) need a separate migration path
(`CREATE_PROGRAM`, `CREATE_CHAIN`, `DEFINE_CHAIN_STEP`, rule sets) and
should be listed as explicitly out of scope rather than half-converted.

## OceanBase 4.4.2 capability matrix

| Feature | Status | Notes |
|---|---|---|
| `CREATE_JOB` | Supported | `number_of_argument` (singular) |
| `CREATE_PROGRAM` | Supported | `number_of_arguments` (plural) |
| `DEFINE_PROGRAM_ARGUMENT` | Supported | Program arguments only |
| `DEFINE_JOB_ARGUMENT` | **Not supported** | Use positional values for inline jobs |
| `SET_JOB_ARGUMENT_VALUE` | Supported | Positional and named forms |
| `job_class` | Supported | Default `'DEFAULT_JOB_CLASS'` |
| `auto_drop` | Supported | Keep as-is |
| `ENABLE` / `DISABLE` | Supported | |
| `RUN_JOB` / `STOP_JOB` | Supported | |
| `job_type` | **`STORED_PROCEDURE` only** | `PLSQL_BLOCK` not available |
| `BYMONTH` / `BYYEARDAY` / `BYMONTHDAY` / `BYDAY` / `BYHOUR` / `BYMINUTE` / `BYSECOND` | Supported (4.4.2) | Strict pairing rules — see `repeat-interval.md` |
| Negative `BYDAY` (`-1FRI`) | **Not supported** | `OB_PASSER_ERROR` |
| `repeat_interval => NULL` | Raises an error | Always supply a value |
| `job_action` with OUT/INOUT params | **Not supported** | Needs a pure-IN wrapper |
| `NLS_ENV` job attribute | **Not supported** | Delete |

## Objects that must exist first

`CREATE_JOB` validates `job_action` at creation time. Every referenced
package/procedure must already exist and be VALID on the target, or the
job creation fails. Emit a prerequisite checklist listing every distinct
`job_action` value.

Also verify none of them has OUT/INOUT parameters:

```sql
SELECT owner, package_name, object_name, argument_name, position, in_out
  FROM all_arguments
 WHERE owner = '<OWNER>'
   AND in_out <> 'IN'
 ORDER BY package_name, object_name, position;
```

Any row returned is a blocker for `STORED_PROCEDURE` scheduling.