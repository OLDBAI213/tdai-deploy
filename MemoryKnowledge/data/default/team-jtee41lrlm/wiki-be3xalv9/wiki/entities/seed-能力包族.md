---
type: entity
title: Seed 能力包族
description: 底层能力包 seed_browser_use / seed_computer_use / seed_computer_use_ax，被上层工具集包装，其中 _ax 走无障碍树。
kind: module
sources: ["doubao-reverse.md"]
tags: [agent, computer-use]
timestamp: 2026-11-10T00:00:00Z
---

# 定义

Seed 能力包族是 [[豆包 PC 客户端]] 中的**底层原语层**，由三个包组成，被上层工具集包装后对外暴露：

| 包 | 面向 | 说明 |
|---|---|---|
| `seed_browser_use` | 浏览器 | 被 [[Aha Browser Use 浏览器工具集]] 的 `SEED_DIRECT` 路由直通调用 |
| `seed_computer_use` | 桌面 | 桌面操作基础原语（像素 / 常规通道） |
| `seed_computer_use_ax` | 桌面 | 走 [[Windows UI Automation]] **无障碍树**，不走像素识别 |

# 关系

- 被 [[Aha Browser Use 浏览器工具集]] 与 [[Computer Use Windows 桌面工具集]] 复用，是分层中的最底层。
- `_ax` 变体是 [[无障碍树 vs 像素识别]] 概念的实证载体。

# Citations

- `doubao-reverse.md` 第二、三、四节
