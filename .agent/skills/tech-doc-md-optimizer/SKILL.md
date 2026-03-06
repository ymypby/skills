---
name: tech-doc-md-optimizer
description: Optimizes existing Chinese technical markdown documents to follow a standard "技术文档.md" template. Use when improving, rewriting, or standardizing markdown technology documents, especially when the user mentions "技术文档.md" or asks to align docs to that template.
---

# Tech Doc Markdown Optimizer

## Goal

Rewrite an **existing Chinese technical markdown document** into the standard structure defined by `references/技术文档.md`, improving clarity and consistency **without changing any real technical facts**. Output must be a **single replacement-ready** `.md` document in the **source language** (usually Chinese).

## Use When (Triggers)

- User mentions `技术文档.md` / `技术文档模版` / “按技术文档模板整理”
- User asks to standardize / clean up / rewrite an existing technical `.md`
- Doc is messy, inconsistent, low readability, or needs batch normalization

## Non-Negotiables

- **No invented facts**: never fabricate features/APIs/constraints/metrics/version records.
- **Preserve meaning & terms**: keep original names for modules/APIs/fields/envs; only normalize if the source is clearly inconsistent.
- **Keep language**: do not translate unless explicitly asked.
- **Readable Chinese**: write in plain, concise Chinese for junior-to-mid engineers (unless the source language differs).
- **Follow the template**: detailed "what each section contains" rules come from `references/技术文档.md` comments (`<!-- COMMENT: ... -->`), not from this file.
- **Final output only**: no analysis or meta text; avoid duplicated content; keep precise numbers unchanged.
- **Source code priority**: When user provides source code directory, trust source code over documentation when there are discrepancies.
- **Human-first clarification**: When encountering ambiguous, unclear, or conflicting concepts/terms/logic, proactively ask the user for clarification before proceeding. Examples:
  - Same concept/term described inconsistently across chapters (e.g., "Concept X in Chapter 1 vs Chapter 2")
  - Conflicting logic or flow descriptions
  - Configuration/parameter defined differently in multiple places
  - Technical facts that are vague or cannot be inferred from context
  - Ask specific questions like: "xx 概念在章节 1 中说的是 A，在章节 2 中说的是 B，请明确该概念的定义？"

## Source Code Integration (When User Provides Source Directory or Markdown Archive)

This skill supports optional source code analysis when the user provides a source code directory or a markdown file containing archived source code. The source code integration is conditional:

**If user provides source code directory:**
- Execute source code analysis phase (Phase 2.5)
- Read relevant source files to understand unclear code
- Trust source code over documentation when there are discrepancies
- Discover additional features from source code and add to appropriate sections
- **Supplement code examples**: When the source document describes code processing logic or implementation approaches but lacks concrete code examples, proactively read source files to find and add corresponding code snippets. Code examples take priority over text descriptions for clarity.

**If user provides a markdown file containing archived source code (e.g., Repomix output):**
- Detect Repomix markdown archive format and similar tools:
  - Repomix header: File starts with `# Repomix Output` or similar tool headers
  - Repomix file markers: `## File: path/to/file.ext` followed by code block
  - Generic markers: "代码文件为 xx.md" / "文件：xx.md" / "File: xx.md"
  - Code blocks preceded by file path comments (e.g., `// src/main/java/xxx/Config.java`)
  - Markdown headers indicating file paths (e.g., `### src/main/java/xxx/Config.java`)
- Parse and extract individual file contents from the markdown archive:
  - For Repomix format: Extract file path from `## File:` headers, extract code from following code block
  - For generic format: Extract file path from markers, extract code from following code block
- Build an in-memory file structure representation for analysis:
  - Map file paths to code contents
  - Preserve directory structure information for context
- Execute source code analysis phase (Phase 2.5) using the extracted file structure

**If user does NOT provide source code directory or markdown archive:**
- Skip source code analysis phase entirely
- Proceed with document optimization based solely on the source document

## Maintenance

### File Responsibilities

**`references/技术文档.md`** - Template Definition
- Defines the complete chapter structure (section order, headings, hierarchy)
- Specifies what content belongs in each section
- Describes formatting rules (tables, code blocks, diagrams, etc.)
- Contains all `<!-- COMMENT: ... -->` annotations that explain section requirements
- Holds example content that illustrates the expected format (to be replaced with real content)

**`SKILL.md`** - Alignment Instructions
- Describes HOW to transform a source document into the template structure
- Defines the workflow for extracting, mapping, and reorganizing content
- Specifies rules for preserving facts while improving readability
- Provides guidance on handling edge cases (missing info, ambiguities, etc.)

### Maintenance Rules

- Keep this `SKILL.md` and comments in `references/技术文档.md` in English; use Chinese only for literal examples/quoted text.
- When template structure changes: update `references/技术文档.md` first, then adjust alignment workflow in `SKILL.md` if needed.
- When alignment logic changes: update only `SKILL.md` without modifying the template.

## Workflow

### Phase 1: Template Analysis

1. **Read the template structure** from `references/技术文档.md`:
   - Extract the **fixed section order** (must follow exactly):
     1. `## 目录` - Table of contents (auto-generated with markdown anchor links)
     2. `## 版本说明` - Version history table
     3. `## 组件概述` - System/module purpose and scenarios (what & why)
     4. `## 核心概念` - Domain-specific key concepts
     5. `## 使用说明` - Usage guide (with subsections: 前置条件 + 功能特性)
     6. `## 参考` - Reference materials and links
   - Parse all `<!-- COMMENT: ... -->` annotations to understand:
     - What content each section should contain
     - Formatting requirements (tables, code blocks, diagrams)
     - Special rules (e.g., configuration extraction, code block requirements)
     - Content boundary rules (prerequisites vs feature configs)
     - Complex flow criteria for mermaid diagrams
     - Table of contents generation rules

### Phase 2: Source Document Analysis

2. **Read and analyze the source document**:
   - Extract factual information into categorized buckets:
     - Version history (dates, authors, version numbers, change summaries)
     - System/module descriptions (purpose, problems solved, scenarios)
     - Core concepts (domain-specific terms, internal modules, states)
     - Usage instructions (prerequisites, configuration, steps, APIs)
     - Data structures (tables, interfaces, data models)
     - References (diagrams, wiki links, external docs)
   - Identify all code snippets and configuration blocks
   - Note any diagrams or visual content
   - Check if user has provided a source code directory for additional analysis

### Phase 2.5: Source Code Analysis (Conditional)

**This phase is ONLY executed when the user provides a source code directory OR a markdown file containing archived source code. If no source code is provided, skip this phase and proceed with Phase 3.**

3. **Detect source code provision method**:
   - **Directory mode**: User provides a source code directory path
   - **Markdown archive mode** (e.g., Repomix output): User provides a markdown file containing embedded source code with file path markers:
     - **Repomix format**:
       - Header: `# Repomix Output` or similar at file start
       - File markers: `## File: path/to/file.ext` followed by code block
     - **Generic format**:
       - Explicit markers: "代码文件为 xx.md" / "文件：xx.md" / "File: xx.md"
       - Code blocks with file path comments (e.g., `// src/main/java/xxx/Config.java`)
       - Markdown headers indicating file paths (e.g., `### src/main/java/xxx/Config.java`)
   - **If markdown archive mode detected**: 
     - Parse and extract individual file contents
     - For Repomix: Extract file path from `## File:` headers, code from following code block
     - For generic: Extract file path from markers, code from following code block
     - Build in-memory file structure mapping file paths to code contents
     - Preserve directory structure information for context understanding

4. **Scan and analyze source code** (when source directory or markdown archive is provided):
   - **Exclude non-source directories/files** (directory mode only): Skip the following as they contain test code, build artifacts, or other non-source files:
     - `test/`, `tests/`, `*test*/` (test code directories)
     - `target/`, `build/`, `dist/`, `out/`, `bin/` (build output directories)
     - `.git/`, `.idea/`, `.vscode/` (IDE/tool configuration directories)
     - `node_modules/`, `vendor/` (dependency directories)
   - Identify key code files:
     - Configuration classes (e.g., `*Config.java`, `*Properties.java`)
     - API controllers (e.g., `*Controller.java`, `*Api.java`)
     - Service classes (e.g., `*Service.java`)
     - Model/Entity classes (e.g., `*Model.java`, `*Entity.java`)
     - Annotation-based configurations
   - Extract information from code:
     - Feature definitions and capabilities
     - Configuration options and defaults
     - API endpoints and parameters
     - Data structures and relationships
   - Identify discrepancies between documentation and code:
     - **Trust source code as the source of truth**
     - Note any features in code but not in documentation
     - Note any configuration differences
   - Discover additional features/scenarios not mentioned in the source document
   - **Supplement code examples for text descriptions**:
     - Identify code-related descriptions in the source document that lack concrete code examples (e.g., "通过配置类初始化"、"使用注解启用功能"、"调用 XX 方法处理")
     - Search source code for matching implementations based on keywords, class names, method names, or logic descriptions
     - Extract relevant code snippets (classes, methods, annotations, configurations)
     - Add extracted code as properly-formatted code blocks with appropriate language hints (java, python, javascript, etc.)
     - Place code examples adjacent to or replacing the text descriptions for better clarity
     - Prefer code examples over lengthy text descriptions when both are available

### Phase 3: Content Mapping

3. **Map source content to template sections**:
   - For each template section, find matching content from source buckets
   - Apply template COMMENT rules to determine correct placement
   - Handle multiple implementation approaches:
     - When a feature has multiple implementation methods (e.g., XML vs. Java config)
     - Use distinct sub-headers like "方式一：xxx 方式", "方式二：xxx 方式"
   - For content that doesn't fit existing sections:
     - Create new sections only if template allows extension
     - Otherwise, place in the most appropriate existing section

4. **Handle code-discovered content** (if Phase 2.5 was executed):
   - Merge features/configurations discovered from source code with source document content
   - For new features discovered from code but not in documentation:
     - Add to appropriate template sections (e.g., new feature under "功能特性")
     - Mark as "新增" or note that it was discovered from source code
   - When documentation and code have discrepancies:
     - **Use code as the source of truth**
     - Update the documentation to match the code
     - Note the correction if necessary

### Phase 4: Structure Transformation

4. **Restructure to match template headings**:
   - Use the **same headings and order** as the template
   - Keep section hierarchy consistent (## for main sections, ### for subsections)
   - If a template section has no source info:
     - Keep the heading
     - Add placeholder: "待补充" or "暂无内容"
   - Remove any source sections that don't map to template

5. **Transform version history** (`## 版本说明`):
   - Use the template table format: `| 发布日期 | 修改人 | 版本号 | 修改内容 |`
   - Extract and format any version info from source
   - If no version info exists: keep header with placeholder row only

### Phase 5: Content Rewriting

6. **Rewrite for readability** (preserving all facts):
   - Convert long paragraphs to bullet lists or tables where appropriate
   - Ensure configuration content is in proper code blocks with language hints
   - Ensure code snippets have appropriate language identifiers
   - Use short, clear sentences in Chinese
   - Maintain consistent terminology throughout

7. **Handle special formatting** per template rules:
   - **Configuration files**: Always use code blocks with syntax highlighting (yaml, json, properties, xml)
   - **Code snippets**: Always use code blocks with language identifier (java, python, sql, javascript)
   - **Diagrams**: Use mermaid syntax. Create diagrams proactively when:
     - Source document already contains a flowchart/diagram (convert to mermaid)
     - A **complex flow** is identified with ANY of these characteristics:
       - Multi-step sequence: 3 or more sequential steps
       - Multi-party interaction: 2 or more systems/roles interacting
       - Conditional branches: Contains decision logic (if/else, success/failure paths)
       - Loops/retries: Contains iterative execution or retry mechanisms
       - State transitions: Involves state changes of objects/orders/tasks
   - **Content boundaries**:
     - Global/shared configurations → `### 一、前置条件`
     - Feature-specific configurations → `### 二、功能特性` (under each feature)
   - **Example content handling**:
     - When source has no corresponding content for a template section:
       - Remove template examples
       - Use placeholder: "待补充"

### Phase 6: Validation

8. **Proactive clarification for ambiguities** (Human-first principle):
   - When encountering any of the following scenarios, STOP and ask the user for clarification before proceeding:
     - **Inconsistent concept/term definitions**: Same concept/term described differently across chapters (e.g., "X 概念在章节 1 中定义为 A，在章节 2 中定义为 B，请明确该概念的正确定义？")
     - **Conflicting logic or flows**: Steps or logic that contradict each other in different parts of the document
     - **Configuration/parameter conflicts**: Same configuration key or parameter defined with different values/types in multiple places
     - **Vague technical facts**: Technical descriptions that are too vague to infer concrete implementation details
     - **Missing critical information**: Key information required for correctness is absent and cannot be reasonably inferred
   - **Question format**: When asking for clarification:
     - Quote the specific unclear or conflicting content from the source document
     - Point out the exact contradiction or ambiguity (e.g., "章节 1 说...，章节 2 说...")
     - List 2-3 possible interpretations or resolutions
     - Ask a specific question like: "xx 概念在章节 1 中说的是 A，在章节 2 中说的是 B，请明确该概念的定义？"
     - Wait for user confirmation before finalizing the ambiguous content

9. **Final validation checklist**:
   - Structure and headings match `references/技术文档.md`
   - All `<!-- COMMENT: ... -->` requirements are satisfied
   - No fabricated facts or altered parameters
   - No duplicated sections or content
   - Placeholders used where source info was missing
   - All code/config in proper fenced blocks

### Phase 7: Table of Contents Generation

10. **Generate Table of Contents** (after document structure is complete):
    - Scan all headings and create 3-level TOC:
      - **## level** (main sections): No indent
        - Format: `- [标题](#标题)`
      - **### level** (subsections): 2-space indent
        - Format: `  - [一、前置条件](#一前置条件)`
      - **#### level** (feature items): 4-space indent
        - Format: `    - [1、日志脱敏](#1 日志脱敏)`
    - Include ALL #### level feature items under both "前置条件" and "功能特性"
    - Place the generated TOC in the `## 目录` section at the beginning

### Phase 8: Output

11. **Emit the final markdown document**:
    - Single clean markdown document ready to paste
    - No reasoning text or meta-commentary
    - Source language preserved (Chinese unless specified otherwise)
    - TOC section included at the beginning with clickable anchor links

## Checklist (Before Output)

- Structure and headings follow `references/技术文档.md`.
- Section order is correct (目录 → 版本说明 → 组件概述 → 核心概念 → 使用说明 → 参考).
- Table of Contents generated with clickable markdown anchor links.
- TOC has 3 levels of depth:
  - ## level sections: No indent
  - ### level subsections: 2-space indent
  - #### level feature items: 4-space indent (under both 前置条件 and 功能特性)
- All #### level feature items included (e.g., "1、依赖引入", "1、日志脱敏")
- No fabricated facts; no altered precise parameters.
- No duplicated sections/content; placeholders used where needed.
- Output is a single clean markdown document (no reasoning text).




