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
- **双向关系完整**：每个文档自包含完整的 references/referenced_by 关系，**创建时填写完整**，而非留空
- **三阶段确认**：所有创建/更新操作必须经过 规划→确认→执行 三阶段，确保知识质量
- **迭代循环**：确认阶段用户如有异议，必须回到规划阶段修正，循环直到用户确认无问题

## Wiki 目录结构

```
wiki/
├── index.md               # 全局内容索引
├── log.md                 # 活动日志（追加式）
├── overview/              # 领域总体视图（高层次全局概览）
├── sources/               # 大文件/重要文档摘要（可选）
├── entities/              # 领域核心实体
├── procedures/            # 流程/操作
├── concepts/              # 抽象理念/模式/原则
└── synthesis/             # 综合分析/对比报告
```

## 关键规则 - 必须遵守

1. **Ingest 必须遵循三阶段确认流程**：详见 [workflow-guide.md](references/workflow-guide.md)
   - **阶段 1 - 规划 [STOP]**：提取后必须向用户展示规划表，包含：
     - 待创建的页面列表（含提取理由）
     - 待更新的页面列表（含新增内容说明）
     - 页面关系图（双向 references/referenced_by）
     - 需要修复的现有页面 referenced_by 列表
     - **等待用户确认后才能进入阶段 2**
   - **阶段 2 - 确认 [STOP]**：用户审查规划并反馈
     - **如果用户有异议**：回到阶段 1，修正规划，重新提交确认（迭代循环）
     - **如果用户确认无问题**：进入阶段 3 执行
   - **阶段 3 - 执行**：用户确认后执行
     - 创建/更新页面，**front matter 中同时填写完整的 references 和 referenced_by**
     - 更新受影响的现有页面的 referenced_by（修复已有页面的关系不一致）
     - 更新 index.md 和追加 log.md
   - **禁止行为**：
     - 禁止：不提供规划表就请求用户确认
     - 禁止：未展示阶段 1 就直接创建/更新页面
     - 禁止：用户未明确确认就继续执行
     - 禁止：创建页面时 referenced_by 留空
     - 禁止：阶段 2 用户有异议后不回到阶段 1 修正
2. **wiki 更新仅由用户明确指令触发**：LLM 不得自动更新 wiki
3. **关系完整性**：**创建页面时必须同时填写 references 和 referenced_by**，不允许"创建时留空后续填充"的模式
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
- 各类型页面模板（所有模板的 referenced_by 必须在创建时填写完整）
- references/referenced_by 双向关系维护规则
- 文件大小控制

## 日志和索引

详见 [log-index-guide.md](references/log-index-guide.md)，包含：
- log.md 格式规范
- index.md 格式规范
- 维护检查清单（含 referenced_by 修复步骤）