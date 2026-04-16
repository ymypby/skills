---
name: tech-doc-md-optimizer
description: Optimizes existing Chinese technical markdown documents to follow the standard "技术文档.md" template. Use when improving, rewriting, or standardizing markdown technology documents, especially when the user mentions "技术文档.md", "技术文档模版", or asks to align docs to that template. Make sure to use this skill whenever working with technical documentation that needs restructuring, standardization, or source code integration.
---

# Tech Doc Markdown Optimizer

## Goal

Transform an existing Chinese technical markdown document into the standard structure defined by `references/技术文档.md`, improving clarity and consistency while preserving all technical facts. Output is a single clean markdown document in the source language.

**Critical Principle**: The output document must be **self-contained** - do NOT assume readers have access to source code. Every feature must include complete, copy-paste ready code and configuration examples.

## Core Principles

1. **No invented facts** - Never fabricate features, APIs, constraints, metrics, or version records
2. **Source code priority** - When user provides source code, trust it over documentation when there are discrepancies
3. **Preserve meaning** - Keep original names for modules, APIs, fields, environments; only normalize if clearly inconsistent
4. **Complete examples required** - ALWAYS provide complete, copy-paste ready code and configuration examples for every feature. Readers cannot access source code, so examples must be self-contained and usable.
5. **Human-first clarification** - Ask the user when encountering ambiguous, unclear, or conflicting concepts before proceeding

## Workflow

### Phase 1: Analyze

**Read the template** from `references/技术文档.md`:
- Fixed section order: 目录 → 版本说明 → 组件概述 → 核心概念 → 使用说明
- Parse `<!-- COMMENT: ... -->` annotations for section requirements
- Note formatting rules (tables, code blocks, mermaid diagrams)

**Analyze the source document**:
- Extract factual information into buckets: version history, system descriptions, concepts, usage instructions, data structures
- Identify code snippets and configuration blocks
- Check for missing prerequisites (dependencies, database, middleware, environment, config, external services)

**Parse source code** (if user provides markdown archive like Repomix output):
- Detect format: Repomix header (`# Repomix Output`), file markers (`## File:`), or generic markers
- Extract file paths and code contents
- Identify configuration classes, API controllers, services, models, annotations
- Discover features in code but not in documentation
- Note discrepancies between documentation and code

### Phase 2: Map

Map source content to template sections:
- Apply template COMMENT rules for correct placement
- Handle multiple implementation approaches with distinct sub-headers ("方式一：xxx 方式")
- Merge code-discovered features with source document content
- For new features from code: add to appropriate sections, mark as "新增"
- When documentation and code conflict: **use code as source of truth**

Content boundaries:
- Global/shared configurations → `### 一、前置条件`
- Feature-specific configurations → `### 二、功能特性`

### Phase 3: Transform

**Restructure** to match template headings:
- Same headings and order as template
- If a template section has no source info: keep heading, add "待补充" placeholder

**Transform version history** to table format: `| 发布日期 | 修改人 | 版本号 | 修改内容 |`

**Rewrite for readability**:
- Convert long paragraphs to bullet lists or tables
- Use code blocks with language hints for config (yaml, json, properties) and code (java, python, sql)
- Write in short, clear Chinese sentences
- Maintain consistent terminology

**Create mermaid diagrams** when:
- Source already contains a flowchart (convert to mermaid)
- Complex flow detected: 3+ sequential steps, 2+ systems interacting, conditional branches, loops/retries, state transitions

**Supplement examples** (CRITICAL - Readers cannot access source code):
- **For EVERY feature in "功能特性" section, MUST include:**
  1. **Configuration Example** - Complete config snippet in YAML/Properties/JSON format
  2. **Code Example** - Usage code snippet showing how to use the feature
  3. **API Example** (if applicable) - Request/Response format with concrete values
- **When source code IS provided**: Extract real examples from code
- **When source code is NOT provided**: Create reasonable examples based on:
  - Common patterns and conventions for similar frameworks
  - Standard API design practices (RESTful conventions)
  - Descriptive placeholder names (not "xxx", use "userId", "orderNo", etc.)
  - Add note if needed: "示例代码，需根据实际情况调整"
- **NEVER use "待补充" for examples** - always provide a complete, usable example
- Prefer complete, copy-paste ready examples over partial snippets

### Phase 4: Output

**Generate Table of Contents** with 3-level depth:
- ## level: No indent, format `- [标题](#标题)`
- ### level: 2-space indent, format `  - [一、前置条件](#一前置条件)`
- #### level: 4-space indent, format `    - [1、日志脱敏](#1 日志脱敏)`
- Include all #### level feature items under both "前置条件" and "功能特性"

**Final validation** (CRITICAL - Check examples):
- Structure matches `references/技术文档.md`
- No fabricated facts or altered parameters
- No duplicated content
- **EVERY feature has configuration example**
- **EVERY feature has code usage example**
- **EVERY API has request/response example**
- All code/config in proper fenced blocks with language hints

**Emit** the final markdown document:
- Single clean markdown, no reasoning text or meta-commentary
- TOC section included at the beginning with clickable anchor links

## Example Requirements (Detailed)

### Configuration Example Format
```yaml
# application.yml - Feature configuration
feature:
  enabled: true
  setting: value
  timeout: 30000
```

### Code Usage Example Format
```java
// Initialize and use the feature
FeatureService service = new FeatureService();
Result result = service.execute(param);
```

### API Example Format
```
POST /api/v1/feature/execute
Content-Type: application/json

{
  "param1": "value1",
  "param2": 123
}

Response:
{
  "code": 200,
  "data": { "result": "success" }
}
```

## Handling Ambiguities

When encountering these scenarios, **ask the user for clarification** before proceeding:
- Same concept/term defined differently across chapters
- Conflicting logic or flows in different parts of the document
- Same configuration key defined with different values/types
- Vague technical facts that cannot be inferred from context
- Missing critical information required for correctness

Ask specific questions like: "xx 概念在章节 1 中说的是 A，在章节 2 中说的是 B，请明确该概念的定义？"

## Maintenance

**`references/技术文档.md`** defines the template structure and section requirements.

**`SKILL.md`** describes how to transform source documents into the template structure.

When template structure changes: update `references/技术文档.md` first, then adjust `SKILL.md` if needed.
When alignment logic changes: update only `SKILL.md`.