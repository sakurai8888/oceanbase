# OceanBase OAT All-In-One Component Deployment Guide

This guide details the step-by-step procedures for deploying MetaDB, InfluxDB, and OMS (OceanBase Migration Service) via OceanBase Admin Toolkit (OAT).

---
## 0. Linux Server Setup

## 1. Add Server in OAT  

OAT System Parameter Configuration (Bypass Server Dependency).
Before adding servers in OAT, update the system parameter configuration to ignore missing host package dependencies (such as legacy `python2`).

1. Navigate to **Systems and... (系统与安全)** $\rightarrow$ **System parameters (系统参数)**.
2. Locate `oat.server.ignore_deps` in the parameter table and click **Modify**.
3. Change the parameter value from `["python3"]` to `["python3","python2"]`.
4. Click **Sure**.

![System Parameters Ignore Dependencies][img_system_params]

---

## 2. MetaDB Installation & Configuration

MetaDB serves as the metadata database cluster for OAT and OceanBase management services.

### 2.1 Installation Paths
In the MetaDB deployment wizard, set the following disk paths:

* **Installation Directory:** `/data/admin/oceanbase`
* **Data Directory:** `/data/medadb/data/1`
* **Log Directory:** `/data/medadb/data/log1`
* **Backup Directory:** *(Optional / Leave Blank)*

![MetaDB Installation Paths][img_metadb_paths]

### 2.2 Server Resource Allocation
Select the target host and assign adequate system resources:

* **Server:** `10.170.0.2` (or your host IP)
* **CPU:** `8 C`
* **Memory:** `20 G`

> **CRITICAL REQUIREMENT:** MetaDB Docker System Memory must be set to **greater than 10GB** (`system_memory >= 10G`).

![MetaDB Server Resource Settings][img_metadb_resources]

### 2.3 OceanBase Startup Parameters
Configure ports and resource pool parameters as follows:

| Parameter Name | Parameter Value | Value Range / Reference |
| :--- | :--- | :--- |
| **MySQL Port** | `2881` | Standard MySQL client protocol port |
| **RPC Port** | `2882` | OceanBase internal communication port |
| **`system_memory`** | `10G` | Minimum required for system memory |
| **`__min_full_resource_pool_memory`** | `1073741824` | Resource pool allocation byte limit |
| **`datafile_disk_percentage`** | `90` | Percentage of disk space for data |
| **`log_disk_percentage`** | `90` | Percentage of disk space for logs |
| **`datafile_size`** | `30G` | Pre-allocated data file size |
| **`log_disk_size`** | `30G` | Pre-allocated log file size |

![MetaDB Startup Parameters][img_metadb_startup_params]

### 2.4 Task Execution & Verification
After launching the installation task (Task ID: 5), verify that all 9 execution steps complete successfully:

![MetaDB Task Completion Log][img_metadb_task_log]

**Post-Installation Path Verification:**
Inspect the OBServer runtime location on the host:
```bash
ls -la /data/admin/oceanbase
```
*(This directory contains the `meta_db` cluster OBServer binaries and process logs).*

---

## 3. InfluxDB Installation

InfluxDB handles time-series metric aggregation for cluster monitoring.

### 3.1 Basic Configuration & Directory Settings
* **InfluxDB Mirror:** `influxdb_1.8.tar.gz`
* **Version:** `1.8` (`x86_64`)
* **Component Name:** `influxdb`
* **Server:** `10.170.0.2`
* **CPU:** `2 C`
* **Memory:** `8 G`
* **Data Directory:** `/data/influxdb`
* **Service Port:** `8086`

![InfluxDB Basic Configuration][img_influxdb_config]

### 3.2 Task Verification
Verify task execution (Task ID: 6) until status displays **Completed (5/5)**:

![InfluxDB Task Completion Log][img_influxdb_task_log]

---

## 4. Docker Container Health Check

After completing MetaDB and InfluxDB deployments, run `docker ps -a` on the host to verify container execution states:

```bash
docker ps -a
```

![Docker PS Output][img_docker_ps]

*Expected Active Containers:*
* `influxdb` (`influxdb:1.8`) — **Up**
* `metadb` (`reg.docker.alibaba-inc.com/devtools/metadb:...`) — **Up**
* `oat` (`reg.docker.alibaba-inc.com/oceanbase/oat:...`) — **Up**

---

## 5. OMS (OceanBase Migration Service) Installation

### 5.1 Deployment Mode Selection
Select **Standalone Mode (单体模式)** to deploy all OMS control plane and worker components inside a unified image container.

![OMS Deployment Mode][img_oms_mode]

### 5.2 Basic Configuration
* **OMS Mirror:** `oms-4.3.2_bp3_x86_all_in_one-amd64-1202605111449.tar`
* **Product Name:** `oms`
* **Region:** `ASIA`
* **Server:** `10.170.0.2`
* **CPU:** `4 C`
* **Memory:** `16 G`
* **HTTP Port:** `8089` (or default management port)
* **Data Directory:** `/data/admin/oms`

![OMS Basic Configuration][img_oms_basic_config]

### 5.3 MetaDB Configuration
Bind OMS to the newly created MetaDB cluster:
* **MetaDB Type:** `MetaDB has been created.`
* **Select MetaDB:** `metadb`
* **Tenant Name:** `oms_meta`
* **Tenant CPU:** `2 C`
* **Tenant Memory:** `4 G`

![OMS MetaDB Binding][img_oms_metadb_config]

### 5.4 InfluxDB Configuration
Bind OMS to the time-series metric storage:
* **Time series database storage:** `InfluxDB has been created.`
* **Select InfluxDB:** `influxdb`
* **Database Account:** `influxdb_user`

![OMS InfluxDB Binding][img_oms_influxdb_config]

### 5.5 Load Balancing Configuration
* **Load Balancing Mode:** Select **`do not use`** (direct IP connectivity).

![OMS Load Balancing Configuration][img_oms_lb_config]

### 5.6 Task Execution & Access Information
Upon launching Task ID 7, verify progress reaches **Completed (14/14)**.

![OMS Task Completion Log][img_oms_task_log]

#### Web Access & Credentials Summary

* **OAT Web Console:** `http://<SERVER_IP>:7000/product`
  * **Default Username:** `admin`
  * **Default Password:** `aaAA11__`
* **OMS Web Console:** `http://<SERVER_IP>:8089` (or `8088`)
  * **Default Username:** `admin`
  * **Default Password:** `aa` (or `aaAA11__`)

---

<!-- Embedded Base64 Image Reference Definitions -->
[img_system_params]: data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==
[img_metadb_paths]: data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==
[img_metadb_resources]: data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==
[img_metadb_startup_params]: data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==
[img_metadb_task_log]: data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==
[img_influxdb_config]: data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==
[img_influxdb_task_log]: data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==
[img_docker_ps]: data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==
[img_oms_mode]: data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==
[img_oms_basic_config]: data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==
[img_oms_metadb_config]: data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==
[img_oms_influxdb_config]: data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==
[img_oms_lb_config]: data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==
[img_oms_task_log]: data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==