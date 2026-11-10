---
type: entity
title: jadx-headless-mcp
description: 无头反编译 MCP 服务（0.7.1），与 Ghidra 同装于 ~/devtools，为 REA 提供 Java 反编译能力。
sources: ["rea-analysis.md"]
tags: [工具链, 反编译, mcp]
kind: external_system
timestamp: 2026-11-10
---

# 定义

**jadx-headless-mcp（0.7.1）** 是一个无头（headless）反编译服务，以 [[MCP]] 形式对外提供反编译能力，作为 [[REA]] 工具链的组成部分。

# 关键属性

| 属性 | 值 |
|---|---|
| 版本 | 0.7.1 |
| 安装位置 | `~/devtools`（与 [[Ghidra]] 同目录） |
| 暴露方式 | MCP（无头服务） |

# 关系

- 被 [[REA]] 调用；与 [[Ghidra]]、[[JDK 25]] 并列。
- 是「把工具以 MCP 暴露」的实例，可与 [[内置 MCP 客户端]]（产品内 MCP 接入）对照理解 [[MCP]] 的两种用法。

# Citations

- `rea-analysis.md`「工具确认」
