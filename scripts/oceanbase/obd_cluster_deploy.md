# OBD Cluster Deploy Configuration

```yaml
user:
  username: root
  password: passwordpassword
  port: 22
oceanbase:
  version: 4.3.5.3
  release: 103060032025102011.el7
  package_hash: 32a2c5fc0ce82b39cc88bf31c5c0beec70e9aaf8
  192.168.1.200:
    zone: zone1
  servers:
  - 192.168.1.200
  global:
    appname: obclu
    root_password: passwordpassword
    mysql_port: 2881
    rpc_port: 2882
    home_path: /home/obadmin/oceanbase
    data_dir: /data/1
    redo_dir: /data/log1
    obshell_port: 2886
    memory_limit: 20GB
    datafile_size: 60GB
    log_disk_size: 25GB
    proxyro_password: passwordpassword
    scenario: htap
    enable_syslog_wf: false
    max_syslog_file_count: 16
    system_memory: 2G
    cpu_count: 16
obproxy:
  version: 4.3.1.4
  package_hash: 7b0647d19f2677b8ba6d5ba7ff0d5f18b6d8ed7a
  release: 242025032019.el7
  servers:
  - 192.168.1.200
  global:
    home_path: /home/obadmin/obproxy
    prometheus_listen_port: 2884
    listen_port: 2883
    enable_obproxy_rpc_service: false
    obproxy_sys_password: passwordpassword
    skip_proxy_sys_private_check: true
    enable_strict_kernel_release: false
    enable_cluster_checkout: false
  depends:
  - oceanbase
  192.168.1.200:
    proxy_id: 7584
    client_session_id_version: 2
```
