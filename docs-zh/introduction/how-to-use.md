# 如何使用 A2UI

选择与你的角色和用例匹配的集成路径。

## 三条路径

### 路径 1：构建宿主应用程序（前端）

将 A2UI 渲染集成到你现有的应用中，或构建新的智能体驱动前端。

**选择一个渲染器 (Renderer)：**

- **Web：** Lit、Angular、React。
- **移动端/桌面端：** Flutter GenUI SDK。

**快速设置：**

对于 Angular：

```bash
npm install @a2ui/angular @a2ui/web_core
```

对于 React：

```bash
npm install @a2ui/react @a2ui/web_core
```

连接到智能体消息（SSE、WebSockets 或 A2A），并自定义样式以匹配你的品牌。

**下一步：** [客户端设置指南](../guides/client-setup.md) | [主题定制](../guides/theming.md)

---

### 路径 2：构建智能体（后端）

创建一个能生成 A2UI 响应的智能体，适用于任何兼容的客户端。

**选择你的框架：**

- **Python：** Google ADK、LangChain、自定义。
- **Node.js：** A2A SDK、Vercel AI SDK、自定义。

在你的 LLM 提示中包含 A2UI Schema，生成 JSONL 消息，并通过 SSE、WebSockets 或 A2A 流式传输到客户端。

**下一步：** [智能体开发指南](../guides/agent-development.md)

---

### 路径 3：使用现有框架

通过内置支持 A2UI 的框架使用 A2UI：

- **[AG UI / CopilotKit](https://ag-ui.com/)** - 带有 A2UI 渲染的全栈 React 框架。
- **[Flutter GenUI SDK](https://docs.flutter.dev/ai/genui)** - 跨平台生成式 UI（内部使用 A2UI）。

**下一步：** [智能体 UI 生态系统](agent-ui-ecosystem.md) | [A2UI 在哪里使用？](../ecosystem/a2ui-in-the-world.md)
