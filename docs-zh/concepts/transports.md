# 传输 (Transports)（消息传递）

传输 (Transport) 将 A2UI 消息从智能体传递到客户端。A2UI 与传输无关——可以使用任何能发送 JSON 的方法。

实际的组件渲染由 [渲染器 (Renderer)](../reference/renderers.md) 完成，[智能体 (Agent)](../reference/agents.md) 负责生成 A2UI 消息。将消息从智能体传递到客户端是传输的工作。

## 工作原理

```
Agent → Transport → Client Renderer
```

A2UI 定义了 JSON 消息的序列。传输层负责将此序列从智能体传递到客户端。常见的传输机制是使用 JSON Lines (JSONL) 等格式的流，其中每行是单个 A2UI 消息。

## 可用传输

| 传输 | 状态 | 用例 |
|------|------|------|
| **A2A 协议** | ✅ 稳定 | 多智能体系统、企业网格 |
| **AG UI** | ✅ 稳定 | 全栈 React 应用 |
| **REST API** | 📋 计划中 | 简单 HTTP 端点 |
| **WebSockets** | 💡 提议中 | 实时双向 |
| **SSE（服务器发送事件）** | 💡 提议中 | Web 流式传输 |

## A2A 协议

[Agent2Agent (A2A) 协议](https://a2a-protocol.org) 提供安全的标准化智能体通信。A2A 扩展提供了与 A2UI 的便捷集成。

**优势：**

- 内置安全性和身份验证。
- 多种消息格式、身份验证和传输协议的绑定。
- 清晰的关注点分离。

如果你使用 A2A，这应该是几乎自动的。

TODO：添加详细指南。

**参见：** [A2A 扩展规格说明](../specification/v0.8-a2a-extension.md)

## AG UI

[AG UI](https://ag-ui.com/) 将 A2UI 消息转换为 AG UI 事件，并自动处理传输和状态同步。它是 React / Next.js 客户端的推荐传输方式。

**参见：** [与任何智能体框架使用 A2UI（使用 AG-UI）](../guides/a2ui-with-any-agent-framework.md) — 将 CopilotKit 与你选择的智能体框架配合使用并启用 A2UI 渲染的指南。

## 自定义传输

你可以使用任何发送 JSON 的传输：

**HTTP/REST：**

```javascript
// TODO: Add an example
```

**WebSockets：**

```javascript
// TODO: Add an example
```

**Server-Sent Events：**

```javascript
// TODO: Add an example
```

## 下一步

- **[A2A 协议文档](https://a2a-protocol.org)**：了解 A2A
- **[A2A 扩展规格](../specification/v0.8-a2a-extension.md)**：A2UI + A2A 详情
