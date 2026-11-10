# REA 逆向豆包 —— 实操记录（2026-11-10）

## 工具确认

`rea` = **Reverse Engineer Anything v6.8.0**（`%APPDATA%\npm\node_modules\rea-agents`）
引擎：Ghidra 12.1.4 + JDK 25 + jadx-headless-mcp 0.7.1，装在 `~/devtools`

```powershell
$env:GHIDRA_INSTALL_DIR="$env:USERPROFILE\devtools\ghidra-12.1.4\ghidra_12.1.4_PUBLIC"
$env:JAVA_HOME="$env:USERPROFILE\devtools\jdk25\jdk-25.0.5+8"
$reas = "$env:APPDATA\npm\node_modules\rea-agents\scripts\rea.mjs"
node $reas doctor
```

## 卡点：Windows native 自检被拒

**症状**

```
REA Windows native self-test failed:
Open Windows path component failed [C:\Windows\TEMP] (Win32 5): 拒绝访问。
```

**根因**：DSH 子进程继承的 `TEMP=C:\Windows\TEMP`（系统级），而当前进程对它没有打开权限（ACL 限制，能写不能 open）。

**修法**：跑 REA 前把 TEMP 指到用户目录。

```powershell
$env:TEMP="$env:USERPROFILE\AppData\Local\Temp"
$env:TMP=$env:TEMP
```

改完立刻通过自检，这是唯一阻塞点。

## 分析豆包前端

目标：`%LOCALAPPDATA%\Doubao\Application\app\local_webcontents`（2113 个 JS/JSON 文件，494 MB）

```powershell
node $reas analyze-javascript-application $target `
  --source-path "apps/entry-moa/main.js" `
  --source-path "apps/entry-main/main.js" `
  --detail summary --evidence_output .\ev-core --format json
```

**注意**：`--detail summary` 必须配 `--evidence_output`，否则报 `invalid_request`。

### 结果

| 指标 | 数值 |
|---|---|
| 解析文件 | 2（entry-moa 2.7MB + entry-main 0.6MB） |
| 读取文本 | 3.5 MB |
| AST 节点 | **886,325** |
| 发现（findings） | **1,431** |
| 模块 | **418** |
| 解析失败 | 0 |
| 证据包 | 127 MB |
| Electron 特征 | 全 0（说明是渲染层 web app，不是 Electron 主进程） |

---

## 逆向出的技能系统（核心发现）

豆包的「技能」不在本地，**全在服务端**。前端 `entry-moa/main.js` 里硬编码了整套 API：

### 技能管理 `/alice/office/skills/*`

```
add                          delete_by_identity       get_detail
get_enterprise_detail        get_download_link        get_exposed
list_my                      list_enterprise          list_user_and_featured
batch_get_package_urls       batch_save_briefs        authorization/submit_outcome
check_enterprise_admin_permission
```

### 连接器（第三方服务接入）

```
manage/connector/create_personal    manage/connector/connect
manage/connector/disconnect         manage/connector/batch_update_status
manage/connector/oauth/authorize_url
manage/connector/oauth/finish
manage/connector/oauth/status
connector/install_feishu            connector/list_by_user
connector/set_conversation_enabled
```

**判断**：豆包的「技能」= 可安装的包 + OAuth 连接器，结构跟 DSH/MCP 的 plugin 体系同构，但走的是自家私有协议。

### 提示词技能 `/samantha/plugin/prompt_skill/*`

```
list_discover_skills
PluginAddPromptSkill
PluginDeletePromptSkill
```

这是「提示词即技能」的那套：一段提示词注册成一个可调用的 skill。

### 设备下发 `/alice/dispatch/*`（值得警惕）

```
all_devices          list_devices         get_device_info
send_command         send_command_result  authorize/device
authorize/device/cancel                   report_device
get_device_connections                    rtc/session_meta
setting/user
```

**这是远程控制通道**：能把指令下发到其他设备并收回执，还带设备授权和 RTC 会话。

### MCP 开关

```
agent_aha_api_mcp_enabled
mcp_config / mcpResponseJson
```

豆包内置 MCP 客户端，「是否启用」由服务端下发的 flag 控制。

---

## 和之前 Python 源码分析的关系

之前从 `task-mode-resource\python-packages` 拿到了**本地工具**（浏览器 50 个 + 桌面 17 个）。
这次从 `local_webcontents` 拿到了**云端能力**（技能市场 + 连接器 + 设备下发）。

两层拼起来才完整：

| 层 | 位置 | 内容 |
|---|---|---|
| 本地执行层 | python-packages | 50 个浏览器工具 + 17 个桌面工具 + 沙箱 |
| 云端编排层 | local_webcontents | 技能管理、连接器 OAuth、设备下发、MCP 开关 |

---

## 可复用结论

1. 做 Electron/JS 逆向，`analyze-javascript-application` + `--source-path` 精准选文件，别全量扫（2113 文件会跑很久）。
2. Windows 上跑 REA 必须先修 TEMP，否则 native 自检直接 fail。
3. 找 API 全集：分析完直接对主 js 做正则 `"/[a-z]+/[a-z_/]+"`，比查 evidence 包快得多。
4. 豆包这类产品，本地能看到的是执行器，能力清单在云端，逆向前端比逆向 DLL 收益高。
