---
name: llm-wiki.ingest
description: 从文件/代码或当前对话上下文中提取知识，创建/更新 wiki 页面。遵循三阶段确认流程（规划→确认→执行），确保知识积累的可控性和质量。当用户需要建立知识库、整理文档、从对话中提取知识时使用此技能。
---
# LLM Wiki Ingest Skill

本技能指导 LLM **从多种来源摄取知识，增量构建持久的 Markdown Wiki**。

## 核心理念

- **知识积累**：不是每次问答重新检索，而是持续构建 wiki，知识随时间增长
- **LLM 自动维护**：用户负责提问和引导，LLM 负责整理、交叉引用、更新
- **灵活溯源**：Entity/Concept/Synthesis/Procedure/Overview 可直接基于原始文件，大文件才创建 sources/ 摘要
- **关系统一管理**：使用 `relations` 字段记录页面间关联关系，**创建时填写完整**，包括直接引用、被引用和内容相关等所有关联类型
- **三阶段确认**：所有创建/更新操作必须经过 规划→确认→执行 三阶段，确保知识质量
- **迭代循环**：确认阶段用户如有异议，必须回到规划阶段修正，循环直到用户确认无问题

## Wiki 目录结构

```
wiki/
├── index.md               # 全局内容索引
├── log.md                 # 活动日志（追加式）
├── schemas/               # 知识提取规则（Schema）目录
│   ├── index.md           # Schema 索引（模型按需加载）
│   └── [name].md          # 具体 Schema 文件
├── overview/              # 领域总体视图（高层次全局概览）
├── sources/               # 大文件/重要文档摘要（可选）
├── entities/              # 领域核心实体
├── procedures/            # 流程/操作
├── concepts/              # 抽象理念/模式/原则
└── synthesis/             # 综合分析/对比报告
```

## Schema（知识提取规则）

用户可以在 `wiki/schemas/` 目录中定义知识提取规则（Schema），用于控制模型从源内容中提取特定类型的知识。

### Schema 加载流程

在 Ingest 阶段 1（规划）开始前，执行以下步骤：

1. **检查 schemas/index.md**：读取 `wiki/schemas/index.md`，了解所有可用 Schema 的 description
2. **语义匹配**：根据用户的 Ingest 意图（用户描述、源内容性质），匹配 index.md 中 description 描述的场景和领域
3. **加载 Schema**：如果匹配到适用的 Schema，读取对应的 schema 文件，遵循其中的提取约束和偏好
4. **无 Schema 时**：如果 `wiki/schemas/` 目录不存在或 index.md 为空，使用默认提取规则（提取所有类型知识）

### Schema 匹配原则

- 如果用户明确指定 schema（如"使用 testing-procedure"），直接读取该 schema
- 如果用户描述了提取意图（如"从这段对话中提取测试流程"），根据语义匹配最接近的 description
- 如果源内容性质与某个 schema 的 description 高度吻合，自动选用

### 约束应用

加载的 Schema 会影响：
- **提取焦点**：只提取 schema 中指定的知识类型
- **排除范围**：过滤掉 schema 中排除的内容
- **页面类型偏好**：优先或禁止创建某些类型的 wiki 页面

## 关键规则 - 必须遵守

1. **Ingest 必须遵循三阶段确认流程**：详见 [workflow-guide.md](references/workflow-guide.md)
   - **阶段 1 - 规划 [STOP]**：提取后必须向用户展示规划表，包含：
     - 待创建的页面列表（含提取理由）
     - 待更新的页面列表（含新增内容说明）
     - 页面关系图（relations 关联关系）
     - 需要修复的现有页面 relations 列表
     - **等待用户确认后才能进入阶段 2**
   - **阶段 2 - 确认 [STOP]**：用户审查规划并反馈
     - **如果用户有异议**：回到阶段 1，修正规划，重新提交确认（迭代循环）
     - **如果用户确认无问题**：进入阶段 3 执行
   - **阶段 3 - 执行**：用户确认后执行
     - 创建/更新页面，**front matter 中填写完整的 relations**
     - 更新受影响的现有页面的 relations（修复已有页面的关系不一致）
     - 更新 index.md 和追加 log.md
   - **禁止行为**：
     - 禁止：不提供规划表就请求用户确认
     - 禁止：未展示阶段 1 就直接创建/更新页面
     - 禁止：用户未明确确认就继续执行
     - 禁止：创建页面时 relations 留空
     - 禁止：阶段 2 用户有异议后不回到阶段 1 修正
2. **wiki 更新仅由用户明确指令触发**：LLM 不得自动更新 wiki
3. **关系完整性**：**创建页面时必须填写完整的 relations**，不允许"创建时留空后续填充"的模式
4. **创建前必须查找现有页面**：在建议创建任何新页面之前，必须先查找 wiki 中是否已存在相同或相似主题的页面
   - 查找路径：从 `wiki/index.md` 开始 → 按分类目录逐一扫描 → 读取候选页面内容进行比对
   - 若找到覆盖同一主题的现有页面，优先建议"更新"而非"新建"
   - 禁止行为：未执行查找就直接建议创建新页面

## 知识来源

| 来源类型 | 说明 | 示例 |
|----------|------|------|
| **文件/代码** | Git 仓库中的源文件、PDF、Word 文档等 | `ARCHITECTURE.md`, `src/agent.py`, `data/report.pdf` |
| **当前对话上下文** | 用户与 LLM 的对话中讨论的概念、决策、发现 | 用户描述系统设计、讨论技术方案、分享业务理解 |

## Ingest 工作流程

详见 [workflow-guide.md](references/workflow-guide.md)，包含：
- 三阶段完整流程步骤
- 迭代循环逻辑
- 规划表/确认/执行模板
- 文件来源和对话来源示例

## 页面格式和关系维护

详见 [wiki-structure.md](references/wiki-structure.md)，包含：
- 各类型页面模板（所有模板的 relations 必须在创建时填写完整）
- `relations` 字段维护规则
- 文件大小控制

## 日志和索引

详见 [log-index-guide.md](references/log-index-guide.md)，包含：
- log.md 格式规范
- index.md 格式规范
- 维护检查清单（含 relations 修复步骤）
