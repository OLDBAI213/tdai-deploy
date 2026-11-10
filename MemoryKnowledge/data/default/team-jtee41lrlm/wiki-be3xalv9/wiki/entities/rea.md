---
type: entity
title: REA
description: Reverse Engineer Anything v6.8.0，本次逆向工作的主力工具链封装，以 npm 全局包形式安装、由 rea.mjs 子命令驱动。
sources: ["rea-analysis.md"]
tags: [工具链, 逆向工程, 平台]
kind: platform
timestamp: 2026-11-10
---

# 定义

**REA（Reverse Engineer Anything v6.8.0）** 是一套逆向工程工具链封装，提供统一 CLI 子命令，把二进制分析（[[Ghidra]]）、Java 反编译（[[jadx-headless-mcp]]）与 JS 应用分析串成一条流水线。

# 关键属性

| 属性 | 值 |
|---|---|
| 版本 | v6.8.0 |
| 安装位置 | `%APPDATA%\npm\node_modules\rea-agents` |
| 入口脚本 | `scripts/rea.mjs`（以 `node rea.mjs <subcommand>` 驱动） |
| 运行时依赖 | [[JDK 25]]（`JAVA_HOME`）、[[Ghidra]] 12.1.4（`GHIDRA_INSTALL_DIR`） |
| 配套 MCP | [[jadx-headless-mcp]] 0.7.1 |

# 常用子命令

| 子命令 | 用途 |
|---|---|
| `doctor` | 环境自检（Windows native self-test 在此阶段执行） |
| `analyze-javascript-application` | 分析 JS 应用/前端产物，支持 `--source-path`、`--detail summary`、`--evidence_output`、`--format json` |

# 关系

- 依赖 → [[Ghidra]]、[[JDK 25]]、[[jadx-headless-mcp]]
- 分析 → [[local_webcontents 前端产物]]（靶点）
- 方法论 → [[JS 应用逆向工作流]]、[[运行时类型判定]]

# 已知环境约束

Windows 下子进程继承系统级 `TEMP=C:\Windows\TEMP` 且无 open 权限时，`doctor` 的 native 自检直接失败（Win32 5 拒绝访问）。必须先改 `TEMP`/`TMP`，细节见 [[JS 应用逆向工作流#Windows 前置条件：TEMP 卡点]]。

# Citations

- `rea-analysis.md`「工具确认」「卡点：Windows native 自检被拒」
