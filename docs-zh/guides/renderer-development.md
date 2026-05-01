# A2UI 渲染器实现指南

本文档概述了 A2UI 协议新渲染器实现所需的功能。本文档面向构建新渲染器的开发者（例如用于 React、Flutter、iOS 等）。

> 注意：版本说明
>
> 本指南主要描述 v0.8 消息流。v0.9 重命名了几个消息（`surfaceUpdate` → `updateComponents`、`dataModelUpdate` → `updateDataModel`、`beginRendering` → `createSurface`）并使用更扁平的组件格式。有关详细信息，请参阅 [v0.9 规范](../specification/v0.9-a2ui.md)。

## Web 渲染器：使用 `@a2ui/web_core`（`web_core`）

如果你正在为 Web 构建渲染器（React、Vue、Svelte 等），你无需从头实现消息处理、状态管理和模式验证。**[`@a2ui/web_core`](https://github.com/google/A2UI/tree/main/renderers/web_core)** 包（`web_core`）提供了已维护的 Lit、Angular 和 React 渲染器共享的所有框架无关逻辑。

### `web_core` 提供的内容

| 模块 | 功能 |
|--------|-------------|
| **`MessageProcessor`** | 处理 A2UI JSONL 流，调度消息，管理表面生命周期 |
| **`SurfaceModel` / `SurfaceGroupModel`** | 表面、组件和数据模型的状态管理 |
| **`DataModel` / `DataContext`** | 数据绑定解析、基于路径的查找、模板列表渲染 |
| **`ComponentModel`** | 组件树状态，邻接列表 → 树解析 |
| **类型与模式** | 所有 A2UI 组件、原语、颜色、样式的 TypeScript 类型以及 JSON 模式验证 |
| **表达式解析器** | 客户端函数评估（v0.9） |

### 已维护的渲染器如何使用它

所有三个 Web 渲染器遵循相同的模式——`web_core` 处理协议，渲染器处理 UI：

```typescript
// 类型 — 所有渲染器共享
import type * as Types from '@a2ui/web_core/types/types';
import type * as Primitives from '@a2ui/web_core/types/primitives';

// v0.8: 消息处理和状态
import { A2uiMessageProcessor } from '@a2ui/web_core/data/model-processor';

// v0.9: 消息处理、表面、目录
import { MessageProcessor } from '@a2ui/web_core/v0_9';
import { SurfaceModel } from '@a2ui/web_core/v0_9';

// 样式和布局助手
import * as Styles from '@a2ui/web_core/styles/index';
```

你的渲染器只需要：

1. **将 A2UI 组件类型映射到你框架的组件**（例如 `Text` → `<p>`、`Button` → `<button>`）
2. **订阅来自 `web_core` 的状态变化**并重新渲染
3. **将用户动作转发**回 `MessageProcessor`

查看 [React 渲染器](https://github.com/google/A2UI/tree/main/renderers/react)、[Lit 渲染器](https://github.com/google/A2UI/tree/main/renderers/lit) 和 [Angular 渲染器](https://github.com/google/A2UI/tree/main/renderers/angular) 以获取此模式的工作示例。

### 版本支持

`web_core` 导出 v0.8 和 v0.9 API：

- `@a2ui/web_core/v0_8` 或 `@a2ui/web_core`（默认）—— 稳定的 v0.8
- `@a2ui/web_core/v0_9` —— 带有 `createSurface`、自定义目录、客户端函数的 v0.9
- `@a2ui/web_core/v0_9/basic_catalog` —— v0.9 基础目录表达式解析器和内置函数

> 提示：从 `web_core` 开始
>
> 在没有 `web_core` 的情况下构建 Web 渲染器意味着重新实现大约 3,000 行消息处理、状态管理和模式验证代码。除非你有特定理由偏离，否则请使用它。

---

## I. 核心协议实现检查清单

本节详细介绍了 A2UI 协议的基本机制。一个合规的渲染器必须实现这些系统才能成功解析服务器流、管理状态并处理用户交互。

### 消息处理与状态管理

一个合规的渲染器必须实现以下消息处理和状态管理功能：

- **JSONL 流解析**：实现一个解析器，可以逐行读取流式响应，将每一行解码为独立的 JSON 对象。
- **消息调度器**：创建一个调度器来识别消息类型（`beginRendering`、`surfaceUpdate`、`dataModelUpdate`、`deleteSurface`）并将其路由到正确的处理器。
- **表面管理**：
  - 实现一个数据结构来管理多个 UI 表面，每个表面由其 `surfaceId` 作为键。
  - 处理 `surfaceUpdate`：在指定表面的组件缓冲区中添加或更新组件。
  - 处理 `deleteSurface`：移除指定表面及其所有关联数据和组件。
- **组件缓冲（邻接列表）**：
  - 对于每个表面，维护一个组件缓冲区（例如 `Map<String, Component>`）以按 `id` 存储所有组件定义。
  - 能够通过解析容器组件（`children.explicitList`、`child`、`contentChild` 等）中的 `id` 引用来在渲染时重建 UI 树。
- **数据模型存储**：
  - 对于每个表面，维护一个单独的数据模型存储（例如 JSON 对象或 `Map<String, any>`）。
  - 处理 `dataModelUpdate`：在指定 `path` 处更新数据模型。`contents` 将采用邻接列表格式（例如 `[{ "key": "name", "valueString": "Bob" }]`）。

### 渲染逻辑

实现以下渲染逻辑：

- **渐进式渲染控制**：
  - 缓冲所有传入的 `surfaceUpdate` 和 `dataModelUpdate` 消息，不立即渲染。
  - 处理 `beginRendering`：此消息作为对表面执行初始渲染并设置根组件 ID 的显式信号。
    - 从指定的 `root` 组件 ID 开始渲染。
    - 如果提供了 `catalogId`，确保使用相应的组件目录（如果省略则默认为标准目录）。
    - 应用此消息中提供的任意全局 `styles`（例如 `font`、`primaryColor`）。
- **数据绑定（Data Binding）解析**：
  - 为组件属性中找到的 `BoundValue` 对象实现解析器。
  - 如果仅存在 `literal*` 值（`literalString`、`literalNumber` 等），则直接使用它。
  - 如果仅存在 `path`，则根据表面的数据模型解析它。
  - 如果同时存在 `path` 和 `literal*`，则首先在 `path` 处用字面量值更新数据模型，然后将组件属性绑定到该 `path`。
- **动态列表渲染**：
  - 对于具有 `children.template` 的容器，迭代在 `template.dataBinding` 处找到的数据列表（解析为数据模型中的列表）。
  - 对于数据列表中的每个项目，渲染 `template.componentId` 指定的组件，使项目的数据可用于模板内的相对数据绑定。

### 客户端到服务器的通信

实现以下通信功能：

- **事件处理**：
  - 当用户与定义了 `action` 的组件交互时，构建 `userAction` 载荷。
  - 根据数据模型解析 `action.context` 中的所有数据绑定。
  - 将完整的 `userAction` 对象发送到服务器的事件处理端点。
- **客户端能力报告**：
  - 在发送给服务器的**每个** A2A 消息中（作为元数据的一部分），包含一个 `a2uiClientCapabilities` 对象。
  - 此对象应通过 `supportedCatalogIds` 声明你的客户端支持的组件目录（例如，包括标准 0.8 目录的 URI）。
  - 可选地，如果服务器支持，提供 `inlineCatalogs` 用于自定义的、即时生成的组件定义。
- **错误报告**：实现一种机制以向服务器发送 `error` 消息，报告任意客户端错误（例如数据绑定失败、未知组件类型）。

## II. 标准组件目录检查清单

为确保跨平台的一致用户体验，A2UI 定义了一组标准组件。你的客户端应将这些抽象定义映射到相应的原生 UI 组件。

### 基本内容

标准目录包括以下基本内容组件：

- **Text**：渲染文本内容。必须支持 `text` 上的数据绑定和用于样式的 `usageHint`（h1-h5、body、caption）。
- **Image**：从 URL 渲染图像。必须支持 `fit`（cover、contain 等）和 `usageHint`（avatar、hero 等）属性。
- **Icon**：从目录中指定的标准集合中渲染预定义图标。
- **Video**：为给定 URL 渲染视频播放器。
- **AudioPlayer**：为给定 URL 渲染音频播放器，可选地带有描述。
- **Divider**：渲染视觉分隔线，支持 `horizontal` 和 `vertical` 轴。

### 布局与容器

标准目录包括以下布局和容器组件：

- **Row**：水平排列子元素。必须支持 `distribution`（justify-content）和 `alignment`（align-items）。子元素可以具有 `weight` 属性来控制 flex-grow 行为。
- **Column**：垂直排列子元素。必须支持 `distribution` 和 `alignment`。子元素可以具有 `weight` 属性来控制 flex-grow 行为。
- **List**：渲染可滚动的项目列表。必须支持 `direction`（`horizontal`/`vertical`）和 `alignment`。
- **Card**：在视觉上对其子内容进行分组的容器，通常带有边框、圆角和/或阴影。具有单个 `child`。
- **Tabs**：显示一组选项卡的容器。包括 `tabItems`，其中每个项目有一个 `title` 和一个 `child`。
- **Modal**：显示在主内容上方的对话框。它由 `entryPointChild`（例如按钮）触发，并在激活时显示 `contentChild`。

### 交互式和输入组件

标准目录包括以下交互式和输入组件：

- **Button**：触发 `userAction` 的可点击元素。必须能够包含 `child` 组件（通常是 Text 或 Icon），并可能根据 `primary` 布尔值改变样式。
- **CheckBox**：可切换的复选框，反映布尔值。
- **TextField**：文本输入字段。必须支持 `label`、`text`（值）、`textFieldType`（`shortText`、`longText`、`number`、`obscured`、`date`）和 `validationRegexp`。
- **DateTimeInput**：用于选择日期和/或时间的专用输入。必须支持 `enableDate` 和 `enableTime`。
- **MultipleChoice**：用于从列表（`options`）中选择一个或多个选项的组件。必须支持 `maxAllowedSelections` 并将 `selections` 绑定到列表或单个值。
- **Slider**：用于从定义范围（`minValue`、`maxValue`）中选择数值（`value`）的滑块。
