# 路线图

本路线图概述了 A2UI 项目的当前状态和未来计划。该项目正在积极开发中，优先级可能会根据社区反馈和新出现的用例而改变。

## 当前状态

### 协议

| 版本 | 状态 | 说明 |
|------|------|------|
| **v0.8** | ✅ 稳定 | 初始公开发布 |
| **v0.9** | 🚧 草稿 | 提示优先的规格改进 |

主要特性：

- 流式 JSONL 消息格式。
- 四种核心消息类型（`surfaceUpdate`、`dataModelUpdate`、`beginRendering`、`deleteSurface`）。
- 邻接列表组件模型。
- 基于 JSON Pointer 的数据绑定 (Data Binding)。
- 结构和状态分离。

### 渲染器 (Renderer)

| 客户端库 | 状态 | 平台 | 说明 |
|---------|------|------|------|
| **Web Components (Lit)** | ✅ 稳定 | Web | 框架无关，随处可用 |
| **Angular** | ✅ 稳定 | Web | 完整的 Angular 集成 |
| **Flutter (GenUI SDK)** | ✅ 稳定 | 多平台 | 适用于移动端、Web、桌面端 |
| **React** | 🚧 进行中 | Web | 预计 2026 年 Q1 |
| **SwiftUI** | 📋 计划中 | iOS/macOS | 计划于 2026 年 Q2 |
| **Jetpack Compose** | 📋 计划中 | Android | 计划于 2026 年 Q2 |
| **Vue** | 💡 提议中 | Web | 社区兴趣 |
| [**Svelte/Kit**](https://svelte.dev/docs/kit/introduction) | 💡 提议中 | Web | [社区兴趣](https://news.ycombinator.com/item?id=46287728) |
| **ShadCN (React)** | 💡 提议中 | Web | 社区兴趣 |

### 传输 (Transport)

| 传输 | 状态 | 说明 |
|------|------|------|
| **A2A 协议** | ✅ 完成 | 原生 A2A 传输 |
| **AG UI** | ✅ 完成 | 首日兼容 |
| **REST API** | 📋 计划中 | 双向通信 |
| **WebSockets** | 💡 提议中 | 双向通信 |
| **SSE（服务器发送事件）** | 💡 提议中 | Web 流式传输 |
| **MCP（模型上下文协议）** | 💡 提议中 | 社区兴趣 |

### 智能体 UI 工具包

| 智能体 UI 工具包 | 状态 | 说明 |
|-------------|------|------|
| **CopilotKit** | ✅ 完成 | 得益于 AG UI，首日兼容 |
| **Open AI ChatKit** | 💡 提议中 | 社区兴趣 |
| **Vercel AI SDK UI** | 💡 提议中 | 社区兴趣 |

### 智能体框架

| 集成 | 状态 | 说明 |
|------|------|------|
| **任何支持 A2A 的智能体** | ✅ 完成 | 得益于 A2A 协议，首日兼容 |
| **ADK** | 📋 计划中 | 仍在设计开发者体验，参见 [示例](../samples/agent/adk) |
| **Genkit** | 💡 提议中 | 社区兴趣 |
| **LangGraph** | 💡 提议中 | 社区兴趣 |
| **CrewAI** | 💡 提议中 | 社区兴趣 |
| **AG2** | ✅ 完成 | [A2UIAgent](https://docs.ag2.ai/latest/docs/user-guide/reference-agents/a2uiagent) |
| **Claude Agent SDK** | 💡 提议中 | 社区兴趣 |
| **OpenAI Agent SDK** | 💡 提议中 | 社区兴趣 |
| **Microsoft Agent Framework** | 💡 提议中 | 社区兴趣 |
| **AWS Strands Agent SDK** | 💡 提议中 | 社区兴趣 |

## 近期里程碑

### 2025 年 Q2

多个 Google 团队的多个研究项目，包括集成到内部产品和智能体中。

### 2025 年 Q4

- 发布 v0.8.0 规格说明
- A2A 扩展（感谢 Google A2A 团队！在 [a2asummit.ai](https://a2asummit.ai) 上预告）
- Flutter 渲染器（感谢 Flutter 团队！）
- Angular 渲染器（感谢 Angular 团队！）
- Web Components (Lit) 渲染器（感谢 Opal 团队和朋友们！）
- AG UI / CopilotKit 集成（感谢 CopilotKit 团队！）
- Github 公开发布（Apache 2.0）

## 即将到来的里程碑

### 2026 年 Q1

#### A2UI v0.9

- 规格 0.9 的候选发布版
- 改进渲染器的主题支持（已完成）
- 改进智能体的服务器端主题支持（最小化）
- 改进开发者体验

#### React 渲染器 (Renderer)

具有基于 hooks 的 API 和完整 TypeScript 支持的原生 React 渲染器。

- React 支持常用组件
- React 支持自定义组件
- `useA2UI` hook 用于消息处理
- React 支持主题

### 2026 年 Q2

#### 原生移动端渲染器 (Renderer)

适用于 iOS 和 Android 平台的原生渲染器。

**SwiftUI 渲染器 (iOS/macOS)：**

- 原生 SwiftUI 组件
- iOS 设计语言支持
- macOS 兼容性

**Jetpack Compose 渲染器 (Android)：**

- 原生 Compose UI 组件
- Material Design 3 支持
- Android 平台集成

#### 性能优化

- 渲染器性能基准测试
- 大型组件树的懒加载
- 列表的虚拟滚动
- 组件记忆化策略

### 2026 年 Q4

#### 协议 v1.0

 finalized v1.0 的协议，包括：

- 稳定性保证
- 从 v0.9 迁移的路径
- 全面的测试套件
- 渲染器认证计划

## 长期愿景

### 多智能体协调

增强对多个智能体贡献同一 UI 的支持：

- 推荐智能体组合模式
- 冲突解决策略
- 共享表面 (Surface) 管理

### 无障碍特性

一流的可访问性支持：

- ARIA 属性生成
- 屏幕阅读器优化
- 键盘导航标准
- 对比度和颜色指南

### 高级 UI 模式

支持更复杂的 UI 交互：

- 拖放
- 手势和动画
- 3D 渲染
- AR/VR 界面（探索性）

### 生态系统增长

- 更多框架集成
- 第三方组件库
- 智能体市场集成
- 企业功能和支持

## 社区请求

社区请求的特性（按任意顺序）：

- **更多渲染器集成**：将你的客户端库映射到 A2UI
- **更多智能体框架**：将你的智能体框架映射到 A2UI
- **更多传输 (Transport)**：将你的传输映射到 A2UI
- **社区组件库**：与社区共享自定义组件
- **社区示例**：与社区共享自定义示例
- **社区评估**：生成式 UI 评估场景和标注数据集
- **开发者体验**：如果你能构建更好的 A2UI 体验，请与社区共享

## 如何影响路线图

我们欢迎社区对优先级的意见：

1. **对 Issues 投票**：给你关心的 GitHub issues 投上 👍
2. **提议特性**：在 GitHub 上发起讨论（先搜索现有讨论）
3. **提交 PR**：构建你需要的特性（先搜索现有 PR）
4. **加入讨论**：分享你的用例和需求（先搜索现有讨论）

## 发布周期

- **主版本**（1.0、2.0）：年度发布或当需要重大破坏性变更时
- **次版本**（1.1、1.2）：每季度发布，带有新特性
- **补丁版本**（1.1.1、1.1.2）：按需发布以修复 bug

## 版本策略

A2UI 遵循 [语义化版本控制](https://semver.org/)：

- **主版本 (MAJOR)**：不兼容的协议变更
- **次版本 (MINOR)**：向后兼容的功能新增
- **补丁版本 (PATCH)**：向后兼容的 bug 修复

## 参与其中

想为路线图做贡献？

- 在 [GitHub Discussions](https://github.com/google/A2UI/discussions) 中**提议特性**
- **构建原型**并与社区共享
- 在 GitHub Issues 上**加入对话**

## 保持更新

- 关注 [GitHub 仓库](https://github.com/google/A2UI) 获取更新
- 给仓库加星以表示你的支持
- 关注发布以获取新版本的通知

---

**最后更新：** 2026 年 3 月

有关路线图的问题？在 [GitHub 上发起讨论](https://github.com/google/A2UI/discussions)。
