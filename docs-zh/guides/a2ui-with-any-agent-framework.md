# 使用任意智能体框架使用 A2UI（使用 AG-UI）

A2UI 是一种声明式 UI 格式。[AG-UI](https://ag-ui.com/) 是在智能体与浏览器之间传输 A2UI 消息的传输层。CopilotKit 的 AG-UI 实现是当前将 A2UI 呈现给用户的最快途径——CopilotKit 支持的任意智能体框架（ADK、LangGraph、CrewAI、Mastra、自定义 Python/TS 服务等）都可以生成 A2UI 并在 React 应用中渲染它，无需任何传输粘合代码。

::: info
信息来源

本指南反映了 CopilotKit [ADK + A2UI 文档](https://docs.copilotkit.ai/adk/generative-ui/a2ui)中的关键步骤。有关最新的 API 表面，请参阅 CopilotKit 文档。
:::

## 1. 设置 CopilotKit

将 CopilotKit 安装到你选择的框架（ADK、LangGraph、CrewAI、Mastra 等）的 React/Next.js 应用中：

```bash
npx copilotkit@latest init
```

或者按照 [CopilotKit 快速入门](https://docs.copilotkit.ai/quickstart)将其接入现有项目。这是标准的 CopilotKit 设置——无需 A2UI 特定的脚手架。

## 2. 启用 A2UI

### 后端

在 `CopilotRuntime` 中启用 A2UI，并注入 `render_a2ui` 工具，以便你的智能体可以生成 A2UI 表面（Surface）：

```ts title="app/api/copilotkit/route.ts"
import { CopilotRuntime } from "@copilotkit/runtime";

const runtime = new CopilotRuntime({
  agents: { default: myAgent },
  a2ui: { injectA2UITool: true },
});
```

使用 `a2ui: { injectA2UITool: true, agents: ["my-agent"] }` 将其范围限定到特定智能体。

### 前端

A2UI 渲染器（Renderer）会自动激活。可以选择传递主题：

```tsx
import { CopilotKitProvider } from "@copilotkit/react-core/v2";
import "@copilotkit/react-core/v2/styles.css";
import { myCustomTheme } from "@copilotkit/a2ui-renderer";

<CopilotKitProvider runtimeUrl="/api/copilotkit" a2ui={{ theme: myCustomTheme }}>
  {children}
</CopilotKitProvider>
```

### 自定义组件（BYOC）

A2UI 附带内置目录（Catalog）（Text、Image、Card 等），让你可以立即获得可用的表面。真正的力量在于用*你*自己的 React 组件——你的设计系统、你的数据结构——来扩展它，这样智能体就可以使用你已经信任的原语来组合界面。目录包含三个部分：

1. **定义（Definitions）**——Zod 模式加上自然语言描述。这是智能体在其系统提示中看到的。
2. **渲染器（Renderers）**——类型化的 React 组件，每个定义对应一个。这是用户看到的。
3. **注册（Registration）**——通过 provider 传递目录，使 A2UI 渲染器知道如何绘制你的组件。

#### 1. 定义组件模式

使用 Zod 创建平台无关的定义。`description` 字段会被注入到智能体的提示中，这样 LLM 就知道何时使用每个组件；模式会验证智能体发送的 props。

```ts title="lib/a2ui/definitions.ts"
import { z } from "zod";

export const myDefinitions = {
  StatusBadge: {
    description: "A colored status badge.",
    props: z.object({
      text: z.string(),
      variant: z.enum(["success", "warning", "error"]).optional(),
    }),
  },
  Metric: {
    description: "A key metric with label and value.",
    props: z.object({
      label: z.string(),
      value: z.string(),
      trend: z.enum(["up", "down"]).optional(),
    }),
  },
};

export type MyDefinitions = typeof myDefinitions;
```

#### 2. 创建 React 渲染器

将每个定义映射到一个 React 组件。`createCatalog` 在定义类型上是泛型的，因此渲染器接收的 props 会根据 Zod 模式进行类型检查——`props.text` 中的拼写错误会导致编译错误。

```tsx title="lib/a2ui/renderers.tsx"
"use client";

import { createCatalog, type CatalogRenderers } from "@copilotkit/a2ui-renderer";
import { myDefinitions, type MyDefinitions } from "./definitions";

const myRenderers: CatalogRenderers<MyDefinitions> = {
  StatusBadge: ({ props }) => {
    const colors = {
      success: { bg: "#dcfce7", text: "#166534" },
      warning: { bg: "#fef3c7", text: "#92400e" },
      error: { bg: "#fee2e2", text: "#991b1b" },
    };
    const c = colors[props.variant ?? "success"];
    return (
      <span style={{ padding: "2px 8px", borderRadius: 9999, fontSize: "0.75rem", background: c.bg, color: c.text }}>
        {props.text}
      </span>
    );
  },

  Metric: ({ props }) => (
    <div>
      <div style={{ fontSize: "0.75rem", color: "#6b7280" }}>{props.label}</div>
      <div style={{ fontSize: "1.5rem", fontWeight: 700 }}>
        {props.value} {props.trend === "up" ? "↑" : props.trend === "down" ? "↓" : ""}
      </div>
    </div>
  ),
};

export const myCatalog = createCatalog(myDefinitions, myRenderers, {
  catalogId: "my-app-catalog",
  includeBasicCatalog: true, // merges with built-in components
});
```

`catalogId` 是智能体用于定位此目录的稳定句柄；`includeBasicCatalog: true` 使你自己的组件与内置组件一起可用（省略它则*仅*渲染你的组件）。

#### 3. 将目录传递给 CopilotKit

```tsx title="app/layout.tsx"
"use client";

import { CopilotKitProvider } from "@copilotkit/react-core/v2";
import "@copilotkit/react-core/v2/styles.css";
import { myCatalog } from "@/lib/a2ui/renderers";

export default function Layout({ children }: { children: React.ReactNode }) {
  return (
    <CopilotKitProvider runtimeUrl="/api/copilotkit" a2ui={{ catalog: myCatalog }}>
      {children}
    </CopilotKitProvider>
  );
}
```

智能体现在将看到你的自定义组件以及内置组件，并可以在它们生成的任何 A2UI 表面中使用它们。

有关完整的 BYOC 参考（多个目录、主题化钩子、高级模式），请参阅 CopilotKit 的 [自定义组件（BYOC）部分](https://docs.copilotkit.ai/adk/generative-ui/a2ui#custom-components-byoc)。

## 3. 高级用法

有关完整的 A2UI 集成表面（自定义目录、细粒度控制、高级模式），请参阅 CopilotKit 的 [A2UI 文档](https://docs.copilotkit.ai/generative-ui/a2ui)。

## 下一步

- **[A2UI Composer](https://a2ui-composer.ag-ui.com/)** —— 以可视化方式构建组件。
- **[概念 › 传输层](../concepts/transports.md)** —— A2UI 如何映射到 AG-UI。
- **[v0.9 规范](../specification/v0.9-a2ui.md)** —— 底层协议。
