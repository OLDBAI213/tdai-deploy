# 豆包 PC 端逆向记录（2026-11-10）

对象：`C:\Users\Administrator\AppData\Local\Doubao`
版本：**2.35.8**（channel 1001，Electron / Chromium 147.0.7727.149）

---

## 一、架构：不是纯网页壳

| 组件 | 体积 | 作用 |
|---|---|---|
| `Doubao.dll` | 317 MB | 主逻辑 + 内置 JS bundle |
| `liblark.dll` | 167 MB | 飞书同源内核 |
| `cccreator.dll` | 85 MB | 创作/画布能力 |
| `mcp_helper.dll` | 16 MB | **MCP 协议客户端** |
| `agent_infra.dll` | 10 MB | Agent 基础设施 |
| `sdks\aha_cua\aha_cua.dll` | — | Computer Use Agent SDK |
| `task-mode-resource\python-packages` | — | **纯 Python 源码的 Agent 工具集** |

关键点：Agent 的「工具」不是黑盒，是一堆可读的 `.py` 文件。这是逆向的主入口。

---

## 二、工具集一：浏览器操作（50 个）

源码：`task-mode-resource\python-packages\aha_browser_use\`
路由表：`_routes.py`（代码里硬断言必须正好 50 个）

```
snapshot  webmcp_tools  webmcp_call  text  get  http_get  find  get_page_text
read_all  content_export  extract_content  console_messages  network_requests
page_info  new_tab  list_tabs  switch_tab  current_tab  close_tab
ensure_real_tab  resync  click  type  select  upload  hover  handle_dialog
click_and_handle_dialog  click_xy  left_double  right_single  drag  scroll
scroll_into_view  navigate  wait  wait_for_load  wait_for_element
wait_for_network_idle  hotkey  press_key  screenshot  download
wait_for_download  js  cdp  iframe_target  upload_file  install_executor  make_ref
```

路由分层（`Route` 枚举）：

| 路由 | 数量 | 含义 |
|---|---|---|
| AHA_BUA | 24 | 走原生浏览器内核（AhaBUA） |
| NATIVE_COMPAT | 9 | 原生兼容层 |
| COMPOSITE | 9 | 组合调用 |
| SEED_DIRECT | 5 | 直通底层 seed 工具 |
| CDP_COMPAT | 3 | 走 Chrome DevTools 协议 |
| LOCAL | 2 | 本地执行 |

工具协议错误码也是固定的，例如 `BU_REF_STALE`、`BU_SELECT_AMBIGUOUS`、`BU_DOWNLOAD_BLOCKED`。这说明豆包用的是一套**带引用（ref）快照**的 Agent 浏览器协议，和 Playwright MCP 那类思路一致：先 `snapshot` 拿带编号的节点树，再按 ref 点击。

---

## 三、工具集二：Windows 桌面操作（17 个）

源码：`gac_runtime\modules\computer_use_windows.py`（协议版本 1，模块 ID 2）

```
list_apps      launch_app     screenshot     click          hover
drag           scroll         type           hotkey         wait
press          key_down       key_up         get_clipboard  set_clipboard
copy_selection switch_desktop
```

配套服务层在 `gac_runtime\computer_use\_windows\services\`：`app.py` / `clipboard.py` / `desktop.py` / `keyboard.py` / `mouse.py` / `screenshot.py` / `wait.py`。

特点：
- 截图上限 128 MB，单帧响应上限 129 MB，传输超时 500 秒——为长任务设计。
- `switch_desktop` 能切 Windows 虚拟桌面。
- `key_down` / `key_up` 可分离，支持组合键长按。

---

## 四、技能 / 模式

| 模式 | 落点 | 能力 |
|---|---|---|
| 任务模式 | `task-mode-resource\runtime-bundle` | 后台长任务，带 Python 运行时 |
| 编程模式 / coding | `User Data\coding` | 起**子 agent** 在沙箱里写代码、直接改文件 |
| 沙箱 | `User Data\sandbox_runtime`（519 MB） | 内置 Node + Python，带 npm/pip 缓存 |

`seed_browser_use` / `seed_computer_use` / `seed_computer_use_ax` 是底层能力包，其中 `_ax` 走 Windows UI Automation（无障碍树），不走像素识别。

---

## 五、它在你电脑上做过什么（实证）

`User Data\coding\snapshot\` 下有 5 条执行快照，全部集中在 **2026-09-26 14:06–14:14**：

| 时间 | 工具 | 行数 | 写入路径 |
|---|---|---|---|
| 14:06:53 | Write | 326 | `AI\02_研究资料\骑砍2模组\政治经济家族类5模组深度研究-20260926.md` |
| 14:06:58 | Write | 391 | `AI\02_研究资料\骑砍2模组\战争军事类9模组深度研究-20260926.md` |
| 14:10:11 | Write | 353 | `AI\02_研究资料\骑砍2模组\骑砍2七模组深研与依赖冲突分析-20260926.md` |
| 14:11:14 | Write | 229 | `AI\02_研究资料\骑砍2霸主-本地环境调研\骑砍2-本体1.4.8-战帆-四前置-modmaster-深度调研.md` |
| 14:14:31 | Write | 269 | `AI\02_研究资料\骑砍2模组\骑砍2世界观与模组流程整合指南-20260926.md` |

每条记录的字段：`agentType=sub_agent`、`agentId=s_000ckaGcErx`、`sandboxId=sandbox-d8a83207-...`、`firstToolName=Write`、`addedLines`、`changeType`。

结论：**豆包的 coding 模式能在你机器上起子 agent，用 Write 工具直接落盘到任意路径，并把执行元数据留在本地，不做清理。**

文件命名格式（`s_` + 短 ID）就是子 agent 会话 ID，五个文件对应五个子 agent。

---

## 六、可复用的结论

1. 想做「浏览器 Agent」：照 `aha_browser_use` 的分层抄——50 个工具分 6 类路由，核心是 snapshot→ref→act 三步，别用坐标点击。
2. 想做「桌面 Agent」：`computer_use_windows` 的 17 个工具就是最小完备集，重点是 `screenshot` + `click/hover/drag/scroll` + `type/hotkey` + `wait` + `clipboard`。
3. 想做「长任务」：必须有沙箱（node + python），否则模型写不出可执行的中间产物。
4. 安全上要知道：装了豆包等于装了一个**可以读写你任意目录的远程 Agent**，执行记录仅本地留存，不上报可见性未知。
