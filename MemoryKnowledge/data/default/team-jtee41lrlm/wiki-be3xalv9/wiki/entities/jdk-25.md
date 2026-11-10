---
type: entity
title: JDK 25
description: 逆向工具链的 Java 运行时依赖（jdk-25.0.5+8），通过 JAVA_HOME 指定，供 Ghidra 等引擎使用。
sources: ["rea-analysis.md"]
tags: [工具链, 运行时]
kind: external_system
timestamp: 2026-11-10
---

# 定义

**JDK 25** 是 [[REA]] 工具链的 Java 运行时依赖，为 [[Ghidra]] 等基于 JVM 的引擎提供执行环境。

# 关键属性

| 属性 | 值 |
|---|---|
| 版本 | `jdk-25.0.5+8` |
| 安装位置 | `~/devtools/jdk25/` |
| 定位方式 | 环境变量 `JAVA_HOME` |

# 关系

- 被 [[REA]]/[[Ghidra]] 依赖；与 [[jadx-headless-mcp]] 同属 JVM 侧组件。

# Citations

- `rea-analysis.md`「工具确认」
