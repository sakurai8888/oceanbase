# OceanBase PoC Testing Repository

This repository contains materials for **OceanBase database** related technical documents to illustrate OceanBase's functionality, performance, high availability, and Oracle compatibility.



### Docs (`docs/`)

- `test_case_lists.txt` — PoC test case index (numbering for `poc_scripts/`).
- `oracle_tenant_sql_diagnosis_views.md` — How to use
  `gv$ob_plan_cache_plan_stats`, `gv$ob_sql_audit`, and
  `gv$ob_sql_plan_monitor` in an Oracle tenant: column reference, view
  linkage, step-by-step SQL troubleshooting, and memory/storage control
  parameters.

### Linux (`scripts/linux/`)

- `linux_commands.md` — Useful shell one-liners (disk usage loops,
  find-and-delete patterns).



### Oceanbase (`scripts/oceanbase/`)

- `linux_commands.md` — Useful shell one-liners (disk usage loops,
  find-and-delete patterns).


## Requirements

- OceanBase database (Oracle mode for compatibility/TDE scripts)
- `obclient` or MySQL client to run the SQL scripts
- Java + Ant (for BenchmarkSQL)
- ob-loader-dumper (for import/export test cases)
