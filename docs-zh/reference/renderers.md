# 渲染器（客户端库）

渲染器（Renderer）将 A2UI JSON 消息转换为不同平台的原生 UI 组件。

[Agent](agents.md) 负责生成 A2UI 消息，
而 [传输层](../concepts/transports.md) 负责将消息传递到客户端。
客户端渲染器库必须缓冲和处理 A2UI 消息、实现 A2UI 生命周期、渲染小组件，并将用户操作路由回 Agent。

让我们用 Web 作为类比。A2UI 协议就像 HTML。它提供了 UI 模型的语言和语义。Agent 就像向客户端提供 HTML 的服务端。渲染器则像浏览器。它与 Agent 通信，解释 A2UI 协议，并渲染 UI。正如 HTML 有多个浏览器引擎，A2UI 也有多个不同的渲染器。

您可以将自定义组件带入渲染器，或构建自己的渲染器来支持 UI 组件框架，具有很高的灵活性。

## 官方维护的渲染器

### Web

| 渲染器         | 平台 | v0.8 | v0.9 | 链接                                                            |
| ------------- | ---- | ---- | ---- | --------------------------------------------------------------- |
| **React**     | Web  | ✅ Stable | ❌ | [Code](https://github.com/google/A2UI/tree/main/renderers/react) |
| **Lit（Web Components）** | Web  | ✅ Stable | ✅ Stable | [Code](https://github.com/google/A2UI/tree/main/renderers/lit) |
| **Angular**   | Web  | ✅ Stable | ✅ Stable | [Code](https://github.com/google/A2UI/tree/main/renderers/angular) |
| **Flutter（GenUI SDK）** | Mobile/Desktop/Web | ✅ Stable | ✅ Stable | [Docs](https://docs.flutter.dev/ai/genui) · [Code](https://github.com/flutter/genui) |

### Mobile

| 渲染器            | 平台    | v0.8 | v0.9     | 链接                                                            |
| ----------------- | ------- | ---- | -------- | --------------------------------------------------------------- |
| **Flutter（GenUI SDK）** | Mobile/Desktop/Web | ✅ Stable | ✅ Stable | [Docs](https://docs.flutter.dev/ai/genui) · [Code](https://github.com/flutter/genui) |
| **SwiftUI**       | iOS/macOS | —  | 🚧 计划于 Q2 | — |
| **Jetpack Compose** | Android | —  | 🚧 计划于 Q2 | — |

更多信息请查看 [路线图](../roadmap.md)。

## 生态系统渲染器

社区正在为更多平台构建 A2UI 渲染器：

- **[json-render](https://json-render.dev/docs/a2ui)** — Vercel 的 React 库，通过 Zod schemas 渲染 A2UI 目录（[对比](https://dipjyotimetia.medium.com/vercels-json-render-vs-google-s-a2ui-the-head-to-head-6f213cf1a23b)）
- **[A2UI-Android](https://github.com/lmee/A2UI-Android)** — 社区 Jetpack Compose 渲染器，20+ 组件（~15 ⭐，v0.8）
- **[a2ui-react-native](https://github.com/sivamrudram-eng/a2ui-react-native)** — 面向 iOS/Android 的 React Native 渲染器（~9 ⭐，v0.8）

请参阅 **[完整的生态系统渲染器列表](../ecosystem/renderers.md)** 以了解更多社区项目以及如何提交自己的渲染器。

## 渲染器工作原理

渲染过程通常包括以下步骤：

1. **接收**来自传输层的 A2UI 消息。
2. **解析** JSON 并根据 schema 进行验证。
3. **渲染**：使用平台原生组件。
4. **样式化**：根据您的应用主题进行样式设置。

## 使用渲染器

按照所选渲染器的设置指南，将 A2UI 集成到您的应用中：

- **[React](../guides/client-setup.md#react)**
- **[Lit（Web Components）](../guides/client-setup.md#web-components-lit)**
- **[Angular](../guides/client-setup.md#angular)**
- **[Flutter（GenUI SDK）](../guides/client-setup.md#flutter-genui-sdk)**

## 构建渲染器

想为您的平台构建渲染器？

- 查看 [路线图](../roadmap.md) 了解计划中的框架。
- 查看现有渲染器了解模式。
- 参阅我们的 [渲染器开发指南](../guides/renderer-development.md) 了解实现渲染器的详细信息。

兼容的渲染器必须满足以下关键要求：

- 解析 A2UI JSON 消息，特别是邻接表格式。
- 将 A2UI 组件映射到原生小组件。
- 处理数据绑定和生命周期事件。
- 处理一系列增量 A2UI 消息以构建和更新 UI。
- 支持服务端发起的更新。
- 支持用户操作。

如需了解更多信息，请参阅以下资源：

- **[客户端设置指南](../guides/client-setup.md)**：集成说明。
- **[快速入门](../quickstart.md)**：尝试 Lit 渲染器。
- **[组件参考](components.md)**：需要支持哪些组件。
