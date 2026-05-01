# A2UI 在世界

A2UI 正被 Google 和合作伙伴组织的团队采用，用于构建下一代智能体驱动的应用程序。以下是 A2UI 产生影响的实际案例。

## 生产环境部署

### Google Opal：人人可用的 AI 迷你应用

[Opal](http://opal.google) 让数十万人能够通过自然语言构建、编辑和分享 AI 迷你应用 — 无需编码。

**Opal 如何使用 A2UI：**

Google 的 Opal 团队自始至终都是 **A2UI 的核心贡献者**。他们使用 A2UI 为 Opal 的 AI 迷你应用提供动力，实现动态的生成式 UI 系统。

- **快速原型设计**：快速构建和测试新的 UI 模式。
- **用户生成的应用**：任何人都可以创建具有自定义 UI 的应用。
- **动态界面**：UI 自动适应每个用例。

> "A2UI 是我们工作的基石。它赋予我们灵活性，让 AI 以新颖的方式驱动用户体验，而不受固定前端的限制。其声明式特性和对安全的关注使我们能够快速且安全地进行实验。"
>
> **— Dimitri Glazkov**，Opal 团队首席工程师

**了解更多：** [opal.google](http://opal.google)

---

### Gemini Enterprise：面向企业的自定义 Agent

Gemini Enterprise 使企业能够构建强大的、定制的 AI Agent，以满足其特定的工作流程和数据需求。

**Gemini Enterprise 如何使用 A2UI：**

A2UI 正被集成到企业中，允许企业 Agent 在业务应用程序中渲染**丰富的交互式 UI** — 超越简单的文本响应，引导员工完成复杂的工作流程。

- **数据输入表单**：AI 生成的结构化数据收集表单。
- **审批仪表板**：用于审查和审批流程的动态 UI。
- **工作流程自动化**：复杂任务的逐步界面。
- **定制企业 UI**：针对行业特定需求的定制化界面。

> "我们的客户需要他们的 Agent 不仅仅是回答问题；他们需要 Agent 引导员工完成复杂的工作流程。A2UI 将允许在 Gemini Enterprise 上构建的开发者让他们的 Agent 生成任何任务所需的动态自定义 UI，从数据输入表单到审批仪表板，大幅加速工作流程自动化。"
>
> **— Fred Jabbour**，Gemini Enterprise 产品经理

**了解更多：** [Gemini Enterprise](https://cloud.google.com/gemini)

---

### Flutter GenUI SDK：面向移动端的生成式 UI

[Flutter GenUI SDK](https://docs.flutter.dev/ai/genui) 为跨移动端、桌面端和 Web 的 Flutter 应用程序带来动态的、AI 生成的 UI。

**GenUI 如何使用 A2UI：**

GenUI SDK 使用 **A2UI 作为服务端 Agent 和 Flutter 应用程序之间通信的基础协议**。当您使用 GenUI 时，底层就是在使用 A2UI。

- **跨平台支持**：同一 Agent 可在 iOS、Android、Web、桌面端运行。
- **原生性能**：Flutter 小组件在每个平台上原生渲染。
- **品牌一致性**：UI 匹配应用的设计系统。
- **服务端驱动 UI**：Agent 控制显示内容，无需应用更新。

> "我们的开发者选择 Flutter 是因为它使他们能够快速创建富有表现力、品牌丰富、自定义设计系统，在每个平台上都感觉很棒。A2UI 非常适合 Flutter 的 GenUI SDK，因为它确保每个用户、在每个平台上都能获得高质量的类原生体验。"
>
> **— Vijay Menon**，Dart & Flutter 工程总监

**试用：**

- [GenUI 文档](https://docs.flutter.dev/ai/genui)
- [入门视频](https://www.youtube.com/watch?v=nWr6eZKM6no)
- [Verdure 示例](https://github.com/flutter/genui/tree/main/examples/verdure)（客户端-服务端 A2UI 示例）

---

### Google ADK：Agent 开发工具包

[Agent Development Kit](https://google.github.io/adk-docs/)（ADK）是 Google 用于构建和部署 AI Agent 的开源框架。内置的开发者 UI [ADK Web](https://github.com/google/adk-web) 包含原生 A2UI 渲染。

**ADK 如何使用 A2UI：**

ADK 集成了 A2UI v0.8 标准目录，可直接在聊天中将符合规范的 Agent 部分渲染为原生 UI 组件。ADK 还处理 A2UI↔A2A 消息转换，因此用 ADK 构建的 Agent 可以向任何支持 A2UI 的客户端发送丰富的 UI。

- **内置渲染**：ADK Web 在开发 UI 中原生渲染 A2UI 组件。
- **A2A 集成**：A2UI 消息在 A2A DataPart 元数据和 ADK 事件之间转换。
- **Agent SDK**：[A2UI Python Agent SDK](https://github.com/google/A2UI/tree/main/agent_sdks/python) 提供了一个 ADK 扩展，用于从 Agent 生成 A2UI。

**试用：**
- [ADK 文档](https://google.github.io/adk-docs/)
- [ADK Web](https://github.com/google/adk-web)（带有 A2UI 支持的开发者 UI）
- [Agent 开发指南](../guides/agent-development.md)（使用 ADK 构建 A2UI Agent）

---

## 合作伙伴集成

### AG UI / CopilotKit：全栈智能体框架

[AG UI](https://ag-ui.com/) 和 [CopilotKit](https://www.copilotkit.ai/) 提供了一个用于构建智能体应用程序的综合框架，具有**零日 A2UI 兼容性**。

**它们如何协同工作：**

AG UI 擅长在自定义前端和其专用 Agent 之间创建高带宽连接。通过添加 A2UI 支持，开发者可以获得两全其美的效果：

- **状态同步**：AG UI 处理应用状态和聊天历史。
- **A2UI 渲染**：从第三方 Agent 渲染动态 UI。
- **多 Agent 支持**：协调来自多个 Agent 的 UI。
- **React 集成**：与 React 应用程序无缝集成。

> "AG UI 擅长在自定义构建的前端和其专用 Agent 之间创建高带宽连接。通过添加对 A2UI 的支持，我们为开发者提供了两全其美的效果。他们现在可以构建丰富的、状态同步的应用程序，同时还能通过 A2UI 渲染来自第三方 Agent 的动态 UI。这对于多 Agent 世界来说是一个完美的匹配。"
>
> **— Atai Barkai**，CopilotKit 和 AG UI 创始人

**了解更多：**

- [AG UI](https://ag-ui.com/)
- [CopilotKit](https://www.copilotkit.ai/)

---

### AG2：原生支持 A2UI 的多 Agent 框架

[AG2](https://ag2.ai/) 是一个流行的多 Agent 框架，提供高级的 Agent 编排能力。其 [A2UIAgent](https://docs.ag2.ai/latest/docs/user-guide/reference-agents/a2uiagent) 是一个具有原生 A2UI 支持的参考 Agent，使 AG2 Agent 能够通过 A2A 和 AG-UI 生成丰富的交互式 UI。

**AG2 如何使用 A2UI：**

A2UIAgent 在 AG2 的 ConversableAgent 中扩展了内置的 A2UI 功能 — 提示工程、带重试的 schema 验证和操作处理 — 因此开发者可以为 Agent 添加生成式 UI，而无需自定义渲染代码。

- **验证输出**：内置的 schema 验证和重试确保可靠的 A2UI 生成。
- **双重传输**：通过 A2A（JSON-RPC）和 AG-UI（SSE）提供相同的 UI。
- **跨平台**：一个 Agent 服务于 Web、桌面和移动客户端。
- **自定义目录**：使用特定领域的组件扩展组件目录。

> "A2UIAgent 将 A2UI 协议带到 AG2，使 Agent 能够通过动态、丰富和交互式 UI 进行表达。可靠的、与客户端无关的渲染意味着我们的开发者在集成上花的时间更少，在构建优秀体验上花的时间更多。"
>
> **— Mark Sze**，AG2 创始工程师

**了解更多：**

- [A2UIAgent 文档](https://docs.ag2.ai/latest/docs/user-guide/reference-agents/a2uiagent)
- [技术深入](https://docs.ag2.ai/latest/docs/blog/2026/03/20/AG2-A2UI/) — 使用 AG2 构建 A2UI Agent
- [A2UIAgent + Flutter 示例](https://github.com/ag2ai/build-with-ag2/tree/main/a2ui/flutter) — A2UIAgent 通过 A2A 提供给 Flutter GenUI 客户端
- [AG2](https://ag2.ai/)

---

### Google 的 AI 驱动产品

随着 Google 在公司范围内采用 AI，A2UI 提供了一种**标准化方式，让 AI Agent 交换用户界面**，而不仅仅是文本。

**内部 Agent 采用情况：**

- **多 Agent 工作流**：多个 Agent 为同一表面做出贡献。
- **远程 Agent 支持**：运行在不同服务上的 Agent 可以提供 UI。
- **标准化**：跨团队的通用协议减少了集成开销。
- **外部暴露**：内部 Agent 可以轻松暴露到外部（例如 Gemini Enterprise）。

> "就像 A2A 让任何 Agent 可以与其他 Agent 通信，与平台无关一样，A2UI 标准化了用户界面层，并通过编排器支持远程 Agent 用例。这对内部团队来说非常强大，使他们能够快速开发 Agent，让丰富的用户界面成为常态而非例外。随着 Google 进一步推动生成式 UI，A2UI 为服务端驱动 UI 提供了一个完美的平台，可在任何客户端上渲染。"
>
> **— James Wren**，AI 驱动的 Google 高级首席工程师

---

## 社区项目

A2UI 社区正在构建令人兴奋的项目：

### 开源示例

- **Restaurant Finder**（[samples/agent/adk/restaurant_finder](https://github.com/google/A2UI/tree/main/samples/agent/adk/restaurant_finder)）
    - 带动态表单的餐桌预订
    - Gemini 驱动的 Agent
    - 提供完整源代码

- **Contact Lookup**（[samples/agent/adk/contact_lookup](https://github.com/google/A2UI/tree/main/samples/agent/adk/contact_lookup)）
    - 带结果列表的搜索界面
    - A2A Agent 示例
    - 演示数据绑定

- **Component Gallery**（[samples/client/angular - gallery mode](https://github.com/google/A2UI/tree/main/samples/client/angular)）
    - 所有组件的交互式展示
    - 带代码的在线示例
    - 非常适合学习

### 第三方集成

- **[json-render](https://json-render.dev/docs/a2ui)** — Vercel 的 React 库，通过 Zod schemas 渲染 A2UI 组件目录。参见 [json-render 与 A2UI 对比](https://dipjyotimetia.medium.com/vercels-json-render-vs-google-s-a2ui-the-head-to-head-6f213cf1a23b)。
- **[OpenClaw Canvas](https://docs.openclaw.ai/platforms/mac/canvas)** — OpenClaw 使用 A2UI 通过其 canvas 系统在连接设备上渲染 Agent 生成的 UI。参见 [架构概述](https://ppaolo.substack.com/p/openclaw-system-architecture-overview)。

### 社区贡献

用 A2UI 构建了什么？[与社区分享！](community.md)

---

## 下一步

如需了解更多信息，请参阅以下资源：

- [快速入门指南](../quickstart.md) - 尝试演示。
- [Agent 开发](../guides/agent-development.md) - 构建 Agent。
- [客户端设置](../guides/client-setup.md) - 集成渲染器。
- [社区](community.md) - 加入社区。

---

**在生产环境中使用 A2UI？** 在 [GitHub Discussions](https://github.com/google/A2UI/discussions) 上分享您的故事。
