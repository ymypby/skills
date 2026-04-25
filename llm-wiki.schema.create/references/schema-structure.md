# Schema 结构定义

## Schema 文件

### 文件命名规范

- 使用 kebab-case 格式（全小写，单词间用连字符 `-` 连接）
- 文件名应简洁反映 schema 的核心领域，如 `testing-procedure`、`api-design`
- 避免使用缩写或含义不清的词汇

### Front Matter 格式

```yaml
---
description: >
  适用的领域、场景、提取目标。
  领域背景、适用场景、主要提取方向。
created: "YYYY-MM-DD"
---
```

### 正文内容结构

Schema 正文应包含以下结构要素（按需选用）：

| 结构要素 | 说明 | 示例 |
|----------|------|------|
| 关注范围 | 明确提取时应聚焦的内容领域和上下文 | user-story、测试流程 |
| 提取规则 | 具体的知识提取约束和偏好 | 保持步骤完整性 |
| 排除范围 | 明确不应提取的内容类型 | 根因分析、架构设计 |
| 页面类型偏好 | 优先创建的页面类型 | procedure、entity、concept |
| 特殊约定 | 针对该领域的特定规则或格式要求 | 特定字段格式 |

### 示例

```yaml
---
description: >
  适用于软件测试领域的知识提取。
  主要从问题修复对话、需求讨论、功能描述中提取测试相关的知识。
created: "2026-04-24"
---

## 关注范围

关注 user-story 和对应的测试流程。

## 提取规则

- 提取测试步骤时保持完整性和可执行性
- 保留测试前置条件和预期结果

## 排除范围

排除问题根因分析、代码实现细节、系统架构设计。

## 页面类型偏好

优先创建 procedure 类型页面。
可选创建 entity 类型页面（涉及新的测试对象时）。
```

## Schema Index

### 格式规范

```markdown
# Schema Index

- **schema-name**
  - 描述：description 内容摘要。
  - 路径：`schema-name.md`
```

### 示例

```markdown
# Schema Index

- **testing-procedure**
  - 描述：适用于软件测试领域的知识提取。主要从问题修复对话、需求讨论、功能描述中提取测试相关的知识。
  - 路径：`testing-procedure.md`
