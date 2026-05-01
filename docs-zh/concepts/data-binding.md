# 数据绑定 (Data Binding)

数据绑定 (Data Binding) 使用 JSON Pointer 路径（[RFC 6901](https://tools.ietf.org/html/rfc6901)）将 UI 组件连接到应用状态。它允许 A2UI 高效地定义大数据数组的布局，并在不重新生成的情况下显示更新后的内容。

## 结构 vs. 状态

A2UI 分离了：

1. **UI 结构**（组件 (Component)）：界面的外观
2. **应用状态**（数据模型 (Data Model)）：它显示的数据

这使能了：
- 响应式更新。
- 数据驱动的 UI。
- 可复用的模板。
- 双向绑定。

## 数据模型 (Data Model)

每个表面 (Surface) 都有一个保存状态的 JSON 对象：

```json
{
  "user": {"name": "Alice", "email": "alice@example.com"},
  "cart": {
    "items": [{"name": "Widget", "price": 9.99, "quantity": 2}],
    "total": 19.98
  }
}
```

## JSON Pointer 路径

**语法：**

- `/user/name` - 对象属性
- `/cart/items/0` - 数组索引（从零开始）
- `/cart/items/0/price` - 嵌套路径

**示例：**

```json
{"user": {"name": "Alice"}, "items": ["Apple", "Banana"]}
```

- `/user/name` → `"Alice"`
- `/items/0` → `"Apple"`

## 字面值 vs. 路径值

=== "v0.8"

    **字面量（固定的）：**
    ```json
    {
      "id": "title",
      "component": {
        "Text": {
          "text": { "literalString": "Welcome" }
        }
      }
    }
    ```

    **数据绑定的（响应式）：**
    ```json
    {
      "id": "username",
      "component": {
        "Text": {
          "text": { "path": "/user/name" }
        }
      }
    }
    ```

=== "v0.9"

    **字面量（固定的）：**
    ```json
    {
      "id": "title",
      "component": "Text",
      "text": "Welcome"
    }
    ```

    **数据绑定的（响应式）：**
    ```json
    {
      "id": "username",
      "component": "Text",
      "text": { "path": "/user/name" }
    }
    ```

当 `/user/name` 从 "Alice" 变为 "Bob" 时，文本**自动更新**为 "Bob"。

## 响应式更新

绑定到数据路径的组件在数据更改时自动更新：

```json
{
  "id": "status",
  "component": {
    "Text": {
      "text": { "path": "/order/status" }
    }
  }
}
```

- **初始：** `/order/status` = "Processing..." → 显示 "Processing..."
- **更新：** 使用 `status: "Shipped"` 发送数据模型更新 → 显示 "Shipped"

无需组件更新——只需数据更新。

## 动态列表

使用模板渲染数组：

```json
{
  "id": "product-list",
  "component": {
    "Column": {
      "children": {
        "template": {
          "dataBinding": "/products",
          "componentId": "product-card"
        }
      }
    }
  }
}
```

**数据：**
```json
{
  "products": [
    { "name": "Widget", "price": 9.99 },
    { "name": "Gadget", "price": 19.99 }
  ]
}
```

**结果：** 渲染两个卡片，每个产品一个。

### 作用域路径

在模板内部，路径限定到数组元素：

```json
{
  "id": "product-name",
  "component": {
    "Text": {
      "text": { "path": "/name" }
    }
  }
}
```

- 对于 `/products/0`，`/name` 解析为 `/products/0/name` → "Widget"
- 对于 `/products/1`，`/name` 解析为 `/products/1/name` → "Gadget"

添加/移除元素会自动更新渲染的组件。

## 输入绑定

交互式组件双向更新数据模型：

| 组件 | 示例 | 用户操作 | 数据更新 |
|------|------|----------|----------|
| **TextField** | `{"text": {"path": "/form/name"}}` | 输入 "Alice" | `/form/name` = "Alice" |
| **CheckBox** | `{"value": {"path": "/form/agreed"}}` | 勾选复选框 | `/form/agreed` = true |
| **MultipleChoice** | `{"selections": {"path": "/form/country"}}` | 选择 "Canada" | `/form/country` = ["ca"] |

## 最佳实践

- **使用细粒度更新**：仅更新更改的路径。
  ```json
  {
    "dataModelUpdate": {
      "path": "/user",
      "contents": [
        { "key": "name", "valueString": "Alice" }
      ]
    }
  }
  ```

- **按领域组织**：对相关数据进行分组。
  ```json
  {"user": {...}, "cart": {...}, "ui": {...}}
  ```

- **预计算显示值**：在发送之前在智能体上格式化数据（货币、日期）。
  ```json
  {"price": "$19.99"}  // 而不是: {"price": 19.99}
  ```
