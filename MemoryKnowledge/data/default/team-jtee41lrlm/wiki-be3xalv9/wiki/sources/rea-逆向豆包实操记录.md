---
type: source
title: REA 逆向豆包实操记录
description: 使用 REA（Reverse Engineer Anything v6.8.0）对豆包客户端前端产物 local_webcontents 做静态分析的实操记录，含工具环境卡点、逆向出的云端能力清单与「本地执行层 + 云端编排层」双层结论。
sources: ["rea-analysis.md"]
source_type: other
tags: [逆向工程, 豆包, REA, 前端分析, 架构]
timestamp: 2026-11-10
---

# 文档概述

本记录（2026-11-10）是一次逆向工程实操：作者用 [[REA]]（Reverse Engineer Anything v6.8.0，引擎为 [[Ghidra]] 12.1.4 + [[JDK 25]] + [[jadx-headless-mcp]] 0.7.1）对 [[豆包客户端]] 的渲染层产物 [[local_webcontents 前端产物]] 做静态分析。

记录包含两类内容：

1. **工具侧可复用手法与环境卡点**：Windows `TEMP` 权限导致 native 自检失败、`--detail summary` 必须配 `--evidence_output`、用 `--source-path` 精准选文件、分析后用正则扫 API 全集。
2. **产品侧架构发现**：豆包的技能、连接器、提示词技能、设备下发、MCP 开关等能力全部位于服务端，前端仅硬编码 API 路由；与先前对 `python-packages` 的分析合并后，构成 [[双层能力架构]]。

# 工具与环境

```powershell
$env:GHIDRA_INSTALL_DIR="$env:USERPROFILE\devtools\ghidra-12.1.4\ghidra_12.1.4_PUBLIC"
$env:JAVA_HOME="$env:USERPROFILE\devtools\jdk25\jdk-25.0.5+8"
$reas = "$env:APPDATA\npm\node_modules\rea-agents\scripts\rea.mjs"
node $reas doctor
```

- 工具链安装在 `~/devtools`（Ghidra 与 jadx-headless-mcp 同装）。
- 唯一阻塞点：REA Windows native 自检读取 `C:\Windows\TEMP` 被拒（Win32 5）。修法是把 `TEMP`/`TMP` 指到用户目录，详见 [[JS 应用逆向工作流]]。

# 分析目标与命令

目标：`%LOCALAPPDATA%\Doubao\Application\app\local_webcontents`（2113 个 JS/JSON 文件，494 MB）。

```powershell
node $reas analyze-javascript-application $target `
  --source-path "apps/entry-moa/main.js" `
  --source-path "apps/entry-main/main.js" `
  --detail summary --evidence_output .\ev-core --format json
```

# 分析结果

| 指标 | 数值 |
|---|---|
| 解析文件 | 2（entry-moa 2.7MB + entry-main 0.6MB） |
| 读取文本 | 3.5 MB |
| AST 节点 | 886,325 |
| 发现（findings） | 1,431 |
| 模块 | 418 |
| 解析失败 | 0 |
| 证据包 | 127 MB |
| Electron 特征 | 全 0 |

Electron 特征全 0 说明靶点是渲染层 web app，而非 Electron 主进程，见 [[运行时类型判定]]。

# 逆向出的能力面（核心发现）

豆包的「技能」不在本地，全在服务端；前端 `entry-moa/main.js` 硬编码了整套 API。

| 能力面 | 路由前缀 | 页面 |
|---|---|---|
| 技能管理 | `/alice/office/skills/*` | [[技能系统]] |
| 连接器（第三方服务接入） | `/alice/office/manage/connector/*`、`/connector/*` | [[连接器系统]] |
| 提示词技能 | `/samantha/plugin/prompt_skill/*` | [[提示词技能]] |
| 设备下发（远程控制） | `/alice/dispatch/*` | [[设备下发通道]] |
| 内置 MCP 客户端 | `agent_aha_api_mcp_enabled`、`mcp_config` | [[内置 MCP 客户端]] |

判断：豆包的「技能」= 可安装的包 + OAuth 连接器，结构上与 DSH／[[MCP]] 的 plugin 体系同构，但走自家私有协议 —— 见 [[技能即安装包与 OAuth 连接器]]。

# 与前序 Python 源码分析的关系

先前从 `task-mode-resource\python-packages` 得到**本地工具**（浏览器 50 个 + 桌面 17 个）；本次从 `local_webcontents` 得到**云端能力**。

| 层 | 位置 | 内容 |
|---|---|---|
| 本地执行层 | python-packages | 50 个浏览器工具 + 17 个桌面工具 + 沙箱 |
| 云端编排层 | local_webcontents | 技能管理、连接器 OAuth、设备下发、MCP 开关 |

两层拼起来才是完整产品画像 —— [[双层能力架构]]。注意本地执行层为**前序分析结论，待回溯原始文档补证**（[[本地执行层（python-packages）]]）。

# 可复用结论

1. Electron/JS 逆向用 `analyze-javascript-application` + `--source-path` 精准选文件，不要全量扫描。
2. Windows 上跑 REA 必须先改 `TEMP`，否则 native 自检直接 fail。
3. 找 API 全集：分析完对主 js 做正则 `"/[a-z]+/[a-z_/]+"`，比查 evidence 包快得多。
4. 此类产品本地可见的是执行器，能力清单在云端，逆向前端收益高于逆向 DLL。

# Citations

- 原文：`rea-analysis.md`（2026-11-10 实操记录）
- 相关：[[JS 应用逆向工作流]]、[[服务端下发的能力开关]]、[[远程控制通道与权限风险]]
