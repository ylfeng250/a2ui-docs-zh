# 什么是 A2UI？

**A2UI（Agent to UI，智能体到 UI）是一种用于智能体驱动界面的声明式 UI 协议。** AI 智能体生成丰富、交互式的 UI，跨平台（Web、移动端、桌面端）原生渲染，无需执行任意代码。

## 问题所在

**仅文本的智能体交互效率低下：**

```
User: "Book a table for 2 tomorrow at 7pm"
Agent: "Okay, for what day?"
User: "Tomorrow"
Agent: "What time?"
...
```

**更好的方式：** 智能体生成一个带有日期选择器、时间选择器和提交按钮的表单。用户与 UI 交互，而不是纯文本。

## 挑战

在多智能体系统中，智能体通常远程运行（不同的服务器、组织）。它们不能直接操纵你的 UI——它们必须发送消息。

**传统方法：** 在 iframe 中发送 HTML/JavaScript。

- 沉重、视觉上不协调。
- 安全复杂性。
- 与应用样式不匹配。

**需要：** 传输像数据一样安全、像代码一样有表达力的 UI。

## 解决方案

A2UI：描述 UI 的 JSON 消息，能够：

- 由 LLM 生成为结构化输出。
- 通过任何传输 (Transport)（A2A、AG UI、SSE、WebSockets）传输。
- 客户端使用自己的原生组件进行渲染。

**结果：** 客户端控制安全性和样式，智能体生成的 UI 感觉像原生的。

### 示例

=== "v0.8 (Stable)"

    ```jsonl
    {
      "surfaceUpdate": {
        "surfaceId": "booking",
        "components": [
          {
            "id": "title",
            "component": {
              "Text": {
                "text": { "literalString": "Book Your Table" },
                "usageHint": "h1"
              }
            }
          },
          {
            "id": "datetime",
            "component": {
              "DateTimeInput": {
                "value": { "path": "/booking/date" },
                "enableDate": true
              }
            }
          },
          {
            "id": "submit-text",
            "component": {
              "Text": {
                "text": { "literalString": "Confirm" }
              }
            }
          },
          {
            "id": "submit-btn",
            "component": {
              "Button": {
                "child": "submit-text",
                "action": { "name": "confirm_booking" }
              }
            }
          }
        ]
      }
    }
    {
      "dataModelUpdate": {
        "surfaceId": "booking",
        "contents": [
          {
            "key": "booking",
            "valueMap": [
              { "key": "date", "valueString": "2025-12-16T19:00:00Z" }
            ]
          }
        ]
      }
    }
    {
      "beginRendering": {
        "surfaceId": "booking",
        "root": "title"
      }
    }
    ```

=== "v0.9 (Draft)"

    ```jsonl
    {
      "version": "v0.9",
      "createSurface": {
        "surfaceId": "booking",
        "catalogId": "https://a2ui.org/specification/v0_9/basic_catalog.json"
      }
    }
    {
      "version": "v0.9",
      "updateComponents": {
        "surfaceId": "booking",
        "components": [
          {
            "id": "title",
            "component": "Text",
            "text": "Book Your Table",
            "variant": "h1"
          },
          {
            "id": "datetime",
            "component": "DateTimeInput",
            "value": { "path": "/booking/date" },
            "enableDate": true
          },
          {
            "id": "submit-text",
            "component": "Text",
            "text": "Confirm"
          },
          {
            "id": "submit-btn",
            "component": "Button",
            "child": "submit-text",
            "variant": "primary",
            "action": {
              "event": { "name": "confirm_booking" }
            }
          }
        ]
      }
    }
    {
      "version": "v0.9",
      "updateDataModel": {
        "surfaceId": "booking",
        "path": "/booking",
        "value": {
          "date": "2025-12-16T19:00:00Z"
        }
      }
    }
    ```

    v0.9 中的关键区别：`createSurface` 替代了 `beginRendering`，组件使用更扁平的结构（`"component": "Text"` 而不是嵌套对象），所有消息都包含 `version` 字段。

客户端将这些消息渲染为原生组件（Angular、Flutter、React 等）。

## 核心价值

**1. 安全性：** 声明式数据，而非代码。智能体从客户端的可信目录 (Catalog) 中请求组件。无代码执行风险。

**2. 原生感：** 没有 iframe。客户端使用自己的 UI 框架进行渲染。继承应用样式、可访问性和性能。

**3. 可移植性：** 一个智能体响应到处可用。相同的 JSON 可在 Web（Lit/Angular/React）、移动端（Flutter/SwiftUI/Jetpack Compose）、桌面端上渲染。

## 设计原则

**1. LLM 友好：** 带 ID 引用的扁平组件列表。易于增量生成、纠正错误和流式传输。

**2. 框架无关：** 智能体发送抽象组件树。客户端将其映射到原生组件（Web/移动端/桌面端）。

**3. 关注点分离：** 三层——UI 结构、应用状态、客户端渲染。实现数据绑定、响应式更新和清晰的架构。

## A2UI 不是什么

- 不是一个框架（它是一个协议）。
- 不是 HTML 的替代品（用于智能体生成的 UI，而非静态网站）。
- 不是一个强大的样式系统（客户端控制样式，服务器端样式支持有限）。
- 不限于 Web（在移动端和桌面端上也能工作）。

## 关键概念

A2UI 依赖以下关键概念：

- **表面 (Surface)**：组件的画布（对话框、侧边栏、主视图）。
- **组件 (Component)**：UI 元素（Button、TextField、Card 等）。
- **数据模型 (Data Model)**：应用状态，组件绑定到它。
- **目录 (Catalog)**：可用的组件类型。
- **消息 (Message)**：JSON 对象（`surfaceUpdate`、`dataModelUpdate`、`beginRendering` 等）。

有关类似项目的比较，请参阅 [智能体 UI 生态系统](agent-ui-ecosystem.md)。
