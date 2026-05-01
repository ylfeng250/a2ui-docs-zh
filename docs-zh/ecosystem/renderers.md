# 生态系统渲染器

社区和第三方的 A2UI 渲染器实现。

> NOTE
> 这些渲染器由其各自作者维护，而非 A2UI 团队。请查看每个项目的兼容性、版本支持和维护状态。

> TIP
> 正在寻找**官方** A2UI React 渲染器？参见 [`@a2ui/react`](https://www.npmjs.com/package/@a2ui/react) — 由 A2UI 团队维护的核心 A2UI React 渲染器。

## 社区渲染器

| 渲染器 | 平台 | v0.8 | v0.9 | 活跃度 | 链接 |
|----------|----------|------|------|----------|-------|
| **easyops-cn/a2ui-sdk** (`@a2ui-sdk/react`) | React (Web) | ✅ | ❌ | ![Stars](https://img.shields.io/github/stars/easyops-cn/a2ui-sdk?style=flat-square&label=⭐) ![Last commit](https://img.shields.io/github/last-commit/easyops-cn/a2ui-sdk?style=flat-square&label=updated) | [GitHub](https://github.com/easyops-cn/a2ui-sdk) · [npm](https://www.npmjs.com/package/@a2ui-sdk/react) · [Docs](https://a2ui-sdk.js.org/) |
| **lmee/A2UI-Android** | Android (Compose) | ✅ | ❌ | ![Stars](https://img.shields.io/github/stars/lmee/A2UI-Android?style=flat-square&label=⭐) ![Last commit](https://img.shields.io/github/last-commit/lmee/A2UI-Android?style=flat-square&label=updated) | [GitHub](https://github.com/lmee/A2UI-Android) |
| **sivamrudram-eng/a2ui-react-native** | React Native | ✅ | ❌ | ![Stars](https://img.shields.io/github/stars/sivamrudram-eng/a2ui-react-native?style=flat-square&label=⭐) ![Last commit](https://img.shields.io/github/last-commit/sivamrudram-eng/a2ui-react-native?style=flat-square&label=updated) | [GitHub](https://github.com/sivamrudram-eng/a2ui-react-native) |
| **zhama/a2ui** | React (Web) | ✅ | ❌ | — | [npm](https://www.npmjs.com/package/@zhama/a2ui) |
| **jem-computer/A2UI-react** | React (Web) | ✅ | ❌ | ![Stars](https://img.shields.io/github/stars/jem-computer/A2UI-react?style=flat-square&label=⭐) ![Last commit](https://img.shields.io/github/last-commit/jem-computer/A2UI-react?style=flat-square&label=updated) | [GitHub](https://github.com/jem-computer/A2UI-react) |
| **BBC6BAE9/a2ui-swift** | Apple (iOS, iPadOS, macOS, tvOS, watchOS, visionOS) | ✅ | ✅ | ![Stars](https://img.shields.io/github/stars/BBC6BAE9/a2ui-swift?style=flat-square&label=⭐) ![Last commit](https://img.shields.io/github/last-commit/BBC6BAE9/a2ui-swift?style=flat-square&label=updated) | [GitHub](https://github.com/BBC6BAE9/a2ui-swift) |


### 值得提及的项目

这些项目处于早期阶段或实验性：

- **[xpert-ai/a2ui-react](https://www.npmjs.com/package/@xpert-ai/a2ui-react)** (`@xpert-ai/a2ui-react`) — 带有 ShadCN UI 组件的 React 渲染器（v0.0.1，发布于 2026 年 1 月）。
- **[josh-english-2k18/a2ui-3d-renderer](https://github.com/josh-english-2k18/a2ui-3d-renderer)** — 用于 A2UI 的实验性 Three.js/WebGL 3D 渲染器（~2 stars）。
- **[AINative-Studio/ai-kit-a2ui](https://github.com/AINative-Studio/ai-kit-a2ui)** — 用于 AIKit 框架的 React + ShadCN 渲染器（~2 stars）。

### 相关项目

这些项目并非直接的 A2UI 渲染器，但密切相关并支持 A2UI：

| 项目 | 平台 | 描述 | 链接 |
|---------|----------|-------------|-------|
| **vercel-labs/json-render** (`@json-render/*`) | React, Vue, Svelte, Solid, React Native | Vercel 的生成式 UI 框架 — 使用自己的 JSON schema（非 A2UI 协议）和基于 Zod 的组件目录。支持流式传输、36 个预构建的 shadcn/ui 组件以及跨平台渲染。 | [GitHub](https://github.com/vercel-labs/json-render) · [npm](https://www.npmjs.com/package/@json-render/core) · [Docs](https://json-render.dev/) |

### 亮点

**easyops-cn/a2ui-sdk** (`@a2ui-sdk/react`) 是最全功能的社区 React 渲染器，发布了 11 个版本，具有 Radix UI 原语、Tailwind CSS 样式和专用文档网站。它已在 [A2UI 讨论区发布](https://github.com/google/A2UI/discussions/489)。对于官方 A2UI React 渲染器，请参见 [`@a2ui/react`](https://www.npmjs.com/package/@a2ui/react)。

**lmee/A2UI-Android** 填补了一个重要空白 — 它是目前唯一的 Jetpack Compose 渲染器，覆盖 Android 5.0+，包含 20+ 组件、数据绑定和无障碍支持。

**sivamrudram-eng/a2ui-react-native** 是唯一的 React Native 渲染器，通过单一代码库在 iOS 和 Android 上启用 A2UI。

**BBC6BAE9/a2ui-swift**（前身为 **a2ui-swiftui**）是一个原生 SwiftUI 渲染器，支持 iOS、macOS、visionOS、watchOS 和 tvOS。它覆盖了所有 18 个标准 A2UI 组件，具有 v0.8 + v0.9 双协议支持，包括 JSONL 流式传输，并使用 Observation 框架实现响应式。

## 提交渲染器

如果您构建了 A2UI 渲染器，请提交以在此处列出。

### 如何提交

要提交渲染器，请执行以下步骤：

1. **Fork** [google/A2UI](https://github.com/google/A2UI) 仓库
2. **编辑**此文件（`docs/ecosystem/renderers.md`）— 在社区渲染器表中添加一行，包含渲染器名称、平台、npm 包（如有）、版本支持以及源码链接
3. **向 `google/A2UI` 提交 PR**，附带渲染器的简短描述
4. **在 [GitHub Discussions](https://github.com/google/A2UI/discussions) 中发帖** — 让社区知道您构建了什么！一段简短的演示视频效果很好。

需要灵感？浏览仓库中的 **[社区示例](https://github.com/google/A2UI/tree/main/samples)** — 涵盖 Angular、Lit 和基于 ADK 的 Agent，是很好的起点。

### 什么样的社区渲染器更受青睐？

满足以下条件的渲染器更有可能被接受和使用：

- 具有**已发布的源代码**（优先选择开源，MIT 或 Apache 2.0）。
- 明确说明支持**哪个 A2UI 规范版本**（v0.8、v0.9 或两者）。
- 覆盖了其他 A2UI 渲染器中的**基本组件**：文本、按钮、输入、基本布局组件等。
- 包含带安装说明和最小使用示例的 **README**。
- **积极维护**中 — 如果不再支持，请标记为归档。

社区渲染器无需达到生产就绪即可被列出 — 实验性和早期阶段的项目欢迎在"值得提及的项目"部分列出。
