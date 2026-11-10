---
type: entity
title: 子 agent
description: 以 s_xxxx 会话 ID 标识的执行实例，通过 Write 等工具直接向任意路径写入文件。
kind: other
sources: ["doubao-reverse.md"]
tags: [agent, 安全]
timestamp: 2026-11-10T00:00:00Z
---

# 定义

子 agent（`agentType=sub_agent`）是 [[编程模式（coding）]] 在主 agent 之下派生出的执行实例，每个实例以 `s_` + 短 ID 作为会话 ID（如 `s_000ckaGcErx`），并绑定一个 `sandboxId`。

# 关键属性

| 字段 | 示例值 | 含义 |
|---|---|---|
| `agentType` | `sub_agent` | 执行者类型 |
| `agentId` | `s_000ckaGcErx` | 子 agent 会话 ID |
| `sandboxId` | `sandbox-d8a83207-...` | 所属沙箱 |
| `firstToolName` | `Write` | 首个调用工具 |
| `addedLines` | 229–391 | 新增行数 |
| `changeType` | — | 变更类型 |

子 agent 具备**对本机任意路径的写权限**——实证中写入目标位于用户自定义的 `AI\02_研究资料\` 目录，而非应用自身目录。

# 关系

- 由 [[编程模式（coding）]] 派生，运行于 [[沙箱运行时]]。
- 每次执行在 [[执行快照目录]] 留下一条 [[本地执行痕迹]] 记录。
- 是 [[本地任意目录读写权限模型]] 与 [[沙箱内子 agent 长任务模式]] 的核心行为主体。

# Citations

- `doubao-reverse.md` 第五节（它在你电脑上做过什么）
