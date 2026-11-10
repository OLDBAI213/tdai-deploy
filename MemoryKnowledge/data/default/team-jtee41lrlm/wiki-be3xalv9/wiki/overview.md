---
type: overview
title: Overview
description: A global overview of this wiki
timestamp: 2026-11-10T02:03:58.825Z
---

The knowledge base centers on the [[豆包 PC 客户端]] and its sibling [[豆包客户端]], treated both as a product surface and as the subject of structured reverse engineering. [[REA]] is the organizing methodology: it separates the target application, the analysis toolchain, and the resulting capability model into reusable layers, with [[REA 逆向豆包实操记录]] and [[豆包 PC 端逆向记录（2026-11-10）]] serving as the concrete evidence trail for how those layers were derived.

The analysis side is a desktop reverse-engineering toolchain. [[Ghidra]] handles native binary analysis, while [[jadx-headless-mcp]] exposes decompilation of the client's Java/Dalvik artifacts to agents; both run on [[JDK 25]]. [[Windows UI Automation]] supplies the observation and control surface for the running application, and findings are persisted into the [[执行快照目录]], which snapshots state so that sessions are reproducible and comparable across runs.

The runtime side describes how the client actually executes work. A [[沙箱运行时]] provides isolation, with [[任务模式 runtime-bundle]] packaging everything a task needs to start; inside it, a [[子 agent]] architecture delegates work, driven by a [[技能系统]] in which [[提示词技能]] encode reusable behaviors and [[编程模式（coding）]] enables code-writing tasks. [[Seed 能力包族]] groups capability bundles as the distributable unit, and [[local_webcontents 前端产物]] represents the locally rendered front-end artifacts these tasks produce and consume.

The outermost layer is the tool and connectivity surface exposed to those agents. [[Aha Browser Use 浏览器工具集]] covers browser automation and [[Computer Use Windows 桌面工具集]] covers desktop-level interaction, both brokered through the [[内置 MCP 客户端]]. [[连接器系统]] and the [[设备下发通道]] extend reach beyond the local machine toward connected devices and external services, closing the loop from reverse-engineering insight to delivered capability. A [[test.md（无内容占位来源）]] page is a placeholder and carries no substantive content.
