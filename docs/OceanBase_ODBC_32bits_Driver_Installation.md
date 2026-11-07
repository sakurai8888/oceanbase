# OceanBase 32-Bit ODBC Driver Installation & Configuration Manual

**Target OS:** Red Hat Enterprise Linux 8 / UBI 8 (x86_64)  
**Target Package:** `oceanbase-odbc32-candidate-2.0.9.11-1.el8.i686.rpm`  
**Architecture:** 32-bit (`i686`) driver execution on a 64-bit (`x86_64`) system

---

## 1. RPM Dependency Installation

Install prerequisite 32-bit libraries prior to installing the OceanBase ODBC package. Navigate to rpm directory and execute the installation sequence.

### Step 1.1: Install 32-bit Core C Library (`glibc.i686`)
```bash
rpm -ivh glibc-2.28-251.el8_10.48.i686.rpm
```
*Output:*
```text
Verifying...                         ################################# [100%]
Preparing...                         ################################# [100%]
Updating / installing...
   1:glibc-2.28-251.el8_10.48        ################################# [100%]
```

### Step 1.2: Install 32-bit GLIBC Gconv Modules (`glibc-gconv-extra.i686`)
Required for multi-byte character encoding conversions (`iconv`).
```bash
rpm -ivh glibc-gconv-extra-2.28-251.el8_10.48.i686.rpm
```
*Output:*
```text
Verifying...                         ################################# [100%]
Preparing...                         ################################# [100%]
Updating / installing...
   1:glibc-gconv-extra-2.28-251.el8_10################################# [100%]
```

### Step 1.3: Install 32-bit Compression Library (`zlib.i686`)
```bash
rpm -ivh zlib-1.2.11-25.el8.i686.rpm
```
*Output:*
```text
Verifying...                         ################################# [100%]
Preparing...                         ################################# [100%]
Updating / installing...
   1:zlib-1.2.11-25.el8               ################################# [100%]
```

### Step 1.4: Install 32-bit OpenSSL Shared Libraries (`openssl-libs.i686`)
Provides 32-bit TLS/SSL connectivity primitives (`libssl.so.1.1`, `libcrypto.so.1.1`).
```bash
rpm -ivh openssl-libs-1.1.1k-18.el8_6.i686.rpm
```
*Output:*
```text
Verifying...                         ################################# [100%]
Preparing...                         ################################# [100%]
Updating / installing...
   1:openssl-libs-1:1.1.1k-18.el8_6  ################################# [100%]
```



### Step 1.5: Install OceanBase 32-Bit ODBC Candidate Driver
```bash
rpm -ivh oceanbase-odbc32-candidate-2.0.9.11-1.el8.i686.rpm
```
*Output:*
```text
Verifying...                         ################################# [100%]
Preparing...                         ################################# [100%]
Updating / installing...
   1:oceanbase-odbc32-candidate-2.0.9.################################# [100%]
```

---

## 2. Environment Variables Setup

Set the active shell environment variables to point unixODBC and the dynamic loader to the OceanBase 32-bit installation tree under `/opt/oceanbase-odbc32/`:

```bash
export ODBCSYSINI=/opt/oceanbase-odbc32/etc
export ODBCINI=/opt/oceanbase-odbc32/etc/odbc.ini
export LD_LIBRARY_PATH=/opt/oceanbase-odbc32/unixodbc/lib:$LD_LIBRARY_PATH
```

---

## 3. Driver & Shared Library Diagnostics

### Step 3.1: Verify Driver Binary Properties
```bash
file /opt/oceanbase-odbc32/lib/libobodbc.so
```
*Output:*
```text
/opt/oceanbase-odbc32/lib/libobodbc.so: ELF 32-bit LSB shared object, Intel 80386, version 1 (SYSV), dynamically linked, BuildID[sha1]=ae5a3dc6d161ed37717d0fb76849afe032be412d, with debug_info, not stripped
```

### Step 3.2: Verify Dynamic Library Linkages (`ldd`)
```bash
ldd /opt/oceanbase-odbc32/lib/libobodbc.so
```
*Expected Output:*
```text
        linux-gate.so.1 (0xf7ef2000)
        libodbcinst.so.2 => /opt/oceanbase-odbc32/unixodbc/lib/libodbcinst.so.2 (0xf7dbc000)
        libm.so.6 => /lib/libm.so.6 (0xf7ce7000)
        libpthread.so.0 => /lib/libpthread.so.0 (0xf7cc7000)
        libdl.so.2 => /lib/libdl.so.2 (0xf7cc2000)
        libssl.so.1.1 => /lib/libssl.so.1.1 (0xf7c26000)
        libcrypto.so.1.1 => /lib/libcrypto.so.1.1 (0xf7956000)
        libc.so.6 => /lib/libc.so.6 (0xf77ae000)
        /lib/ld-linux.so.2 (0xf7ef4000)
        libz.so.1 => /lib/libz.so.1 (0xf7794000)
```
*(All 32-bit shared object dependencies resolve cleanly without any `not found` status).*

### Step 3.3: Verify unixODBC Configuration Paths (`odbcinst -j`)
```bash
/opt/oceanbase-odbc32/unixodbc/bin/odbcinst -j
```
*Output:*
```text
unixODBC 2.3.14
DRIVERS............: /opt/oceanbase-odbc32/etc/odbcinst.ini
SYSTEM DATA SOURCES: /opt/oceanbase-odbc32/etc/odbc.ini
FILE DATA SOURCES..: /opt/oceanbase-odbc32/etc/ODBCDataSources
USER DATA SOURCES..: /opt/oceanbase-odbc32/etc/odbc.ini
SQLULEN Size.......: 4
SQLLEN Size........: 4
SQLSETPOSIROW Size.: 2
```

---

## 4. Configuration Files

### Step 4.1: Driver Definition (`/opt/oceanbase-odbc32/etc/odbcinst.ini`)

Ensure `/opt/oceanbase-odbc32/etc/odbcinst.ini` contains the exact driver definition section:

```ini
[OceanBase32]
Description=OceanBase ODBC 2.0.9.11 i686 candidate
Driver=/opt/oceanbase-odbc32/lib/libobodbc.so
```

### Step 4.2: Data Source Name Definition (`/opt/oceanbase-odbc32/etc/odbc.ini`)

Edit `/opt/oceanbase-odbc32/etc/odbc.ini` to define the target OceanBase database DSN (`[OBDSN]`):

```ini
[OBDSN]
Driver=OceanBase32
SERVER=<IP Address>
PORT=2883
USER=IATEST@IMH#OB
Password=***********
DATABASE=IATEST
CHARSET=utf8mb4
```

---

## 5. Database Connection Validation

Establish a connection using the 32-bit `isql` utility:

```bash
/opt/oceanbase-odbc32/unixodbc/bin/isql OBDSN IATEST@IMH#OB ************
```

*Successful Connection Output:*
```text
+---------------------------------------+
| Connected!                            |
|                                       |
| sql-statement                         |
| help [tablename]                      |
| echo [string]                         |
| quit                                  |
|                                       |
+---------------------------------------+
SQL>
```