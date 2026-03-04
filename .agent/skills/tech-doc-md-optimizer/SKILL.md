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
- **Follow the template**: detailed “what each section contains” rules come from `references/技术文档.md` comments (`<!-- COMMENT: ... -->`), not from this file.
- **Final output only**: no analysis or meta text; avoid duplicated content; keep precise numbers unchanged.

## Maintenance

- Keep this `SKILL.md` And comments in `references/技术文档.md`in English; use Chinese only for literal examples/quoted text.
- Put detailed section rules in `references/技术文档.md` comments, not here.

## Workflow

1. **Read the template**: `references/技术文档.md` (section order, headings, and all `<!-- COMMENT: ... -->` requirements).
2. **Read the source doc** and extract facts into buckets: version history, 功能描述/场景、核心概念、使用步骤/配置、数据/接口、风险与参考链接等。
3. **Restructure to match template headings**:
   - Use the **same headings and order** as the template.
   - Map source content into the most appropriate section per template comments.
   - If a template section has no source info: keep the heading and add a short placeholder like “待补充/暂无内容”.
4. **Version table (`## 版本说明`)**:
   - Use the template table columns: `发布日期` `修改人` `版本号` `修改内容`.
   - If no version info exists: keep header and (optionally) one placeholder row; do not fake history.
5. **Rewrite for readability** (facts unchanged):
   - Prefer short paragraphs, bullet lists, and tables for structured info.
   - Add diagrams (e.g. mermaid) only when they can be derived from the source/template guidance; never invent steps/branches/states.
6. **If ambiguity blocks correctness**: ask targeted Chinese clarification questions before finalizing, using this pattern:
   - Quote the unclear sentence, list 2–3 interpretations, ask the user to confirm/correct.
7. **Emit the final markdown document** aligned to the template, ready to paste into a `.md` file.

## Checklist (Before Output)

- Structure and headings follow `references/技术文档.md`.
- No fabricated facts; no altered precise parameters.
- No duplicated sections/content; placeholders used where needed.
- Output is a single clean markdown document (no reasoning text).




