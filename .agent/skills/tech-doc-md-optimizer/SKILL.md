---
name: tech-doc-md-optimizer
description: Optimizes existing Chinese technical markdown documents to follow a standard "技术文档.md" template. Use when improving, rewriting, or standardizing markdown technology documents, especially when the user mentions "技术文档.md" or asks to align docs to that template.
---

# Tech Doc Markdown Optimizer

## Goal

Rewrite an existing Chinese technical markdown document into the structure defined by `references/技术文档.md`, improving clarity without changing technical facts. Output: single replacement-ready `.md` in source language.

## Triggers

- User mentions `技术文档.md` / `技术文档模版` / "按技术文档模板整理"
- User asks to standardize / clean up / rewrite a technical `.md`

## Non-Negotiables

- **No invented facts**: Never fabricate features/APIs/constraints/metrics.
- **Preserve terms**: Keep original names for modules/APIs/fields.
- **Follow template**: Section rules come from `references/技术文档.md` comments.
- **Final output only**: No analysis or meta text.

## Workflow

### Phase 1: Analyze & Extract

1. **Read template** from `references/技术文档.md`:
   - Section order: 目录 → 版本说明 → 组件概述 → 核心概念 → 使用说明 → 参考
   - Parse `<!-- COMMENT: ... -->` for content rules

2. **Extract source facts** into buckets:
   - Version history, system description, core concepts
   - Usage instructions (prerequisites, features, configs)
   - References, diagrams

### Phase 2: Transform & Rewrite

3. **Restructure** to template headings:
   - Use same headings and order
   - No source info → keep heading, add "待补充"
   - Map content per template COMMENT rules

4. **Handle boundaries**:
   - Global configs → `### 一、前置条件`
   - Feature-specific configs → `### 二、功能特性`
   - Multiple approaches → "方式一/方式二"

5. **Format**:
   - Config/code → fenced blocks with language hints
   - Long paragraphs → bullet lists or tables
   - Consistent terminology

6. **Diagrams** (mermaid): Create when:
   - Source has flowchart/diagram (convert)
   - Complex flow: ≥3 steps, ≥2 parties, branches, loops, state transitions

### Phase 3: TOC & Output

7. **Generate TOC** (3 levels):
   - `##` level: no indent
   - `###` level: 2-space indent
   - `####` level: 4-space indent (feature items)
   - Place in `## 目录` section

8. **Output** final document:
   - Clean markdown, no meta text
   - TOC with clickable anchors

## Checklist

- [ ] Section order correct (目录 → 版本说明 → 组件概述 → 核心概念 → 使用说明 → 参考)
- [ ] TOC has 3 levels with proper indentation
- [ ] All #### feature items included
- [ ] No fabricated facts
- [ ] All code/config in fenced blocks
- [ ] Placeholders used where source info missing