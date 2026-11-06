汇丰行内用于特权账号管理有三个软件，TPAM，Vault 和 CyberArk，三者功能上各有侧重，也有重叠的地方。

Vault 主要用于保管应用用户和租户管理员的密码（主要是非交互用户的密码），定期自动轮转密码，比如一个月，应用自动通过 API 获取新的密码。

CyberArk 则用于保管 Fire Fighting 抢修用户、应用 release 发版用户，read-only 只读用户的密码（主要都是交互用户的密码）。通过 console 的方式人工登录，申请到对应用户的密码后，密码有一定的生存期限 Time To Live，比如 4 个小时，超过 TTL 密码会被轮转掉。

# TPAM
TPAM 目前明确没法适配 OceanBase。 

# HashiCorp Vault
## 第一种方案
Vault 虽然也不支持 OceanBase，但它支持 MySQL 以及 MySQL 租户，这个在恒生银行的项目中做了适配，是没有问题的。但是汇丰用的是 Oracle 租户，这条路走不通。好在 Vault 提供了 plugin 的功能，Vault 管理 Oracle 数据库就是使用 plugin 的方式的，plugin 的开发需使用 Go 语言开发。Go 连接 OceanBase Oracle 租户目前不是一个正式功能，但有一些 demo，本次是参考了这些 demo，经过配置，使原来 Vault 的 Oracle plugin 在 OceanBase Oracle 租户下也能兼容地工作。

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

1. 安装介质：

libobclient-2.2.6-42024052211.el7.x86_64.rpm

obci-2.0.9-32024052710.el7.x86_64.rpm

<font style="color:rgb(0, 0, 0);">oracle oci的头文件，解压到 /u01/obclient/include</font>

[include_oci.zip](https://yuque.antfin.com/attachments/lark/0/2024/zip/99856522/1719912330116-d7427fca-c509-469c-8e6c-86f5ae83349c.zip)

2. 在编译环境安装上述产品，按照语雀如下文档测试 Go 通过 go-oci8 驱动到 OceanBase Oracle 租户的连通性：

无法连接外网 github：

[https://yuque.antfin.com/obtech/dbcysz/aspeking79lv0um8](https://yuque.antfin.com/obtech/dbcysz/aspeking79lv0um8)

可以连接外网 github：

[https://yuque.antfin.com/obtech/dbcysz/ev2bmr](https://yuque.antfin.com/obtech/dbcysz/ev2bmr)

3. 在编译环境下载 vault-plugin-database-oracle 插件：

[https://github.com/hashicorp/vault-plugin-database-oracle](https://github.com/hashicorp/vault-plugin-database-oracle)

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
    connection_url="{{username}}:{{password}}@133.128.206.2:9883/VAULTTEST" \
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



但是这个方案在向汇丰 Global 团队申请的时候被否决了，原因是 Oracle 插件是原生带在 Vault 产品中的，包括 Oracle Instant Client library 在内，但是 OceanBase 插件和 obci，libobclient，include_oci 都需要额外安装。这一点被认为存在风险，因此被否决了。

## 第二种方案
因此，Global 希望 Vault 能像 CyberArk 一样，实现通过 SSH 运行 obclient 访问 OceanBase 这样的方式。Vault 给出了这样一个方案：

<img src="https://intranetproxy.alipay.com/skylark/lark/0/2025/png/29656635/1741580513160-c090d103-a37d-4039-827a-c23885ef42e4.png" width="609" title="" crop="0,0,1,1" id="u658eadd6" class="ne-image">

在这个方案里，Vault 给了一个新的插件模板 vault-plugin-database-cmd，这个插件会通过运行 SSH 命令远程执行 obclient 命令，连接到 OceanBase 上执行创建用户、轮转密码等任务。

这里的插件可以以 Docker 容器的方式部署，也可以不使用 Docker 容器。

插件样例：[https://github.com/gitrgoliveira/vault-plugin-database-cmd](https://github.com/gitrgoliveira/vault-plugin-database-cmd)<font style="color:rgb(0, 0, 0);"> </font>

<font style="color:rgb(0, 0, 0);"></font>

<font style="color:rgb(0, 0, 0);">这里总结了一些 Vault 插件的工作原理：</font>[https://yuque.antfin.com/zhuzhengrong.zzr/oe1ygz/nyxxqr0678erxb12](https://yuque.antfin.com/zhuzhengrong.zzr/oe1ygz/nyxxqr0678erxb12)

### 基本部署方式
最后这个插件也调试通了，步骤如下：

1. fork 或者 clone 插件 vault-plugin-database-cmd 到本地
2. 编译插件二级制

`go build -o vault-plugin-database-cmd ./cmd/vault-plugin-database-cmd/`

3. 在 vault 环境中注册插件

```shell
vault plugin register \
		-sha256=$(SHA256) \
		-version="v0.1.0" \
		database vault-plugin-database-cmd
```

4. 配置数据库连接，定义 vault root 用户

```shell
vault write database-cmd/config/my-database \
    plugin_name="vault-plugin-database-cmd" \
    plugin_version="v0.1.0" \
    allowed_roles="*" \
    username="VAULTTEST" \
    password="********" \
    root_rotation_statements="ssh admin@cnl25177550.cn.hsbc \"obclient -hcnl25177550.cn.hsbc -P9883 -u{{username}}@vault#dbtest3 -p{{root_password}} -A -c -e 'ALTER USER {{username}} IDENTIFIED BY \\\"{{password}}\\\"'\""
```

5. 创建一个 password policy

新建 password policy 文件：example_policy.hcl

```shell
length=20

rule "charset" {
  charset = "abcdefghijklmnopqrstuvwxyz"
  min-chars = 1
}

rule "charset" {
  charset = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
  min-chars = 1
}

rule "charset" {
  charset = "0123456789"
  min-chars = 1
}

rule "charset" {
  charset = "_"
  min-chars = 1
}
```

表示密码长度 20 个字符，至少一个小写字母、一个大写字母、一个数字、一个特殊字符（下划线）。没有其他特殊字符是因为执行 ssh obclient SQL 命令会有语法问题。

创建 password policy：

```shell
vault write sys/policies/password/example policy=@example_policy.hcl
```

验证生成的密码：

```shell
vault read sys/policies/password/example/generate
```

6. 配置数据库连接使用这个 password policy

```shell
vault write database-cmd/config/my-database password_policy="example"
```

查看配置是否生效：

```shell
vault read database-cmd/config/my-database
```

7. 创建一个静态角色

```shell
vault write database-cmd/static-roles/my-role2 \
    db_name=my-database \
    username="VAULTTEST1" \
    rotation_schedule="*/2 * * * *" \
    rotation_statements="ssh admin@cnl25177550.cn.hsbc \"obclient -hcnl25177550.cn.hsbc -P9883 -u{{root_username}}@vault#dbtest3 -p{{root_password}} -A -c -e 'ALTER USER {{username}} IDENTIFIED BY \\\"{{password}}\\\"'\""
```

8. 轮转 vault root 用户密码

```shell
vault write -force database-cmd/rotate-root/my-database
```

注：\\\"{{password}}\\\" 是因为 Go 的字符串处理，ssh 的命令字符串处理，可能会抵消掉部分引号，导致当密码中有特殊字符、首字符是数字等情况下，会报语法错误。

### 定制化修改
交付过程中发现，如果 Vault 修改了密码，OCP 中保存的密码凭证就会失效，也需要同步修改，增加了运维的复杂度。因此考虑让 Vault 调用 OCP API 修改用户密码，这样 OCP 和 Vault 都会记录修改后的新密码，类似如下：

<img src="https://intranetproxy.alipay.com/skylark/lark/0/2025/png/29656635/1748228349313-ea2475d0-fc6c-40aa-a399-2c5561349034.png" width="1000" title="" crop="0,0,1,1" id="uf9cbde6e" class="ne-image">

配置数据库连接，定义 vault root 用户，其实就是一个 OCP 具有修改所有集群租户下用户的用户：

```shell
vault write database-cmd/config/my-database \
    plugin_name="vault-plugin-database-cmd" \
    plugin_version="v0.1.0" \
    allowed_roles="*" \
    username="VAULTTEST" \
    password="********" \
    root_rotation_statements="curl -sX PUT -H 'Content-Type: application/json' --user {{username}}:{{root_password}} "https://mca-ob-pt-ocp-zhj.cn.hsbc/api/v2/profiles/me/changePassword" -d '[\"currentPassword\":\"{{root_password}}\",\"newPassword\":\"{{password}}\"]'"
```

创建一个静态角色，关联到一个已经存在的数据库用户：

```shell
vault write database-cmd/static-roles/my-role2 \
    db_name=my-database \
    username="VAULTTEST1" \
    rotation_schedule="*/2 * * * *" \
    rotation_statements="curl -sX POST -H 'Content-Type: application/json' --user {{root_username}}:{{root_password}} -d '{\"newPassword\":\"{{password}}\"}' https://mca-ob-pt-ocp-zhj.cn.hsbc/api/v2/ob/clusters/1000002/tenants/800003/users/{{username}}/changePassword"
```

创建一个动态角色，关联到一个新建的数据库用户：

```shell
vault write database-cmd/roles/my-role1 \
	db_name=my-database \
  // 这段 API 要改
	creation_statements="curl -sX POST -H 'Content-Type: application/json' --user {{root_username}}:{{root_password}} -d '{\"username\":\"{{username}}\",\"password\":\"{{password}}\", \"globalPrivileges\":[\"CREATE SESSION\", \"SELECT ANY DICTIONARY\"]}' https://mca-ob-pt-ocp-zhj.cn.hsbc/api/v2/ob/clusters/1000002/tenants/800003/users"  \
  revocation_statements="curl -sX DELETE -H 'Content-Type: application/json' --user {{root_username}}:{{root_password}} https://mca-ob-pt-ocp-zhj.cn.hsbc/api/v2/ob/clusters/1000002/tenants/800003/users/{{username}}"  \
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

# CyberArk
CyberArk 虽然不支持 OceanBase，但它提供了一种方式，通过 obclient 登录 OceanBase，然后编写 prompt file 来和 OceanBase 进行交互，比如 CREATE USER, ALTER USER IDENTIFIED BY 等，这部分需要 CyberArk 原厂开发，经测试通过。

<img src="https://intranetproxy.alipay.com/skylark/lark/0/2025/png/29656635/1737531703182-c59ab43f-c97c-450f-94ca-a2eeb6d5335f.png" width="865" title="" crop="0,0,1,1" id="ucac98aa5" class="ne-image">

[OceanBase+Plugin+Implementation+Guide.pdf](https://yuque.antfin.com/attachments/lark/0/2024/pdf/29656635/1734339801158-e5e13aa7-5ef2-472f-a9aa-5deecf2bd419.pdf)



# 特权账户梳理
| <font style="color:white;">产品</font> | <font style="color:white;">用户</font> | <font style="color:white;">初始化方式</font> | <font style="color:white;">是否</font><font style="color:white;"> lock</font> | <font style="color:white;">是否纳管</font> | <font style="color:white;">是否交互</font> | <font style="color:white;">使用频率</font> | <font style="color:white;">密码是否可获取</font> | <font style="color:white;">密码是否可修改</font> | <font style="color:white;">修改难度</font> |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| <font style="color:black;">OBServer sys 租户</font> | <font style="color:black;">root</font> | <font style="color:black;">用户输入</font> | <font style="color:black;">否</font> | <font style="color:black;">Vault</font> | <font style="color:black;">yes</font> | <font style="color:black;">低</font> | <font style="color:black;">是</font> | <font style="color:black;">是</font> | <font style="color:black;">低，黑屏修改需同步到</font><font style="color:black;"> OCP </font><font style="color:black;">密码凭证，或白屏修改</font> |
| | <font style="color:black;">ORAAUDITOR</font> | <font style="color:black;">随机生成</font> | <font style="color:black;">是</font> | <font style="color:black;">N/A</font> | <font style="color:black;">N/A</font> | <font style="color:black;"></font> | <font style="color:black;">否</font> | <font style="color:black;">是</font> | <font style="color:black;">无</font> |
| | <font style="color:black;">proxyro</font> | <font style="color:black;">随机生成</font> | <font style="color:black;">否</font> | <font style="color:black;">no</font> | <font style="color:black;">no</font> | <font style="color:black;"></font> | <font style="color:black;">否</font> | <font style="color:black;">是</font> | <font style="color:black;">高，需修改</font><font style="color:black;"> OBServer</font><font style="color:black;">、</font><font style="color:black;">OBProxy</font><font style="color:black;">、</font><font style="color:black;">OCP</font><font style="color:black;">、</font><font style="color:black;">OCP </font><font style="color:black;">富客户端等多个地方</font> |
| | <font style="color:black;">ocp_monitor</font> | <font style="color:black;">随机生成</font> | <font style="color:black;">否</font> | <font style="color:black;">no</font> | <font style="color:black;">no</font> | <font style="color:black;"></font> | <font style="color:black;">否</font> | <font style="color:black;">是</font> | <font style="color:black;">低，需在</font><font style="color:black;"> OBServer </font><font style="color:black;">黑屏修改后再同步到</font><font style="color:black;"> OCP </font><font style="color:black;">密码凭证</font> |
| <font style="color:black;">OBServer 业务租户</font> | <font style="color:black;">sys</font> | <font style="color:black;">用户输入</font> | <font style="color:black;">否</font> | <font style="color:black;">Vault</font> | <font style="color:black;">yes</font> | <font style="color:black;">低</font> | <font style="color:black;">是</font> | <font style="color:black;">是</font> | <font style="color:black;">低，黑屏修改需同步到</font><font style="color:black;"> OCP </font><font style="color:black;">密码凭证，或白屏修改</font> |
| | <font style="color:black;">ORAAUDITOR</font> | <font style="color:black;">随机生成</font> | <font style="color:black;">是</font> | <font style="color:black;">N/A</font> | <font style="color:black;">N/A</font> | <font style="color:black;"></font> | <font style="color:black;">否</font> | <font style="color:black;">是</font> | <font style="color:black;">无</font> |
| | <font style="color:black;">STANDBYRO</font> | <font style="color:black;">随机生成</font> | <font style="color:black;">否</font> | <font style="color:black;">Vault(k/v)</font> | <font style="color:black;">yes</font> | <font style="color:black;">低</font> | <font style="color:black;"></font> | <font style="color:black;"></font> | <font style="color:black;"></font> |
| | <font style="color:black;">LBACSYS</font> | <font style="color:black;">随机生成</font> | <font style="color:black;">是</font> | <font style="color:black;">N/A</font> | <font style="color:black;">N/A</font> | <font style="color:black;"></font> | <font style="color:black;">否</font> | <font style="color:black;">是</font> | <font style="color:black;">无</font> |
| <font style="color:black;">OBProxy</font> | <font style="color:black;">proxysys</font> | <font style="color:black;">用户输入</font> | <font style="color:black;">否</font> | <font style="color:#DF2A3F;">待定</font> | <font style="color:black;">yes</font> | <font style="color:black;">低</font> | <font style="color:black;">是</font> | <font style="color:black;">是</font> | <font style="color:black;">低，黑屏修改需同步到</font><font style="color:black;"> OCP </font><font style="color:black;">密码凭证，或白屏修改</font> |
| <font style="color:black;">OCP</font> | <font style="color:black;">admin</font> | <font style="color:black;">用户输入</font> | <font style="color:black;">否</font> | <font style="color:black;">Vault(k/v)</font> | <font style="color:black;">yes</font> | <font style="color:black;">低</font> | <font style="color:black;">是</font> | <font style="color:black;">是</font> | <font style="color:black;">无</font> |
| <font style="color:black;">ODC</font> | <font style="color:black;">admin</font> | <font style="color:black;">用户输入</font> | <font style="color:black;">否</font> | <font style="color:black;">Vault(k/v)</font> | <font style="color:black;">yes</font> | <font style="color:black;">低</font> | <font style="color:black;">是</font> | <font style="color:black;">是</font> | <font style="color:black;">无</font> |
| <font style="color:black;">OMS</font> | <font style="color:black;">admin</font> | <font style="color:black;">用户输入</font> | <font style="color:black;">否</font> | <font style="color:black;">Vault(k/v)</font> | <font style="color:black;">yes</font> | <font style="color:black;">低</font> | <font style="color:black;">是</font> | <font style="color:black;">是</font> | <font style="color:black;">无</font> |
| | <font style="color:black;">root</font> | <font style="color:black;">用户输入</font> | <font style="color:black;">否</font> | <font style="color:black;">Vault(k/v)</font> | <font style="color:black;">yes</font> | <font style="color:black;">低</font> | <font style="color:black;">是</font> | <font style="color:black;">是</font> | <font style="color:black;">无</font> |
| | <font style="color:black;">数据同步用户</font> | <font style="color:black;">用户输入</font> | <font style="color:black;">否</font> | <font style="color:black;">Vault(k/v)</font> | <font style="color:black;">yes</font> | <font style="color:black;">低</font> | <font style="color:black;">是</font> | <font style="color:black;">否</font> | <font style="color:black;">不能改，涉及 OMS 同步、迁移</font> |
| | <font style="color:black;">DRC 用户</font> | <font style="color:black;">用户输入</font> | <font style="color:black;">否</font> | <font style="color:black;">Vault(k/v)</font> | <font style="color:black;">yes</font> | <font style="color:black;">低</font> | <font style="color:black;">是</font> | <font style="color:black;">否</font> | <font style="color:black;">不能改，涉及 OMS 同步、迁移</font> |
| | <font style="color:black;">__OCEANBASE_INNER_DRC_USER</font> | <font style="color:black;">用户输入</font> | <font style="color:black;">否</font> | <font style="color:black;">Vault(k/v)</font> | <font style="color:black;">yes</font> | <font style="color:black;">低</font> | <font style="color:black;">是</font> | <font style="color:black;">否</font> | <font style="color:black;">不能改，涉及 OMS 同步、迁移</font> |
| <font style="color:black;">OAT</font> | <font style="color:black;">admin</font> | <font style="color:black;">用户输入</font> | <font style="color:black;">否</font> | <font style="color:black;">Vault(k/v)</font> | <font style="color:black;">yes</font> | <font style="color:black;">低</font> | <font style="color:black;">是</font> | <font style="color:black;">是</font> | <font style="color:black;">无</font> |
| | <font style="color:black;">MariaDB root 用户</font> | <font style="color:black;">随机生成</font> | <font style="color:black;">否</font> | <font style="color:black;">no</font> | <font style="color:black;">no</font> | <font style="color:black;"></font> | <font style="color:black;">否</font> | <font style="color:black;">是</font> | <font style="color:black;">极高，无现成手段，需分析</font> |
| <font style="color:black;">metadb sys 租户</font> | <font style="color:black;">root</font> | <font style="color:black;">用户输入</font> | <font style="color:black;">否</font> | <font style="color:black;">Vault</font> | <font style="color:black;">yes</font> | <font style="color:black;">低</font> | <font style="color:black;">是</font> | <font style="color:black;">是</font> | <font style="color:black;">低，黑屏修改需同步到</font><font style="color:black;"> OCP </font><font style="color:black;">密码凭证，或白屏修改</font> |
| | <font style="color:black;">ORAAUDITOR</font> | <font style="color:black;">随机生成</font> | <font style="color:black;">是</font> | <font style="color:black;">N/A</font> | <font style="color:black;">N/A</font> | <font style="color:black;"></font> | <font style="color:black;">否</font> | <font style="color:black;">是</font> | <font style="color:black;">无</font> |
| | <font style="color:black;">proxyro</font> | <font style="color:black;">随机生成</font> | <font style="color:black;">否</font> | <font style="color:black;">no</font> | <font style="color:black;">no</font> | <font style="color:black;"></font> | <font style="color:black;">否</font> | <font style="color:black;">是</font> | <font style="color:black;">中，需修改</font><font style="color:black;"> OBServer</font><font style="color:black;">、</font><font style="color:black;">OBProxy </font><font style="color:black;">多个地方</font> |
| | <font style="color:black;">ocp_monitor</font> | <font style="color:black;">随机生成</font> | <font style="color:black;">否</font> | <font style="color:black;">no</font> | <font style="color:black;">no</font> | <font style="color:black;"></font> | <font style="color:black;">否</font> | <font style="color:black;">是</font> | <font style="color:black;">低，需在</font><font style="color:black;"> OBServer </font><font style="color:black;">黑屏修改后再同步到</font><font style="color:black;"> OCP </font><font style="color:black;">密码凭证</font> |
| <font style="color:black;">OCP meta 租户</font> | <font style="color:black;">root</font> | <font style="color:black;">用户输入</font> | <font style="color:black;">否</font> | <font style="color:black;">Vault(k/v)</font> | <font style="color:black;">yes</font> | <font style="color:black;">低</font> | <font style="color:black;">是</font> | <font style="color:black;">是</font> | <font style="color:black;">高，需重建</font><font style="color:black;"> OCP </font><font style="color:black;">容器</font> |
| | <font style="color:black;">ORAAUDITOR</font> | <font style="color:black;">随机生成</font> | <font style="color:black;">是</font> | <font style="color:black;">N/A</font> | <font style="color:black;">N/A</font> | <font style="color:black;"></font> | <font style="color:black;">否</font> | <font style="color:black;">是</font> | <font style="color:black;">无</font> |
| | <font style="color:black;">LBACSYS</font> | <font style="color:black;">随机生成</font> | <font style="color:black;">是</font> | <font style="color:black;">N/A</font> | <font style="color:black;">N/A</font> | <font style="color:black;"></font> | <font style="color:black;">否</font> | <font style="color:black;">是</font> | <font style="color:black;">无</font> |
| <font style="color:black;">OCP monitor 租户</font> | <font style="color:black;">root</font> | <font style="color:black;">用户输入</font> | <font style="color:black;">否</font> | <font style="color:black;">Vault(k/v)</font> | <font style="color:black;">yes</font> | <font style="color:black;">低</font> | <font style="color:black;">是</font> | <font style="color:black;">是</font> | <font style="color:black;">高，需重建</font><font style="color:black;"> OCP </font><font style="color:black;">容器</font> |
| | <font style="color:black;">ORAAUDITOR</font> | <font style="color:black;">随机生成</font> | <font style="color:black;">是</font> | <font style="color:black;">N/A</font> | <font style="color:black;">N/A</font> | <font style="color:black;"></font> | <font style="color:black;">否</font> | <font style="color:black;">是</font> | <font style="color:black;">无</font> |
| | <font style="color:black;">LBACSYS</font> | <font style="color:black;">随机生成</font> | <font style="color:black;">是</font> | <font style="color:black;">N/A</font> | <font style="color:black;">N/A</font> | <font style="color:black;"></font> | <font style="color:black;">否</font> | <font style="color:black;">是</font> | <font style="color:black;">无</font> |
| <font style="color:black;">OMS meta 租户</font> | <font style="color:black;">root</font> | <font style="color:black;">用户输入</font> | <font style="color:black;">否</font> | <font style="color:black;">Vault(k/v)</font> | <font style="color:black;">yes</font> | <font style="color:black;">低</font> | <font style="color:black;">是</font> | <font style="color:black;">是</font> | <font style="color:black;">中，需修改</font><font style="color:black;"> OMS yaml </font><font style="color:black;">配置文件</font> |
| | <font style="color:black;">ORAAUDITOR</font> | <font style="color:black;">随机生成</font> | <font style="color:black;">是</font> | <font style="color:black;">N/A</font> | <font style="color:black;">N/A</font> | <font style="color:black;"></font> | <font style="color:black;">否</font> | <font style="color:black;">是</font> | <font style="color:black;">无</font> |
| | <font style="color:black;">LBACSYS</font> | <font style="color:black;">随机生成</font> | <font style="color:black;">是</font> | <font style="color:black;">N/A</font> | <font style="color:black;">N/A</font> | <font style="color:black;"></font> | <font style="color:black;">否</font> | <font style="color:black;">是</font> | <font style="color:black;">无</font> |
| <font style="color:black;">ODC meta 租户</font> | <font style="color:black;">root</font> | <font style="color:black;">用户输入</font> | <font style="color:black;">否</font> | <font style="color:black;">Vault(k/v)</font> | <font style="color:black;">yes</font> | <font style="color:black;">低</font> | <font style="color:black;">是</font> | <font style="color:black;">是</font> | <font style="color:black;">高，需重建</font><font style="color:black;"> ODC </font><font style="color:black;">容器</font> |
| | <font style="color:black;">ORAAUDITOR</font> | <font style="color:black;">随机生成</font> | <font style="color:black;">是</font> | <font style="color:black;">N/A</font> | <font style="color:black;">N/A</font> | <font style="color:black;"></font> | <font style="color:black;">否</font> | <font style="color:black;">是</font> | <font style="color:black;">无</font> |
| | <font style="color:black;">LBACSYS</font> | <font style="color:black;">随机生成</font> | <font style="color:black;">是</font> | <font style="color:black;">N/A</font> | <font style="color:black;">N/A</font> | <font style="color:black;"></font> | <font style="color:black;">否</font> | <font style="color:black;">是</font> | <font style="color:black;">无</font> |
| <font style="color:black;">metadb OBProxy</font> | <font style="color:black;">proxysys</font> | <font style="color:black;">随机生成</font> | <font style="color:black;">否</font> | <font style="color:black;">N/A</font> | <font style="color:black;">N/A</font> | <font style="color:black;"></font> | <font style="color:black;">否</font> | <font style="color:black;">是</font> | <font style="color:black;">中，需黑屏修改重启</font> |
| <font style="color:black;">InfluxDB</font> | <font style="color:black;">admin</font> | <font style="color:black;">随机生成</font> | <font style="color:black;">否</font> | <font style="color:black;">N/A</font> | <font style="color:black;">N/A</font> | <font style="color:black;"></font> | <font style="color:black;">否</font> | <font style="color:black;">是</font> | <font style="color:black;">中，需修改</font><font style="color:black;"> OMS yaml </font><font style="color:black;">配置文件</font> |


注：

+ OAT 管理的相关产品组件密码可以通过 OAT 内部脚本获取，对于客户来说等同于“无法获取”。
+ OAT 管理的相关产品组件密码如果客户自行修改，则无法通过 OAT 内部脚本再获取，需重新刷新到 OAT，对于客户来说，建议其自行保管。
+ 是否纳管的 Vault(k/v) 表示密码放进 Vault，静态不做修改
