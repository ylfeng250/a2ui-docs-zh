import { defineConfig } from 'vitepress'

export default defineConfig({
  lang: 'zh-CN',
  title: 'A2UI 中文文档',
  description: 'A2UI 协议中文文档 - AI 智能体驱动界面的通用协议',

  base: '/a2ui-docs-zh/',

  markdown: {
    theme: 'dark-plus',
  },

  ignoreDeadLinks: true,

  themeConfig: {
    nav: [
      { text: '首页', link: '/' },
      { text: '快速开始', link: '/quickstart' },
    ],

    sidebar: {
      '/': [
        {
          text: '简介',
          items: [
            { text: 'A2UI 简介', link: '/' },
            { text: '什么是 A2UI？', link: '/introduction/what-is-a2ui' },
            { text: '为谁而设？', link: '/introduction/who-is-it-for' },
            { text: '如何使用', link: '/introduction/how-to-use' },
            { text: 'Agent UI 生态', link: '/introduction/agent-ui-ecosystem' },
          ],
        },
        {
          text: '快速开始',
          items: [
            { text: '快速开始', link: '/quickstart' },
            { text: '组件构建器', link: '/composer' },
          ],
        },
        {
          text: '核心概念',
          items: [
            { text: '概述', link: '/concepts/overview' },
            { text: '组件', link: '/concepts/components' },
            { text: '目录', link: '/concepts/catalogs' },
            { text: '数据绑定', link: '/concepts/data-binding' },
            { text: '数据流', link: '/concepts/data-flow' },
            { text: '操作', link: '/concepts/actions' },
            { text: '传输协议', link: '/concepts/transports' },
          ],
        },
        {
          text: '开发指南',
          items: [
            { text: '客户端设置', link: '/guides/client-setup' },
            { text: '智能体开发', link: '/guides/agent-development' },
            { text: '渲染器开发', link: '/guides/renderer-development' },
            { text: '主题定制', link: '/guides/theming' },
            { text: '编写自定义组件', link: '/guides/authoring-components' },
            { text: '定义自己的目录', link: '/guides/defining-your-own-catalog' },
            { text: '与任意 Agent 框架集成', link: '/guides/a2ui-with-any-agent-framework' },
            { text: 'MCP 应用中的 A2UI', link: '/guides/a2ui-in-mcp-apps' },
            { text: 'MCP 上的 A2UI', link: '/guides/a2ui_over_mcp' },
            { text: 'A2UI 中的 MCP 应用', link: '/guides/mcp-apps-in-a2ui' },
          ],
        },
        {
          text: '协议规范',
          items: [
            { text: 'v0.8 协议', link: '/specification/v0.8-a2ui' },
            { text: 'v0.8 A2A 扩展', link: '/specification/v0.8-a2a-extension' },
            { text: 'v0.9 协议', link: '/specification/v0.9-a2ui' },
            { text: '演进指南', link: '/specification/v0.9-evolution-guide' },
          ],
        },
        {
          text: '参考文档',
          items: [
            { text: '消息', link: '/reference/messages' },
            { text: '组件', link: '/reference/components' },
            { text: '渲染器', link: '/reference/renderers' },
            { text: '智能体', link: '/reference/agents' },
          ],
        },
        {
          text: '术语与路线',
          items: [
            { text: '术语表', link: '/glossary' },
            { text: '路线图', link: '/roadmap' },
          ],
        },
        {
          text: '生态社区',
          items: [
            { text: 'A2UI 在世界中', link: '/ecosystem/a2ui-in-the-world' },
            { text: '渲染器', link: '/ecosystem/renderers' },
            { text: '社区', link: '/ecosystem/community' },
          ],
        },
      ],
    },

    socialLinks: [
      { icon: 'github', link: 'https://github.com/google/A2UI' },
    ],

    footer: {
      message: '基于 Apache 2.0 许可证发布 | 英文原文: <a href="https://github.com/google/A2UI">google/A2UI</a>',
      copyright: 'Copyright 2024 Google LLC',
    },
  },
})
