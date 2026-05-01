# 文档转换脚本

本目录包含用于准备文档以适配 **MkDocs** 构建过程的实用脚本。

## 目的

为了确保在 GitHub 和托管站点上都有出色的阅读体验，本项目使用 **GitHub 风格的 Markdown** 作为主要事实来源。该脚本在构建管道中将 GitHub 的原生语法转换为 **MkDocs 兼容语法**（特别是针对 `pymdown-extensions`）。

## 支持的转换（单向）

脚本执行单向转换：**GitHub Markdown → MkDocs 语法**。

### 警告/提示框转换

脚本处理以下转换：
- GitHub 使用基于引用的语法来显示警告。
- MkDocs 需要 `!!!` 或 `???` 语法来渲染彩色提示框。

## 运行转换

转换作为构建管道的一部分运行。无需额外步骤。如果需要手动运行转换，可以在仓库根目录运行 `convert_docs.py` 脚本。

```bash
python docs/scripts/convert_docs.py
```

### 示例

- **源文件（GitHub 风格 Markdown）：**
  ```markdown
  > ⚠️ **Attention**
  >
  > This is an alert.
  ```

- **目标文件（MkDocs 语法）：**
  ```markdown
  !!! warning "Attention"
      This is an alert.
  ```
