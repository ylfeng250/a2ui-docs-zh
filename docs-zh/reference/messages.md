# 消息类型

本参考资料提供了所有 A2UI 消息类型的详细文档。

## 消息格式

所有 A2UI 消息均为以 JSON Lines（JSONL）格式发送的 JSON 对象。每行恰好包含一条消息。

=== "v0.8 消息类型"

    - `beginRendering` — 通知客户端渲染表面
    - `surfaceUpdate` — 添加或更新组件
    - `dataModelUpdate` — 更新应用状态
    - `deleteSurface` — 删除表面

=== "v0.9 消息类型"

    - `createSurface` — 创建表面并指定其目录
    - `updateComponents` — 添加或更新组件
    - `updateDataModel` — 更新应用状态
    - `deleteSurface` — 删除表面

    所有 v0.9 消息都包含一个 `"version": "v0.9"` 字段。

---

## beginRendering（v0.8）/ createSurface（v0.9）

通知客户端初始化并渲染表面。

=== "v0.8 — `beginRendering`"

    ### Schema

    ```typescript
    {
      beginRendering: {
        surfaceId: string;      // Required: Unique surface identifier
        root: string;           // Required: The ID of the root component to render
        catalogId?: string;     // Optional: URL of component catalog
        styles?: object;        // Optional: Styling information
      }
    }
    ```

    ### Properties

    | 属性          | 类型   | 必需 | 说明                                                           |
    | ------------- | ------ | ---- | -------------------------------------------------------------- |
    | `surfaceId`   | string | ✅    | 此表面的唯一标识符。                                             |
    | `root`        | string | ✅    | 应作为此表面 UI 树根节点的组件 `id`。                             |
    | `catalogId`   | string | ❌    | 组件目录的标识符。如果省略，则默认为 v0.8 标准目录。               |
    | `styles`      | object | ❌    | UI 的样式信息，由目录定义。                                      |

    ### Example

    ```json
    {
      "beginRendering": {
        "surfaceId": "main",
        "root": "root-component"
      }
    }
    ```

    **使用自定义目录：**

    ```json
    {
      "beginRendering": {
        "surfaceId": "custom-ui",
        "root": "root-custom",
        "catalogId": "https://my-company.com/a2ui/v0.8/my_custom_catalog.json"
      }
    }
    ```

    必须在组件定义之后发送。客户端在收到 `beginRendering` 之前会缓冲 `surfaceUpdate` 和 `dataModelUpdate` 消息。

=== "v0.9 — `createSurface`"

    ### Schema

    ```typescript
    {
      version: "v0.9";
      createSurface: {
        surfaceId: string;      // Required: Unique surface identifier
        catalogId: string;      // Required: URL of component catalog
        theme?: object;         // Optional: Theme configuration
        sendDataModel?: boolean; // Optional: Request client to send data model updates
      }
    }
    ```

    ### Properties

    | 属性            | 类型    | 必需 | 说明                                                         |
    | --------------- | ------- | ---- | ------------------------------------------------------------ |
    | `surfaceId`     | string  | ✅    | 此表面的唯一标识符。                                           |
    | `catalogId`     | string  | ✅    | 组件目录的标识符。                                             |
    | `theme`         | object  | ❌    | 主题配置（例如 `primaryColor`）。                               |
    | `sendDataModel` | boolean | ❌    | 如果为 true，客户端会将数据模型变更发送回服务端。                |

    ### Example

    ```json
    {
      "version": "v0.9",
      "createSurface": {
        "surfaceId": "main",
        "catalogId": "https://a2ui.org/specification/v0_9/basic_catalog.json"
      }
    }
    ```

    在 v0.9 中，`createSurface` 替换了 `beginRendering`。根节点由约定确定：`updateComponents` 中必须有一个组件具有 `"id": "root"`。`catalogId` 是必需的。

---

## surfaceUpdate（v0.8）/ updateComponents（v0.9）

在表面内添加或更新组件。

=== "v0.8 — `surfaceUpdate`"

    ### Schema

    ```typescript
    {
      surfaceUpdate: {
        surfaceId: string;        // Required: Target surface
        components: Array<{       // Required: List of components
          id: string;             // Required: Component ID
          component: {            // Required: Wrapper for component data
            [ComponentType]: {    // Required: Exactly one component type
              ...properties       // Component-specific properties
            }
          }
        }>
      }
    }
    ```

    ### Properties

    | 属性          | 类型  | 必需 | 说明                         |
    | ------------- | ----- | ---- | ---------------------------- |
    | `surfaceId`   | string| ✅    | 要更新的表面的 ID              |
    | `components`  | array | ✅    | 组件定义数组                    |

    ### Component Object

    `components` 数组中的每个对象必须包含：

    - `id`（string，必需）：表面内的唯一标识符
    - `component`（object，必需）：一个包装对象，恰好包含一个键（即组件类型，如 `Text`、`Button`）

    ### Examples

    **单个组件：**

    ```json
    {
      "surfaceUpdate": {
        "surfaceId": "main",
        "components": [
          {
            "id": "greeting",
            "component": {
              "Text": {
                "text": {"literalString": "Hello, World!"},
                "usageHint": "h1"
              }
            }
          }
        ]
      }
    }
    ```

    **多个组件（邻接表）：**

    ```json
    {
      "surfaceUpdate": {
        "surfaceId": "main",
        "components": [
          {
            "id": "root",
            "component": {
              "Column": {
                "children": {"explicitList": ["header", "body"]}
              }
            }
          },
          {
            "id": "header",
            "component": {
              "Text": {
                "text": {"literalString": "Welcome"}
              }
            }
          },
          {
            "id": "body",
            "component": {
              "Card": {
                "child": "content"
              }
            }
          },
          {
            "id": "content",
            "component": {
              "Text": {
                "text": {"path": "/message"}
              }
            }
          }
        ]
      }
    }
    ```

    **更新已有组件：**

    ```json
    {
      "surfaceUpdate": {
        "surfaceId": "main",
        "components": [
          {
            "id": "greeting",
            "component": {
              "Text": {
                "text": {"literalString": "Hello, Alice!"},
                "usageHint": "h1"
              }
            }
          }
        ]
      }
    }
    ```

    `id: "greeting"` 的组件会被更新（而非重复添加）。

    ### Usage Notes

    使用时请注意：
    - 必须将一个组件指定为 `beginRendering` 消息中的 `root`，以作为树的根节点。
    - 组件形成邻接表（具有 ID 引用的扁平结构）。
    - 发送具有已存在 ID 的组件将更新该组件。
    - 子元素通过 ID 引用。
    - 组件可以增量添加（流式传输）。

=== "v0.9 — `updateComponents`"

    ### Schema

    ```typescript
    {
      version: "v0.9";
      updateComponents: {
        surfaceId: string;        // Required: Target surface
        components: Array<{       // Required: List of components
          id: string;             // Required: Component ID
          component: string;      // Required: Component type name
          ...properties           // Component-specific properties (flat)
        }>
      }
    }
    ```

    ### Properties

    | 属性          | 类型  | 必需 | 说明                         |
    | ------------- | ----- | ---- | ---------------------------- |
    | `surfaceId`   | string| ✅    | 要更新的表面的 ID              |
    | `components`  | array | ✅    | 组件定义数组                    |

    ### Component Object

    在 v0.9 中，组件结构更扁平：

    - `id`（string，必需）：表面内的唯一标识符
    - `component`（string，必需）：组件类型名称（如 `"Text"`、`"Button"`）
    - 所有其他属性都在组件对象的最顶层。

    ### Examples

    **单个组件：**

    ```json
    {
      "version": "v0.9",
      "updateComponents": {
        "surfaceId": "main",
        "components": [
          {
            "id": "greeting",
            "component": "Text",
            "text": "Hello, World!",
            "variant": "h1"
          }
        ]
      }
    }
    ```

    **多个组件：**

    ```json
    {
      "version": "v0.9",
      "updateComponents": {
        "surfaceId": "main",
        "components": [
          {
            "id": "root",
            "component": "Column",
            "children": ["header", "body"]
          },
          {
            "id": "header",
            "component": "Text",
            "text": "Welcome"
          },
          {
            "id": "body",
            "component": "Card",
            "child": "content"
          },
          {
            "id": "content",
            "component": "Text",
            "text": {"path": "/message"}
          }
        ]
      }
    }
    ```

    **更新已有组件：**

    ```json
    {
      "version": "v0.9",
      "updateComponents": {
        "surfaceId": "main",
        "components": [
          {
            "id": "greeting",
            "component": "Text",
            "text": "Hello, Alice!",
            "variant": "h1"
          }
        ]
      }
    }
    ```

    ### Usage Notes

    使用时请注意：
    - 必须有一个组件具有 `"id": "root"` 以作为树的根节点（约定，而非单独的消息字段）。
    - 组件类型是字符串（`"component": "Text"`）而非包装对象。
    - 属性在组件对象上保持扁平（无类型键嵌套）。
    - 数据绑定使用 `{"path": "/pointer"}`（JSON Pointer）— 与 v0.8 相同的键名，但使用标准 JSON Pointer 路径。
    - 组件可以增量添加（流式传输）。

### Errors

| 错误                     | 原因                               | 解决方案                                                               |
| ------------------------ | ---------------------------------- | ---------------------------------------------------------------------- |
| Surface not found        | `surfaceId` 不存在                  | 确保为给定表面一致地使用唯一的 `surfaceId`。表面在首次更新时隐式创建。 |
| Invalid component type   | 未知的组件类型                      | 检查组件类型是否存在于已协商的目录中。                                  |
| Invalid property         | 该类型不存在此属性                  | 根据目录 schema 进行验证。                                              |
| Circular reference       | 组件将自身引用为子元素               | 修复组件层次结构。                                                      |

---

## dataModelUpdate（v0.8）/ updateDataModel（v0.9）

更新组件绑定的数据模型。

=== "v0.8 — `dataModelUpdate`"

    ### Schema

    ```typescript
    {
      dataModelUpdate: {
        surfaceId: string;      // Required: Target surface
        path?: string;          // Optional: Path to a location in the model
        contents: Array<{       // Required: Data entries
          key: string;
          valueString?: string;
          valueNumber?: number;
          valueBoolean?: boolean;
          valueMap?: Array<{...}>;
        }>
      }
    }
    ```

    ### Properties

    | 属性        | 类型  | 必需 | 说明                                                                    |
    | ----------- | ----- | ---- | ----------------------------------------------------------------------- |
    | `surfaceId` | string| ✅    | 要更新的表面 ID。                                                        |
    | `path`      | string| ❌    | 数据模型中某个位置的路径（如 `user`）。如果省略，更新将应用于根节点。      |
    | `contents`  | array | ✅    | 以邻接表形式的数据条目数组。每个条目有一个 `key` 和一个带类型的 `value*` 属性。 |

    ### `contents` 邻接表

    `contents` 数组是键值对列表。数组中的每个对象必须有一个 `key` 和一个且仅有一个 `value*` 属性（`valueString`、`valueNumber`、`valueBoolean` 或 `valueMap`）。这种结构对 LLM 友好，避免了从泛型 `value` 字段推断类型时的问题。

    ### Examples

    **初始化整个模型：**

    ```json
    {
      "dataModelUpdate": {
        "surfaceId": "main",
        "contents": [
          {
            "key": "user",
            "valueMap": [
              { "key": "name", "valueString": "Alice" },
              { "key": "email", "valueString": "alice@example.com" }
            ]
          },
          { "key": "items", "valueMap": [] }
        ]
      }
    }
    ```

    **更新嵌套属性：**

    ```json
    {
      "dataModelUpdate": {
        "surfaceId": "main",
        "path": "user",
        "contents": [
          { "key": "email", "valueString": "alice@newdomain.com" }
        ]
      }
    }
    ```

    这将更改 `/user/email` 而不影响 `/user/name`。

    ### Usage Notes

    使用时请注意：
    - 数据模型按表面隔离。
    - 当绑定的数据发生变化时，组件会自动重新渲染。
    - 建议对特定路径进行细粒度更新，而非替换整个模型。
    - 使用带类型的值字段（`valueString`、`valueNumber`、`valueBoolean`、`valueMap`）— 对 LLM 友好，无需类型推断。
    - 任何数据转换（例如格式化日期）必须由服务端在发送消息之前完成。

=== "v0.9 — `updateDataModel`"

    ### Schema

    ```typescript
    {
      version: "v0.9";
      updateDataModel: {
        surfaceId: string;      // Required: Target surface
        path?: string;          // Optional: JSON Pointer path (defaults to "/")
        value?: any;            // Optional: Value to set (omit to delete)
      }
    }
    ```

    ### Properties

    | 属性        | 类型 | 必需 | 说明                                                       |
    | ----------- | ---- | ---- | ---------------------------------------------------------- |
    | `surfaceId` | string| ✅   | 要更新的表面 ID。                                            |
    | `path`      | string| ❌   | JSON Pointer 路径（如 `/user/email`）。默认值为 `/`（根节点）。 |
    | `value`     | any  | ❌   | 要设置的值。如果省略，则删除 `path` 处的键。                  |

    ### Examples

    **初始化整个模型：**

    ```json
    {
      "version": "v0.9",
      "updateDataModel": {
        "surfaceId": "main",
        "path": "/",
        "value": {
          "user": {
            "name": "Alice",
            "email": "alice@example.com"
          },
          "items": []
        }
      }
    }
    ```

    **更新嵌套属性：**

    ```json
    {
      "version": "v0.9",
      "updateDataModel": {
        "surfaceId": "main",
        "path": "/user/email",
        "value": "alice@newdomain.com"
      }
    }
    ```

    ### Usage Notes

    使用时请注意：
    - v0.9 使用标准 JSON Pointer 路径和纯 JSON 值 — 无需带类型的包装器。
    - 如果省略 `path`，默认为 `"/"`（根节点）。
    - `value` 可以是任何 JSON 类型（字符串、数字、布尔值、对象、数组、null）。省略即删除。
    - 比 v0.8 的 `contents` 邻接表更简洁 — 更接近标准 JSON Patch 语义。
    - 引用 `{"path": "/user/email"}` 的组件会在那条路径变更时自动更新。

---

## deleteSurface

删除表面及其所有组件和数据。

=== "v0.8 — `deleteSurface`"

    ### Schema

    ```typescript
    {
      deleteSurface: {
        surfaceId: string;        // Required: Surface to delete
      }
    }
    ```

    ### Example

    ```json
    {
      "deleteSurface": {
        "surfaceId": "modal"
      }
    }
    ```

=== "v0.9 — `deleteSurface`"

    ### Schema

    ```typescript
    {
      version: "v0.9";
      deleteSurface: {
        surfaceId: string;        // Required: Surface to delete
      }
    }
    ```

    ### Example

    ```json
    {
      "version": "v0.9",
      "deleteSurface": {
        "surfaceId": "modal"
      }
    }
    ```

### Properties

| 属性        | 类型  | 必需 | 说明               |
| ----------- | ----- | ---- | ------------------ |
| `surfaceId` | string| ✅    | 要删除的表面的 ID    |

### Usage Notes

使用时请注意：
- 删除与表面关联的所有组件。
- 清除该表面的数据模型。
- 客户端应从 UI 中移除该表面。
- 删除不存在的表面是安全的（空操作）。
- 在关闭模态框、对话框或导航离开时使用。
- 两个版本中的结构相同（v0.9 仅添加了 `version` 字段）。

---

## 消息顺序

### 要求

消息顺序必须满足以下要求：

1. `beginRendering` 必须在该表面的初始 `surfaceUpdate` 消息之后。
2. `surfaceUpdate` 可以在 `dataModelUpdate` 之前或之后。
3. 不同表面的消息是独立的。
4. 多条消息可以增量更新同一表面。

### 推荐顺序

=== "v0.8"

    ```jsonl
    { "surfaceUpdate":    { "surfaceId": "main", "components": [...] } }
    { "dataModelUpdate":  { "surfaceId": "main", "contents": {...} } }
    { "beginRendering":   { "surfaceId": "main", "root": "root-id" } }
    ```

=== "v0.9"

    ```jsonl
    { "version": "v0.9", "createSurface":    { "surfaceId": "main", "catalogId": "..." } }
    { "version": "v0.9", "updateComponents": { "surfaceId": "main", "components": [...] } }
    { "version": "v0.9", "updateDataModel":  { "surfaceId": "main", "path": "/", "value": {...} } }
    ```

### 渐进式构建

=== "v0.8"

    ```jsonl
    { "surfaceUpdate":   { "surfaceId": "main", "components": [...] } }  // Header
    { "surfaceUpdate":   { "surfaceId": "main", "components": [...] } }  // Body
    { "beginRendering":  { "surfaceId": "main", "root": "root-id" } }   // Render
    { "surfaceUpdate":   { "surfaceId": "main", "components": [...] } }  // Footer
    { "dataModelUpdate": { "surfaceId": "main", "contents": {...} } }    // Data
    ```

=== "v0.9"

    ```jsonl
    { "version": "v0.9", "createSurface":    { "surfaceId": "main", "catalogId": "..." } }
    { "version": "v0.9", "updateComponents": { "surfaceId": "main", "components": [...] } }  // Header
    { "version": "v0.9", "updateComponents": { "surfaceId": "main", "components": [...] } }  // Body + Footer
    { "version": "v0.9", "updateDataModel":  { "surfaceId": "main", "path": "/", "value": {...} } }
    ```

## 验证

=== "v0.8"

    根据以下内容进行验证：

    - **[server_to_client.json](../../specification/v0_8/json/server_to_client.json)**：消息信封 schema。
    - **[standard_catalog_definition.json](../../specification/v0_8/json/standard_catalog_definition.json)**：组件 schemas。

=== "v0.9"

    根据以下内容进行验证：

    - **[server_to_client.json](../../specification/v0_9/json/server_to_client.json)**：消息信封 schema。
    - **[basic_catalog.json](../../specification/v0_9/json/basic_catalog.json)**：组件 schemas。

## 延伸阅读

- **[组件库](components.md)**：所有可用的组件类型
- **[数据绑定指南](../concepts/data-binding.md)**：数据绑定如何工作
- **[Agent 开发指南](../guides/agent-development.md)**：生成有效的消息
