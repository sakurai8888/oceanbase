---
name: oracle-to-ob-scheduler
description: Convert Oracle DBMS_SCHEDULER job DDL (CREATE_JOB, CREATE_PROGRAM, chains, NLS_ENV, repeat_interval, job arguments) into OceanBase Oracle-mode compatible DDL, and diagnose job scripts that fail on OceanBase. Use when migrating Oracle scheduler jobs to OceanBase 4.x, when a converted job script raises PLS-00302 / ORA-27476 / ORA-27468 / OB_PASSER_ERROR, when repeat_interval is rejected, or when asked to extract, convert, validate or clean up Oracle scheduler job DDL for an OceanBase tenant.
---

# Oracle → OceanBase DBMS_SCHEDULER Job Conversion

Convert Oracle `DBMS_SCHEDULER` job DDL into DDL that actually runs on an
OceanBase Oracle-mode tenant, and diagnose the failures that conversion
typically produces.

## When to use this skill

- A `.sql` dump of Oracle `DBMS_SCHEDULER` objects must be migrated to OceanBase.
- A job script already converted to OceanBase fails at `CREATE_JOB` or at runtime.
- A `repeat_interval` is rejected by OceanBase.
- Jobs with arguments must be migrated (this is where most conversions break).
- A customer-facing, comment-free version of the job script is needed.

## Non-negotiable first step: establish the target version

The conversion rules differ by version. **Never convert without knowing the
target version.** Ask, or run:

```sql
SELECT * FROM v$version;
SELECT value FROM v$parameter WHERE name = 'compatible';
```

Version-sensitive behaviour:

| Feature | 4.2.x | 4.4.2 |
|---|---|---|
| `repeat_interval` BY-clauses (`BYHOUR`, `BYDAY`, `BYMONTHDAY`, …) | **Not supported** — only `FREQ` + `INTERVAL` | Fully supported |
| `SET_JOB_ARGUMENT_VALUE` | May be absent | Supported |
| `DBMS_JOB` | Not supported | Supported |

If the version is unknown, produce the 4.4.2 form and flag the BY-clause
dependency explicitly.

## Workflow

### Step 0 — Try the helper script first

`scripts/convert_jobs.py` applies R1–R8 mechanically and reports what it
could not resolve. Use it to get a first draft, then review.

```bash
# Report only — see what will be flagged before writing anything
python3 scripts/convert_jobs.py dump.sql --report-only

# Produce the converted script
python3 scripts/convert_jobs.py dump.sql -o converted.sql --version 4.4.2
```

The script never invents argument values and never guesses a time zone
offset. Anything it cannot resolve is printed under `ACTION REQUIRED`.
Treat its output as a draft, not a deliverable.

### Step 1 — Inventory the source

Parse the dump and classify every object:

| Object | Action |
|---|---|
| `CREATE_JOB` with `job_type => 'STORED_PROCEDURE'` | Convert (main path) |
| `CREATE_JOB` with `job_type => 'CHAIN'` | **Out of scope** — needs programs, chain steps, rules |
| `CREATE_PROGRAM` | Only needed if a job references `program_name` |
| `CREATE_CHAIN` / `DEFINE_CHAIN_STEP` | Out of scope for a job-only migration |
| `dbms_rule_imp_obj.import_*` | Rule sets — out of scope |
| `set_attribute(...,'NLS_ENV',...)` | Delete |
| `ALTER SESSION SET EVENTS '10xxx TRACE ...'` | Delete (Oracle-internal) |

Report the counts up front. A dump with 80 jobs often contains only a
subset of `STORED_PROCEDURE` jobs; the rest may be chains that need a
different treatment entirely.

### Step 2 — Apply the mechanical rules

See `references/conversion-rules.md` for the full rule table (R1–R8) and
the OceanBase capability matrix.

The five that break scripts most often:

1. `number_of_arguments` → **`number_of_argument`** (singular) in `CREATE_JOB`.
2. `job_class => '"DEFAULT_JOB_CLASS"'` → `job_class => 'DEFAULT_JOB_CLASS'`.
3. `NLS_ENV` attribute → delete.
4. `TO_TIMESTAMP_TZ(..., 'ASIA/HONG_KONG', ...)` → explicit `+08:00` offset, drop the 3rd parameter.
5. `job_name => '"X"'` → `job_name => 'X'`.

### Step 3 — Rewrite every `repeat_interval`

This is the highest-risk step. OceanBase enforces strict `FREQ` + `BY*`
pairing that Oracle does not. See `references/repeat-interval.md`.

Validate each expression against the pairing table. Oracle-legal
combinations that OceanBase rejects must be re-based onto a different
`FREQ`:

| Oracle (illegal on OB) | OceanBase equivalent |
|---|---|
| `FREQ=HOURLY;BYDAY=FRI;BYHOUR=14` | `FREQ=WEEKLY;BYDAY=FRI;BYHOUR=14` |
| `FREQ=HOURLY;BYHOUR=13,15,17` | `FREQ=DAILY;BYHOUR=13,15,17` |
| `FREQ=DAILY;BYDAY=MON,TUE,WED,THU,FRI` | `FREQ=WEEKLY;BYDAY=MON,TUE,WED,THU,FRI` |

### Step 4 — Triage arguments

Jobs with `number_of_arguments > 0` are the usual failure point. See
`references/arguments.md` for the decision tree.

Critical facts:

- OceanBase has **no `DEFINE_JOB_ARGUMENT`**. Only `DEFINE_PROGRAM_ARGUMENT`.
- For an **inline** job (`job_action`), set values **positionally** with
  `SET_JOB_ARGUMENT_VALUE(job, position, value)` — no definition step.
- For **named** arguments or `job_style => 'LIGHTWEIGHT'`, you must go
  through `CREATE_PROGRAM` + `DEFINE_PROGRAM_ARGUMENT` + `CREATE_JOB(program_name=>...)`.
- `CREATE_PROGRAM` uses `number_of_arguments` (plural);
  `CREATE_JOB` uses `number_of_argument` (singular). This asymmetry is a
  documented trap.

**Never invent argument values.** If the dump does not contain them,
emit placeholders and provide the query to collect them from the source
database.

### Step 5 — Emit the script in sections

Structure the output so it can be executed and verified incrementally:

```
SECTION 0  Pre-checks (commented-out SQL)
SECTION 1  CREATE_JOB × N, all enabled => FALSE
SECTION 2  ENABLE × M (only jobs enabled in source)
SECTION 3  SET_JOB_ARGUMENT_VALUE (if applicable)
SECTION 4  Verification queries
SECTION 5  Rollback (DROP_JOB × N, commented out)
SECTION 6  Notes / known risks
```

Creating everything disabled first is deliberate: it lets the scheduling
layer be validated before any heavy batch job fires.

### Step 6 — Verify

See `references/verification.md`. The single most valuable check is
`next_run_date` — it validates all N `repeat_interval` expressions in one
query. A NULL or unexpected `next_run_date` means that expression is
still invalid.

## Hard rules

- **Do not invent values.** Argument values, procedure signatures, and
  business schedules must come from the source or the user.
- **Do not silently drop jobs.** If a job cannot be converted, list it
  explicitly with the reason.
- **Preserve `comments =>` payloads.** These are data written to
  `USER_SCHEDULER_JOBS.COMMENTS`, not SQL comments. Chinese text is
  common; keep it and warn about client charset.
- **Preserve the source enable state.** If a job is disabled in Oracle,
  do not enable it on OceanBase.
- **`start_date` in the past** means the job may fire immediately after
  `ENABLE`. Flag this and offer `SYSTIMESTAMP` as an alternative.
- **`job_action` cannot reference a procedure with OUT/INOUT
  parameters.** OceanBase rejects it. A pure-IN wrapper is required.

## Diagnosing a failed conversion

| Symptom | Likely cause |
|---|---|
| `PLS-00302: component 'NUMBER_OF_ARGUMENTS' must be declared` | Used Oracle's plural form in `CREATE_JOB` |
| `SET_JOB_ARGUMENT_VALUE` reports "job does not exist" | The `CREATE_JOB` above it failed — the job was never created |
| `ORA-27476` / invalid argument on `job_class` | Double-quoted `'"DEFAULT_JOB_CLASS"'` |
| `OB_PASSER_ERROR` on `repeat_interval` | Illegal `FREQ` + `BY*` pairing, or negative `BYDAY` |
| Job created but never fires | `start_date`/`repeat_interval` produced a NULL `next_run_date` |
| `PLS-00306` at runtime | Argument count mismatch — job created with 0 args but procedure needs N |
| `ORA-06550` / `PLS-00905` | `job_action` object is INVALID on the target |

## Files in this skill

- `references/conversion-rules.md` — rule table R1–R8, capability matrix
- `references/repeat-interval.md` — FREQ/BY pairing, rewrite recipes
- `references/arguments.md` — argument decision tree, program variant
- `references/verification.md` — verification and rollback SQL
- `assets/job_template.sql` — annotated single-job template
- `assets/sample_oracle_dump.sql` — 3-job test fixture for the script
- `scripts/convert_jobs.py` — mechanical converter + issue reporter