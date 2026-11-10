---
type: entity
title: 内置 MCP 客户端
description: 豆包产品内的 MCP 接入模块，其启停由服务端下发的 flag agent_aha_api_mcp_enabled 控制。
sources: ["rea-analysis.md"]
tags: [模块, mcp, 能力开关]
kind: module
timestamp: 2026-11-10
---

# 定义

**内置 MCP 客户端** 是 [[豆包客户端]] 内部接入 [[MCP]] 的模块。它的「是否启用」不由前端判断，而由服务端下发的 flag 决定。

# 关键属性

| 属性 | 值 |
|---|---|
| 启用开关 | `agent_aha_api_mcp_enabled`（服务端下发） |
| 相关标识 | `mcp_config`、`mcpResponseJson` |

# 关系

- 宿主：[[豆包客户端]]；标准侧对应 [[MCP]]（实现 vs 标准，勿混为一谈）。
- 是 [[服务端下发的能力开关]] 的典型实例：前端只读 flag，不做本地判定。
- 与 [[jadx-headless-mcp]] 形成对照：后者是「工具以 MCP 暴露」，前者是「产品内作为 MCP 客户端接入」。

# 开放问题

- flag 的获取时机与缓存策略未知（是否可被本地篡改以强开能力，需验证）。

# Citations

- `rea-analysis.md`「MCP 开关」
