# Agent（服务端）

Agent 是服务端程序，用于在响应用户请求时生成 A2UI 消息。

实际的组件渲染由 [渲染器](renderers.md) 完成，在消息通过 [传输层](../concepts/transports.md) 传递到客户端之后。Agent 仅负责生成 A2UI 消息。

## Agent 工作原理

Agent 的工作流程通常包括以下步骤：

1. **接收**用户消息。
2. **处理**：使用 LLM（Gemini、GPT、Claude 等）。
3. **生成** A2UI JSON 消息作为结构化输出。
4. **发送**到客户端（通过传输层）。

来自客户端的用户交互可以视为新的用户输入。

## 示例 Agent

A2UI 仓库包含了可供学习的示例 Agent：

- [Restaurant Finder](https://github.com/google/A2UI/tree/main/samples/agent/adk/restaurant_finder)
    - 使用表单进行餐桌预订。
    - 使用 ADK 编写。
- [Contact Lookup](https://github.com/google/A2UI/tree/main/samples/agent/adk/contact_lookup)
    - 带结果列表的搜索。
    - 使用 ADK 编写。
- [Rizzcharts](https://github.com/google/A2UI/tree/main/samples/agent/adk/rizzcharts/python)
    - A2UI 自定义组件演示。
    - 使用 ADK 编写。
- [Orchestrator](https://github.com/google/A2UI/tree/main/samples/agent/adk/orchestrator)
    - 从远程子 Agent 传递 A2UI 消息。
    - 使用 ADK 编写。

## A2A 中的 Agent 类型

### 1. 面向用户的 Agent（独立）

面向用户的 Agent（User Facing Agent）是用户直接交互的 Agent。

### 2. 作为远程 Agent 宿主的面向用户的 Agent

这是一种模式，其中面向用户的 Agent 充当一个或多个远程 Agent 的宿主。面向用户的 Agent 将调用远程 Agent，远程 Agent 将生成 A2UI 消息。这是 [A2A](https://a2a-protocol.org) 中的一种常见模式，客户端 Agent 调用服务端 Agent。

在此模式中，面向用户的 Agent 可以以两种方式处理消息：
- 面向用户的 Agent 可以"直通" A2UI 消息而无需修改。
- 面向用户的 Agent 可以在发送到客户端之前修改 A2UI 消息。

### 3. 远程 Agent

远程 Agent（Remote Agent）不直接属于面向用户的 UI。相反，它注册为远程 Agent，可以由面向用户的 Agent 调用。这是 [A2A](https://a2a-protocol.org) 中的一种常见模式，客户端 Agent 调用服务端 Agent。
