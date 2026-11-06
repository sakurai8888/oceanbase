# HashiCorp Vault




## 第一种方案
让 Vault 调用 OCP API 修改用户密码，这样 OCP 和 Vault 都会记录修改后的新密码，类似如下：

<img src="https://intranetproxy.alipay.com/skylark/lark/0/2025/png/29656635/1748228349313-ea2475d0-fc6c-40aa-a399-2c5561349034.png" width="1000" title="" crop="0,0,1,1" id="uf9cbde6e" class="ne-image">

配置数据库连接，定义 vault root 用户，其实就是一个 OCP 具有修改所有集群租户下用户的用户：

```shell
vault write database-cmd/config/my-database \
    plugin_name="vault-plugin-database-cmd" \
    plugin_version="v0.1.0" \
    allowed_roles="*" \
    username="VAULTTEST" \
    password="********" \
    root_rotation_statements="curl -sX PUT -H 'Content-Type: application/json' --user {{username}}:{{root_password}} "https://<OCP Address>/api/v2/profiles/me/changePassword" -d '[\"currentPassword\":\"{{root_password}}\",\"newPassword\":\"{{password}}\"]'"
```

创建一个静态角色，关联到一个已经存在的数据库用户：

```shell
vault write database-cmd/static-roles/my-role2 \
    db_name=my-database \
    username="VAULTTEST1" \
    rotation_schedule="*/2 * * * *" \
    rotation_statements="curl -sX POST -H 'Content-Type: application/json' --user {{root_username}}:{{root_password}} -d '{\"newPassword\":\"{{password}}\"}' https://<OCP Address>/api/v2/ob/clusters/1000002/tenants/800003/users/{{username}}/changePassword"
```

创建一个动态角色，关联到一个新建的数据库用户：

```shell
vault write database-cmd/roles/my-role1 \
	db_name=my-database \
  // 这段 API 要改
	creation_statements="curl -sX POST -H 'Content-Type: application/json' --user {{root_username}}:{{root_password}} -d '{\"username\":\"{{username}}\",\"password\":\"{{password}}\", \"globalPrivileges\":[\"CREATE SESSION\", \"SELECT ANY DICTIONARY\"]}' https://<OCP Address>/api/v2/ob/clusters/1000002/tenants/800003/users"  \
  revocation_statements="curl -sX DELETE -H 'Content-Type: application/json' --user {{root_username}}:{{root_password}} https://<OCP Address>/api/v2/ob/clusters/1000002/tenants/800003/users/{{username}}"  \
    default_ttl="1h" \
    max_ttl="24h"
```

#### 第一处修改
需要注意，由于是 OCP 去创建用户，因此用户名格式要遵守 OCP 的要求，其中最大字符不能超过 30 个，插件默认是 64，因此要做修改，如下：

```go
const (
    defaultTimeout = 20000 * time.Millisecond
    // 这里控制的是 displayName 和 roleName 的最大长度，建议改小到比如 3.
    maxKeyLength   = 64
    scriptCommand  = "/bin/bash"
)
```

这个地方也要修改，保证最终生成的用户名不超过 10：

```go
	username, err := credsutil.GenerateUsername(
		credsutil.DisplayName(req.UsernameConfig.DisplayName, maxKeyLength),
		credsutil.RoleName(req.UsernameConfig.RoleName, maxKeyLength),
		credsutil.MaxLength(10))
```

#### 第二处修改
第二个要改的地方是删除用户的地方，由于 OCP API 删除用户传入的用户名必须是大写的，所以这里要改：

```go
func (db *cmd) DeleteUser(ctx context.Context, req dbplugin.DeleteUserRequest) (dbplugin.DeleteUserResponse, error) {
	db.Logger.Info("DeleteUser", "username", req.Username)
	db.Logger.Info("DeleteUser", "statements_commands", req.Statements.Commands)

	// Assemble delete statements into a single script
	script := strings.Join(req.Statements.Commands, "\n")
	params := map[string]string{
		"name":     req.Username,
		"username": strings.ToUpper(req.Username),
	}

	if err := db.executeScript(script, params); err != nil {
		return dbplugin.DeleteUserResponse{}, fmt.Errorf("failed to execute delete script: %w", err)
	}

	return dbplugin.DeleteUserResponse{}, nil
}
```

也就是 "username": req.Username, 要改成 "username": strings.ToUpper(req.Username),

#### 第三处修改
此外，这里用的是 curl 发送 HTTP 请求，如果发生失败，curl 命令的返回码依然会是 0，造成误判。因此要对插件代码做一些改造，增加判断 HTTP 请求返回数据的判断，如下：

```go
import (
    "encoding/json"
)

func (db *cmd) executeScript(script string, params map[string]string) error {

	//to add all the root config params to the script
	for k, v := range db.AllParams {
		params[k] = v
	}

	renderedScript := replaceVars(params, script)

	cmd := exec.Command(scriptCommand, "-c", renderedScript)
	output, err := cmd.CombinedOutput()

    if err != nil {
		db.Logger.Error("Failed to execute script", "script", script, "output", string(output), "error", err)
		return fmt.Errorf("script execution failed: %s, error: %w", script, err)
	}

    if strings.HasPrefix(renderedScript, "curl") {
        db.Logger.Info("The script starts with curl")

        var apiResult map[string]interface{}

        if err := json.Unmarshal(output, &apiResult); err != nil {
            db.Logger.Error("Failed to parse the API result into JSON.")        
            return fmt.Errorf("Failed to parse the API result into JSON.: %s", output)
        }

        if apiStatus, ok := apiResult["status"].(float64); ok {
            db.Logger.Info("apiStatus value:%d", int(apiStatus))
            if int(apiStatus) != 200 {
                db.Logger.Error("The HTTP request failed (based on status code=%d).",int(apiStatus))        
                return fmt.Errorf("The HTTP request failed (based on status code=%d).",int(apiStatus))
            }
        }
    }

    db.Logger.Info("Executed script", "script", script, "output", string(output))
	return nil
}

```

第 2 行需要增加到插件 import 部分中

第 22-39 行添加在 executeScript 中，作用是当命令是 curl 时，还会根据 HTTP 请求返回 json 数据的 status 来判断是否修改密码成功。










## 第二种方案

本次适配的思路是：Vault 上已经现有一个 Oracle 的插件可以正常连接 Oracle 并工作，它是通过 go-oci8 + Oracle Instant Client library（包含 OCI） 连接 Oracle，那么我们用 OBCI 替代 Oracle Instant Client library，也就是通过 go-oci8 + OBCI 连接 OceanBase Oracle 租户，而原本的插件内的 Oracle 语法 OceanBase 都能兼容，可以不做改动，即使改也是极少的（实际可以一行不改）。

<img src="https://intranetproxy.alipay.com/skylark/lark/0/2024/png/29656635/1733291563892-05726ff3-8678-4df1-9121-784ede6784bc.png" width="956" title="" crop="0,0,1,1" id="ucf0a6aa0" class="ne-image">

根据上图架构，先配置一个 Go 能连通 OceanBase 的环境，在此环境上编译 vault-plugin-database-oracle 插件，然后将编译生成的二进制文件放到运行环境（Vault 服务器），将插件注册到 Vault 中，测试运行是否成功。

注意事项：

+ Go 需要 1.21 版本以上
+ 运行环境也要安装 obci，libobclient，include_oci，并且配置 LD_LIBRARY_PATH 环境变量
+ 如果遇到不能注册的问题，可以用 ldd vault-plugin-database-oracle 查看依赖包，也可以设置 OBCI 的环境变量，打印日志：

<font style="color:rgb(0, 0, 0);">export OBCI_LOG_DIR=/data</font>

<font style="color:rgb(0, 0, 0);">export OBCI_LOG_LEVEL=DEBUG</font>

+ 配置环境变量后，需要重启 Vault，否则不会生效



大致步骤如下：

### 1. 安装介质：

libobclient-2.2.6-42024052211.el7.x86_64.rpm

obci-2.0.9-32024052710.el7.x86_64.rpm

<font style="color:rgb(0, 0, 0);">oracle oci的头文件，解压到 /u01/obclient/include</font>

[include_oci.zip](https://yuque.antfin.com/attachments/lark/0/2024/zip/99856522/1719912330116-d7427fca-c509-469c-8e6c-86f5ae83349c.zip)

2. 在编译环境安装上述产品，按照语雀如下文档测试 Go 通过 go-oci8 驱动到 OceanBase Oracle 租户的连通性：



### go-oci8 连通性测试

#### 1. 基本环境安装
##### a.安装libobclient，obci
libobclient-2.2.3-20230628164517.el7.x86_64.rpm

obci-2.0.8-20230908103856.el7.alios7.x86_64.rpm

/u01/obclient/lib

/u01/obclient/include

##### b.安装go
[https://blog.csdn.net/phpstory/article/details/123495879](https://blog.csdn.net/phpstory/article/details/123495879)

主要环境变量有

export GOROOT=/usr/local/go

export GOPATH=/data/go

export PATH=$PATH:$GOROOT/bin:$GOPATH/bin

<img src="https://intranetproxy.alipay.com/skylark/lark/0/2022/png/360679/1659517121628-4600520b-18fc-4717-aeca-723fc48ae09f.png" width="380" title="" crop="0,0,1,1" id="uae617df8" class="ne-image">

#### 2. 新建go-oci8项目
cd $GOPATH/src

mkdir test_oci8

cd test_oci8

go mod init

go get [github.com/mattn/go-oci8](https://github.com/mattn/go-oci8)

[root@903e92ac0a32 test_oci8]# go get github.com/mattn/go-oci8

go: added github.com/mattn/go-oci8 v0.1.1

[root@903e92ac0a32 test_oci8]# 

#### 3. 编辑oci8.pc文件内容
cd $GOPATH/pkg/mod/github.com/mattn/go-oci8@v0.1.1

vi oci8.pc

```
prefix=/u01/obclient
includedir=/u01/obclient/include
libdir=/u01/obclient/lib
```


Name: oci8

Description: Oracle Instant Client

Version: 12.2

Cflags: -I${includedir}
```
Libs: -L${libdir} -lobci
```
#### 4.设置相关环境变量
LD_LIBRARY_PATH ：设置为instantclient的客户端lib库目录路径

PKG_CONFIG_PATH ：设置为oci8.pc文件所在目录路径

```
export PKG_CONFIG_PATH=/data/go/pkg/mod/github.com/mattn/go-oci8@v0.1.1
export LD_LIBRARY_PATH=/u01/obclient/lib/:$LD_LIBRARY_PATH
```


#### 5. 安装go-oci8模块

```
cd $GOPATH/pkg/mod/github.com/mattn/go-oci8@v0.1.1
go install
# 这里注意如果想从新编译安装go-oci8库,必须先清理上次的编译安装
go env
GOCACHE="/root/.cache/go-build"
rm -rf /root/.cache/go-build
go install
```


#### 6.验证代码

```
cd /data/go/src/test_oci8
```
vi test.go


```plain
package main
import (
  "database/sql"
  "log"
  "fmt"
  _"github.com/mattn/go-oci8"
)

func main(){
  sqlconn := "test@oracle/test@xxx.xxx.xxx.xxx:38884/test"
  db, err := sql.Open("oci8", sqlconn)
  if err != nil {
    log.Fatalln(err)
  }
  defer db.Close()
  sql := "select * from test"
  rows, err := db.Query(sql)
  if err != nil {
    log.Fatalln(err)
  }
  defer rows.Close()

  for rows.Next() {
    var re string
    rows.Scan(&re)
    fmt.Println(re)
  }
  if err = rows.Err(); err != nil {
    log.Fatalln(err)
  }
}
```



#### 7.运行结果
go run test.go

<img src="https://intranetproxy.alipay.com/skylark/lark/0/2022/png/360679/1659516297764-3bd34253-fc89-42b7-a68c-b3767322a046.png" width="560" title="" crop="0,0,1,1" id="ue5c52fb1" class="ne-image">




插件里的 README 有编译方法，主要就是这一步：go build -o vault-plugin-database-oracle ./plugin

编译后会产生一个名为 vault-plugin-database-oracle 的二进制文件





4. 将 vault-plugin-database-oracle 传输到运行环境，运行环境也同样也需要安装上述软件包，对其生成 SHA256 码，使用下述命令进行插件注册：

```shell
vault plugin register -sha256=<SHA256 Hex value of the plugin binary> \
    database \                  # type
    vault-plugin-database-oracle
Success! Registered plugin: vault-plugin-database-oracle
```

5. 注册后，创建数据库连接配置，示例：

```shell
vault write database/config/my-ob-database \
    plugin_name=vault-plugin-database-oracle \
    connection_url="{{username}}:{{password}}@IP_ADDRESS:2883/VAULTTEST" \
    allowed_roles="ob-role" \
    username="UCNOBB002_cluster_1-vault-VAULTTEST" \
    password="********"
```

6. 之后，可以以 static，dynamic 的方式对数据库用户进行管理，详见：

[https://yuque.antfin-inc.com/zhuzhengrong.zzr/oe1ygz/npntqa8ura1m3nb5](https://yuque.antfin-inc.com/zhuzhengrong.zzr/oe1ygz/npntqa8ura1m3nb5)



Vault Plugin 参考：

[https://developer.hashicorp.com/vault/docs/plugins/plugin-architecture](https://developer.hashicorp.com/vault/docs/plugins/plugin-architecture)

[https://developer.hashicorp.com/vault/docs/secrets/databases/custom#serving-a-plugin-with-multiplexing](https://developer.hashicorp.com/vault/docs/secrets/databases/custom#serving-a-plugin-with-multiplexing)

[https://developer.hashicorp.com/vault/docs/secrets/databases/custom](https://developer.hashicorp.com/vault/docs/secrets/databases/custom)

[https://github.com/hashicorp/vault/tree/main/sdk/database/dbplugin](https://github.com/hashicorp/vault/tree/main/sdk/database/dbplugin)



