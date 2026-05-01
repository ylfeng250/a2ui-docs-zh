# 快速开始：5 分钟运行 A2UI

通过运行餐厅查找器演示来实践 A2UI。本指南将让你在不到 5 分钟的时间内体验到智能体（Agent）生成的用户界面。

## 你将构建什么

完成本快速入门后，你将拥有：

- 一个运行着 A2UI Lit 渲染器 (Renderer) 的 Web 应用。
- 一个由 Gemini 驱动的智能体，能够生成动态 UI。
- 一个交互式餐厅查找器，支持表单生成、时间选择和确认流程。
- 对 A2UI 消息如何从智能体流向 UI 的理解。

## 先决条件

在开始之前，请确保你已安装：

- **Node.js**（v18 或更高版本）— [在此下载](https://nodejs.org/)
- **uv**（Python 包管理器）— [在此安装](https://docs.astral.sh/uv/getting-started/installation/)（用于运行 Python 智能体后端）
- **一个 Gemini API 密钥** — [从 Google AI Studio 免费获取](https://aistudio.google.com/apikey)

WARNING: 安全提示

本演示运行一个使用 Gemini 生成 A2UI 响应的 A2A 智能体。该智能体可以访问你的 API 密钥，并向 Google 的 Gemini API 发送请求。在生产环境中运行之前，务必审查智能体代码。

## 第 1 步：克隆仓库

```bash
git clone https://github.com/google/a2ui.git
cd a2ui
```

## 第 2 步：设置 API 密钥

将你的 Gemini API 密钥导出为环境变量：

```bash
export GEMINI_API_KEY="your_gemini_api_key_here"
```

## 第 3 步：导航到 Lit 客户端示例目录

客户端应用程序源代码位于 `samples/client/lit/shell`。导航到父级示例目录来运行演示：

```bash
cd samples/client/lit
```

## 第 4 步：安装并运行

运行一键式演示启动器：

```bash
npm run demo:restaurant
```

此命令将：

1. 安装所有依赖项
2. 构建 A2UI 渲染器 (Renderer)
3. 启动 A2A 餐厅查找器智能体（Python 后端）
4. 启动开发服务器
5. 在浏览器中打开 `http://localhost:5173`

餐厅查找器智能体的源代码位于 [`samples/agent/adk/restaurant_finder`](../samples/agent/adk/restaurant_finder)。

### 手动运行（替代方案）

如果你更喜欢在单独的终端中运行智能体和客户端，或者需要故障排除：

**1. 运行智能体：**
```bash
cd samples/agent/adk/restaurant_finder
uv run .
```

**2. 运行客户端：**
```bash
cd samples/client/lit/shell
npm run dev
```

NOTE: 演示已运行

如果一切正常，你应该能在浏览器中看到 Web 应用。智能体现在已准备好生成 UI！

## 第 5 步：试用

在 Web 应用中，尝试以下提示：

1. **"Book a table for 2"** — 观察智能体生成预订表单
2. **"Find Italian restaurants near me"** — 查看动态搜索结果
3. **"What are your hours?"** — 体验针对不同意图的不同 UI 布局

### 幕后发生的事情

```
┌─────────────┐         ┌──────────────┐         ┌────────────────┐
│   You Type  │────────>│ A2A Agent    │────────>│  Gemini API    │
│  a Message  │         │  (Python)    │         │  (LLM)         │
└─────────────┘         └──────────────┘         └────────────────┘
                               │                         │
                               │ Generates A2UI JSON     │
                               │<────────────────────────┘
                               │
                               │ Streams JSONL messages
                               v
                        ┌──────────────┐
                        │   Web App    │
                        │ (A2UI Lit    │
                        │  Renderer)   │
                        └──────────────┘
                               │
                               │ Renders native components
                               v
                        ┌──────────────┐
                        │   Your UI    │
                        └──────────────┘
```

1. **你通过 Web UI 发送消息**
2. **A2A 智能体** 接收消息并将对话发送给 Gemini
3. **Gemini 生成** 描述 UI 的 A2UI JSON 消息
4. **A2A 智能体** 将这些消息流式传回 Web 应用
5. **A2UI 渲染器 (Renderer)** 将它们转换为原生 Web 组件
6. **你在浏览器中看到 UI** 被渲染出来

## A2UI 消息的结构

让我们来看看智能体发送的内容。以下是一个简化的 JSON 消息示例：

=== "v0.8 (Stable)"

    **定义 UI：**

    ```json
    {"surfaceUpdate": {"surfaceId": "main", "components": [
      {"id": "header", "component": {"Text": {"text": {"literalString": "Book Your Table"}, "usageHint": "h1"}}},
      {"id": "date-picker", "component": {"DateTimeInput": {"label": {"literalString": "Select Date"}, "value": {"path": "/reservation/date"}, "enableDate": true}}},
      {"id": "submit-text", "component": {"Text": {"text": {"literalString": "Confirm Reservation"}}}},
      {"id": "submit-btn", "component": {"Button": {"child": "submit-text", "action": {"name": "confirm_booking"}}}}
    ]}}
    ```

    **填充数据：**

    ```json
    {"dataModelUpdate": {"surfaceId": "main", "contents": [
      {"key": "reservation", "valueMap": [
        {"key": "date", "valueString": "2025-12-15"},
        {"key": "time", "valueString": "19:00"},
        {"key": "guests", "valueInt": 2}
      ]}
    ]}}
    ```

    **信号渲染：**

    ```json
    {"beginRendering": {"surfaceId": "main", "root": "header"}}
    ```

=== "v0.9 (Draft)"

    **创建表面 (Surface)：**

    ```json
    {"version": "v0.9", "createSurface": {"surfaceId": "main", "catalogId": "https://a2ui.org/specification/v0_9/basic_catalog.json"}}
    ```

    **定义 UI：**

    ```json
    {"version": "v0.9", "updateComponents": {"surfaceId": "main", "components": [
      {"id": "header", "component": "Text", "text": "# Book Your Table", "variant": "h1"},
      {"id": "date-picker", "component": "DateTimeInput", "label": "Select Date", "value": {"path": "/reservation/date"}, "enableDate": true},
      {"id": "submit-text", "component": "Text", "text": "Confirm Reservation"},
      {"id": "submit-btn", "component": "Button", "child": "submit-text", "variant": "primary", "action": {"event": {"name": "confirm_booking"}}}
    ]}}
    ```

    **填充数据：**

    ```json
    {"version": "v0.9", "updateDataModel": {"surfaceId": "main", "path": "/reservation", "value": {"date": "2025-12-15", "time": "19:00", "guests": 2}}}
    ```

    注意：在 v0.9 中，`createSurface` 替代了 `beginRendering`，组件使用更扁平的格式，数据模型使用普通 JSON 值而不是类型化的邻接列表。

TIP: 它只是 JSON

注意这是多么可读和结构化？LLM 可以轻松生成它，并且可以安全地传输和渲染——无需执行代码。

## 探索其他演示

仓库中包含多个其他演示：

### 组件库（无需智能体）

查看所有可用的 A2UI 组件：

```bash
npm start -- gallery
```

这将运行一个仅客户端的演示，展示每个标准组件（Card、Button、TextField、Timeline 等）及其实时示例和代码样本。

### 其他语言和框架

虽然本指南使用 Lit 客户端作为示例，但 A2UI 在 `samples/client` 目录中提供了其他流行框架的示例：
- **Angular**: `samples/client/angular`
- **React**: `samples/client/react`

探索 [samples/client](../samples/client) 目录以查看所有可用的客户端实现。

## 下一步是什么

现在你已经看到了 A2UI 的实际效果，你准备好：

- **[学习核心概念](concepts/overview.md)**：了解表面 (Surface)、组件 (Component) 和数据绑定 (Data Binding)
- **[设置你自己的客户端](guides/client-setup.md)**：将 A2UI 集成到你自己的应用中
- **[构建一个智能体](guides/agent-development.md)**：创建能生成 A2UI 响应的智能体
- **[探索协议](reference/messages.md)**：深入研究技术规格说明

## 故障排除

### 端口已被占用

如果端口 5173 已被占用，开发服务器将自动尝试下一个可用端口。检查终端输出的实际 URL。

### API 密钥问题

如果看到缺少 API 密钥的错误：

1. 验证密钥已导出：`echo $GEMINI_API_KEY`
2. 确保它是来自 [Google AI Studio](https://aistudio.google.com/apikey) 的有效 Gemini API 密钥
3. 尝试重新导出：`export GEMINI_API_KEY="your_key"`

### 启动时连接错误

如果在浏览器打开时看到 `ERR_CONNECTION_REFUSED` 错误，**不必担心**——这是一个已知的竞争条件（[#587](https://github.com/google/A2UI/issues/587)）。Web 应用的启动速度比 Python 智能体后端快。只需等待几秒钟并刷新页面。

### Python / uv 问题

演示智能体需要 [uv](https://docs.astral.sh/uv/) 才能运行。如果看到 `uv: command not found`：

```bash
# 安装 uv
curl -LsSf https://astral.sh/uv/install.sh | sh

# 验证
uv --version
```

如果遇到其他 Python 错误：

```bash
# 确保 Python 3.10+ 可用
python3 --version

# 尝试手动运行智能体
cd samples/agent/adk/restaurant_finder
uv run .
```

### 仍然有问题？

- 查看 [GitHub Issues](https://github.com/google/a2ui/issues)
- 阅读 [samples/client/lit/README.md](../samples/client/lit)
- 加入社区讨论

## 理解演示代码

想了解它是如何工作的？查看：

- **智能体代码**: `samples/agent/adk/restaurant_finder/` — Python A2A 智能体
- **客户端代码**: `samples/client/lit/` — 带有 A2UI 渲染器 (Renderer) 的 Lit Web 客户端
- **A2UI 渲染器 (Renderer)**: `renderers/lit/`（Lit）和 `renderers/web_core/`（框架无关核心库）

每个目录都有自己的 README，包含详细的文档。

---

**恭喜！** 你已成功运行了第一个 A2UI 应用程序。你已经看到了 AI 智能体如何生成丰富、交互式的 UI，通过安全的声明式 JSON 消息在 Web 应用中原生渲染。
