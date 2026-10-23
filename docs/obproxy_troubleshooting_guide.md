# OceanBase OBProxy Connection Troubleshooting Guide

This document records the step-by-step diagnostic and resolution procedure for fixing OBProxy (Port 2883) connection failures in an OceanBase cluster environment.

---

## 1. Environment Details

* **OBServer Node IP:** `192.168.1.200`
* **OBServer Direct SQL Port:** `2881`
* **OBProxy Port:** `2883`
* **Target Cluster Name:** `obclu`
* **Target Tenant Name:** `oratenant01`
* **Target User:** `ora_user01` / `sys`
* **OBD Cluster Name:** `myobcluster02`

---

## 2. Issue Summary & Root Cause Analysis

### Issue 1: Cluster Not Recognized
* **Symptom:** Executing `obclient -h192.168.1.200 -P2883 -uora_user01@oratenant01#obclu -p` returned `ERROR 4669 (HY000): cluster not exist`.
* **Root Cause:** OBProxy's configuration parameter `rootservice_cluster_name` was set to `undefined`. As a result, OBProxy failed to map incoming client requests containing `#obclu` to its registered RootServer list.

### Issue 2: Immediate Socket Disconnect
* **Symptom:** After setting the cluster name, connecting via port 2883 returned `ERROR 2013 (HY000): Lost connection to MySQL server at 'reading authorization packet', system error: 11`.
* **Root Cause:** OBProxy relies on an internal background account (`proxyro@sys`) to connect to OBServer (Port 2881) and fetch tenant routing metadata. The password configured in OBProxy (`observer_sys_password`) did not match the password of `proxyro@sys` in OBServer, causing authentication to fail and OBProxy to terminate the client socket.

---

## 3. Step-by-Step Resolution

### Step 1: Map Cluster Name in OBProxy

1. Connect to the OBProxy administrative console on port 2883:
   ```bash
   obclient -h192.168.1.200 -P2883 -uroot@proxysys -p'tabi2601@@@'
   ```

2. Assign the actual cluster name (`obclu`) to OBProxy:
   ```sql
   ALTER PROXYCONFIG SET rootservice_cluster_name = 'obclu';
   ```

3. Confirm the parameter was updated:
   ```sql
   SHOW PROXYCONFIG LIKE '%root%';
   ```

---

### Step 2: Restart OBProxy

Because `rootservice_cluster_name` requires a restart (`need_reboot = true`), restart OBProxy using OBD:

```bash
obd cluster restart myobcluster02 -c obproxy
```

---

### Step 3: Align `proxyro` Internal Service Credentials

1. Connect directly to OBServer on port 2881 as the system administrator:
   ```bash
   obclient -h192.168.1.200 -P2881 -uroot@sys -p
   ```

2. Reset the `proxyro` password and ensure appropriate permissions are granted:
   ```sql
   -- Set password for proxyro account
   ALTER USER proxyro IDENTIFIED BY 'proxyro_123';

   -- Grant global metadata read permissions
   GRANT SELECT ON *.* TO proxyro;
   ```

3. Connect back to the OBProxy administrative console:
   ```bash
   obclient -h192.168.1.200 -P2883 -uroot@proxysys -p'tabi2601@@@'
   ```

4. Update OBProxy's stored credential for OBServer authentication:
   ```sql
   ALTER PROXYCONFIG SET observer_sys_password = 'proxyro_123';
   ```

---

### Step 4: Verify Client Connections

Test tenant access through OBProxy (Port 2883) using the standard connection string format:

```bash
obclient -h192.168.1.200 -P2883 -uora_user01@oratenant01#obclu -pAa12345678
```

---

## 4. OceanBase Connection Format Reference

| Target Engine / Console | Port | Connection String Format | Example |
| :--- | :--- | :--- | :--- |
| **OBServer (Direct)** | `2881` | `username@tenant` | `obclient -h192.168.1.200 -P2881 -usys@oratenant01 -p` |
| **OBProxy (Routed)** | `2883` | `username@tenant#cluster_name` | `obclient -h192.168.1.200 -P2883 -uora_user01@oratenant01#obclu -p` |
| **OBProxy Admin Console** | `2883` | `root@proxysys` | `obclient -h192.168.1.200 -P2883 -uroot@proxysys -p` |