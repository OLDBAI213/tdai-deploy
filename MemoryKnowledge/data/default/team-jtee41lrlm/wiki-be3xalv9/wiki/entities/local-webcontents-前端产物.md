---
type: entity
title: local_webcontents 前端产物
description: 豆包客户端渲染层的前端静态产物目录，含 2113 个 JS/JSON（494 MB），本次逆向的实际靶点。
sources: ["rea-analysis.md"]
tags: [前端, 静态产物, 逆向靶点]
kind: module
timestamp: 2026-11-10
---

# 定义

**local_webcontents** 是 [[豆包客户端]] 的渲染层前端产物目录，位于 `%LOCALAPPDATA%\Doubao\Application\app\local_webcontents`。它是本次逆向的实际靶点：能力清单（API 路由、flag 名）以硬编码字符串形式存在其中。

# 关键属性

| 属性 | 值 |
|---|---|
| 文件规模 | 2113 个 JS/JSON，494 MB |
| 实际解析入口 | `apps/entry-moa/main.js`（2.7 MB）、`apps/entry-main/main.js`（0.6 MB） |
| 运行时性质 | 渲染层 web app，非 Electron 主进程（特征全 0） |
| 承载内容 | 技能/连接器/提示词技能/设备下发/MCP 的 API 路由与开关名 |

# 分析产出（一次全量分析）

| 指标 | 数值 |
|---|---|
| 读取文本 | 3.5 MB |
| AST 节点 | 886,325 |
| findings | 1,431 |
| 模块 | 418 |
| 解析失败 | 0 |
| 证据包 | 127 MB |

# 关系

- 归属 [[豆包客户端]]；由 [[REA]] 的 `analyze-javascript-application` 分析。
- 内容映射到 [[技能系统]]、[[连接器系统]]、[[提示词技能]]、[[设备下发通道]]、[[内置 MCP 客户端]]。
- 与 [[本地执行层（python-packages）]] 互补，共同支撑 [[双层能力架构]]。

# 经验

不要全量扫描：2113 个文件会跑很久。用 `--source-path` 精准选入口，详见 [[JS 应用逆向工作流]]。

# Citations

- `rea-analysis.md`「分析豆包前端」「结果」
