---
type: entity
title: 任务模式 runtime-bundle
description: task-mode-resource\runtime-bundle，带 Python 运行时的后台长任务执行环境。
kind: module
sources: ["doubao-reverse.md"]
tags: [agent, runtime]
timestamp: 2026-11-10T00:00:00Z
---

# 定义

任务模式是 [[豆包 PC 客户端]] 的**后台长任务**执行模式，落点为 `task-mode-resource\runtime-bundle`，自带 Python 运行时。

同目录 `task-mode-resource\python-packages` 存放了 Agent 工具集的纯 Python 源码（[[Aha Browser Use 浏览器工具集]]），是逆向的主要入口。

# 关键属性

- 路径：`task-mode-resource\runtime-bundle`
- 内置 Python 运行时，可在后台持续执行任务。
- 与 [[沙箱运行时]]（Node + Python）互补：前者是任务执行环境，后者是可写代码的沙箱。

# 关系

- 属于 [[豆包 PC 客户端]] 的模式之一；另一模式为 [[编程模式（coding）]]。
- 支撑 [[沙箱内子 agent 长任务模式]] 的「长任务」侧需求。

# Citations

- `doubao-reverse.md` 第四节（技能 / 模式）
