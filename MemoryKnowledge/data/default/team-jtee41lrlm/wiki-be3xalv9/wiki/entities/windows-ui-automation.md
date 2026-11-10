---
type: entity
title: Windows UI Automation
description: Windows 系统级无障碍（Accessibility）API，被 seed_computer_use_ax 用于获取界面元素树而非像素识别。
kind: external_system
sources: ["doubao-reverse.md"]
tags: [windows, accessibility, computer-use]
timestamp: 2026-11-10T00:00:00Z
---

# 定义

Windows UI Automation 是 Windows 提供的系统级无障碍 / 自动化接口，能够以**结构化元素树**的形式暴露界面上的控件与层级。在 [[豆包 PC 客户端]] 中，它由 [[Seed 能力包族]] 的 `seed_computer_use_ax` 使用。

# 关键属性

- 通道形态：无障碍树（Accessibility Tree），非截图 + 视觉识别
- 使用方：`seed_computer_use_ax` → [[Computer Use Windows 桌面工具集]]
- 主要优势：控件可寻址、文本可读、不依赖分辨率与渲染

# 关系

- 支撑 [[无障碍树 vs 像素识别]] 这一取舍概念。
- 与 [[Computer Use Agent]] 的可控性直接相关：AX 通道让「点击某个按钮」变成可寻址操作。

# Citations

- `doubao-reverse.md` 第四节
