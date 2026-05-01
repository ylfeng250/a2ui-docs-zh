# 智能体开发指南

构建生成 A2UI 界面的 AI 智能体。本指南涵盖从 LLM 生成和流式传输 UI 消息。

## 快速概览

构建 A2UI 智能体：

1. **理解用户意图** → 决定显示什么 UI
2. **生成 A2UI JSON** → 使用 LLM 结构化输出或提示
3. **验证与流式传输** → 检查模式，发送到客户端
4. **处理动作** → 响应用户交互

## 从一个简单的智能体开始

本指南使用 ADK 构建一个简单的智能体，从文本开始并将其升级为 A2UI。

请参阅 [ADK 快速入门](https://google.github.io/adk-docs/get-started/python/) 中的分步说明。

```bash
pip install google-adk
adk create my_agent
```

> **提示**：如果你正在使用 `uv` 并且在示例目录中工作（或者项目已经依赖 `google-adk`），你可以使用 `uv run adk` 而不是全局安装：
>
> ```bash
> uv run adk create my_agent
> ```

然后用一个非常简单的餐厅推荐智能体编辑 `my_agent/agent.py` 文件。

```python
import json
from google.adk.agents.llm_agent import Agent
from google.adk.tools.tool_context import ToolContext

def get_restaurants(tool_context: ToolContext) -> str:
    """Call this tool to get a list of restaurants."""
    return json.dumps([
        {
            "name": "Xi'an Famous Foods",
            "detail": "Spicy and savory hand-pulled noodles.",
            "imageUrl": "http://localhost:10002/static/shrimpchowmein.jpeg",
            "rating": "★★★★☆",
            "infoLink": "[More Info](https://www.xianfoods.com/)",
            "address": "81 St Marks Pl, New York, NY 10003"
        },
        {
            "name": "Han Dynasty",
            "detail": "Authentic Szechuan cuisine.",
            "imageUrl": "http://localhost:10002/static/mapotofu.jpeg",
            "rating": "★★★★☆",
            "infoLink": "[More Info](https://www.handynasty.net/)",
            "address": "90 3rd Ave, New York, NY 10003"
        },
        {
            "name": "RedFarm",
            "detail": "Modern Chinese with a farm-to-table approach.",
            "imageUrl": "http://localhost:10002/static/beefbroccoli.jpeg",
            "rating": "★★★★☆",
            "infoLink": "[More Info](https://www.redfarmnyc.com/)",
            "address": "529 Hudson St, New York, NY 10014"
        },
    ])

AGENT_INSTRUCTION="""
You are a helpful restaurant finding assistant. Your goal is to help users find and book restaurants using a rich UI.

To achieve this, you MUST follow this logic:

1.  **For finding restaurants:**
    a. You MUST call the `get_restaurants` tool. Extract the cuisine, location, and a specific number (`count`) of restaurants from the user's query (e.g., for "top 5 chinese places", count is 5).
    b. After receiving the data, you MUST follow the instructions precisely to generate the final a2ui UI JSON, using the appropriate UI example from the `prompt_builder.py` based on the number of restaurants."""

root_agent = Agent(
    model='gemini-2.5-flash',
    name="restaurant_agent",
    description="An agent that finds restaurants and helps book tables.",
    instruction=AGENT_INSTRUCTION,
    tools=[get_restaurants],
)
```

别忘了设置 `GOOGLE_API_KEY` 环境变量来运行此示例。

```bash
echo 'GOOGLE_API_KEY="YOUR_API_KEY"' > .env
```

你可以使用 ADK Web 界面测试这个智能体：

```bash
adk web
```

从列表中选择 `my_agent`，询问关于纽约餐厅的问题。你应该会在 UI 中以纯文本形式看到餐厅列表。

## 生成 A2UI 消息

让 LLM 生成 A2UI 消息需要进行一些提示工程。SDK 提供了 `A2uiSchemaManager` 来帮助你生成包含 A2UI 模式和组件目录示例的系统提示。

首先，确保你已经安装了 `a2ui-agent-sdk`（示例中已包含）。

在你的智能体文件（例如 `agent.py`）中，导入必要的类：

```python
from a2ui.schema.constants import VERSION_0_8, VERSION_0_9
from a2ui.schema.manager import A2uiSchemaManager
from a2ui.basic_catalog.provider import BasicCatalog
```

然后，你可以使用 `A2uiSchemaManager` 来生成系统提示。这确保模式和示例被正确格式化并保持最新。

```python
# Define your agent's role
ROLE_DESCRIPTION = (
    "You are a helpful restaurant finding assistant. Your final output MUST be a a2ui"
    " UI JSON response."
)

# Define rules for when to use which UI template
UI_DESCRIPTION = """
-   If the query is for a list of restaurants, use the restaurant data you have already received from the `get_restaurants` tool to populate the `dataModelUpdate.contents` (v0.8) or `updateDataModel.value` (v0.9+) object (e.g., for the "items" key).
-   If the number of restaurants is 5 or fewer, you MUST use the `SINGLE_COLUMN_LIST_EXAMPLE` template.
-   If the number of restaurants is more than 5, you MUST use the `TWO_COLUMN_LIST_EXAMPLE` template.
-   If the query is to book a restaurant (e.g., "USER_WANTS_TO_BOOK..."), you MUST use the `BOOKING_FORM_EXAMPLE` template.
-   If the query is a booking submission (e.g., "User submitted a booking..."), you MUST use the `CONFIRMATION_EXAMPLE` template.
"""

# Initialize the schema manager with the Basic Catalog
schema_manager = A2uiSchemaManager(
    version=VERSION_0_8, # Use VERSION_0_9 for newer protocol
    catalogs=[
        BasicCatalog.get_config(
            version=VERSION_0_8, examples_path="examples/0.8"
        )
    ],
)

# Generate the full system prompt
A2UI_AND_AGENT_INSTRUCTION = schema_manager.generate_system_prompt(
    role_description=ROLE_DESCRIPTION,
    ui_description=UI_DESCRIPTION,
    include_schema=True,
    include_examples=True,
    validate_examples=True,
)

root_agent = Agent(
    model='gemini-2.5-flash',
    name="restaurant_agent",
    description="An agent that finds restaurants and helps book tables.",
    instruction=A2UI_AND_AGENT_INSTRUCTION,
    tools=[get_restaurants],
)
```

## 理解输出

你的智能体将不再严格输出文本。相反，它会输出文本和 A2UI 消息的 **JSON 列表**。

我们导入的 `A2UI_SCHEMA` 是一个标准 JSON 模式，定义了有效的操作，例如：

* `render`（显示 UI）
* `update`（更新现有 UI 中的数据）

由于输出是结构化 JSON，你可以在将其发送到客户端之前解析并验证它。

```python
# 1. 解析 JSON
# 警告：将输出解析为 JSON 是一个脆弱的实现，仅适用于文档说明。
# LLM 经常在 JSON 输出周围加上 Markdown 围栏，并且可能犯其他错误。
# 依赖框架来替你解析 JSON。
parsed_json_data = json.loads(json_string_cleaned)

# 2. 根据 A2UI_SCHEMA 验证
# 这确保 LLM 生成了有效的 A2UI 命令
jsonschema.validate(
    instance=parsed_json_data, schema=self.a2ui_schema_object
)
```

通过根据 `A2UI_SCHEMA` 验证输出，你可以确保客户端永远不会收到格式错误的 UI 指令。

TODO：继续本指南，介绍如何解析、验证并将输出发送到客户端渲染器的示例，无需 A2A 扩展。
