# 编写自定义组件

了解如何在 A2UI 中定义、实现和注册自定义组件，以 `rizzcharts` 示例为例。本指南专注于围绕 Angular 代码编写组件。

## 概览

编写新组件涉及四个主要步骤：

1.  **定义目录模式（Catalog Schema）**：在 JSON Schema 中指定组件的属性和类型。
2.  **定义组件（客户端）**：使用你的框架（例如 Angular）实现 UI。
3.  **向渲染器注册（客户端）**：将组件添加到客户端目录。
4.  **从智能体调用**：指示智能体通过 `send_a2ui_json_to_client` 使用组件。

---

## 1. 定义目录模式

目录模式定义了你目录的 API。它列出了可用组件及其属性，智能体使用这些来构建 UI 载荷。

**此模式充当客户端和服务器（智能体）之间的契约。** 双方必须对此模式达成一致才能进行渲染。客户端通告其支持的目录，服务器选择一个兼容的目录。有关此握手如何工作的详细信息，请参阅 [A2UI 目录协商](../concepts/catalogs.md#a2ui-catalog-negotiation)。

在 [`rizzcharts`](../../samples/agent/adk/rizzcharts/python/README.md) 示例中，目录模式在 [`rizzcharts_catalog_definition.json`](../../samples/agent/adk/rizzcharts/catalog_schemas/0.9/rizzcharts_catalog_definition.json) 中定义。

以下是 `Chart` 组件的模式：

```json
"Chart": {
  "type": "object",
  "description": "An interactive chart that uses a hierarchical list of objects for its data.",
  "properties": {
    "type": {
      "type": "string",
      "description": "The type of chart to render.",
      "enum": [
        "doughnut",
        "pie"
      ]
    },
    "title": {
      "type": "object",
      "description": "The title of the chart. Can be a literal string or a data model path.",
      "properties": {
        "literalString": {
          "type": "string"
        },
        "path": {
          "type": "string"
        }
      }
    },
    "chartData": {
      "type": "object",
      "description": "The data for the chart, provided as a list of items. Can be a literal array or a data model path.",
      "properties": {
        "literalArray": {
          "type": "array",
          "items": {
            "type": "object",
            "properties": {
              "label": {
                "type": "string"
              },
              "value": {
                "type": "number"
              },
              "drillDown": {
                "type": "array",
                "description": "An optional list of items for the next level of data.",
                "items": {
                  "type": "object",
                  "properties": {
                    "label": {
                      "type": "string"
                    },
                    "value": {
                      "type": "number"
                    }
                  },
                  "required": [
                    "label",
                    "value"
                  ]
                }
              }
            },
            "required": [
              "label",
              "value"
            ]
          }
        },
        "path": {
          "type": "string"
        }
      }
    }
  },
  "required": [
    "type",
    "chartData"
  ]
}
```

---

## 2. 实现组件（客户端）

使用你的客户端框架实现组件。对于 Angular，你的组件应该扩展 `@a2ui/angular` 提供的 `DynamicComponent`。

在 [`rizzcharts`](../../samples/client/angular/projects/rizzcharts/README.md) 示例中，`Chart` 组件在 [`chart.ts`](../../samples/client/angular/projects/rizzcharts/src/a2ui-catalog/chart.ts) 中定义。

```typescript
import { DynamicComponent } from '@a2ui/angular';
import * as Primitives from '@a2ui/web_core/types/primitives';
import * as Types from '@a2ui/web_core/types/types';
import { Component, computed, input, Signal, signal } from '@angular/core';

@Component({
  selector: 'a2ui-chart',
  template: `
    <div>
      <h2>{{ resolvedTitle() }}</h2>
      <canvas baseChart [data]="currentData()" [type]="chartType()"></canvas>
    </div>
  `,
})
export class Chart extends DynamicComponent<Types.CustomNode> {
  readonly type = input.required<string>();
  protected readonly chartType = computed(() => this.type() as ChartType);

  readonly title = input<Primitives.StringValue | null>();
  protected readonly resolvedTitle = computed(() => super.resolvePrimitive(this.title() ?? null));

  readonly chartData = input.required<Primitives.StringValue | null>();
  // ... data resolution logic using super.resolvePrimitive for data paths
}
```

在实现组件时请记住以下关键点：
- **扩展 `DynamicComponent`**：这使你可以使用 `resolvePrimitive` 进行数据绑定（Data Binding）解析。
- **使用 Angular 输入（Inputs）**：将模式中的属性映射到 Angular 输入。

---

## 3. 向渲染器注册（客户端）

组件实现后，将其注册到客户端目录中。这将组件名称（智能体使用的）映射到实现类。

在 [`rizzcharts`](../../samples/agent/adk/rizzcharts/python/README.md) 示例中，这是在 [`catalog.ts`](../../samples/client/angular/projects/rizzcharts/src/a2ui-catalog/catalog.ts) 中完成的。

```typescript
import { Catalog, DEFAULT_CATALOG } from '@a2ui/angular';
import { inputBinding } from '@angular/core';

export const RIZZ_CHARTS_CATALOG = {
  ...DEFAULT_CATALOG,
  Chart: {
    type: () => import('./chart').then((r) => r.Chart),
    bindings: ({ properties }) => [
      inputBinding('type', () => ('type' in properties && properties['type']) || undefined),
      inputBinding('title', () => ('title' in properties && properties['title']) || undefined),
      inputBinding(
        'chartData',
        () => ('chartData' in properties && properties['chartData']) || undefined,
      ),
    ],
  },
} as Catalog;
```

注册的关键点：
- **懒加载（Lazy Loading）**：使用 `import()` 来懒加载组件代码。
- **输入绑定（Input Bindings）**：使用 `inputBinding` 将模式中的属性映射到 Angular 输入。

---

## 4. 从智能体调用

要使用自定义组件，你需要使用来自 A2UI SDK 的工具初始化智能体，这些工具了解你的目录。SDK 会处理解析目录并向模型提供示例。

以下是流程的连接方式：

### 4.1 会话准备（执行器）

执行层（例如 `RizzchartsAgentExecutor`）拦截传入消息以检测是否启用了 A2UI 以及客户端支持哪些目录。它解析目录并将其保存到会话状态。

```python
# In agent_executor.py

use_ui = try_activate_a2ui_extension(context)
if use_ui:
    # Resolve catalog based on client capabilities
    a2ui_catalog = self.schema_manager.get_selected_catalog(
        client_ui_capabilities=capabilities
    )
    examples = self.schema_manager.load_examples(a2ui_catalog, validate=True)

    # Save to session (Event contains state_delta)
    await runner.session_service.append_event(
        session,
        Event(
            actions=EventActions(
                state_delta={
                    _A2UI_ENABLED_KEY: True,
                    _A2UI_CATALOG_KEY: a2ui_catalog,
                    _A2UI_EXAMPLES_KEY: examples,
                }
            ),
        ),
    )
```

### 4.2 智能体工具设置

智能体使用 [SendA2uiToClientToolset](../../agent_sdks/python/src/a2ui/adk/send_a2ui_to_client_toolset.py) 来为智能体提供一个工具，使其可以向客户端发送 A2UI。

```python
from a2ui.adk.send_a2ui_to_client_toolset import SendA2uiToClientToolset

a2ui_catalog = self.schema_manager.get_selected_catalog(
    client_ui_capabilities=capabilities
)
agent.tools = [
    SendA2uiToClientToolset(
        a2ui_catalog=a2ui_catalog,
        a2ui_enabled=True,
    )
]
```

### 4.3 工具执行

LLM 对 [SendA2uiToClientToolset](../../agent_sdks/python/src/a2ui/adk/send_a2ui_to_client_toolset.py) 中工具的调用在 A2A 智能体执行器中使用 [A2uiEventConverter](../../agent_sdks/python/src/a2ui/adk/send_a2ui_to_client_toolset.py) 进行拦截。这会自动将工具调用转换为带有 A2UI 载荷的 A2A Dataparts。

```python
from a2ui.adk.send_a2ui_to_client_toolset import (
    A2uiEventConverter,
)

config = A2aAgentExecutorConfig(event_converter=A2uiEventConverter())
```
