# Job Arguments — Decision Tree and Traps

Arguments are where most Oracle → OceanBase job conversions break. Work
through this tree in order.

## Step 1 — Find the jobs that actually take arguments

In the source dump, look for `number_of_arguments` with a value > 0:

```sql
number_of_arguments=>6,
```

Jobs with `=>0` need no argument handling at all — just omit the
parameter (OceanBase defaults to `0`).

## Step 2 — Check whether the values exist in the dump

Search the dump for `DEFINE_JOB_ARGUMENT` and `SET_JOB_ARGUMENT_VALUE`.

**If neither appears**, the argument values are missing from the export.
This is common: Data Pump / `dbms_metadata` PROCOBJ exports frequently
omit the argument rows even when they export programs, chains and rules
completely.

Collect them from the source database:

```sql
SELECT job_name, argument_position, argument_name, value
  FROM dba_scheduler_job_args
 WHERE owner = '<OWNER>'
   AND job_name IN ('JOB_A','JOB_B')
 ORDER BY job_name, argument_position;
```

**Never invent values.** Emit placeholders (`<v1>`, `<v2>`, …) and ship
the query above alongside them.

## Step 3 — Pick a strategy

### Strategy A — Drop the arguments (POC / scheduling validation only)

Remove `number_of_argument` entirely. Every job becomes a zero-argument
inline job.

- Jobs are created and scheduled correctly.
- They fail at **runtime** with `PLS-00306` unless the procedure declares
  defaults for every parameter.
- Acceptable when the goal is to validate the scheduling layer in
  isolation, or when the jobs are disabled in the source anyway.

Check whether a zero-argument call is legal:

```sql
SELECT object_name, argument_name, position, defaulted
  FROM all_arguments
 WHERE owner = '<OWNER>'
   AND object_name IN ('PKG_A','PKG_B')
   AND in_out = 'IN'
 ORDER BY object_name, subprogram_id, position;
```

`defaulted = 'Y'` for every parameter → zero-argument call is safe.
Any `defaulted = 'N'` → the job will fail at runtime.

### Strategy B — Positional values on an inline job (preferred)

OceanBase has **no `DEFINE_JOB_ARGUMENT`**. For an inline job
(`job_action`, not `program_name`) no definition step is needed —
`number_of_argument` already declares the count. Set values by position:

```sql
BEGIN
    DBMS_SCHEDULER.CREATE_JOB(
        job_name           => 'JOB_A',
        job_type           => 'STORED_PROCEDURE',
        job_action         => 'PKG.PROC',
        number_of_argument => 1,          -- SINGULAR
        start_date         => TO_TIMESTAMP_TZ('2026-11-13 10:00:00 +08:00','DD-MON-RRRR HH.MI.SSXFF AM TZR'),
        repeat_interval    => 'FREQ=DAILY;INTERVAL=1;BYHOUR=10;BYMINUTE=0;BYSECOND=0',
        end_date           => NULL,
        enabled            => FALSE,
        auto_drop          => TRUE,
        job_class          => 'DEFAULT_JOB_CLASS',
        comments           => NULL
    );

    DBMS_SCHEDULER.SET_JOB_ARGUMENT_VALUE('JOB_A', 1, '<v1>');
    COMMIT;
END;
/
```

Order matters: `CREATE_JOB` → `SET_JOB_ARGUMENT_VALUE` → `ENABLE`.

### Strategy C — Program-based (named arguments / LIGHTWEIGHT)

Required if you need argument **names**, `job_style => 'LIGHTWEIGHT'`, or
if Strategy B is rejected by the build.

```sql
BEGIN
    DBMS_SCHEDULER.CREATE_PROGRAM(
        program_name        => 'PKG_PROG',
        program_type        => 'STORED_PROCEDURE',
        program_action      => 'PKG.PROC',
        number_of_arguments => 6,          -- PLURAL here
        enabled             => FALSE);

    FOR i IN 1..6 LOOP
        DBMS_SCHEDULER.DEFINE_PROGRAM_ARGUMENT(
            program_name      => 'PKG_PROG',
            argument_position => i,
            argument_name     => 'p_arg' || i,
            argument_type     => 'VARCHAR2',   -- must match the real signature
            default_value     => '0',
            out_argument      => FALSE);
    END LOOP;

    DBMS_SCHEDULER.ENABLE('PKG_PROG');
    COMMIT;
END;
/

BEGIN
    DBMS_SCHEDULER.CREATE_JOB(
        job_name        => 'JOB_A',
        program_name    => 'PKG_PROG',
        start_date      => TO_TIMESTAMP_TZ('2026-11-13 10:00:00 +08:00','DD-MON-RRRR HH.MI.SSXFF AM TZR'),
        repeat_interval => 'FREQ=DAILY;INTERVAL=1;BYHOUR=10;BYMINUTE=0;BYSECOND=0',
        end_date        => NULL,
        enabled         => FALSE,
        auto_drop       => TRUE,
        job_class       => 'DEFAULT_JOB_CLASS',
        comments        => NULL);

    DBMS_SCHEDULER.SET_JOB_ARGUMENT_VALUE('JOB_A', 1, '<v1>');
    COMMIT;
END;
/
```

**Optimisation:** jobs that call the same procedure with the same arity
can share one program. Four jobs calling `PKG.PROC(a)` need one program
and four jobs, not four programs.

## The singular / plural trap

| Call | Parameter name |
|---|---|
| `CREATE_JOB` | `number_of_argument` — **singular** |
| `CREATE_PROGRAM` | `number_of_arguments` — **plural** |

Oracle uses the plural form everywhere. A dump converted by find-and-replace
will therefore be wrong for `CREATE_JOB`.

## Diagnostic: "job does not exist"

If `SET_JOB_ARGUMENT_VALUE` reports that the job does not exist, the
`CREATE_JOB` above it almost certainly failed. The most likely reason is
the plural `number_of_arguments` in `CREATE_JOB`, which raises:

```
PLS-00302: component 'NUMBER_OF_ARGUMENTS' must be declared
```

Check the job actually exists before debugging the argument call:

```sql
SELECT job_name, enabled, state FROM user_scheduler_jobs
 WHERE job_name = 'JOB_A';
```

## Diagnostic: `PLS-00306` at runtime

```
PLS-00306: wrong number or types of arguments in call to 'PROC'
```

The job was created with fewer arguments than the procedure requires.
Either supply the arguments (Strategy B/C) or confirm the procedure has
defaults for all parameters.

## `argument_type` must match the real signature

`SET_JOB_ARGUMENT_VALUE` only supports SQL types. Booleans are not
supported. If the procedure parameter is `NUMBER` or `DATE`, declare
`argument_type` accordingly — `VARCHAR2` is not a safe default.

```sql
SELECT argument_name, position, data_type, in_out, defaulted
  FROM all_arguments
 WHERE owner = '<OWNER>'
   AND object_name = 'PKG'
   AND in_out = 'IN'
 ORDER BY subprogram_id, position;
```

## Cross-check: jobs with arguments are often dead

A useful heuristic: if the set of jobs with `number_of_arguments > 0` is
**exactly** the set of jobs that are never `ENABLE`d in the dump, those
jobs were probably created by a script that never finished configuring
them, and have never run.

Confirm before investing effort:

```sql
SELECT job_name, COUNT(*) AS runs, MAX(log_date) AS last_run
  FROM dba_scheduler_job_run_details
 WHERE owner = '<OWNER>'
   AND job_name IN ('JOB_A','JOB_B')
 GROUP BY job_name;
```

Zero runs → deprioritise or exclude from scope.