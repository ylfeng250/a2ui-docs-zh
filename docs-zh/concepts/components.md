# 组件和结构

A2UI 使用**邻接列表模型**来表示组件层次结构。组件是一个带有 ID 引用的扁平列表，而不是嵌套的 JSON 树。

## 为什么使用扁平列表？

**传统的嵌套方法：**

- LLM 必须在一次传递中生成完美的嵌套
- 难以更新深度嵌套的组件
- 难以增量流式传输

**A2UI 邻接列表：**

- 扁平结构，LLM 易于生成。
- 增量发送组件。
- 通过 ID 更新任何组件。
- 清晰的结构和数据分离。

## 邻接列表模型

=== "v0.8"

    ```json
    {
      "surfaceUpdate": {
        "components": [
          {
            "id": "root",
            "component": {
              "Column": {
                "children": { "explicitList": ["greeting", "buttons"] }
              }
            }
          },
          {
            "id": "greeting",
            "component": {
              "Text": { "text": { "literalString": "Hello" } }
            }
          },
          {
            "id": "buttons",
            "component": {
              "Row": {
                "children": { "explicitList": ["cancel-btn", "ok-btn"] }
              }
            }
          },
          {
            "id": "cancel-btn",
            "component": {
              "Button": {
                "child": "cancel-text",
                "action": { "name": "cancel" }
              }
            }
          },
          {
            "id": "cancel-text",
            "component": {
              "Text": { "text": { "literalString": "Cancel" } }
            }
          },
          {
            "id": "ok-btn",
            "component": {
              "Button": {
                "child": "ok-text",
                "action": { "name": "ok" }
              }
            }
          },
          {
            "id": "ok-text",
            "component": {
              "Text": { "text": { "literalString": "OK" } }
            }
          }
        ]
      }
    }
    ```

=== "v0.9"

    ```json
    {
      "version": "v0.9",
      "updateComponents": {
        "surfaceId": "main",
        "components": [
          {
            "id": "root",
            "component": "Column",
            "children": ["greeting", "buttons"]
          },
          {
            "id": "greeting",
            "component": "Text",
            "text": "Hello"
          },
          {
            "id": "buttons",
            "component": "Row",
            "children": ["cancel-btn", "ok-btn"]
          },
          {
            "id": "cancel-btn",
            "component": "Button",
            "child": "cancel-text",
            "action": { "event": { "name": "cancel" } }
          },
          {
            "id": "cancel-text",
            "component": "Text",
            "text": "Cancel"
          },
          {
            "id": "ok-btn",
            "component": "Button",
            "child": "ok-text",
            "action": { "event": { "name": "ok" } }
          },
          {
            "id": "ok-text",
            "component": "Text",
            "text": "OK"
          }
        ]
      }
    }
    ```

    v0.9 使用更扁平的组件格式：`"component": "Text"` 而不是嵌套的 `{"Text": {...}}`，子元素是简单数组而不是 `{"explicitList": [...]}`。

组件通过 ID 引用子元素，而不是通过嵌套。

## 组件基础

每个组件都有：

1. **ID**：唯一标识符（`"welcome"`）
2. **类型**：组件类型（`Text`、`Button`、`Card`）
3. **属性**：特定于该类型的配置

=== "v0.8"

    ```json
    {
      "id": "welcome",
      "component": {
        "Text": {
          "text": { "literalString": "Hello" },
          "usageHint": "h1"
        }
      }
    }
    ```

=== "v0.9"

    ```json
    {
      "id": "welcome",
      "component": "Text",
      "text": "Hello",
      "variant": "h1"
    }
    ```

## 基础目录 (Basic Catalog)

为了帮助开发者快速上手，A2UI 团队维护了 [基础目录 (Basic Catalog)](../../specification/v0_9/json/basic_catalog.json)。

这是一个预定义的目录文件，包含一组标准通用组件（按钮、输入、卡片）。它不是特殊的"类型"的目录；它只是我们有开源渲染器的一个版本的目录。

有关带示例的完整组件库，请参阅 [组件参考](../reference/components.md)。

## 静态 vs. 动态子元素

**静态（`explicitList`）** - 固定的子元素 ID 列表：
```json
{
  "children": {
    "explicitList": ["back-btn", "title", "menu-btn"]
  }
}
```

**动态（`template`）** - 从数据数组生成子元素：
```json
{
  "children": {
    "template": {
      "dataBinding": "/items",
      "componentId": "item-template"
    }
  }
}
```

对于 `/items` 中的每个元素，渲染 `item-template`。详见 [数据绑定](data-binding.md)。

## 用值填充数据

组件通过两种方式获取值：

- **字面量** - 固定值：`{"text": {"literalString": "Welcome"}}`
- **数据绑定** - 来自数据模型：`{"text": {"path": "/user/name"}}`

LLM 可以生成带有字面量值的组件，或将它们绑定到数据路径以获取动态内容。

## 组合表面 (Surface)

组件组合成**表面 (Surface)**（组件）：

=== "v0.8"

    1. LLM 通过 `surfaceUpdate` 生成组件定义
    2. LLM 通过 `dataModelUpdate` 填充数据
    3. LLM 通过 `beginRendering` 信号渲染
    4. 客户端将所有组件渲染为原生组件

=== "v0.9"

    1. LLM 通过 `createSurface` 创建一个表面（指定目录）
    2. LLM 通过 `updateComponents` 生成组件定义
    3. LLM 通过 `updateDataModel` 填充数据
    4. 客户端将所有组件渲染为原生组件

表面是一个完整的、有凝聚力的 UI（表单、仪表板、聊天等）。

## 增量更新

增量更新支持以下操作：

- **添加** - 发送带有新 ID 的新组件定义
- **更新** - 发送带有现有 ID 和新属性的组件定义
- **移除** - 更新父级的 `children` 列表以排除已移除的 ID

扁平结构使所有更新都成为简单的基于 ID 的操作。

## 定义你自己的目录

虽然基础目录对于开始很有用，但大多数生产应用将定义自己的目录以反映其特定的设计系统。

通过定义你自己的目录，你将智能体限制为仅使用你的应用程序中实际存在的组件和视觉语言，而不是通用的输入或按钮。

有关实现细节，请参阅 [定义你自己的目录指南](../guides/defining-your-own-catalog.md)。

## 最佳实践

1. **描述性 ID**：使用 `"user-profile-card"` 而不是 `"c1"`
2. **浅层层次结构**：避免深层嵌套
3. **结构与内容分离**：使用数据绑定，不使用字面量
4. **使用模板复用**：一个模板，通过动态子元素创建多个实例
