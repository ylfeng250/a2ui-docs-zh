# A2UI 目录 (Catalogs)

## 概述

本指南定义了 A2UI 目录 (Catalog) 架构并提供了实现路线图。它解释了目录 Schema 的结构，概述了使用预构建的"基础目录 (Basic Catalog)"与定义你自己特定于应用的目录的策略，并详细说明了目录协商、版本控制和运行时验证的技术协议。

## 目录 Schema

目录 Schema 是一个 [JSON Schema 文件](../../specification/v0_9/json/client_capabilities.json#L62C5-L95C6)，概述了智能体可以使用服务器驱动 UI 来定义 A2UI 表面的组件、函数和主题。从智能体发送的所有 A2UI JSON 都根据所选的目录进行验证。

以下是 [目录 JSON Schema](../../specification/v0_9/json/client_capabilities.json#L62C5-L95C6)：

```json
{
  "Catalog": {
    "type": "object",
    "description": "A collection of component and function definitions.",
    "properties": {
      "catalogId": {
        "type": "string",
        "description": "Unique identifier for this catalog."
      },
      "components": {
        "type": "object",
        "description": "Definitions for UI components supported by this catalog.",
        "additionalProperties": {
          "$ref": "https://json-schema.org/draft/2020-12/schema"
        }
      },
      "functions": {
        "type": "array",
        "description": "Definitions for functions supported by this catalog.",
        "items": {
          "$ref": "#/$defs/FunctionDefinition"
        }
      },
      "theme": {
        "title": "A2UI Theme",
        "description": "A schema that defines a catalog of A2UI theme properties.",
        "type": "object",
        "additionalProperties": {
          "$ref": "https://json-schema.org/draft/2020-12/schema"
        }
      }
    },
    "required": [
      "catalogId"
    ],
    "additionalProperties": false
  }
}
```

## 目录策略

每个 A2UI 表面都由一个目录 (Catalog) 驱动。目录 (Catalog) 只是一个 JSON Schema 文件，告诉智能体它可以使用的组件、函数和主题。

无论你是构建简单的原型还是复杂的生产应用，要求都是一样的：你必须提供一个智能体用于表达 UI 的目录定义。

### 基础目录 (Basic Catalog)

为了帮助开发者快速上手，A2UI 团队维护了 [基础目录 (Basic Catalog)](../../specification/v0_9/json/basic_catalog.json)。

这是一个预定义的目录文件，包含一组标准通用组件（按钮、输入、卡片）和函数。它不是特殊的"类型"的目录；它只是我们已经编写过并且有开源渲染器的一个版本的目录。

基础目录允许你引导应用程序或验证 A2UI 概念，而无需从头开始编写你自己的 Schema。它故意保持精简，以便不同的渲染器可以轻松实现。

由于 A2UI 是为 LLM 在設計时或运行时生成 UI 而设计的，我们认为可移植性不需要跨多个客户端的标准化目录；LLM 可以为每个单独的前端解释目录。

[查看 A2UI v0.9 基础目录](../../specification/v0_9/json/basic_catalog.json)

### 定义你自己的目录

虽然基础目录对于开始很有用，但大多数生产应用将定义自己的目录以反映其特定的设计系统。

通过定义你自己的目录，你将智能体限制为仅使用你的应用程序中实际存在的组件和视觉语言，而不是通用的输入或按钮。这个目录可以完全从头开始构建，也可以从基础目录导入定义以节省时间（例如，使用基础文本定义同时定义你自己的独特卡片组件）。

为简单起见，我们建议直接反映客户端设计系统构建目录，而不是尝试通过适配器将基础目录映射到它。由于 A2UI 是为 GenUI 设计的，我们期望 LLM 可以为不同的客户端解释不同的目录。

[查看 Rizzcharts 目录示例](../../samples/agent/adk/rizzcharts/catalog_schemas/0.9/rizzcharts_catalog_definition.json)

### 建议

| 用例 | 建议 | 工作量 |
|:-----|:-----|:-------|
| 向成熟的前端添加 A2UI | 定义一个反映你现有设计系统的目录。 | 中等 |
| 向新的/绿地应用添加 A2UI | 从基础目录开始，然后随着应用的发展演变为自己的目录 | 低（假设渲染器已存在） |

## 构建目录

目录是一个 JSON Schema 文件，符合 [目录 Schema](../../specification/v0_9/json/client_capabilities.json#L62C5-L95C6)，定义了智能体在构建表面时可以使用的组件、主题和函数。

### 示例：最小目录

这是一个定义单个组件的简单目录。

```json
{
  "$id": "https://github.com/.../hello_world/v1/catalog.json",
  "components": {
    "HelloWorldBanner": {
      "type": "object",
      "description": "A simple banner greeting.",
      "properties": {
        "message": {
          "type": "string",
          "description": "The banner text."
        },
        "backgroundColor": {
          "type": "string",
          "default": "#f0f0f0"
        }
      },
      "required": [
        "message"
      ]
    }
  }
}
```

当智能体使用该目录时，它会生成严格符合该结构的有效负载：

```json
[
  {
    "version": "v0.9",
    "createSurface": {
      "surfaceId": "hello-world-surface",
      "catalogId": "https://github.com/.../hello_world/v1/catalog.json"
    }
  },
  {
    "version": "v0.9",
    "updateComponents": {
      "surfaceId": "hello-world-surface",
      "components": [
        {
          "id": "root",
          "component": "HelloWorldBanner",
          "message": "Hello, world! Welcome to your first catalog.",
          "backgroundColor": "#4CAF50"
        }
      ]
    }
  }
]
```

### 独立目录

A2UI 目录必须是独立的（不引用外部文件），以简化 LLM 推理和依赖管理。

虽然最终目录必须是独立的，但你仍可以在本地开发期间使用指向外部文档的 JSON Schema `$ref` 模块化地编写目录。在分发目录之前，运行 `tools/build_catalog/assemble_catalog.py` 将所有外部文件引用捆绑到单个独立的 JSON Schema 文件中：

```bash
uv run tools/build_catalog/assemble_catalog.py [INPUTS ...] --output-name <OUTPUT_NAME> [--catalog-id <ID>] [--version <VERSION>] [--extend-basic-catalog] [--out-dir <DIR>] [--verbose]
```

其中：

* `inputs`：一个或多个 A2UI 组件目录 JSON 的路径或 URL。
* `--output-name`：（必需）合并后目录的所需名称（例如 `my_merged_catalog`）。如果省略，会自动附加 `.json` 扩展名。
* `--catalog-id`：输出的自定义 `catalogId`。默认为 `urn:a2ui:catalog:<base_name>`。
* `--version`：要使用的 A2UI 规格版本。可选值为 `0.9` 或 `0.10`。默认为 `0.9`。
* `--extend-basic-catalog`：如果传递，无论输入目录是否显式引用它，都会自动在根输出中包含 `basic_catalog.json` 的全部内容。
* `--out-dir`，`-o`：保存组装目录的目录。默认为 `dist`。
* `--verbose`，`-v`：如果传递，启用详细的调试日志以帮助诊断问题。

### 组合和导入

你不必从头开始定义所有内容。你可以定义一个使用基础目录或其他目录中现有组件的目录，重用现有的渲染逻辑。

#### 示例：扩展基础目录

此目录从基础目录导入所有元素，并添加一个新的 `SuggestionChips` 组件。

```json
{
  "$id": "https://github.com/.../hello_world_with_all_basic/v1/catalog.json",
  "components": {
    "allOf": [
      { "$ref": "basic_catalog_definition.json#/components" },
      {
        "SuggestionChips": {
          "type": "object",
          "description": "A list of suggested prompts",
          "properties": {
            "suggestions": {
              "type": "array",
              "description": "The suggested prompts."
            }
          },
          "required": [ "suggestions" ]
        }
      }
    ]
  }
}
```

**在发布之前，请务必运行 `tools/build_catalog/assemble_catalog.py` 来解析外部 $ref。**

#### 示例：挑选组件

此目录仅从基础目录导入 `Text` 来构建一个简单的 Popup 表面。

```json
{
  "$id": "https://github.com/.../hello_world_with_some_basic/v1/catalog.json",
  "components": {
    "allOf": [
      { "$ref": "basic_catalog.json#/components/Text" },
      {
        "Popup": { 
          "type": "object",
          "description": "A modal overlay that displays an icon and text.",
          "properties": {
            "text": { "$ref": "common_types.json#/$defs/ComponentId" }
          },
          "required": [ "text" ]
        }
      }
    ]
  }
}
```

**在发布之前，请务必运行 `tools/build_catalog/assemble_catalog.py` 来解析外部 $ref。**

### 实现渲染器

客户端渲染器通过将 Schema 定义映射到实际代码来实现目录。

hello world 目录的 TypeScript 渲染器示例：

```typescript
import { Catalog, DEFAULT_CATALOG } from '@a2ui/angular'; 
import { inputBinding } from '@angular/core'; 

export const RIZZ_CHARTS_CATALOG = {   
  ...DEFAULT_CATALOG, // Include the basic catalog   
  HelloWorldBanner: {     
    type: () => import('./hello_world_banner').then((r) => r.HelloWorldBanner),     
    bindings: ({ properties }) => [       
      inputBinding('message', () => ('message' in properties && properties['message']) || undefined)
    ],   
  }, 
} as Catalog;
```

以及 hello_world_banner 的实现：

```typescript
import { DynamicComponent } from '@a2ui/angular';
import { Component, Input } from '@angular/core';

@Component({
  selector: 'hello-world-banner',
  imports: [], 
  template: `
    <div>
      <h2>Hello World Banner</h2>
      <p>{{ message }}</p>
    </div>
  `,
})
export class HelloWorldBanner extends DynamicComponent {
  @Input() message?: string;
}
```

你可以在 [Rizzcharts 演示](../../samples/client/angular/projects/rizzcharts/src/a2ui-catalog/catalog.ts) 中查看客户端渲染器的工作示例。

## A2UI 目录协商

由于客户端和智能体可以支持多个目录，它们必须通过目录协商握手来达成一致。

### 第 1 步：智能体公布其支持的目录（可选）

智能体可以选择性地公布它能够使用的目录（例如，在 A2A 智能体卡中）。这是信息性的；它帮助客户端了解智能体是否支持它们的特定功能，但客户端不必使用它。

以下是一个 A2A AgentCard 示例，公布智能体支持基础和 rizzcharts 目录：

```json
{
  "name": "Ecommerce Dashboard Agent",
  "description": "This agent visualizes ecommerce data...",
  "capabilities": {
    "extensions": [
      {
        "uri": "https://a2ui.org/a2a-extension/a2ui/v0.8",
        "description": "Provides agent driven UI using the A2UI JSON format.",
        "params": {
          "supportedCatalogIds": [
            "https://a2ui.org/specification/v0_9/basic_catalog.json",
            "https://github.com/.../rizzcharts_catalog_definition.json"
          ]
        }
      }
    ]
  }
}
```

### 第 2 步：客户端公布其支持的目录（必需）

客户端按偏好排序，在每条消息的元数据中向智能体发送一个 supportedCatalogIds 列表。这告诉智能体客户端当前准备渲染什么。

以下是一个 A2A 消息示例，其中 metadata 包含 supportedCatalogIds：

```json
{
  "parts": [
    {
      "text": "What is the current status of my flight?"
    }
  ],
  "metadata": {
    "a2uiClientCapabilities": {
      "supportedCatalogIds": [
        "https://a2ui.org/specification/v0_9/basic_catalog.json",
        "https://github.com/.../rizzcharts_catalog_definition.json"
      ]
    }
  }
}
```

### 第 3 步：智能体选择

当智能体创建新表面时，它会从客户端的 `supportedCatalogIds` 列表中选择最佳匹配。此选择在该表面的生命周期内锁定。如果找不到兼容的目录，智能体将不发送 UI。

以下是一个来自智能体的 A2UI 消息示例，定义了表面中使用的 catalog_id：

```json
{
  "createSurface": {
    "surfaceId": "salesDashboard",
    "catalogId": "https://a2ui.org/specification/v0_9/basic_catalog.json"
  }
}
```

## 目录命名和版本控制

A2UI 组件目录需要版本控制，因为目录定义通常是在编译时构建的，因此智能体生成的内容与客户端能够渲染的内容之间的任何不匹配都可能影响 UI。

### CatalogId 命名约定

`catalogId` 是用于客户端和智能体之间协商的唯一文本标识符。

* **格式：** 虽然 `catalogId` 在技术上是字符串，但 A2UI 约定是使用 **URI**（例如 `https://example.com/catalogs/mysurface/v1/catalog.json`）。
* **目的：** 我们使用 URI 使 ID 全局唯一，并方便人类开发者在浏览器中检查。
* **无运行时获取：** 此 URI 并不意味着智能体或客户端在运行时下载目录。**目录定义必须事先（在编译/部署时）为智能体和客户端所知**。URI 仅用作稳定标识符。

### 版本控制指南

为了支持持续演进而不破坏旧客户端或智能体，A2UI 根据变更是否**可以安全忽略**对目录更新进行分类。

虽然标准 JSON 解析器会忽略未知字段，但在服务器驱动 UI 中删除组件可能会删除其整个视图树。为了平衡安全性和灵活性，更新被分为**破坏性**和**非破坏性**类别，依赖**优雅降级**来吸收版本滞后。

*   **破坏性变更（需要主版本提升）**
    任何以旧客户端无法安全忽略的方式更改结构的变更，都需要增加 `catalogId` URI 中的**主**版本（例如从 `v1` 到 `v2`）。
    *   **添加容器组件：** 例如添加 `Grid` 或 `Accordion` 组件。如果旧客户端忽略容器，它将删除所有子元素，破坏 UI 树。
    *   **删除容器组件：** 例如删除 `Grid` 或 `Accordion` 组件。如果旧智能体使用该容器，它将被客户端忽略，客户端将删除其所有子元素，破坏 UI 树。
    *   **更改字段类型：** 例如将属性从 `string` 更改为 `object`。这将在旧客户端上导致 JSON Schema 验证失败。
    *   **添加必需属性：** 没有默认值，因为旧智能体不会知道要发送它。

*   **非破坏性变更（在主版本下允许）**
    可以安全忽略或优雅降级而不破坏布局或数据模型的变更可以保持当前版本。
    *   **添加叶子组件（非容器）：** 例如添加 `Badge` 或 `Tooltip`。如果被忽略，布局保持不变。
    *   **添加可选属性：** 例如向 Card 添加 `subtitle`。
    *   **删除属性：** 如果智能体停止发送它，客户端可以安全地忽略。
    *   **添加新函数或样式：** 通常可以忽略而不更改组件的语义含义。
    *   **元数据变更：** 更新 `description` 字段或修复文档中的拼写错误不需要版本提升，对运行时没有影响。

### 优雅降级

**非破坏性变更依赖优雅降级。** 如果智能体在旧客户端上使用新组件/属性，客户端**必须**优雅地处理它（例如忽略它或渲染文本后备或"不支持"占位符），而不是崩溃。客户端还可以向智能体报告验证错误，使智能体能够自我纠正并自动降级 UI。

#### 优雅降级示例

以下是目录版本不匹配在实际中的处理方式：

*   **旧的 iOS 客户端使用的目录比智能体旧**
    *   智能体发送旧 iOS 客户端不了解的新组件 `Badge`。客户端为其渲染通用文本框占位符或安全文本描述，保持界面其余部分正常运行。
    *   智能体在 `Button` 上发送旧客户端不了解的新属性 `badge`。客户端安全地忽略它并渲染标准按钮。
    *   智能体不再发送在后续目录版本中已删除的 `Facepile` 组件。这对客户端没有问题。

*   **Web 客户端在智能体之前推出新的目录版本**
    *   Web 客户端支持新组件 `Badge`，但智能体尚不了解它。
    *   Web 客户端删除了 `Button` 上的 `badge` 属性，因此如果智能体发送它，客户端会忽略。
    *   Web 客户端添加了智能体不了解的 `Button` 新样式。同样，由于智能体不使用它们，不会造成问题。

### 使用 CatalogId 进行版本控制

我们建议在 catalogId 中包含版本。这允许在迁移期间使用 A2UI 目录协商同时支持多个版本，确保零停机时间。

**推荐模式：**

| 变更类型 | URI 示例 | 说明 |
|:---------|:---------|:-----|
| **当前** | .../rizzcharts/v1/catalog.json | 版本 1.x。支持 1.x 分支中的所有增量更新。 |
| **破坏性** | .../rizzcharts/v2/catalog.json | 引入破坏性结构变更的新 Schema。 |

### 处理迁移

要升级目录而不破坏活跃的智能体，请使用 A2UI 目录协商：

1. **客户端更新：** 客户端更新其 supportedCatalogIds 列表以包含*两个*旧版本和新版本（例如 `[".../v2/...", ".../v1/..."]`）。
2. **智能体更新：** 使用 v2 Schema 重建智能体。当它们看到客户端支持 v2 时，它们会更喜欢它。
3. **遗留支持：** 尚未重建的旧智能体将继续匹配客户端列表中的 v1，确保它们保持可用。

## A2UI Schema 验证和回退

为了确保稳定的用户体验，A2UI 采用两阶段验证策略。这种"纵深防御"方法尽可能早地捕获错误，同时确保客户端在面对意外的有效负载时仍然健壮。

### 两阶段验证

1. **智能体端（发送前）：** 在传输任何 UI 有效负载之前，智能体运行时针对目录定义验证生成的 JSON。
   * 目的：在源头捕获幻觉属性或畸形结构。
   * 结果：如果验证失败，智能体可以尝试修复或重新生成 A2UI JSON，或者进行优雅降级（如在对话应用中回退到文本）。
2. **客户端端：** 收到有效负载后，客户端库针对目录的本地定义验证 JSON。
   * 目的：安全性和稳定性。这确保在用户设备上执行的代码严格符合预期契约，防止版本不匹配或受损的智能体输出。
   * 结果：此处的失败使用"error"客户端消息报告回智能体。

### 优雅降级

即使有效负载通过 Schema 验证，渲染器仍可能遇到运行时问题（例如缺少资产、尚未加载的组件实现或特定于平台的限制）。

客户端在遇到这些错误时不应崩溃。相反，它们应采用优雅降级：

* **未知组件：** 如果组件在 Schema 中已识别但尚未在渲染器中实现，渲染一个"安全"的后备（例如带有组件调试名称的通用卡片）或完全跳过渲染该特定节点。
* **文本回退：** 如果整个表面无法渲染，显示原始文本描述（如果有）或通用错误消息：*"此界面无法显示。"*

### 客户端到服务器的错误报告

当客户端检测到验证错误或运行时故障时，它可以将此报告回智能体。这允许智能体系统为开发者记录故障或调整其未来行为。

客户端使用标准 A2UI 客户端到服务器事件 Schema 发送 `VALIDATION_FAILED` 事件。

以下是客户端报告缺少必需字段的示例：

```json
{
  "version": "v0.9",
  "error": {
    "code": "VALIDATION_FAILED",
    "surfaceId": "flight-status-card-123",
    "path": "/components/FlightCard/flightNumber",
    "message": "Missing required property 'flightNumber' in component 'FlightCard'."
  }
}
```

## 内联目录

客户端在运行时发送的内联目录受支持，但不建议在_production_中使用。有关它们的更多详细信息可以在[此处](../../specification/v0_9/docs/a2ui_protocol.md#client-capabilities--metadata)找到。
