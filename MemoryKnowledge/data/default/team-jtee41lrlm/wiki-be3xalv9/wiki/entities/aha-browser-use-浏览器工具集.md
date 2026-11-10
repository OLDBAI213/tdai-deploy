---
type: entity
title: Aha Browser Use 浏览器工具集
description: 豆包随包分发的 50 个浏览器操作工具，基于 _routes.py 六类路由分层，核心交互范式为 snapshot→ref→act。
kind: module
sources: ["doubao-reverse.md"]
tags: [agent, browser, 逆向]
timestamp: 2026-11-10T00:00:00Z
---

# 定义

`aha_browser_use` 是 `task-mode-resource\python-packages\` 下的**纯 Python 源码**浏览器 Agent 工具集，共 50 个工具，是 [[豆包 PC 客户端]] 浏览器侧的完整能力面。因为它以可读 `.py` 形式分发，也是整个逆向的主入口。

# 关键属性

- 源码路径：`task-mode-resource\python-packages\aha_browser_use\`
- 路由表：`_routes.py`，代码中**硬断言工具数量必须正好为 50**（防止能力面被静默增删）。
- 调度方式：[[工具路由分层]]（6 类 `Route` 枚举）。
- 交互范式：[[snapshot→ref→act 协议]]——先快照取带编号节点树，再按 ref 操作。
- 契约面：[[工具协议错误码]]（`BU_REF_STALE`、`BU_SELECT_AMBIGUOUS`、`BU_DOWNLOAD_BLOCKED` 等）。

## 工具清单（50 个）

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

## 路由分布

| 路由 | 数量 | 含义 |
|---|---|---|
| AHA_BUA | 24 | 走原生浏览器内核（AhaBUA） |
| NATIVE_COMPAT | 9 | 原生兼容层 |
| COMPOSITE | 9 | 组合调用 |
| SEED_DIRECT | 5 | 直通底层 seed 工具（[[Seed 能力包族]]） |
| CDP_COMPAT | 3 | 走 [[Chrome DevTools Protocol]] |
| LOCAL | 2 | 本地执行 |

# 关系

- 属于 [[豆包 PC 客户端]] 的两大工具集之一（另一个是 [[Computer Use Windows 桌面工具集]]）。
- 实现 [[snapshot→ref→act 协议]]、[[工具路由分层]]、[[工具协议错误码]] 三个概念。
- 与 [[Playwright MCP]] 属同类「快照 + 引用」浏览器 Agent 方案，可相互对照。
- `SEED_DIRECT` 路由向下复用 [[Seed 能力包族]]。

# Citations

- `doubao-reverse.md` 第二节（工具集一：浏览器操作）
