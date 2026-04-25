---
name: llm-wiki.schema.create
description: 协助创建、编辑和管理 wiki schema 文件。Schema 定义知识提取的约束和偏好，存放在 wiki/schemas/ 目录。当提到创建 schema、添加提取规则、定义知识提取偏好、更新提取约束时使用此技能。
---

# Wiki Schema Creator

管理 `wiki/schemas/` 目录下的知识提取规则文件。

## Schema 结构

详见 [schema-structure.md](references/schema-structure.md)，该文件定义了：
- Schema 文件的命名规范（kebab-case 格式）
- Front matter 格式（description、created 字段）
- 正文内容结构要素（关注范围、提取规则、排除范围、页面类型偏好、特殊约定）
- Schema Index 的固定格式

**何时参考 schema-structure.md：**
- 创建新 schema 时，了解完整的文件结构
- 更新现有 schema 时，确认正文结构是否符合规范
- 检查 Schema Index 格式是否正确

## 工作流程

本技能采用三阶段交互模式：**分析 → 确认 → 执行**。每个阶段完成后需等待用户确认，用户可随时中止或返回上一步。

### 阶段 1: 分析与建议

1. 读取 `wiki/schemas/index.md`，了解现有 schema
2. 读取与用户意图相关的现有 schema 文件
3. 比较用户意图与现有 schema 的 description，判断匹配程度
4. 给出建议：新增、更新、或拆分

匹配程度判断：

| 匹配程度 | 表现 | 示例 | 建议 |
|----------|------|------|------|
| 高度匹配 | 领域相同、提取目标相同、排除范围一致 | 用户要添加测试步骤提取规则，已有 testing-procedure schema | 更新现有 schema |
| 部分匹配-领域差异 | 领域相关但焦点不同 | 已有 api-design schema，用户要创建 api-testing schema | 新增独立 schema |
| 部分匹配-范围重叠 | 提取目标有重叠但各有侧重 | 已有 testing-procedure 覆盖功能测试，用户要添加性能测试规则 | 考虑拆分现有 schema 或新增独立 schema |
| 无匹配 | 没有相关领域 | 用户要创建 deployment-guide schema，当前无部署相关 schema | 新增 schema |

多匹配时的优先级规则：
1. 优先选择 description 最匹配的 schema
2. 若多个 schema 匹配度相近，比较它们的排除范围与用户意图的契合度
3. 若仍无法确定，建议用户明确需求范围

向用户展示：

```markdown
## Schema 分析与建议

### 现有 Schema

| Schema | 描述 |
|--------|------|
| [name](name.md) | description 摘要 |

### 匹配分析

- **[name]**：[匹配程度] - [差异说明]

### 建议

| 类型 | 操作 | 理由 |
|------|------|------|
| 新增/更新/拆分 | [操作] | [理由] |

---

请确认以上建议，或提出修改意见。
```

**[STOP]** 等待用户确认。

### 阶段 2: 确认

用户反馈。如有异议，回到阶段 1 重新分析。用户确认后进入阶段 3。

**异常处理：**
- 若用户取消操作，保存当前分析结果并结束流程
- 若用户需求不明确，询问具体领域、提取目标、排除范围
- 若发现文件冲突（同名 schema 但内容不同），提示用户选择保留或合并

### 阶段 3: 执行

1. 创建/更新 schema 文件：
   - 文件名使用 kebab-case 格式（全小写，单词间用 `-` 连接）
   - 包含 front matter（description、created 字段为必填）
   - 正文按结构要素编写：关注范围、提取规则、排除范围、页面类型偏好
2. 更新 `wiki/schemas/index.md`，添加或修改对应条目
3. 验证：
   - 文件格式：确认 front matter 包含必填字段，description 长度 20-100 字符
   - Index 一致性：确认 index 条目与文件内容一一对应
   - 描述辨识度：确认 description 与其他 schema 不重复
   - 命名规范：确认文件名符合 kebab-case，无缩写或含义不清的词汇

展示执行结果。

## 注意事项

- 三阶段流程必须执行，不得跳过
- 用户有异议时回到阶段 1
- description 是匹配的关键，帮助写出有辨识度的描述
- 文件命名和内容结构遵循 schema-structure.md 的规范
- 术语统一：本文档使用 "Schema"（首字母大写）指代具体的 schema 文件，使用 "schema"（小写）泛指概念