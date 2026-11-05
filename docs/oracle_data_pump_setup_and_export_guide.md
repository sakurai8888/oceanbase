# Oracle Data Pump Schema Metadata Export & DDL Extraction Guide

This guide details the procedure for setting up Oracle Data Pump directories, running a metadata-only schema export, and generating a portable DDL SQL script from the resulting dump file.

---

## Step 1: Directory Setup & Database Mapping

Before executing Data Pump commands, you must create a physical folder on the server's operating system and map it to an Oracle Directory Object within the database instance.

```sql
-- Create the physical operating system directory (if executing inside SQL*Plus / SQLcl shell)
host mkdir -p /tmp/dpdump

-- Map the OS path to an Oracle Database Directory Object
CREATE OR REPLACE DIRECTORY DIR_DUMP AS '/tmp/dpdump';

-- Grant mandatory read/write permissions to the target schema user
GRANT READ, WRITE ON DIRECTORY DIR_DUMP TO ora_user01;
```

### Parameter Breakdown
* **`host mkdir -p /tmp/dpdump`**: Ensures the physical path exists on the database server file system.
* **`CREATE OR REPLACE DIRECTORY DIR_DUMP`**: Creates a logical database pointer (`DIR_DUMP`) mapping to `/tmp/dpdump`.
* **`GRANT READ, WRITE`**: Provides `ora_user01` with OS file creation and access rights through Oracle's security model.

---

## Step 2: Export Schema Metadata (`expdp`)

Extract the database object definitions for schema `ORA_USER01` without including data rows or optimizer statistics.

```bash
expdp ora_user01/Aa12345678@//localhost:1521/freepdb1 \
  schemas=ORA_USER01 \
  content=METADATA_ONLY \
  exclude=STATISTICS \
  directory=DIR_DUMP \
  dumpfile=ora_user01_meta.dmp \
  logfile=ora_user01_meta.log
```

### Parameter Breakdown
* **`schemas=ORA_USER01`**: Specifies that only objects belonging to the `ORA_USER01` schema will be exported.
* **`content=METADATA_ONLY`**: Instructs Data Pump to extract DDL structure definitions (tables, views, indexes, triggers, stored procedures) while excluding data rows.
* **`exclude=STATISTICS`**: Prevents export worker (`DW00`) crashes caused by metadata handler issues with optimizer statistics in certain database releases.
* **`directory=DIR_DUMP`**: References the database directory object where output files will be saved.
* **`dumpfile=ora_user01_meta.dmp`**: Specifies the name of the generated binary Data Pump dump file.
* **`logfile=ora_user01_meta.log`**: Specifies the log file for monitoring export progress and errors.

---

## Step 3: Extract Clean DDL SQL File (`impdp`)

Convert the binary dump file into a clean, human-readable `.sql` script without executing any changes against the database.

```bash
impdp ora_user01/Aa12345678@//localhost:1521/freepdb1 \
  directory=DIR_DUMP \
  dumpfile=ora_user01_meta.dmp \
  sqlfile=ora_user01_ddl.sql \
  transform=SEGMENT_ATTRIBUTES:n
```

### Parameter Breakdown
* **`sqlfile=ora_user01_ddl.sql`**: Instead of importing objects into the database, Data Pump writes all `CREATE` DDL statements directly to a plain-text SQL file inside `DIR_DUMP`.
* **`transform=SEGMENT_ATTRIBUTES:n`**: Omits storage and physical attributes (such as `TABLESPACE`, `INITIAL`, `NEXT`, `PCTFREE`) from the output. This produces clean, environment-agnostic DDL scripts suitable for deployment to other databases or version control systems.