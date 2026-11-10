---
type: entity
title: Computer Use Windows 桌面工具集
description: 豆包 Windows 桌面操作模块，17 个工具 + 7 个服务层模块，协议版本 1、模块 ID 2，构成桌面 Agent 的最小完备集。
kind: module
sources: ["doubao-reverse.md"]
tags: [agent, desktop, computer-use, 逆向]
timestamp: 2026-11-10T00:00:00Z
---

# 定义

`computer_use_windows` 是 [[豆包 PC 客户端]] 中负责 **Windows 桌面操作**的模块，让模型直接驱动图形界面（应用、鼠标、键盘、剪贴板、虚拟桌面）。

源码：`gac_runtime\modules\computer_use_windows.py`，协议版本 **1**，模块 ID **2**。

# 关键属性

## 工具清单（17 个）

```
list_apps      launch_app     screenshot     click          hover
drag           scroll         type           hotkey         wait
press          key_down       key_up         get_clipboard  set_clipboard
copy_selection switch_desktop
```

## 服务层模块（7 个）

`gac_runtime\computer_use\_windows\services\`：`app.py` / `clipboard.py` / `desktop.py` / `keyboard.py` / `mouse.py` / `screenshot.py` / `wait.py`。

## 设计特征

| 特征 | 值 / 说明 |
|---|---|
| 截图上限 | 128 MB |
| 单帧响应上限 | 129 MB |
| 传输超时 | 500 秒 |
| 虚拟桌面 | `switch_desktop` 可切换 Windows 虚拟桌面 |
| 按键分离 | `key_down` / `key_up` 独立暴露，支持组合键长按 |

大体积与长超时说明该模块是**为长任务设计**的，而非交互式即时操作的薄封装。

# 关系

- 与 [[Aha Browser Use 浏览器工具集]] 并列为 [[豆包 PC 客户端]] 的两大工具集。
- 是 [[桌面 Agent 最小完备工具集]] 的具体实现，也是 [[Computer Use Agent]] 形态的桌面侧落地。
- 底层能力可能来自 [[Seed 能力包族]]，其中 `seed_computer_use_ax` 走 [[Windows UI Automation]]，体现 [[无障碍树 vs 像素识别]] 的取舍。

# Citations

- `doubao-reverse.md` 第三节（工具集二：Windows 桌面操作）
