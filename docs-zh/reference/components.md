# 组件库

本页面展示了所有 A2UI 组件及其示例和使用模式。

> NOTE: Schema Files
>
> === "v0.8"
>
>     [:material-code-json: 标准目录定义（JSON Schema）](../../specification/v0_8/json/standard_catalog_definition.json)
>
> === "v0.9"
>
>     [:material-code-json: 基础目录定义（JSON Schema）](../../specification/v0_9/json/basic_catalog.json)

---

## 布局组件

### Row

水平布局容器。子元素从左到右排列。

=== "v0.8"

    **属性：** `children`（`explicitList` 或 `template`）、`distribution`、`alignment`

    ```json
    {
      "id": "toolbar",
      "component": {
        "Row": {
          "children": { "explicitList": ["btn1", "btn2", "btn3"] },
          "distribution": "spaceBetween",
          "alignment": "center"
        }
      }
    }
    ```

=== "v0.9"

    **属性：** `children`（数组或模板）、`justify`、`align`

    ```json
    {
      "id": "toolbar",
      "component": "Row",
      "children": ["btn1", "btn2", "btn3"],
      "justify": "spaceBetween",
      "align": "center"
    }
    ```

### Column

垂直布局容器。子元素从上到下排列。

=== "v0.8"

    **属性：** `children`（`explicitList` 或 `template`）、`distribution`、`alignment`

    ```json
    {
      "id": "content",
      "component": {
        "Column": {
          "children": { "explicitList": ["header", "body", "footer"] },
          "distribution": "start",
          "alignment": "stretch"
        }
      }
    }
    ```

=== "v0.9"

    **属性：** `children`（数组或模板）、`justify`、`align`

    ```json
    {
      "id": "content",
      "component": "Column",
      "children": ["header", "body", "footer"],
      "justify": "start",
      "align": "stretch"
    }
    ```

### List

可滚动的项目列表。支持静态子元素和动态模板。

=== "v0.8"

    **属性：** `children`（`explicitList` 或 `template`）、`direction`、`alignment`

    ```json
    {
      "id": "message-list",
      "component": {
        "List": {
          "children": {
            "template": {
              "dataBinding": "/messages",
              "componentId": "message-item"
            }
          },
          "direction": "vertical"
        }
      }
    }
    ```

=== "v0.9"

    **属性：** `children`（数组或模板）、`direction`、`align`

    ```json
    {
      "id": "message-list",
      "component": "List",
      "children": {
        "componentId": "message-item",
        "path": "/messages"
      },
      "direction": "vertical"
    }
    ```

---

## 展示组件

### Text

显示带有样式提示的文本内容。

=== "v0.8"

    **属性：** `text`（BoundValue）、`usageHint`

    `usageHint` 取值：`h1`、`h2`、`h3`、`h4`、`h5`、`caption`、`body`

    ```json
    {
      "id": "title",
      "component": {
        "Text": {
          "text": { "literalString": "Welcome to A2UI" },
          "usageHint": "h1"
        }
      }
    }
    ```

=== "v0.9"

    **属性：** `text`（字符串或 Data Binding）、`variant`

    `variant` 取值：`h1`、`h2`、`h3`、`h4`、`h5`、`caption`、`body`

    ```json
    {
      "id": "title",
      "component": "Text",
      "text": "Welcome to A2UI",
      "variant": "h1"
    }
    ```

### Image

从 URL 显示图片。

=== "v0.8"

    **属性：** `url`（BoundValue）、`fit`、`usageHint`

    ```json
    {
      "id": "hero",
      "component": {
        "Image": {
          "url": { "literalString": "https://example.com/hero.png" },
          "fit": "cover",
          "usageHint": "hero"
        }
      }
    }
    ```

=== "v0.9"

    **属性：** `url`（字符串或 Data Binding）、`fit`、`variant`

    ```json
    {
      "id": "hero",
      "component": "Image",
      "url": "https://example.com/hero.png",
      "fit": "cover",
      "variant": "hero"
    }
    ```

### Icon

从目录中定义的标准集合中显示图标。

=== "v0.8"

    **属性：** `name`（BoundValue）

    ```json
    {
      "id": "check-icon",
      "component": {
        "Icon": {
          "name": { "literalString": "check" }
        }
      }
    }
    ```

=== "v0.9"

    **属性：** `name`（字符串或 Data Binding）

    ```json
    {
      "id": "check-icon",
      "component": "Icon",
      "name": "check"
    }
    ```

### Divider

视觉分隔线。

=== "v0.8"

    **属性：** `axis`

    ```json
    {
      "id": "separator",
      "component": {
        "Divider": {
          "axis": "horizontal"
        }
      }
    }
    ```

=== "v0.9"

    **属性：** `axis`

    ```json
    {
      "id": "separator",
      "component": "Divider",
      "axis": "horizontal"
    }
    ```

---

## 交互组件

### Button

触发操作的点击按钮。

=== "v0.8"

    **属性：** `child`（组件 ID）、`primary`（布尔值）、`action`

    ```json
    {
      "id": "submit-btn",
      "component": {
        "Button": {
          "child": "submit-text",
          "primary": true,
          "action": {
            "name": "submit_form"
          }
        }
      }
    }
    ```

=== "v0.9"

    **属性：** `child`（组件 ID）、`variant`、`action`

    ```json
    {
      "id": "submit-btn",
      "component": "Button",
      "child": "submit-text",
      "variant": "primary",
      "action": {
        "event": {
          "name": "submit_form"
        }
      }
    }
    ```

### TextField

带有可选验证的文本输入字段。

=== "v0.8"

    **属性：** `label`（BoundValue）、`text`（BoundValue）、`textFieldType`、`validationRegexp`

    `textFieldType` 取值：`shortText`、`longText`、`number`、`obscured`、`date`

    ```json
    {
      "id": "email-input",
      "component": {
        "TextField": {
          "label": { "literalString": "Email Address" },
          "text": { "path": "/user/email" },
          "textFieldType": "shortText"
        }
      }
    }
    ```

=== "v0.9"

    **属性：** `label`（字符串）、`value`（字符串或 Data Binding）、`textFieldType`、`validationRegexp`

    `textFieldType` 取值：`shortText`、`longText`、`number`、`obscured`、`date`

    ```json
    {
      "id": "email-input",
      "component": "TextField",
      "label": "Email Address",
      "value": { "path": "/user/email" },
      "textFieldType": "shortText"
    }
    ```

### CheckBox

布尔开关。

=== "v0.8"

    **属性：** `label`（BoundValue）、`value`（BoundValue，布尔值）

    ```json
    {
      "id": "terms-checkbox",
      "component": {
        "CheckBox": {
          "label": { "literalString": "I agree to the terms" },
          "value": { "path": "/form/agreedToTerms" }
        }
      }
    }
    ```

=== "v0.9"

    **属性：** `label`（字符串）、`value`（Data Binding，布尔值）

    ```json
    {
      "id": "terms-checkbox",
      "component": "CheckBox",
      "label": "I agree to the terms",
      "value": { "path": "/form/agreedToTerms" }
    }
    ```

### Slider

数字范围输入。

=== "v0.8"

    **属性：** `value`（BoundValue）、`minValue`、`maxValue`

    ```json
    {
      "id": "volume",
      "component": {
        "Slider": {
          "value": { "path": "/settings/volume" },
          "minValue": 0,
          "maxValue": 100
        }
      }
    }
    ```

=== "v0.9"

    **属性：** `value`（Data Binding）、`minValue`、`maxValue`

    ```json
    {
      "id": "volume",
      "component": "Slider",
      "value": { "path": "/settings/volume" },
      "minValue": 0,
      "maxValue": 100
    }
    ```

### DateTimeInput

日期和/或时间选择器。

=== "v0.8"

    **属性：** `value`（BoundValue）、`enableDate`、`enableTime`

    ```json
    {
      "id": "date-picker",
      "component": {
        "DateTimeInput": {
          "value": { "path": "/booking/date" },
          "enableDate": true,
          "enableTime": false
        }
      }
    }
    ```

=== "v0.9"

    **属性：** `value`（Data Binding）、`enableDate`、`enableTime`

    ```json
    {
      "id": "date-picker",
      "component": "DateTimeInput",
      "value": { "path": "/booking/date" },
      "enableDate": true,
      "enableTime": false
    }
    ```

### MultipleChoice（v0.8）/ ChoicePicker（v0.9）

从列表中选择一个或多个选项。

=== "v0.8"

    **属性：** `options`（数组）、`selections`（BoundValue）、`maxAllowedSelections`

    ```json
    {
      "id": "country-select",
      "component": {
        "MultipleChoice": {
          "options": [
            { "label": { "literalString": "USA" }, "value": "us" },
            { "label": { "literalString": "Canada" }, "value": "ca" }
          ],
          "selections": { "path": "/form/country" },
          "maxAllowedSelections": 1
        }
      }
    }
    ```

=== "v0.9"

    **属性：** `options`（数组）、`selections`（Data Binding）、`maxAllowedSelections`

    ```json
    {
      "id": "country-select",
      "component": "ChoicePicker",
      "options": [
        { "label": "USA", "value": "us" },
        { "label": "Canada", "value": "ca" }
      ],
      "selections": { "path": "/form/country" },
      "maxAllowedSelections": 1
    }
    ```

---

## 容器组件

### Card

带阴影/边框和内边距的容器。

=== "v0.8"

    **属性：** `child`（组件 ID）

    ```json
    {
      "id": "info-card",
      "component": {
        "Card": {
          "child": "card-content"
        }
      }
    }
    ```

=== "v0.9"

    **属性：** `child`（组件 ID）

    ```json
    {
      "id": "info-card",
      "component": "Card",
      "child": "card-content"
    }
    ```

### Modal

由入口点组件触发的覆盖对话框。

=== "v0.8"

    **属性：** `entryPointChild`（组件 ID）、`contentChild`（组件 ID）

    ```json
    {
      "id": "confirmation-modal",
      "component": {
        "Modal": {
          "entryPointChild": "open-modal-btn",
          "contentChild": "modal-content"
        }
      }
    }
    ```

=== "v0.9"

    **属性：** `entryPointChild`（组件 ID）、`contentChild`（组件 ID）

    ```json
    {
      "id": "confirmation-modal",
      "component": "Modal",
      "entryPointChild": "open-modal-btn",
      "contentChild": "modal-content"
    }
    ```

### Tabs

用于将内容组织到可切换面板中的选项卡式界面。

=== "v0.8"

    **属性：** `tabItems`（`{ title, child }` 数组）

    ```json
    {
      "id": "settings-tabs",
      "component": {
        "Tabs": {
          "tabItems": [
            { "title": { "literalString": "General" }, "child": "general-tab" },
            { "title": { "literalString": "Privacy" }, "child": "privacy-tab" }
          ]
        }
      }
    }
    ```

=== "v0.9"

    **属性：** `tabItems`（`{ title, child }` 数组）

    ```json
    {
      "id": "settings-tabs",
      "component": "Tabs",
      "tabItems": [
        { "title": "General", "child": "general-tab" },
        { "title": "Privacy", "child": "privacy-tab" }
      ]
    }
    ```

---

## 通用属性

所有组件共享：

- `id`（必需）：表面内的唯一标识符。
- `accessibility`：无障碍属性（label、role）。
- `weight`：在 Row 或 Column 内的 flex-grow 值。

## 版本差异总结

组件名称和属性在版本之间基本相同。结构差异如下：

| 方面 | v0.8 | v0.9 |
|--------|------|------|
| 组件包装 | `"component": { "Text": { ... } }` | `"component": "Text", ...props` |
| 字符串值 | `{ "literalString": "Hello" }` | `"Hello"` |
| 子元素 | `{ "explicitList": ["a", "b"] }` | `["a", "b"]` |
| 数据绑定 | `{ "path": "/data" }` | `{ "path": "/data" }`（相同） |
| 文本/图片样式 | `usageHint` | `variant` |
| 按钮样式 | `primary: true` | `variant: "primary"` |
| 操作格式 | `{ "name": "..." }` | `{ "event": { "name": "..." } }` |
| 选择组件 | `MultipleChoice` | `ChoicePicker` |
| 布局对齐 | `distribution`、`alignment` | `justify`、`align` |
| TextField 值 | `text` | `value` |

## 在线示例

要查看所有组件的实际效果：

```bash
cd samples/client/angular
npm start -- gallery
```

## 延伸阅读

> NOTE: Schema Files
>
> === "v0.8"
>
>     [:material-code-json: 标准目录定义（JSON Schema）](../../specification/v0_8/json/standard_catalog_definition.json)
>
> === "v0.9"
>
>     [:material-code-json: 基础目录定义（JSON Schema）](../../specification/v0_9/json/basic_catalog.json)

- **[定义自己的目录](../guides/defining-your-own-catalog.md)**：构建自定义组件
- **[主题指南](../guides/theming.md)**：让组件样式与品牌匹配
