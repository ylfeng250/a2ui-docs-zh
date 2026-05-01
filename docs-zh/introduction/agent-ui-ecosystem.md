# A2UI 对比如何？

智能体 UI 领域正在快速发展。以下是 A2UI 与其他主要方法的关系。

## 一览

| | **A2UI** | **MCP Apps** | **AG UI** |
|---|---|---|---|
| **方法** | 声明式组件蓝图 | 通过 `ui://` URI 提供预构建的 HTML | 连接后端和前端的宽带协议 |
| **渲染** | 原生组件（Angular、Flutter、Lit 等） | 沙盒化 `iframe` | 开发者定义（任何框架） |
| **样式** | 宿主应用控制——继承设计系统 | 隔离——远程服务器控制外观 | 开发者控制——宿主应用的一部分 |
| **安全性** | 声明式数据，无代码执行 | 沙盒化 iframe 隔离 | 你自己应用中的受信任代码 |
| **多智能体** | ✅ 跨越信任边界 | ✅ 多个 MCP 服务器 | ⚠️ 主要是单智能体 |
| **跨平台** | ✅ Web、移动端、桌面端、原生 | ⚠️ 专注于 Web（iframe） | ✅ 协议框架无关 |
| **LLM 生成** | ✅ 专为流式输出设计 | ❌ 由服务器预构建 | ✅ 通过 A2UI 集成 |
| **规格** | 开放协议（Apache 2.0） | [MCP 扩展](https://modelcontextprotocol.io/docs/extensions/apps)（SEP-1865） | 开源（由 CopilotKit） |

## A2UI vs MCP Apps

[MCP Apps](https://blog.modelcontextprotocol.io/posts/2025-11-21-mcp-apps/) 将 UI 视为一种**资源**——服务器通过 `ui://` URI 提供预构建的 HTML，在沙盒化 iframe 中渲染。远程集成控制所有内容与外观，配置通过工具调用来完成。A2UI 采用**声明式 UI** 方法——智能体发送组件蓝图，但宿主应用程序控制样式、主题以及这些组件的配置和渲染方式。当服务器应拥有完整 UI 体验时选择 MCP Apps；当你希望动态、跨平台的 UI 自然融入你的应用时选择 A2UI。

## A2UI vs AG UI / CopilotKit

[AG UI](https://ag-ui.com/) 是一种**传输协议 (Transport Protocol)**，将智能体后端与前端连接，实现实时状态同步。A2UI 是一种**UI 格式**——描述要渲染什么的有效负载。它们是互补的：使用 AG UI 作为管道，A2UI 作为内容。AG UI 是 [CopilotKit](https://copilotkit.ai) 团队的项目，他们也贡献了 [A2UI Composer](../composer.md)。AG UI 具有首日 A2UI 兼容性。

## A2UI vs ChatKit (OpenAI)

[ChatKit](https://platform.openai.com/docs/guides/chatkit) 在 OpenAI 生态系统内提供紧密集成的体验。A2UI 与 ChatKit 有一些共同的设计理念——两者都定义了一组基本组件，并使用可配置的声明式抽象层。A2UI 是**平台无关**的——专为构建自己的智能体表面的开发者设计，涵盖 Web、移动端和桌面端，或者用于需要跨信任边界渲染 UI 的多智能体系统。

## 将它们一起使用

这些方法是互补的，而不是竞争的：

- **A2UI + AG UI** — AG UI 作为传输 (Transport)，A2UI 作为生成式 UI 格式。
- **A2UI + A2A** — A2UI 消息通过 [A2A 协议](../concepts/transports.md) 发送，用于多智能体系统。
- **A2UI + MCP** — 即将到来的桥接允许 MCP 服务器在提供 HTML 资源的同时提供 A2UI 蓝图。

## 延伸阅读

有关更多信息，请参阅以下资源：

- [什么是 A2UI？](what-is-a2ui.md) — 协议概述。
- [传输 (Transports)](../concepts/transports.md) — A2UI 消息如何在智能体和客户端之间传输。
- [A2UI 在哪里使用？](../ecosystem/a2ui-in-the-world.md) — 案例研究和采用者。
