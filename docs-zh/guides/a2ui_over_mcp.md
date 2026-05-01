# 通过模型上下文协议（MCP）提供 A2UI

本指南展示如何使用工具和嵌入资源（Embedded Resources）从 **MCP 服务器**提供**丰富的交互式 A2UI 界面**。完成本指南后，你将拥有一个可工作的 MCP 服务器，可以向任意 MCP 兼容客户端返回 A2UI 组件。

<video width="100%" height="auto" controls playsinline style="display: block; aspect-ratio: 16/9; object-fit: cover; border-radius: 8px; margin-bottom: 24px;">
  <source src="https://raw.githubusercontent.com/google/A2UI/main/docs/assets/guides-a2ui-over-mcp-tour.mp4" type="video/mp4">
  你的浏览器不支持 video 标签。
</video>

## 前提条件

在开始之前，请确保已安装以下内容：

- **Python**（3.10 或更高版本）。
- **[uv](https://docs.astral.sh/uv/)** 用于快速的 Python 包管理。
- **Node.js**（18 或更高版本）用于 MCP Inspector。

## 快速开始：运行示例

在深入研究协议细节之前，让我们先运行一个可工作的示例。A2UI 仓库中包含一个现成的 MCP 示例程序。

```bash
# 克隆仓库（如果尚未克隆）
git clone https://github.com/google/A2UI.git
cd A2UI/samples/agent/mcp/a2ui-over-mcp-recipe

# 启动 MCP 服务器（SSE 传输，端口 8000）
uv run .
```

在单独的终端中，启动 [MCP Inspector](https://github.com/modelcontextprotocol/inspector) 以与服务器交互：

```bash
npx @modelcontextprotocol/inspector
```

在 Inspector 中：

1. 将**传输类型（Transport Type）**设置为 `SSE`
2. 连接到 `http://localhost:8000/sse`
3. 点击 **List Tools** → 你将看到 `get_recipe_a2ui`
4. 运行该工具 → 响应中包含渲染配方卡片的 A2UI JSON

> 注意：
>
> 示例使用了对 A2UI 智能体 SDK 的本地路径引用。对于你自己的项目，请从 PyPI 安装：
> ```bash
> pip install a2ui-agent-sdk
> ```

在 [`samples/agent/mcp/`](https://github.com/google/A2UI/tree/main/samples/agent/mcp) 查看所有示例。

## 工作原理

MCP 服务器将 A2UI 内容作为工具响应中的**嵌入资源**返回。客户端检测到 `application/json+a2ui` MIME 类型并将载荷路由到 A2UI 渲染器。

```
Client → tools/call → MCP Server
                         ↓
              Generate A2UI JSON
                         ↓
         Wrap as EmbeddedResource
              (application/json+a2ui)
                         ↓
Client ← CallToolResult ← MCP Server
   ↓
A2UI Renderer displays UI
```

## 目录协商

服务器在向客户端发送 A2UI 之前，必须建立可用的目录。根据你的架构，这可以通过两种方式之一发生。

### 选项 A：在 MCP 初始化期间（推荐）

MCP 是一种有状态会话协议，因此最有效的方法是在连接设置期间一次性声明能力。客户端在 `capabilities` 下声明其 A2UI 支持：

```json
{
  "jsonrpc": "2.0",
  "method": "initialize",
  "id": "init-123",
  "params": {
    "protocolVersion": "2025-11-25",
    "clientInfo": {
      "name": "a2ui-enabled-client",
      "version": "1.0.0"
    },
    "capabilities": {
      "a2ui": {
        "clientCapabilities": {
          "v0.9": {
            "supportedCatalogIds": [
              "https://a2ui.org/specification/v0_9/basic_catalog.json"
            ]
          }
        }
      }
    }
  }
}
```

服务器会在会话期间存储此状态。

### 选项 B：每消息元数据（适用于无状态服务器）

如果你的服务器必须保持无状态，客户端可以在每次工具调用的 `_meta` 字段中传递 A2UI 能力：

```json
{
  "jsonrpc": "2.0",
  "method": "tools/call",
  "id": "id-123",
  "params": {
    "name": "generate_report",
    "arguments": { "date": "2026-03-01" },
    "_meta": {
      "a2ui": {
        "clientCapabilities": {
          "v0.9": {
            "supportedCatalogIds": [
              "https://a2ui.org/specification/v0_9/basic_catalog.json"
            ],
            "inlineCatalogs": []
          }
        }
      }
    }
  }
}
```

## 返回 A2UI 内容

A2UI 内容作为 `CallToolResult` 中的**嵌入资源**返回。关键规则：

- **URI**：必须使用 `a2ui://` 前缀和描述性名称（例如 `a2ui://training-plan-page`）
- **MIME 类型**：必须是 `application/json+a2ui`——这告诉客户端将载荷路由到 A2UI 渲染器

### Python 示例

```python
import json
import mcp.types as types

@self.tool()
def get_hello_world_ui():
    """Returns a simple A2UI hello world interface."""
    a2ui_payload = [
        {
            "version": "v0.9",
            "createSurface": {
                "surfaceId": "default",
                "catalogId": "https://a2ui.org/specification/v0_9/basic_catalog.json"
            }
        },
        {
            "version": "v0.9",
            "updateComponents": {
                "surfaceId": "default",
                "components": [
                    {
                        "id": "root",
                        "component": "Text",
                        "text": "Hello World!"
                    }
                ]
            }
        }
    ]

    # Wrap A2UI as an Embedded Resource
    a2ui_resource = types.EmbeddedResource(
        type="resource",
        resource=types.TextResourceContents(
            uri="a2ui://hello-world",
            mimeType="application/json+a2ui",
            text=json.dumps(a2ui_payload),
        )
    )

    # Include a text summary alongside the UI
    text_content = types.TextContent(
        type="text",
        text="Here is a hello world UI."
    )

    return types.CallToolResult(content=[text_content, a2ui_resource])
```

> 提示：
>
> 始终在你的 A2UI 资源旁边包含 `TextContent`。不支持 A2UI 的客户端将回退显示文本。

## 处理用户动作

类似 `Button` 的交互式组件可以触发动作，这些动作会作为 MCP 工具调用发送回服务器。

### 1. 定义带动作的按钮

在你的 A2UI JSON 中，为组件添加 `action`：

```json
{
  "id": "confirm-button",
  "component": {
    "Button": {
      "child": "confirm-button-text",
      "action": {
        "event": {
          "name": "confirm_booking",
          "context": {
            "start": "/dates/start",
            "end": "/dates/end"
          }
        }
      }
    }
  }
}
```

### 2. 客户端将动作作为工具调用发送

当用户点击按钮时，客户端会根据表面状态解析数据绑定（如 `/dates/start`）并发送工具调用：

```json
{
  "jsonrpc": "2.0",
  "method": "tools/call",
  "id": "id-456",
  "params": {
    "name": "action",
    "arguments": {
      "name": "confirm_booking",
      "context": {
        "start": "2026-03-20",
        "end": "2026-03-25"
      }
    }
  }
}
```

### 3. 在服务器上处理动作

```python
@self.tool()
async def action(name: str, context: dict) -> types.CallToolResult:
    """Handle A2UI user actions."""
    if name == "confirm_booking":
        # Process the booking, then return confirmation UI
        return types.CallToolResult(content=[
            types.TextContent(
                type="text",
                text=f"Booking confirmed: {context['start']} to {context['end']}"
            )
        ])
    raise ValueError(f"Unknown action: {name}")
```

## 错误处理

客户端可以通过工具调用将 A2UI 渲染错误报告回服务器：

```json
{
  "jsonrpc": "2.0",
  "method": "tools/call",
  "id": "id-789",
  "params": {
    "name": "error",
    "arguments": {
      "code": "INVALID_JSON",
      "message": "Failed to parse A2UI payload.",
      "surfaceId": "default"
    }
  }
}
```

在服务器上处理它：

```python
@self.tool()
async def error(code: str, message: str, surfaceId: str = "") -> types.CallToolResult:
    """Handle A2UI client errors."""
    # Log the error, retry, or send a fallback UI
    return types.CallToolResult(content=[
        types.TextContent(
            type="text",
            text=f"Acknowledged error {code}: {message}"
        )
    ])
```

## 语言化和可见性控制

使用 MCP **资源注释（Resource Annotations）**控制 LLM 是否可以在后续回合中"读取"A2UI 载荷：

```python
a2ui_resource = types.EmbeddedResource(
    type="resource",
    resource=types.TextResourceContents(
        uri="a2ui://training-plan-page",
        mimeType="application/json+a2ui",
        text=json.dumps(a2ui_payload)
    ),
    # Show the UI to the user, but hide the raw JSON from the LLM
    annotations=types.Annotations(audience=["user"])
)
```

| 受众 | 行为 |
|------|------|
| *(空)* | 对用户和 LLM 均可见 |
| `["user"]` | 为用户渲染；对 LLM 上下文隐藏 |
| `["assistant"]` | 可供 LLM 进行后续推理；不渲染 |

## 使用 A2UI 智能体 SDK

对于生产用途，**A2UI 智能体 SDK**会替你处理模式管理、验证和提示生成：

```bash
pip install a2ui-agent-sdk
```

```python
from a2ui.schema.manager import A2uiSchemaManager
from a2ui.basic_catalog.provider import BasicCatalog

# Initialize the schema manager with the basic catalog
schema_manager = A2uiSchemaManager(
    catalogs=[BasicCatalog.get_config()],
)

# Validate A2UI output before sending
selected_catalog = schema_manager.get_selected_catalog()
selected_catalog.validator.validate(a2ui_payload)
```

有关模式管理、动态目录和流式处理的详细信息，请参阅完整的 [智能体开发指南](agent-development.md)。

## 下一步

- [A2UI 规范](../specification/v0.9-a2ui.md) —— 完整的协议参考
- [组件画廊](../reference/components.md) —— 浏览可用组件
- [A2UI 表面中的 MCP 应用](mcp-apps-in-a2ui.md) —— 在 A2UI 中嵌入基于 HTML 的 MCP 应用
- [客户端设置](client-setup.md) —— 构建显示 A2UI 的渲染器
