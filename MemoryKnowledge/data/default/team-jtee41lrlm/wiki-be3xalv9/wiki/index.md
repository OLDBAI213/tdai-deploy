# Index

## Sources

* [豆包 PC 端逆向记录（2026-11-10）](/sources/豆包-pc-端逆向记录-2026-11-10.md) - 对豆包 PC 客户端 2.35.8 安装目录的逆向记录，覆盖混合原生/Python 架构、浏览器与桌面两大 Agent 工具集、coding 模式落盘实证，以及可复用的 Agent 工程与安全结论。
* [REA 逆向豆包实操记录](/sources/rea-逆向豆包实操记录.md) - 使用 REA（Reverse Engineer Anything v6.8.0）对豆包客户端前端产物 local_webcontents 做静态分析的实操记录，含工具环境卡点、逆向出的云端能力清单与「本地执行层 + 云端编排层」双层结论。
* [test.md（无内容占位来源）](/sources/test-md-无内容占位来源.md) - 收到的 test.md 仅含占位符「??」，无可提取内容，暂作占位记录。

## Entities

* [编程模式（coding）](/entities/编程模式-coding.md) - User Data\coding 下的编程模式，可启动子 agent 在沙箱内写代码并直接向任意路径写文件。
* [豆包 PC 客户端](/entities/豆包-pc-客户端.md) - 豆包桌面客户端（2.35.8，Electron/Chromium 外壳），由原生 DLL 与随包 Python 源码共同构成的远程 Agent 载体。
* [豆包客户端](/entities/豆包客户端.md) - 被分析的目标桌面产品（Doubao），渲染层为 web app，能力清单全部位于服务端；是「本地执行层 + 云端编排层」两条证据线的共同锚点。
* [技能系统](/entities/技能系统.md) - 豆包云端技能市场，路由前缀 /alice/office/skills/*，含 14 个技能管理与授权端点。
* [连接器系统](/entities/连接器系统.md) - 豆包第三方服务接入子系统，路由 /alice/office/manage/connector/* 与 /connector/*，含 OAuth 授权流、飞书安装与会话级开关。
* [内置 MCP 客户端](/entities/内置-mcp-客户端.md) - 豆包产品内的 MCP 接入模块，其启停由服务端下发的 flag agent_aha_api_mcp_enabled 控制。
* [任务模式 runtime-bundle](/entities/任务模式-runtime-bundle.md) - task-mode-resource\runtime-bundle，带 Python 运行时的后台长任务执行环境。
* [沙箱运行时](/entities/沙箱运行时.md) - User Data\sandbox_runtime（519 MB），内置 Node 与 Python 并带 npm/pip 缓存的可执行沙箱环境。
* [设备下发通道](/entities/设备下发通道.md) - 豆包跨设备指令下发与远程控制面，路由 /alice/dispatch/*，含指令、回执、设备授权、设备上报与 RTC 会话。
* [提示词技能](/entities/提示词技能.md) - 豆包子系统，路由 /samantha/plugin/prompt_skill/*，把一段提示词注册为可调用 skill（list/add/delete）。
* [执行快照目录](/entities/执行快照目录.md) - User Data\coding\snapshot\ 目录，保存每次子 agent 执行的结构化元数据，且不做清理。
* [子 agent](/entities/子-agent.md) - 以 s_xxxx 会话 ID 标识的执行实例，通过 Write 等工具直接向任意路径写入文件。
* [Aha Browser Use 浏览器工具集](/entities/aha-browser-use-浏览器工具集.md) - 豆包随包分发的 50 个浏览器操作工具，基于 _routes.py 六类路由分层，核心交互范式为 snapshot→ref→act。
* [Computer Use Windows 桌面工具集](/entities/computer-use-windows-桌面工具集.md) - 豆包 Windows 桌面操作模块，17 个工具 + 7 个服务层模块，协议版本 1、模块 ID 2，构成桌面 Agent 的最小完备集。
* [Ghidra](/entities/ghidra.md) - REA 依赖的原生二进制分析引擎（12.1.4 PUBLIC 版），通过 GHIDRA_INSTALL_DIR 环境变量定位。
* [jadx-headless-mcp](/entities/jadx-headless-mcp.md) - 无头反编译 MCP 服务（0.7.1），与 Ghidra 同装于 ~/devtools，为 REA 提供 Java 反编译能力。
* [JDK 25](/entities/jdk-25.md) - 逆向工具链的 Java 运行时依赖（jdk-25.0.5+8），通过 JAVA_HOME 指定，供 Ghidra 等引擎使用。
* [local_webcontents 前端产物](/entities/local-webcontents-前端产物.md) - 豆包客户端渲染层的前端静态产物目录，含 2113 个 JS/JSON（494 MB），本次逆向的实际靶点。
* [REA](/entities/rea.md) - Reverse Engineer Anything v6.8.0，本次逆向工作的主力工具链封装，以 npm 全局包形式安装、由 rea.mjs 子命令驱动。
* [Seed 能力包族](/entities/seed-能力包族.md) - 底层能力包 seed_browser_use / seed_computer_use / seed_computer_use_ax，被上层工具集包装，其中 _ax 走无障碍树。
* [Windows UI Automation](/entities/windows-ui-automation.md) - Windows 系统级无障碍（Accessibility）API，被 seed_computer_use_ax 用于获取界面元素树而非像素识别。
