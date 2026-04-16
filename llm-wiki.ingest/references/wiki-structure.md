# Wiki 结构模板

本文档定义 Wiki 各类型页面的格式和内容模板。

## Front Matter 元数据说明

每个 wiki 页面必须在顶部包含 YAML front matter，字段说明如下：

| 字段        | 类型   | 必填 | 说明                                                                 |
| ----------- | ------ | ---- | -------------------------------------------------------------------- |
| `title`     | string | 是   | 页面标题，用于显示和索引                                             |
| `type`      | string | 是   | 页面类型：`overview`、`entity`、`procedure`、`concept`、`synthesis`、`source` |
| `created`   | string | 是   | 页面创建日期，格式 `YYYY-MM-DD`                                      |
| `updated`   | string | 是   | 最后更新日期，格式 `YYYY-MM-DD`，初始创建时与 `created` 相同         |
| `relations` | array  | 是   | 关联关系数组，表示与本页面有关联的其他页面，每个元素包含 `path`（相对路径）和 `desc`（关系描述，≤50字）；如果不存在关联关系，值为 `[]` |

### relations 格式示例

```yaml
relations:
  - path: "../entities/user.md"
    desc: "本文描述了用户实体的认证流程"
  - path: "../concepts/authentication.md"
    desc: "本文使用了认证模式进行安全验证"
  - path: "../overview/auth.md"
    desc: "概览页面引用了本文作为核心概念"
```

**重要规则**：
- `relations` 字段记录与本页面有关联的所有其他 wiki 页面
- 关联类型包括：直接引用、被引用、内容相关
- **创建页面时必须根据 Ingest 规划填写完整的 relations**，禁止"创建时留空后续填充"
- 如果关联关系发生变化，必须同时更新双方页面的 relations

## 页面类型定义

### Overview（领域总体视图）

**类型特征**：

- 高层次全局概览，提供领域/模块的导航入口
- 整合多个相关概念和实体，展示它们之间的关系
- 不包含具体实现细节，仅作为目录和背景知识

**禁止内容**：

- 禁止：深入描述单一概念的细节（应归入 concept 页面）
- 禁止：包含具体实现步骤或操作流程
- 禁止：只有 1-2 个概念的简单主题强行创建 overview

**模板**：

```yaml
---
title: "领域名称 概览"
type: overview
created: "YYYY-MM-DD"
updated: "YYYY-MM-DD"
relations:
  - path: "../concepts/xxx.md"
    desc: "概览包含此核心概念（≤50字）"
  - path: "../entities/yyy.md"
    desc: "概览涉及此核心实体（≤50字）"
---

# Overview: 领域名称 概览

## 摘要
一段话概括该领域的核心内容和目标。

## 包含的概念
- [概念 A](../concepts/a.md) - 简要说明
- [概念 B](../concepts/b.md) - 简要说明

## 相关的实体
- [实体 X](../entities/x.md) - 简要说明

## 相关的流程
- [流程 P](../procedures/p.md) - 简要说明

## 架构/流程概览
用简单的图示或步骤描述整体架构或主要流程。

## 相关概览
- [其他领域](other.md) - 关系说明

## 来源

> 本文档内容提取自：
> - [ARCHITECTURE.md](../../ARCHITECTURE.md) - 相关章节
```

### Entity（领域实体）

**类型特征**：

- 描述领域中的核心"事物"：业务概念、角色、系统、组件、数据模型等
- 有明确边界的独立实体，可识别且可命名

**注意**：

- Entity 不限于代码相关，可以是任何领域中可识别的独立事物
- **Entity 可以独立存在，不需要强制关联 concept**

**禁止内容**：

- 禁止：为单个代码类创建 entity 页面（除非该跨多个文件/模块有业务意义）

**模板**：

```yaml
---
title: "实体名称"
type: entity
created: "YYYY-MM-DD"
updated: "YYYY-MM-DD"
relations:
  # 如果有关联的实体或概念，在此声明
  - path: "../entities/yyy.md"
    desc: "该实体与 yyy 实体协作"
  - path: "../concepts/xxx.md"
    desc: "该实体使用 xxx 模式"
  # 根据 Ingest 规划填写，列出与本页面有关联的所有页面
---

# Entity: 实体名称

## 摘要
一段话概括该实体是什么、在领域中扮演什么角色。

## 职责/角色
- 职责 1
- 职责 2

## 相关代码/文件
- `path/to/file1.py` - 说明
- `path/to/file2.py` - 说明

## 核心属性/特征
- `property1`: 描述
- `property2`: 描述

## 与其他实体的关系
- 与 [实体 B](../entities/b.md) 的关系说明

## 来源

> 本文档内容提取自：
> - `path/to/source/file.py` - 相关代码实现
```

### Procedure（流程/操作）

**类型特征**：

- 描述"通过做什么完成了什么"：流程、步骤、结果、操作手册
- 描述具体的、可执行的流程步骤
- 关注"怎么做"和"结果是什么"

**禁止内容**：

- 禁止：将抽象理念或设计模式归类为 procedure（应归入 concept）
- 禁止：将静态实体或业务概念归类为 procedure（应归入 entity）
- 禁止：包含过于琐碎的实现细节（如单行代码变更）

**模板**：

```yaml
---
title: "流程名称"
type: procedure
created: "YYYY-MM-DD"
updated: "YYYY-MM-DD"
relations:
  - path: "../entities/xxx.md"
    desc: "流程操作此实体（≤50字）"
  - path: "../concepts/yyy.md"
    desc: "流程使用此概念模式（≤50字）"
  - path: "../overview/zzz.md"
    desc: "概览页面引用了本文作为相关流程"
---

# Procedure: 流程名称

## 摘要
一段话概括这个流程的目标和结果。

## 前置条件
- 条件 1
- 条件 2

## 步骤

### 步骤 1: 步骤名称
详细说明...

### 步骤 2: 步骤名称
详细说明...

## 结果/输出
- 结果 1
- 结果 2

## 相关实体
- [实体名称](../entities/xxx.md) - 关系说明

## 相关概念
- [概念名称](../concepts/yyy.md) - 关系说明

## 来源

> 本文档内容提取自：
> - `path/to/source/file.py` - 相关代码实现
```

### Concept（抽象理念/模式）

**类型特征**：

- 描述抽象的理念、模式、原则、设计思想
- 关注"为什么"和"是什么"，而非"怎么做"

**核心原则：一个概念页面 = 一个概念**

- **禁止在一个概念页面中汇总多个概念**
- Concept 是可选的，不要为了关联而强行创建空壳 concept
- 如果需要汇总多个概念，应该创建 overview 页面，而非 concept 页面
- 模板中的"核心理念"和"相关模式"是**同一个概念的不同侧面**，不是多个独立概念

**禁止内容**：

- 禁止：在一个页面中汇总多个概念（如需汇总，应创建 overview）
- 禁止：为关联而创建空壳概念（如无通用抽象理念则不创建）

**模板**：

```yaml
---
title: "概念名称"  # 一个页面只描述一个概念
type: concept
created: "YYYY-MM-DD"
updated: "YYYY-MM-DD"
relations:
  # 如果有关联的实体或其他概念，在此声明
  - path: "../entities/xxx.md"
    desc: "该概念被 xxx 实体使用"
  - path: "../overview/auth.md"
    desc: "概览页面包含本文作为核心概念"
---

# Concept: 概念名称

## 摘要
一段话概括该概念的核心思想和抽象本质。

## 核心理念
> **注意**：此章节描述的是该概念的核心理念，不是多个独立概念。
> 只描述与当前概念直接相关的理念。

- 理念描述（只描述这一个概念的核心理念）

## 相关模式
> **注意**：此章节描述的是该概念相关的设计模式或原则，不是多个独立概念。
> 只描述与当前概念直接相关的模式。

- 模式/原则描述（只描述这一个概念相关的模式）

## 应用场景
- 场景 1：说明
- 场景 2：说明

## 来源

> 本文档内容提取自：
> - `path/to/source/file.py` - 相关代码实现
```

### Synthesis（综合分析）

**类型特征**：

- 对多个源文件/概念的深度分析、对比报告、总结
- 综合分析结果，而非单一概念的描述
- 通常是用户明确要求或 LLM 发现有价值的综合分析

**禁止内容**：

- 禁止：将单一概念的描述归类为 synthesis
- 禁止：包含未经分析的原始信息堆砌

**模板**：

```yaml
---
title: "分析标题"
type: synthesis
created: "YYYY-MM-DD"
updated: "YYYY-MM-DD"
relations:
  - path: "../concepts/xxx.md"
    desc: "分析涉及此概念（≤50字）"
  - path: "../sources/yyy.md"
    desc: "分析引用此源文件摘要（≤50字）"
  - path: "../overview/zzz.md"
    desc: "概览页面引用了本文的分析结论"
---

# Synthesis: 分析标题

## 摘要
一段话概括分析的核心发现。

## 分析内容

### 主题 1
详细说明...

### 主题 2
详细说明...

## 对比/发现
- 发现 1
- 发现 2

## 来源
- [概念/文件 1](../concepts/xxx.md)
- [源文件 2](../sources/yyy.md)
```

### Source（源文件摘要）

**类型特征**：

- 大文件（>5000 行或 100 页）或重要非代码文档的摘要
- 作为原始文件的索引入口，而非替代原始文件
- 通常由文件来源的 Ingest 操作创建

**禁止内容**：

- 禁止：为小型文件创建 source 摘要（直接引用即可）
- 禁止：在 source 中包含过度详细的原文引用（应保持摘要性质）

**模板**：

```yaml
---
title: "Source: 文件名"
type: source
created: "YYYY-MM-DD"
updated: "YYYY-MM-DD"
original_path: "path/to/original/file"
relations:
  # 根据 Ingest 规划填写，列出哪些页面引用了此源文件
  - path: "../overview/auth.md"
    desc: "概览页面引用了本文作为信息来源"
  - path: "../concepts/xxx.md"
    desc: "概念页面引用了本文的内容"
---

# Source: 文件名

## 基本信息
- **路径**: `path/to/original/file`
- **行数/页数**: 约 XXX
- **首次摄取**: YYYY-MM-DD

## 关键内容提取
- 关键点 1
- 关键点 2
- 关键点 3

## 被引用页面
- [概念/实体名称](../path/to/page.md)
```

## 页面命名规范

**重要**：文件名不需要包含类型标识（如 `-concept`、`-entity`、`-procedure`），因为文件已经在对应目录中。

### 英文命名规则

- **必须小写**
- **单词间用 `-` 隔开**（kebab-case）
- 示例：`jwt-authentication.md`、`payment-service.md`、`agent-decision-loop.md`


| 类型       | 命名规则     | 推荐                                | 不推荐                          |
| ---------- | ------------ | ----------------------------------- | ------------------------------- |
| overview   | 领域名称     | `authentication.md`                 | `authentication-overview.md`   |
| entity     | 名词         | `user.md`, `payment-service.md`     | `user-entity.md`               |
| procedure  | 流程名称     | `deploy.md`, `release.md`           | `deploy-procedure.md`          |
| concept    | 抽象名词短语 | `authentication.md`, `caching.md`   | `authentication-concept.md`    |
| synthesis  | 描述性标题   | `architecture-comparison.md`        | `architecture-synthesis.md`    |
| source     | 原文件名转换 | `architecture.md`                   | `architecture-source.md`       |


### 来源引用

当页面引用了源文档或对话上下文时，在正文中添加来源说明：

**文件/代码来源**：

```markdown
## 来源

> 本文档内容提取自：
> - [ARCHITECTURE.md](../../ARCHITECTURE.md) - 第 3 章：系统架构
> - [src/agent.py](../../src/fs_explorer/agent.py) - Agent 实现
```

**对话上下文来源**：

```markdown
## 来源

> 本文档内容提取自：
> - 当前对话上下文 - 用户描述的认证体系设计（2026-04-14）
> - 当前对话上下文 - 关于 JWT 认证流程的讨论（2026-04-14）
```

**注意**：来源引用放在正文的"来源"段落中，不需要在 front matter 中添加 source_paths 字段。这样在正文中会有更好的上下文来理解当前引用是做什么的。

## 文件大小控制

- **建议**每个文件不超过 **3000 字符**，以保持可读性和上下文窗口友好