# 数据流 (Data Flow)

消息如何从智能体流向 UI。

## 架构

```
Agent (LLM) → A2UI Generator → Transport (SSE/WS/A2A)
                                      ↓
Client (Stream Reader) → Message Parser → Renderer → Native UI
```

![end-to-end-data-flow](/assets/end-to-end-data-flow.png)

## 消息格式

A2UI 定义了描述 UI 的 JSON 消息序列。在流式传输时，这些消息通常格式化为**JSON Lines (JSONL)**，其中每行是一个完整的 JSON 对象。

=== "v0.8"

    ```jsonl
    {
      "surfaceUpdate": {
        "surfaceId": "main",
        "components": [...]
      }
    }
    {
      "dataModelUpdate": {
        "surfaceId": "main",
        "contents": [
          {
            "key": "user",
            "valueMap": [
              { "key": "name", "valueString": "Alice" }
            ]
          }
        ]
      }
    }
    {
      "beginRendering": {
        "surfaceId": "main",
        "root": "root-component"
      }
    }
    ```

=== "v0.9"

    ```jsonl
    {
      "version": "v0.9",
      "createSurface": {
        "surfaceId": "main",
        "catalogId": "https://a2ui.org/specification/v0_9/basic_catalog.json"
      }
    }
    {
      "version": "v0.9",
      "updateComponents": {
        "surfaceId": "main",
        "components": [...]
      }
    }
    {
      "version": "v0.9",
      "updateDataModel": {
        "surfaceId": "main",
        "path": "/user",
        "value": { "name": "Alice" }
      }
    }
    ```

**为什么使用这种格式？**

一系列自包含的 JSON 对象具有流式友好、LLM 易于增量生成和对错误具有弹性的特点。

## 生命周期示例：餐厅预订

**用户：** "明天晚上7点订两人桌"

=== "v0.8"

    **1. 智能体定义 UI 结构：**

    ```json
    {
      "surfaceUpdate": {
        "surfaceId": "booking",
        "components": [
          {
            "id": "root",
            "component": {
              "Column": {
                "children": {
                  "explicitList": ["header", "guests-field", "submit-btn"]
                }
              }
            }
          },
          {
            "id": "header",
            "component": {
              "Text": {
                "text": { "literalString": "Confirm Reservation" },
                "usageHint": "h1"
              }
            }
          },
          {
            "id": "guests-field",
            "component": {
              "TextField": {
                "label": { "literalString": "Guests" },
                "text": { "path": "/reservation/guests" }
              }
            }
          },
          {
            "id": "submit-btn",
            "component": {
              "Button": {
                "child": "submit-text",
                "action": {
                  "name": "confirm",
                  "context": [
                    { "key": "details", "value": { "path": "/reservation" } }
                  ]
                }
              }
            }
          }
        ]
      }
    }
    ```

    **2. 智能体填充数据：**

    ```json
    {
      "dataModelUpdate": {
        "surfaceId": "booking",
        "path": "/reservation",
        "contents": [
          { "key": "datetime", "valueString": "2025-12-16T19:00:00Z" },
          { "key": "guests", "valueString": "2" }
        ]
      }
    }
    ```

    **3. 智能体信号渲染：**

    ```json
    {
      "beginRendering": {
        "surfaceId": "booking",
        "root": "root"
      }
    }
    ```

    **4. 用户将客人编辑为 "3"** → 客户端自动更新 `/reservation/guests`

    **5. 用户单击"确认"** → 客户端发送操作：

    ```json
    {
      "userAction": {
        "name": "confirm",
        "surfaceId": "booking",
        "context": {
          "details": {
            "datetime": "2025-12-16T19:00:00Z",
            "guests": "3"
          }
        }
      }
    }
    ```

    **6. 智能体响应** → 更新 UI 或发送：

    ```json
    { "deleteSurface": { "surfaceId": "booking" } }
    ```

=== "v0.9"

    **1. 智能体创建表面：**

    ```json
    {
      "version": "v0.9",
      "createSurface": {
        "surfaceId": "booking",
        "catalogId": "https://a2ui.org/specification/v0_9/basic_catalog.json"
      }
    }
    ```

    **2. 智能体定义 UI 结构：**

    ```json
    {
      "version": "v0.9",
      "updateComponents": {
        "surfaceId": "booking",
        "components": [
          {
            "id": "root",
            "component": "Column",
            "children": ["header", "guests-field", "submit-btn"]
          },
          {
            "id": "header",
            "component": "Text",
            "text": "Confirm Reservation",
            "variant": "h1"
          },
          {
            "id": "guests-field",
            "component": "TextField",
            "label": "Guests",
            "value": { "path": "/reservation/guests" }
          },
          {
            "id": "submit-btn",
            "component": "Button",
            "child": "submit-text",
            "variant": "primary",
            "action": {
              "event": {
                "name": "confirm",
                "context": {
                  "details": { "path": "/reservation" }
                }
              }
            }
          }
        ]
      }
    }
    ```

    **3. 智能体填充数据：**

    ```json
    {
      "version": "v0.9",
      "updateDataModel": {
        "surfaceId": "booking",
        "path": "/reservation",
        "value": {
          "datetime": "2025-12-16T19:00:00Z",
          "guests": "2"
        }
      }
    }
    ```

    **4. 用户将客人编辑为 "3"** → 客户端自动更新 `/reservation/guests`

    **5. 用户单击"确认"** → 客户端发送操作：

    ```json
    {
      "version": "v0.9",
      "action": {
        "name": "confirm",
        "surfaceId": "booking",
        "context": {
          "details": {
            "datetime": "2025-12-16T19:00:00Z",
            "guests": "3"
          }
        }
      }
    }
    ```

    **6. 智能体响应** → 更新 UI 或发送：

    ```json
    {
      "version": "v0.9",
      "deleteSurface": { "surfaceId": "booking" }
    }
    ```

## 传输选项

A2UI 与传输 (Transport) 无关——任何能传递 JSON 消息的机制都可以工作：

- **[A2A 协议](https://a2a-protocol.org/)**：标准化的智能体到智能体通信，也用于智能体到 UI 传递
- **[AG UI](https://docs.ag-ui.com/)**：双向、实时的智能体-UI 协议
- **REST / HTTP**：简单的请求-响应或用于单向流式传输的服务器发送事件 (SSE)
- **WebSocket**：持久的双向连接，适用于实时更新和用户操作
- **任何其他传输**：gRPC、消息队列、自定义协议——只要能承载 JSON，就可以工作

有关实现细节，请参阅 [传输](transports.md)。

## 渐进式渲染

无需等待整个响应生成后才向用户显示任何内容，响应的片段可以在生成时流式传输到客户端并渐进式渲染。

用户实时看到 UI 的构建，而不是盯着加载旋转指示器。

## 错误处理

系统按以下方式处理错误：

- **畸形消息：** 跳过并继续，或将错误发送回智能体进行纠正。
- **网络中断：** 显示错误状态，重新连接，智能体重新发送或恢复。

## 性能

优化性能：

- **批处理：** 缓冲 16ms 的更新，一起批处理渲染。
- **差异比较：** 比较旧/新组件，仅更新已更改的属性。
- **细粒度更新：** 更新 `/user/name` 而不是整个 `/` 模型。
