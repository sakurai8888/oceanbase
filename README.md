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

- `Partition_test.sql` — Range-partitioned table example with global
  partitioned index and SPLIT PARTITION demonstration.
- `oracle_tenant_plsql_loop.sql` — PL/SQL loop patterns, function,
  and procedure examples for Oracle-mode tenants.
- `oceanbase_tde.sql` — Transparent Data Encryption (TDE) setup example.
- `poc_6_1-14.sql` — PoC test script bundle for section 6.

### Oracle (`scripts/oracle/`)

- `oracle_demo_schema.sql` — Self-contained Oracle-mode demo schema
  covering tables, partitions, indexes, triggers, sequences, types,
  functions, procedures, packages, views, and synonyms.



## Requirements

- OceanBase database (Oracle mode for compatibility/TDE scripts)
- `obclient` or MySQL client to run the SQL scripts
- Java + Ant (for BenchmarkSQL)
- ob-loader-dumper (for import/export test cases)
