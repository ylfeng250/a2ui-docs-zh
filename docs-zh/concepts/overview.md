# 核心概念 (Core Concepts)

本节解释了 A2UI 的基本架构。理解这些概念将帮助你构建有效的智能体驱动界面。

有关关键术语的简短定义，请参阅 [术语表](../glossary.md)。

## 全局视角

A2UI 围绕三个核心思想构建：

1. **流式消息 (Streaming Messages)**：UI 更新作为从智能体到客户端的 JSON 消息序列流动
2. **声明式组件 (Declarative Components)**：UI 被描述为数据，而不是编程为代码
3. **数据绑定 (Data Binding)**：UI 结构与应用程序状态分离，实现响应式更新

## 关键主题

### [数据流 (Data Flow)](data-flow.md)
消息如何从智能体传递到渲染的 UI。包括餐厅预订流程的完整生命周期示例、传输选项（SSE、WebSockets、A2A）、渐进式渲染和错误处理。

### [组件结构 (Components)](components.md)
A2UI 的**邻接列表模型**，用于表示组件层次结构。了解为什么扁平列表比嵌套树更好，如何使用静态与动态子元素，以及增量更新的最佳实践。

### [数据绑定 (Data Binding)](data-binding.md)
组件如何使用 JSON Pointer 路径连接到应用状态。涵盖响应式组件、动态列表、输入绑定以及使 A2UI 强大的结构与状态分离。

## 消息类型

=== "v0.8 (Stable)"

    版本 0.8 使用以下消息类型：

    - **`surfaceUpdate`**：定义或更新 UI 组件
    - **`dataModelUpdate`**：更新应用状态
    - **`beginRendering`**：信号客户端渲染
    - **`deleteSurface`**：移除 UI 表面

=== "v0.9 (Draft)"

    版本 0.9 使用以下消息类型：

    - **`createSurface`**：创建新表面并指定其目录 (Catalog)
    - **`updateComponents`**：在表面中添加或更新 UI 组件
    - **`updateDataModel`**：更新应用状态
    - **`deleteSurface`**：移除 UI 表面

    v0.9 将表面创建与渲染分离——`createSurface` 替代了 `beginRendering` 和 `surfaceUpdate` 中的隐式表面创建。所有消息都包含 `version` 字段。

有关完整的技术细节，请参阅 [消息参考](../reference/messages.md)。
