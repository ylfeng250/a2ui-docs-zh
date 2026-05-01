# 处理用户操作

本指南解释了 A2UI 如何处理用户交互。组件使用 `action` 属性来触发本地的**函数 (Function)**（在渲染器上执行）或**事件 (Event)**（分派给智能体）。此外，**数据模型同步 (Data Model Synchronization)** 确保智能体始终可以访问完整的 UI 状态，实现语音命令等无缝的多模态交互。这种设计使界面具有高度响应性，同时保持了安全、受限的环境。

## 操作架构

操作 (Action) 允许 UI 组件触发由 [`Action`](../../specification/v0_9/json/common_types.json#L271-L313) schema（在 `common_types.json` 中）定义的行为。操作可以触发：

1.  **事件 (Event)**：分派给智能体进行处理（在智能体上执行，例如单击"提交"）。
2.  **函数 (Function)**：完全在渲染器上使用 [`FunctionCall`](../../specification/v0_9/json/common_types.json#L200-L242) 执行（在渲染器上执行，例如打开一个 URL）。

### 1. 函数 (Function)（本地）

函数在渲染器上执行即时行为，无需网络往返。智能体不会被告知本地函数调用。它们使用 `functionCall` 关键字。

```json
{
  "id": "help-btn",
  "component": "Button",
  "child": "help-text",
  "action": {
    "functionCall": {
      "call": "openUrl",
      "args": { "url": "https://a2ui.org/help" }
    }
  }
}
```

函数的常见用途包括：
- **导航**：打开 URL 或切换标签页。
- **验证**：在提交之前检查输入（参见下方检查）。

### 2. 事件 (Event)（智能体）

事件将数据发送给智能体进行处理。它们使用 `event` 关键字。

`Button` 等组件暴露了 `action` 属性。以下是事件如何连接：

```json
{
  "id": "submit-btn",
  "component": "Button",
  "child": "btn-text",
  "action": {
    "event": {
      "name": "submit_reservation",
      "context": {
        "time": { "path": "/reservationTime" },
        "size": { "path": "/partySize" }
      }
    }
  }
}
```

- **`name`**：智能体用于切换的稳定标识符。
- **`context`**：键值对的映射。值可以是字面值或使用 `path` 从数据模型的当前状态中拉取。

NOTE: **上下文 vs. 数据模型**：虽然数据模型表示一个表面的整个状态树，但操作中的 `context` 实际上是该状态的**精心挑选的"视图"**或子集。这通过为特定事件提供恰好需要的值来简化智能体的工作，而无需智能体导航可能庞大而复杂的数据模型。

### 基础目录验证（检查）

基础目录定义了一组可在渲染器上执行的检查。交互式组件可以定义一个 `checks` 列表（使用 [`Checkable`](../../specification/v0_9/json/common_types.json#L258-L270) schema，在 `common_types.json` 中）。对于 `Button`，如果任何检查失败，按钮将在渲染器上**自动禁用**。

- **UX 重点**：验证检查旨在通过防止无效交互来管理**UI 状态（用户体验）**。它们不是**数据完整性**检查的替代品，后者仍必须在智能体上执行。

这允许 UI 在用户尝试提交之前强制执行要求（如非空字段）。

```json
{
  "id": "submit-button",
  "component": "Button",
  "child": "submit-text",
  "checks": [
    {
      "condition": {
        "call": "required",
        "args": { "value": { "path": "/partySize" } }
      },
      "message": "Party size is required"
    }
  ],
  "action": { "event": { "name": "submit_booking" } }
}
```

## 本地状态更新与"写入"契约

在事件甚至分派之前，渲染器已经在本地管理 UI 的状态。A2UI 为所有输入组件（如 `TextField`、`CheckBox` 或 `Slider`）定义了**读写契约**。

1.  **读取（模型 → 视图）**：组件渲染时，从数据模型中的绑定 `path` 中拉取其值。
2.  **写入（视图 → 模型）**：用户一旦交互（例如键入字符或单击复选框），渲染器就**立即**将新值写入本地数据模型。

这意味着本地模型始终是 UI 当前状态的**唯一真相来源**。这种"视图到模型"的同步完全在渲染器上发生。数据模型仅在事件发生时（如按钮单击）发送给智能体。

IMPORTANT: **同步更新**：本地模型更新是**同步的**。这保证在任何事件解析其 `context` 路径或打包 `DataModelSync` 有效负载之前，数据模型已完全更新。键入和单击之间没有竞争条件；"写入"总是首先提交。

这种本地优先的方法提供了显著的**性能优势**。因为同步是即时且本地的，所以开发者无需实现网络去抖动，也不必担心用户输入 `TextField` 时的延迟抖动。在用户准备好分派正式事件之前，网络完全受到保护，免受"UI 噪声"（如个别击键）的影响。

### 表单提交模式

这种分离允许一个健壮的表单提交模式：

- **绑定**：`TextField` 绑定到 `/reservationTime`。
- **交互**：用户输入"7:00 PM"。`/reservationTime` 处的本地模型立即更新。
- **提交**：用户单击"预订"按钮。按钮的事件从本地模型解析 `path: "/reservationTime"` 并将当前值发送给智能体。

## 用户交互流程

当用户与组件交互（例如单击按钮）时：

1.  **解析**：渲染器针对本地**数据模型**解析 `context` 中的所有 `path` 引用。
2.  **构建**：渲染器构建一个符合 [`client_to_server.json`](../../specification/v0_9/json/client_to_server.json) 的 `action` 有效负载。
3.  **分派**：有效负载通过所选的传输 (Transport)（例如 A2A、WebSockets）发送。

### 示例：操作有效负载（v0.9）

如果用户单击上述按钮，数据模型包含 `{"reservationTime": "7:00 PM", "partySize": 4}`，渲染器使用 `action` 键发送消息：

```json
{
  "version": "v0.9",
  "action": {
    "name": "submit_reservation",
    "surfaceId": "booking-surface",
    "sourceComponentId": "submit-btn",
    "timestamp": "2026-02-25T10:40:00Z",
    "context": {
      "time": "7:00 PM",
      "size": 4
    }
  }
}
```

IMPORTANT: **关于版本的说明（v0.8 vs v0.9）**：在 v0.8 中，顶层有效负载键是 `userAction`（例如 `{"userAction": {...}}`）。v0.9 转换为上方显示的更简单的 `action` 键。标准协议解析器期望有效负载中与声明的版本对应的键。

## 智能体处理

智能体（或编排器 (Orchestrator)）接收此事件并对其采取行动。在智能体系统中，智能体通常将事件转换为对 LLM 的隐藏用户查询。

**示例智能体处理（Python）：**

```python
if action_name == "submit_reservation":
    time = context.get("time")
    size = context.get("size")
    # Feed this to the LLM
    query = f"User submitted a reservation for {size} people at {time}."
    response = await llm.generate(query)
```

## 渲染器到智能体的错误报告

除了由用户触发的事件之外，渲染器还可以使用 [`client_to_server.json`](../../specification/v0_9/json/client_to_server.json) 中定义的 `error` 有效负载向智能体报告系统级错误。

### 验证失败

如果智能体发送的 A2UI JSON 违反了目录 Schema 或协议规则，渲染器会发送 `VALIDATION_FAILED` 错误。这是智能体系统的一个关键反馈循环：

```json
{
  "version": "v0.9",
  "error": {
    "code": "VALIDATION_FAILED",
    "surfaceId": "booking-surface",
    "path": "/components/0/children",
    "message": "Expected array of strings, got null."
  }
}
```

智能体可以捕获此错误，道歉（或在内部自我纠正），并重新发送已更正的 UI。

## 数据模型同步（v0.9）

A2UI v0.9 引入了一个强大的"无状态"同步功能。这允许渲染器自动将其发送给智能体的每条消息的元数据中包含表面的**整个数据模型**。

### 启用同步

同步由智能体在表面初始化期间请求。通过在 `createSurface` 消息中设置 `sendDataModel: true`，智能体指示渲染器启动同步循环。

```json
{
  "version": "v0.9",
  "createSurface": {
    "surfaceId": "booking-surface",
    "catalogId": "https://a2ui.org/catalogs/v1/basic.json",
    "sendDataModel": true
  }
}
```

### 线路上的同步

启用同步后，渲染器不会将数据模型作为单独的消息发送。相反，它将其作为**元数据**附加到传出传输信封（例如 A2A 消息）。

在 A2A（智能体到智能体）绑定中，数据模型放置在信封 `metadata` 字段中的 `a2uiClientDataModel` 对象中。

**带同步的 A2A 信封示例：**

```json
{
  "parts": [{ "text": "Submit the reservation" }],
  "metadata": {
    "a2uiClientDataModel": {
      "version": "v0.9",
      "surfaces": {
        "booking-surface": {
          "reservationTime": "7:00 PM",
          "partySize": 4,
          "notes": "Window seat preferred"
        }
      }
    }
  }
}
```

### 为什么使用数据模型同步？

- **更简单的布线**：你不需要手动将每个输入字段映射到按钮的 `context` 属性。智能体只需检查元数据即可看到所有字段的当前状态。
- **无状态智能体**：智能体不需要为每个用户会话维护本地状态；它在每次交互中都会收到完整的当前上下文。
- **口头快捷方式**：允许用户通过语音或文本触发事件（例如"好的，提交"），即使没有单击特定按钮。由于智能体会收到带有文本消息的更新数据模型，它可以立即处理请求。

## 渲染器元数据和能力

在智能体安全地发送 UI 之前，渲染器必须公布它支持哪些组件目录 (Catalog)。这是通过 `a2uiClientCapabilities` 对象处理的。

### 公布能力

渲染器在它们发送给智能体的消息的**元数据**中包含 `a2uiClientCapabilities` 对象（例如在 A2A 信封的 `metadata` 字段中）。

```json
{
  "v0.9": {
    "supportedCatalogIds": [
      "https://a2ui.org/specification/v0_9/basic_catalog.json",
      "https://my-company.com/catalogs/v1/custom.json"
    ],
    "inlineCatalogs": []
  }
}
```

- **`supportedCatalogIds`**：渲染器可以渲染的目录 URI 数组。
- **`inlineCatalogs`**：（可选）用于开发或专门环境，允许内联发送完整的目录 Schema。

没有这个握手，智能体无法确定渲染器是否能处理正在发送的特定组件。

## 传输和编码

A2UI 与传输 (Transport) 无关，但最常见的是通过 **A2A（智能体到智能体）** 或 WebSockets 使用。了解有效负载如何封装对于实现至关重要。

### A2A 编码

在标准 A2A 绑定中，A2UI 消息被编码为 A2A **DataPart**。要将其标识为 A2UI 有效负载，必须使用特定元数据封装该部分：

- **mimeType**：`application/json+a2ui`

`DataPart` 的 `data` 字段包含 A2UI 消息的**列表**。这允许在单个网络数据包中发送多个更新（例如，`createSurface` 后跟 `updateComponents`）。

NOTE: **A2A 版本控制**：`data` 字段中使用**列表**是在 **A2A v1.0** 中引入的。早期版本的 A2A 协议期望 `data` 字段包含单个 JSON 对象。

```json
{
  "kind": "data",
  "metadata": {
    "mimeType": "application/json+a2ui"
  },
  "data": [
    {
      "version": "v0.9",
      "action": { ... }
    }
  ]
}
```

## 安全考虑因素

A2UI 的设计将安全的沙盒通信作为核心原则。因为协议依赖通过网络传递用户状态和交互触发器，所以它对数据可见性和执行执行严格的边界。

### 沙盒执行

A2UI 的核心卖点是限制带来的安全性。通过禁止来自智能体的任意代码执行（如注入原始 JavaScript），A2UI 确保智能体只能触发预注册的行为。`functionCall` 机制充当智能体与渲染器环境交互的安全、沙盒方式，而不会将用户暴露给恶意脚本。

### 数据模型隔离和编排器路由

当启用 `sendDataModel: true` 时，渲染器会将表面的整个数据模型包含在传出消息中。开发者必须了解此数据的可见性：

- **点对点可见性**：只有接收传输信封的后端（创建表面的智能体或中间编排器 (Orchestrator)）才能读取此有效负载。
- **编排器的责任**：在多智能体架构中，中央编排器 (Orchestrator) 通常将用户意图路由到专门的子智能体。编排器必须执行**数据隔离**。它负责解析 `a2uiClientDataModel`，识别 `surfaceId`，并确保数据模型仅传递给拥有该表面的特定子智能体。一个智能体的表面数据绝不能泄漏到另一个智能体。

## 编排和路由

在多智能体系统中，中央**编排器 (Orchestrator)** 通常管理用户与多个专用子智能体之间的交互。一个关键挑战是确保来自渲染器的 `action` 消息被路由回生成 UI 表面的特定子智能体。

### 表面所有权模式

为此，编排器必须维护 `surfaceId` 到其拥有子智能体的映射。这通常存储在**会话状态**中。

#### 1. 映射所有权

当子智能体发出 `createSurface` 消息时，编排器拦截它并记录所有权。

```python
# 简化的编排器逻辑：记录所有权
def on_surface_created(surface_id, agent_name, session):
    # 在编排器的会话状态中存储映射
    session.state.update({f"owner_of_{surface_id}": agent_name})
```

#### 2. 路由事件

当渲染器将 `action` 发送回编排器时，编排器查找 `surfaceId` 并将请求转移到正确的子智能体。

```python
# 简化的编排器逻辑：路由事件
async def handle_incoming_action(payload, session):
    action = payload.get("action")
    surface_id = action.get("surfaceId")
    
    # 查找拥有者智能体
    target_agent = session.state.get(f"owner_of_{surface_id}")
    
    if target_agent:
        # 以编程方式将请求路由到子智能体
        return transfer_to(target_agent)
```

这种模式确保即使在复杂的多智能体环境中，双向通信循环也能保持完整，并且每个功能区域都是有状态的。

### 通过元数据剥离防止数据泄漏

在多智能体环境中，`a2uiClientDataModel` 可能包含由不同智能体拥有的多个表面的状态。为防止敏感数据泄漏，编排器必须**剥离**数据模型元数据，仅包括被调用子智能体拥有的表面。

最好在出站元数据拦截器中实现：

```python
# 简化的编排器拦截器：剥离数据模型
async def intercept(self, request_payload, target_agent, session):
    message = request_payload["params"]["message"]
    data_model = message.get("metadata", {}).get("a2uiClientDataModel")
    
    if data_model:
        # 过滤表面，仅保留 target_agent 拥有的表面
        filtered_surfaces = {
            surface_id: state for surface_id, state in data_model["surfaces"].items()
            if session.state.get(f"owner_of_{surface_id}") == target_agent.name
        }
        
        # 用剥离的数据模型替换
        message["metadata"]["a2uiClientDataModel"]["surfaces"] = filtered_surfaces

    return request_payload
```

通过剥离元数据，编排器确保子智能体只能看到它们被授权查看的那部分数据模型。

CAUTION: **安全风险：状态抓取**：如果编排器未能剥离 `a2uiClientDataModel`，恶意或受损的子智能体可能会"抓取"其他活动表面的状态。例如，如果编排器泄漏了整个多表面数据模型，天气子智能体可能会读取银行表面中的敏感数据。剥离是多智能体系统中的强制性安全要求。

---

## 综合示例

### 1. 按钮提交（显式上下文）

此示例显示一个显式收集它需要发送的数据的按钮。

**组件定义：**
```json
{
  "id": "submit-button",
  "component": "Button",
  "child": "submit-text",
  "action": {
    "event": {
      "name": "submit_booking",
      "context": {
        "partySize": { "path": "/partySize" },
        "reservationTime": { "path": "/reservationTime" }
      }
    }
  }
}
```

**生成的操作有效负载：**
智能体在 `context` 字段中直接接收包含 `partySize` 和 `reservationTime` 的 `action` 对象。

### 2. 口头提交（数据模型同步）

在此场景中，用户没有单击按钮。相反，他们说"好的，提交表单。"

**初始化：**
智能体创建表面时设置了 `sendDataModel: true`：

```json
{
  "version": "v0.9",
  "createSurface": {
    "surfaceId": "booking-surface",
    "catalogId": "...",
    "sendDataModel": true
  }
}
```

**渲染器传输：**
渲染器发送一个 A2A 消息，其中包含用户的文本和元数据中的数据模型：

```json
{
  "parts": [{ "text": "Okay, submit the form" }],
  "metadata": {
    "a2uiClientDataModel": {
      "version": "v0.9",
      "surfaces": {
        "booking-surface": {
          "partySize": 4,
          "reservationTime": "7:00 PM"
        }
      }
    }
  }
}
```

**智能体处理：**
智能体看到用户的意图（"提交"），并查看 `metadata` 以查找 `partySize` 和 `reservationTime` 的当前值，使其能够无需进一步澄清即可完成任务。
