# 日志和索引规范

本文档定义 `log.md` 和 `index.md` 的格式和维护规则。

## log.md - 活动日志

### 职责

log.md 是**纯时间线记录**，记录 wiki 的演变更迭历史。

### 格式

```markdown
# Wiki Activity Log

## [YYYY-MM-DD] operation | 标题

简要描述操作内容。

- 详细项 1
- 详细项 2
```

### 操作类型

| 类型 | 说明 |
|------|------|
| `ingest` | 摄取新源内容 |
| `query` | 用户提问 |
| `lint` | 维护检查 |
| `update` | 手动更新页面 |

### Ingest 日志格式

**文件/代码来源**：

```markdown
## [YYYY-MM-DD] ingest | 文件名

- 来源: 文件/代码 - path/to/file (行数/页数)
- 创建: overview/auth.md（如适用）
- 创建: wiki/path/to/page.md
- 更新: wiki/path/to/page.md
- sources/ 摘要: 创建/跳过
- 更新: referenced_by, index.md
```

**对话上下文来源**：

```markdown
## [YYYY-MM-DD] ingest | 对话 - 简要描述讨论主题

- 来源: 当前对话上下文 - 讨论主题摘要
- 创建: wiki/path/to/page.md
- 更新: wiki/path/to/page.md
- 更新: referenced_by, index.md
```

### Query 日志格式

```markdown
## [YYYY-MM-DD] query | "用户问题摘要"

- 读取: overview/auth.md（如适用）
- 读取: wiki/path/to/page.md
- 回答: 基于 wiki 内容
```

### Lint 日志格式

```markdown
## [YYYY-MM-DD] lint

- 扫描: N 个页面
- 更新 referenced_by: M 个页面
- 孤立页面: K 个（列出）
- 建议: 补充 N 个交叉引用
- 执行更新: 是/否
```

### 追加规则

- **只追加，不修改历史条目**
- 新条目添加在文件末尾
- 日期格式统一为 `YYYY-MM-DD`
- 每次操作一个条目

### 完整示例

```markdown
# Wiki Activity Log

## [2026-04-13] ingest | ARCHITECTURE.md

- 来源: 文件/代码 - ARCHITECTURE.md (1233 行)
- 创建: sources/architecture.md
- 创建: overview/authentication.md
- 创建: concepts/agent-decision-loop.md
- 创建: concepts/event-workflow.md
- 更新: referenced_by, index.md

## [2026-04-13] query | "Agent 如何决定下一步？"

- 读取: concepts/agent-decision-loop.md
- 回答: 基于 Agent 决策循环和工作流引擎解释

## [2026-04-13] ingest | src/fs_explorer/agent.py

- 来源: 文件/代码 - src/fs_explorer/agent.py (直接引用，无需摘要)
- 更新: concepts/agent-decision-loop.md (补充工具注册细节)
- 更新: concepts/token-tracking.md
- 更新: referenced_by, index.md

## [2026-04-14] ingest | 对话 - 认证体系设计讨论

- 来源: 当前对话上下文 - 用户描述的 JWT 认证系统设计
- 创建: concepts/jwt-authentication.md
- 创建: entities/session.md
- 更新: referenced_by, index.md

## [2026-04-13] lint

- 扫描: 10 个页面
- 更新 referenced_by: 6 个页面
- 孤立页面: 无
- 未发现矛盾内容
```

---

## index.md - 全局内容索引

### 职责

index.md 是**内容导向的索引**，提供：
1. 所有页面的快速导航
2. 一行摘要帮助理解页面内容
3. 入关系反向索引（被谁引用）

### 格式

```markdown
# Wiki Index

## Overview

### [领域名称 概览](overview/auth.md)
- **摘要**: 一行描述
- **包含**: [概念 A](concepts/a.md), [概念 B](concepts/b.md)
- **被引用**: [综合分析 A](synthesis/a.md)

## Entities

### [实体名称](entities/xxx.md)
- **摘要**: 一行描述
- **被引用**: [概念 A](concepts/a.md), [概念 B](concepts/b.md)

## Procedures

### [流程名称](procedures/deploy.md)
- **摘要**: 一行描述
- **前置条件**: 条件 A, 条件 B
- **被引用**: [综合分析 A](synthesis/a.md)

## Concepts

### [概念名称](concepts/xxx.md)
- **摘要**: 一行描述
- **所属领域**: [领域概览](overview/auth.md)
- **被引用**: [综合分析 A](synthesis/a.md)

## Synthesis

### [分析标题](synthesis/xxx.md)
- **摘要**: 一行描述
- **来源**: [概念 A](concepts/a.md), [源文件 B](sources/b.md)

## Sources

### [Source: 文件名](sources/xxx.md)
- **摘要**: 一行描述
- **原路径**: `path/to/original/file`
- **被引用**: [概念 A](concepts/a.md)

---
*最后更新: YYYY-MM-DD*
```

### 索引规则

**1. 按类型分组**

页面按 overview/entity/procedure/concept/synthesis/source 分组排列。

**2. 每个条目包含**

- 页面标题（链接）
- 一行摘要
- 所属领域/包含概念（如适用）
- 被引用列表（referenced_by 的内容）

**3. 排序规则**

- 组内按字母顺序排列
- 或按创建时间倒序排列（保持一致即可）

**4. 更新规则**

- 创建新页面时：在对应组中添加条目
- 删除页面时：移除对应条目
- referenced_by 更新时：同步更新"被引用"列表
- 更新概览页时：同步更新所属领域/包含概念

### 完整示例

```markdown
# Wiki Index

## Overview

### [认证体系 概览](overview/authentication.md)
- **摘要**: 认证相关的整体设计和流程
- **包含**: [认证流程](concepts/authentication-flow.md), [Token 管理](concepts/token-management.md)
- **被引用**: [架构分析](synthesis/architecture-analysis.md)

## Entities

### [Session](entities/session.md)
- **摘要**: 用户会话实体，包含 Token 追踪和超时管理
- **被引用**: [Agent Decision Loop](concepts/agent-decision-loop.md), [Event Workflow](concepts/event-workflow.md)

### [User](entities/user.md)
- **摘要**: 系统用户实体
- **被引用**: [认证流程](concepts/authentication-flow.md)

## Procedures

### [部署](procedures/deploy.md)
- **摘要**: 从代码提交到生产环境发布的完整流程
- **前置条件**: 代码审查通过, 测试通过
- **被引用**: [架构分析](synthesis/architecture-analysis.md)

## Concepts

### [Agent Decision Loop](concepts/agent-decision-loop.md)
- **摘要**: LLM Agent 通过循环调用决定下一步操作
- **所属领域**: [Agent 架构 概览](overview/agent-architecture.md)
- **被引用**: [架构分析](synthesis/architecture-analysis.md)

### [Event Workflow](concepts/event-workflow.md)
- **摘要**: 基于 llama-index-workflows 的事件驱动编排
- **所属领域**: [Agent 架构 概览](overview/agent-architecture.md)
- **被引用**: [架构分析](synthesis/architecture-analysis.md)

## Synthesis

### [架构分析](synthesis/architecture-analysis.md)
- **摘要**: 整体三层架构分析
- **来源**: [Agent Decision Loop](concepts/agent-decision-loop.md), [Event Workflow](concepts/event-workflow.md), [ARCHITECTURE.md](sources/architecture.md)

## Sources

### [ARCHITECTURE.md](sources/architecture.md)
- **摘要**: 架构文档摘要，包含系统架构、核心组件、三阶段策略
- **原路径**: `ARCHITECTURE.md`
- **被引用**: [架构分析](synthesis/architecture-analysis.md)

---
*最后更新: 2026-04-13*
```

---

## 维护检查清单

### 每次 Ingest 后

- [ ] index.md 中添加了新页面条目
- [ ] index.md 更新了被引用列表
- [ ] 如有 overview 页面，更新了包含/所属领域
- [ ] 如有 procedure 页面，更新了前置条件/步骤
- [ ] log.md 追加了新条目
- [ ] 日期格式正确
- [ ] 新页面 references 已填写完整
- [ ] 新页面 referenced_by 已填写完整（根据 Ingest 规划）
- [ ] 现有页面 referenced_by 已修复（受本次 Ingest 影响的页面）
- [ ] index.md 的"被引用"列表与页面 referenced_by 一致

### 每次 Query 后

- [ ] log.md 追加了 query 条目

### 每次 Lint 后

- [ ] index.md 的"被引用"列表与页面 referenced_by 一致
- [ ] log.md 追加了 lint 条目