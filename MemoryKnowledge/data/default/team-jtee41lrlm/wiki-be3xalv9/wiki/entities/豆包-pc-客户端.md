---
type: entity
title: 豆包 PC 客户端
description: 豆包桌面客户端（2.35.8，Electron/Chromium 外壳），由原生 DLL 与随包 Python 源码共同构成的远程 Agent 载体。
kind: platform
sources: ["doubao-reverse.md"]
tags: [agent, electron, 逆向]
timestamp: 2026-11-10T00:00:00Z
---

# 定义

豆包 PC 客户端是字节跳动的桌面端应用，本 wiki 关注的是它作为**远程 Agent 载体**的一面：它在本机运行 Agent 工具集（浏览器操作、Windows 桌面操作），并能在沙箱中启动 [[子 agent]] 完成长任务。

逆向目标为 **2.35.8**（channel 1001），安装路径 `C:\Users\Administrator\AppData\Local\Doubao`。

# 关键属性

| 属性 | 值 |
|---|---|
| 版本 | 2.35.8（channel 1001） |
| 外壳运行时 | [[Electron / Chromium]]（Chromium 147.0.7727.149） |
| 安装根目录 | `C:\Users\Administrator\AppData\Local\Doubao` |
| 架构判定 | [[混合原生 + Electron 壳架构]] |
| 逆向入口 | `task-mode-resource\python-packages` 下的可读 `.py` 源码 |

# Schema

安装目录下的组件构成：

| 组件 | 体积 | 作用 | 独立页面 |
|---|---|---|---|
| `Doubao.dll` | 317 MB | 主逻辑 + 内置 JS bundle | — |
| `liblark.dll` | 167 MB | 飞书同源内核（复用飞书技术栈） | — |
| `cccreator.dll` | 85 MB | 创作 / 画布能力 | — |
| `mcp_helper.dll` | 16 MB | MCP 协议客户端 | [[MCP Helper DLL]] |
| `agent_infra.dll` | 10 MB | Agent 基础设施 | — |
| `sdks\aha_cua\aha_cua.dll` | — | Computer Use Agent SDK | [[Aha CUA DLL]] |
| `task-mode-resource\python-packages` | — | 纯 Python 源码的 Agent 工具集 | [[Aha Browser Use 浏览器工具集]] |

模式与运行时落点：

| 模式 | 路径 | 说明 |
|---|---|---|
| 任务模式 | `task-mode-resource\runtime-bundle` | 见 [[任务模式 runtime-bundle]] |
| 编程模式 / coding | `User Data\coding` | 见 [[编程模式（coding）]] |
| 沙箱 | `User Data\sandbox_runtime`（519 MB） | 见 [[沙箱运行时]] |

# 关系

- 内嵌两大工具集：[[Aha Browser Use 浏览器工具集]]（浏览器 50 工具）与 [[Computer Use Windows 桌面工具集]]（桌面 17 工具），二者共同支撑 [[Computer Use Agent]] 形态。
- 通过 [[MCP Helper DLL]] 作为 MCP 客户端接入外部生态（见 [[MCP 协议]]）。
- 通过 [[Aha CUA DLL]] 提供 Computer Use Agent SDK 能力。
- 依赖 [[沙箱运行时]] 与 [[任务模式 runtime-bundle]] 承载长任务，见 [[沙箱内子 agent 长任务模式]]。
- 其子 agent 行为在 [[执行快照目录]] 留下 [[本地执行痕迹]]，构成 [[本地任意目录读写权限模型]] 的证据。

# Citations

- `doubao-reverse.md` 第一节（架构）、第四节（技能 / 模式）
