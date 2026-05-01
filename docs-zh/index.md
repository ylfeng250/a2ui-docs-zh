---
layout: home

hero:
  name: "A2UI"
  text: "AI 智能体驱动界面的通用协议"
  tagline: 让 AI 智能体能够生成丰富的交互式用户界面，在 Web、移动和桌面端原生渲染，无需执行任意代码。
  actions:
    - theme: brand
      text: 快速开始
      link: /quickstart
    - theme: alt
      text: 核心概念
      link: /concepts/overview
    - theme: alt
      text: 术语表
      link: /glossary
    - theme: alt
      text: 英文原文
      link: https://github.com/google/A2UI

features:
  - title: 安全设计
    details: 声明式数据格式，非可执行代码。智能体只能使用目录中预批准的组件，防止 UI 注入攻击。
  - title: 大模型友好
    details: 扁平的流式 JSON 结构，专为大模型生成而设计。LLM 可以增量构建 UI，无需一次性输出完美 JSON。
  - title: 框架无关
    details: 一份智能体响应，处处可用。使用你自己的样式化组件在 Angular、Flutter、React 或原生移动端渲染相同 UI。
  - title: 渐进渲染
    details: 随生成实时流式推送 UI 更新。用户可以看到界面实时构建，无需等待完整响应。
---
