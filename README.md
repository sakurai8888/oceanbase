# OceanBase PoC Testing Repository

This repository contains materials for **OceanBase database** PoC (Proof of Concept)
testing — test case lists, SQL scripts, and benchmarking tools used to evaluate
OceanBase's functionality, performance, high availability, and Oracle compatibility.

## Repository Structure

```
.
├── README.md                  # This file
├── docs/
│   └── test_case_lists.txt    # Full PoC test case outline (Chinese)
├── scripts/
│   ├── oceanbase/             # OceanBase SQL scripts
│   │   ├── poc_test_scripts_to_upload.sql  # Oracle compatibility checks (test 6.15)
│   │   └── oceanbase_tde.sql               # TDE (Transparent Data Encryption) setup
│   └── linux/                 # Linux/shell scripts and snippets
│       └── linux_commands.md               # Handy shell one-liners for testing
├── poc_scripts/               # Extracted PoC scripts, organized by test case ID
│   ├── poc_5_1_1/             # Data loading test
│   └── poc_5_2_1/             # Data import/export test (ob-loader-dumper)
└── archives/                  # Packed toolkits and script bundles
    ├── benchmarksql-5.0.tar.gz
    ├── poc_scripts.tar.gz
    └── db_poc_scripts_131.zip.001 ~ .005
```

## Test Scope Overview

The test plan in `docs/test_case_lists.txt` covers:

1. **同城双活异地容灾** — Same-city active-active + remote disaster recovery
2. **运维管理能力** — Operations: monitoring, diagnostics, backup & recovery
3. **数据库性能** — Performance: data loading, import/export, DML, Databench-T
4. **数据库基础功能** — Core features: DDL/DML, partitioning, indexes, stored
   procedures, Oracle syntax compatibility, distributed transactions
5. **资源管理及扩缩容** — Resource management and scaling
6. **数据迁移与同步** — Data migration and synchronization
7. **安全性与兼容性** — Security (including TDE) and compatibility

## Scripts

### OceanBase SQL (`scripts/oceanbase/`)

- `poc_test_scripts_to_upload.sql` — SQL checks for Oracle compatibility
  (test case 6.15): `chr`, `trunc`, `nvl`, `nvl2`, `translate`, etc. Run against an
  OceanBase Oracle-mode tenant.
- `oceanbase_tde.sql` — Step-by-step TDE setup for an Oracle tenant:
  enable `tde_method`, create/open keystore, set master key, create encrypted
  tablespaces, and verify via `sys.V$OB_ENCRYPTED_TABLES`.
  Reference: [OceanBase TDE docs](https://en.oceanbase.com/docs/common-oceanbase-database-10000000001717360)

### Linux (`scripts/linux/`)

- `linux_commands.md` — Useful shell one-liners (disk usage loops,
  find-and-delete patterns).

## PoC Scripts (`poc_scripts/`)

Extracted from `archives/poc_scripts.tar.gz`. Each folder matches a test case ID
from the test case list:

- `poc_5_1_1/` — Data loading: `genfile.sh` generates data files,
  `create_table.sql` / `load_data.sql` create and load tables.
- `poc_5_2_1/` — Import/export with ob-loader-dumper: includes `import/`,
  `dump/` directories and `verify_table.sql` for validation.

## Archives

> **Note:** the `.tar.gz` files are actually plain (uncompressed) tar archives.
> Extract them with `tar xf <file>` — no `-z` flag.

- `archives/benchmarksql-5.0.tar.gz` — [BenchmarkSQL](https://github.com/pgsql-io/benchmarksql)
  5.0, a TPC-C-like benchmark tool used for the performance test cases (section 5.x).
  Extract: `tar xf benchmarksql-5.0.tar.gz`
- `archives/poc_scripts.tar.gz` — Original bundle of the extracted `poc_scripts/`.
- `archives/db_poc_scripts_131.zip.001` – `.005` — Split zip archive (~42 MB) with
  the full PoC script set (v1.31). Reassemble and extract:

  ```bash
  cat db_poc_scripts_131.zip.00* > db_poc_scripts_131.zip
  unzip db_poc_scripts_131.zip
  ```

## Requirements

- OceanBase database (Oracle mode for compatibility/TDE scripts)
- `obclient` or MySQL client to run the SQL scripts
- Java + Ant (for BenchmarkSQL)
- ob-loader-dumper (for import/export test cases)
