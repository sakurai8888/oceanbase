# `repeat_interval` — FREQ / BY* Pairing Rules

OceanBase enforces strict pairing between `FREQ` and the `BY*` clauses.
Oracle does not. This is the second most common cause of a failed
conversion, and it is **silent** — the job may be created but never fire,
or `next_run_date` comes back NULL.

## Pairing table (OceanBase 4.4.2)

| `FREQ` | Permitted `BY*` clauses |
|---|---|
| `YEARLY` | `BYMONTH` + `BYMONTHDAY`, **or** `BYYEARDAY`; then `BYHOUR` + `BYMINUTE` + `BYSECOND` |
| `MONTHLY` | `BYMONTHDAY` + `BYHOUR` + `BYMINUTE` + `BYSECOND` |
| `WEEKLY` | `BYDAY` + `BYHOUR` + `BYMINUTE` + `BYSECOND` |
| `DAILY` | `BYHOUR` + `BYMINUTE` + `BYSECOND` |
| `HOURLY` | `BYMINUTE` + `BYSECOND` **only** |
| `MINUTELY` | `BYSECOND` **only** |
| `SECONDLY` | No `BY*` clauses at all |

Read this as: the `FREQ` selects the granularity, and only the clauses
*below* that granularity may be used to refine it. `FREQ=HOURLY` already
fixes the hour, so `BYHOUR` is meaningless and rejected.

## Additional constraints

- **`INTERVAL` must precede the `BY*` clauses.**
  `freq=YEARLY;INTERVAL=2;BYMONTH=JUL` — correct.
  `freq=YEARLY;BYMONTH=JUL;INTERVAL=2` — rejected.
- **Negative `BYDAY` is not supported.** `BYDAY=-1FRI` raises
  `OB_PASSER_ERROR`. There is no equivalent for "last Friday of month";
  `BYMONTHDAY` is not a substitute. Escalate to the business.
- **`repeat_interval => NULL` raises an error.** Always supply a value.
- Multi-value lists (`BYHOUR=13,15,17`) are supported.
- Case is insensitive (`freq=` and `FREQ=` both work), but be consistent.

## Rewrite recipes

Oracle-legal combinations that OceanBase rejects, and their equivalents.
All rewrites below are **semantically identical** to the original.

### `FREQ=HOURLY` + `BYDAY` + `BYHOUR` → `FREQ=WEEKLY`

Oracle pattern: "every Friday at 14:00, 16:00, 18:00".

```sql
-- Oracle
FREQ=HOURLY;BYDAY=FRI;BYHOUR=14,16,18;BYMINUTE=0;BYSECOND=0
-- OceanBase
FREQ=WEEKLY;INTERVAL=1;BYDAY=FRI;BYHOUR=14,16,18;BYMINUTE=0;BYSECOND=0
```

### `FREQ=HOURLY` + `BYHOUR` → `FREQ=DAILY`

Oracle pattern: "every hour from 13:00 to 23:00".

```sql
-- Oracle
freq=HOURLY;byhour=13,14,15,16,17,18,19,20,21,22,23;byminute=0;bysecond=0
-- OceanBase
FREQ=DAILY;INTERVAL=1;BYHOUR=13,14,15,16,17,18,19,20,21,22,23;BYMINUTE=0;BYSECOND=0
```

### `FREQ=DAILY` + `BYDAY` → `FREQ=WEEKLY`

Oracle pattern: "Monday to Friday at 11:00".

```sql
-- Oracle
freq=daily;byday=MON,TUE,WED,THU,FRI;byhour=11;byminute=0;bysecond=0
-- OceanBase
FREQ=WEEKLY;INTERVAL=1;BYDAY=MON,TUE,WED,THU,FRI;BYHOUR=11;BYMINUTE=0;BYSECOND=0
```

## Patterns that are already valid — do not touch

| Intent | Expression |
|---|---|
| Every hour at :50 | `freq=HOURLY;interval=1;byminute=50;bysecond=0` |
| Every hour on the hour | `freq=HOURLY;interval=1;byminute=0;bysecond=0` |
| Daily at 07:00 | `FREQ=DAILY;INTERVAL=1;BYHOUR=7;BYMINUTE=0;BYSECOND=0` |
| Weekly Sunday 13:00 | `freq=weekly;interval=1;byday=SUN;byhour=13;byminute=0;bysecond=0` |
| Weekly Friday 15:00 | `FREQ=WEEKLY;INTERVAL=1;BYDAY=FRI;BYHOUR=15;BYMINUTE=0;BYSECOND=0` |
| Monthly 8th at 08:00 | `FREQ=MONTHLY;INTERVAL=1;BYMONTHDAY=8;BYHOUR=8;BYMINUTE=0;BYSECOND=0` |
| Monthly 1st at 11:00 | `freq=monthly;interval=1;bymonthday=1;byhour=11;byminute=0;bysecond=0` |
| Every 2 years, Apr 2 16:00 | `freq=yearly;interval=2;bymonth=4;bymonthday=2;byhour=16;byminute=0;bysecond=0` |

## OceanBase 4.2.x fallback

On 4.2.x only `FREQ` + `INTERVAL` are supported. Move the time-of-day
into `start_date` and drop every `BY*` clause:

```sql
-- 4.4.2
start_date      => TO_TIMESTAMP_TZ('2026-11-13 10:00:00 +08:00','YYYY-MM-DD HH24:MI:SS TZH:TZM'),
repeat_interval => 'FREQ=DAILY;INTERVAL=1;BYHOUR=10;BYMINUTE=0;BYSECOND=0'

-- 4.2.x equivalent
start_date      => TO_TIMESTAMP_TZ('2026-11-13 10:00:00 +08:00','YYYY-MM-DD HH24:MI:SS TZH:TZM'),
repeat_interval => 'FREQ=DAILY;INTERVAL=1'
```

Multi-value `BYHOUR` has **no** single-job equivalent on 4.2.x — one job
per hour is required. Flag this as a design change, not a mechanical
conversion.

## Validation

`next_run_date` is the cheapest way to validate every expression at once:

```sql
SELECT job_name,
       repeat_interval,
       TO_CHAR(next_run_date,'YYYY-MM-DD HH24:MI:SS') AS next_run
  FROM user_scheduler_jobs
 ORDER BY job_name;
```

- `next_run` NULL → the expression is invalid or `start_date` is in the past
  with no future occurrence.
- `next_run` at an unexpected time → the `BY*` clauses were misread.

Spot-check the multi-value cases with a manual `RUN_JOB` before trusting
the schedule.