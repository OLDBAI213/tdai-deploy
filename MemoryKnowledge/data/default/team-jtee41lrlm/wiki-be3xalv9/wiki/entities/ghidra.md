---
type: entity
title: Ghidra
description: REA 依赖的原生二进制分析引擎（12.1.4 PUBLIC 版），通过 GHIDRA_INSTALL_DIR 环境变量定位。
sources: ["rea-analysis.md"]
tags: [工具链, 二进制分析]
kind: external_system
timestamp: 2026-11-10
---

# 定义

**Ghidra** 是 [[REA]] 使用的原生二进制分析引擎，负责 native 二进制侧的静态分析；本次记录中主要作为工具链依赖与环境自检对象出现。

# 关键属性

| 属性 | 值 |
|---|---|
| 版本 | 12.1.4（`ghidra_12.1.4_PUBLIC`） |
| 安装位置 | `~/devtools/ghidra-12.1.4/` |
| 定位方式 | 环境变量 `GHIDRA_INSTALL_DIR` |

# 关系

- 被 [[REA]] 调用；与 [[JDK 25]]、[[jadx-headless-mcp]] 共同构成逆向工具链。
- 本次分析未直接使用其二进制能力，靶点为前端产物（[[local_webcontents 前端产物]]）；但 `doctor` 自检会触及 native 路径，故 [[JS 应用逆向工作流#Windows 前置条件：TEMP 卡点]] 同样影响它。

# Citations

- `rea-analysis.md`「工具确认」
