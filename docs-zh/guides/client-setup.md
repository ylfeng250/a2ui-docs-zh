# 客户端设置指南

使用对应平台的渲染器将 A2UI 集成到你的应用中。

## 渲染器

| 渲染器                   | 平台               | v0.8 | v0.9 | 状态            |
| ------------------------ | ------------------ | ---- | ---- | --------------- |
| **[React](https://github.com/google/A2UI/tree/main/renderers/react)** | Web | ✅ | ✅ | ✅ 稳定 |
| **[Lit (Web Components)](https://github.com/google/A2UI/tree/main/renderers/lit)** | Web | ✅ | ✅ | ✅ 稳定 |
| **[Angular](https://github.com/google/A2UI/tree/main/renderers/angular)** | Web | ✅ | ✅ | ✅ 稳定 |
| **[Flutter (GenUI SDK)](https://docs.flutter.dev/ai/genui)** | Mobile/Desktop/Web | ✅ | ✅ | ✅ 稳定 |
| **Jetpack Compose**      | Android            | —    | —    | 🚧 计划 2026 Q2 |

有关更多信息，请参阅所有 [A2UI 渲染器](../reference/renderers.md) 和 [社区 A2UI 渲染器](../ecosystem/renderers.md)。

## 组件目录

组件目录是任意组件的集合。A2UI 提供了一个"基础目录（Basic Catalog）"，但我们期望你会添加自己的组件，或使用共享库，或完全用你自己的组件替换基础组件。

**你的设计系统才是关键。** 你可以注册任意组件和函数的集合，A2UI 都能与之配合。目录只是你的智能体和渲染器之间的契约。

有关如何定义与你的设计系统匹配的目录，请参阅 [定义你自己的目录](defining-your-own-catalog.md)。

## 共享 Web 库

所有 Web 渲染器（Lit、Angular、React）共享一个共同的基础：**`@a2ui/web_core`**。这个库提供了每个 Web 渲染器所需的消息处理器、状态管理和数据绑定（Data Binding）逻辑。每个特定框架的渲染器都构建在其之上，只添加其框架的渲染层。

这意味着核心协议处理在 Web 平台之间是一致的——只有组件渲染有所不同。

共享的 `web_core` 库提供：

- **消息处理器（Message Processor）**：管理 A2UI 状态并处理传入消息。


## Web Components (Lit)

```bash
npm install @a2ui/lit @a2ui/web_core
```

安装后，你可以在应用中使用渲染器。Lit 渲染器使用：

- **消息处理器**：包装 A2UI 消息处理器。
- **`<a2ui-surface>` 组件**：在你的应用中渲染表面（Surface）。
- **Lit Signals**：提供用于自动 UI 更新的响应式状态管理。

**查看工作示例：** [Lit shell 示例](https://github.com/google/a2ui/tree/main/samples/client/lit/shell) —— 查看其 README 以获取详细的运行说明。

## Angular

```bash
npm install @a2ui/angular @a2ui/web_core
```

安装后，你可以在应用中使用渲染器。Angular 渲染器提供：

- **`A2uiRendererService`**：管理 A2UI 消息处理器和响应式模型的服务。
- **`a2ui-v09-component-host` 组件**：从表面渲染 A2UI 组件的动态组件主机。
- **`A2UI_RENDERER_CONFIG` token**：用于使用目录和操作处理器配置渲染器。

### 设置示例（v0.9）

A2UI 使用特定于协议的版本化导入。对于 v0.9，按如下方式配置你的应用提供者：

```typescript
import { ApplicationConfig } from '@angular/core';
import { 
  A2UI_RENDERER_CONFIG, 
  A2uiRendererService, 
  minimalCatalog 
} from '@a2ui/angular/v0_9';

export const appConfig: ApplicationConfig = {
  providers: [
    {
      provide: A2UI_RENDERER_CONFIG,
      useValue: {
        catalogs: [minimalCatalog],
        actionHandler: (action) => {
          console.log('Action dispatched:', action);
        }
      }
    },
    A2uiRendererService
  ]
};
```

**查看工作示例：** [Angular 示例](https://github.com/google/a2ui/tree/main/samples/client/angular)

### 流式传输

默认情况下，Angular 客户端使用非流式 API。要启用流式传输，请在启动应用之前将 `ENABLE_STREAMING` 环境变量设置为 `true`：

```bash
export ENABLE_STREAMING=true
npm start -- restaurant
```

## React

```bash
npm install @a2ui/react @a2ui/web_core
```

React 渲染器提供：

- **`MessageProcessor` 类**：管理 A2UI 消息处理器和响应式模型的类。
- **`<A2UISurface>` 组件**：在你的 React 应用中渲染 A2UI 表面
- **`useA2UI()` 钩子**：从任意组件访问消息处理器

**查看工作示例：** [React shell](https://github.com/google/A2UI/tree/main/samples/client/react/shell)

## Flutter (GenUI SDK)

```bash
flutter pub add flutter_genui
```

Flutter 使用 GenUI SDK，它提供原生的 A2UI 渲染。

**文档：** [GenUI SDK](https://docs.flutter.dev/ai/genui) | [GitHub](https://github.com/flutter/genui) | [GenUI Flutter 包中的 README](https://github.com/flutter/genui/blob/main/packages/genui/README.md#getting-started-with-genui)

## 连接到智能体

你的客户端应用需要：

1. **接收来自智能体的 A2UI 消息**（通过传输层）
2. **使用消息处理器处理消息**
3. **将用户动作发送回智能体**

常见的传输选项：

- **Server-Sent Events (SSE)**：从服务器到客户端的单向流式传输
- **WebSockets**：双向实时通信
- **A2A 协议**：具有 A2UI 支持的标准化智能体到智能体通信

查看 [samples/client/lit/shell/client.ts](https://github.com/google/a2ui/tree/main/samples/client/lit/shell/client.ts) 了解使用 A2A 协议客户端的示例。

**参见：** [传输层指南](../concepts/transports.md)

## 处理用户动作

当用户与 A2UI 组件交互（点击按钮、提交表单等）时，客户端会：

1. 从组件捕获动作事件
2. 解析动作所需的任意数据上下文
3. 将动作发送给智能体
4. 处理智能体的响应消息

查看 [samples/client/lit/shell/app.ts](https://github.com/google/a2ui/tree/main/samples/client/lit/shell/app.ts) 中 `#maybeRenderData` 的 `@a2uiaction` 事件处理器，了解处理按钮点击和表单提交的示例。

## 错误处理

需要处理的常见错误：

- **无效的表面 ID**：在收到 `beginRendering`（v0.8）或 `createSurface`（v0.9）之前引用了表面。
- **无效的组件 ID**：组件 ID 在表面内必须唯一。
- **无效的数据路径**：检查数据模型结构和 JSON Pointer 语法。
- **模式验证失败**：验证消息格式是否与 A2UI 规范匹配。

查看 [samples/client/lit/shell/app.ts](https://github.com/google/a2ui/tree/main/samples/client/lit/shell/app.ts) 中 `#sendMessage` 的 `try...catch` 块，了解处理通信错误的示例。

## 下一步

- **[快速入门](../quickstart.md)**：尝试演示应用
- **[主题与样式](theming.md)**：自定义外观
- **[定义你自己的目录](defining-your-own-catalog.md)**：扩展组件目录
- **[智能体开发](agent-development.md)**：构建生成 A2UI 的智能体
- **[参考文档](../reference/messages.md)**：深入了解协议
