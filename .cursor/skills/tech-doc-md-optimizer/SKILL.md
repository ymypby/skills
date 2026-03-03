---
name: tech-doc-md-optimizer
description: Optimizes existing Chinese technical markdown documents to follow a standard "技术文档.md" template. Use when improving, rewriting, or standardizing markdown technology documents, especially when the user mentions "技术文档.md" or asks to align docs to that template.
---

# Technical Documentation Template Optimization (Markdown)

## Purpose

This skill rewrites and improves **existing Chinese technical markdown documents** so that they follow a consistent `技术文档.md` template:

- Keeps all real technical facts from the source
- Normalizes structure to a standard template
- Improves clarity, readability, and maintainability
- Produces a clean markdown document that can directly replace the original

All **prompts and instructions in this skill are written in English**, but:

- Source documents will usually be Chinese
- The output document should keep the **original language** (normally Chinese), only improving structure and wording

## When to Use (Triggers)

Use this skill in these situations:

- The user mentions **“技术文档模版”, “技术文档模版.md”, “技术文档.md”** or similar
- The user asks to **standardize, clean up, or improve** an existing markdown technical document
- The user complains the document is **messy, unclear, inconsistent, or low quality**
- The user wants to **batch or repeatedly** normalize multiple markdown technical docs to the same structure

## Core Principles

1. **No invented facts**
   - You may rewrite sentences, rearrange sections, adjust the original document’s structure and sentence order based on the concrete context, and delete meaningless filler
   - You must NOT invent new features, APIs, constraints, version history records, metrics, or other technical facts

2. **Template alignment first, content polish second**
   - First, align the document’s structure to the `技术文档.md` template in `references/技术文档.md`
   - Then, improve clarity, readability, and consistency inside that structure

3. **Terminology consistency**
   - Preserve the original naming for components, services, APIs, fields, environments, etc.
   - Do not rename things unless the original document is clearly inconsistent and you can safely normalize

4. **Language preservation**
   - Even though the reference template uses **English** for sample content, the **output** should keep the language of the source (normally Chinese)
   - Do NOT translate the document unless explicitly requested

5. **Final output is a complete markdown document**
   - No analysis, no commentary, no skill instructions in the output
   - The final result must be a self-contained `.md` file that can replace the original

## Workflow (Step by Step)

### Step 1: Read the template and source document

1. Read the reference template file:
   - Path: `references/技术文档.md`
   - Treat it as the default shape of the technical document
   - Pay attention to **section order**, in-line comments in `<!-- COMMENT: ... -->`, and the concrete Chinese example content（例如通知组件、数据库 DDL、参考链接等）
2. Read the user’s source markdown technical document
   - Identify existing information about:
     - Version history / change log
     - Functional description
     - Context and background
     - Architecture or design
     - APIs / interfaces
     - Data models
     - Non-functional requirements, risks, deployment notes, etc.

### Step 2: Align the top-level structure

In the output document, the **structure must be fully aligned to the `references/技术文档.md` template and MUST NOT be modified**:

- Use **exactly the same set of headings（标题文案 + 层级）和顺序** as in `references/技术文档.md`
- Do **NOT** add, remove, rename, merge, split, or reorder any of the template’s sections（包括顶层章节与示例中的常见小节）
- 对于 `## 使用说明` 下的二级/三级小节结构、每个小节应承载的内容、以及“二、功能介绍”中每个小点必须是完整功能点等约束，**严格以模板文件中的注释（`<!-- COMMENT: ... -->`）和示例内容为准**

For each section:

- Map relevant content from the source document into the most appropriate section according to the comments and examples in `references/技术文档.md`
- If a section in the template has **no corresponding information** in the source:
  - **仍然保留该章节标题**，并使用一个明确的占位说明（例如“待补充”或类似语句），但不要虚构具体内容
  - 占位说明的写法应与模板注释中表达的“待补充/暂无内容”等意图保持一致

### Step 3: Build a proper version history table

Under `## 版本说明`:

- Use a **markdown table** consistent with the template in `references/技术文档.md`，with the following columns:
  - `发布日期`、`修改人`、`版本号`、`修改内容`
- Extract any available version/change information from the source document and map it into table rows
- If the source has **no clear version info**:
  - Do NOT fabricate real-looking version records
  - You may:
    - Keep the table header with no data rows, OR
    - Add a single placeholder row with clearly non-final values（例如在“修改内容”中填写“待补充”）

### Step 4: Rewrite and structure the content

While keeping all true technical information:

- **Normalize headings**
  - Use a consistent hierarchy (`#` for title, `##` for main sections, `###` for subsections, etc.)
- **Use lists and tables**
  - Convert long enumerations into bullet lists
  - Use tables for structured data (parameters, configuration, status codes, etc.)
- **Use visual representations when helpful**
  - Where appropriate, you may introduce diagrams or flow representations（例如顺序图、流程图、状态图，推荐使用 markdown/mermaid 语法）to clarify processes or interactions
  - Any table or diagram must strictly reflect facts already present or implied in the source document; do NOT invent new steps, branches, or states
- **Improve clarity**
  - Remove empty phrases (“this section briefly introduces…”)
  - Split very long sentences into shorter, clearer ones
  - Highlight key constraints, preconditions, and caveats with headings or list items

### Step 5: Ensure information completeness and safety

Before finalizing:

- Verify that all meaningful technical content from the source document is preserved
- Do not change numeric values, thresholds, time windows, quotas, or other precise parameters
- If something in the source is ambiguous or you do not fully understand it:
  - Do NOT guess or silently rewrite the content
  - Ask the user targeted clarification questions in Chinese before finalizing the document
  - When asking questions, follow a standardized pattern so the user can reply efficiently, for example:
    - 引用原文的关键语句或段落（使用引用块或内联引号），说明“不够清晰/存在多种理解方式”
    - 按列表给出 2–3 个你认为可能的理解方式，请用户在其中选择或补充
    - 明确告诉用户，你会在拿到答复后再更新对应的小节内容
  - 示例提问模版（可根据实际情况微调）：
    - “在当前技术文档中，关于『XXX』的描述不够清晰，可能存在多种理解方式。请确认该段的准确含义：1）……；2）……；或补充更详细的业务背景，我会据此完善文档。”

### Step 6: Produce the final markdown document

The final output should:

- Be a **single markdown document** with:
  - A `## 版本说明` section that contains a correctly formatted version history table
  - A `## 功能描述` section summarizing what the system/module does
  - A `## 使用说明` section explaining how to configure and use the component/system（包含前置条件与功能介绍等常见小节）
  - A `## 参考` section listing diagrams, internal wiki links, and external docs if such information exists in the source
- Contain **no** explanatory text about the transformation or your reasoning
- Be ready to paste directly into a `.md` file

## Summary Checklist

When using this skill, ensure:

1. **Structure aligned**: The document follows the `references/技术文档.md` template with at least `## 版本说明`、`## 功能描述`、`## 使用说明` 和（如有内容）`## 参考`。
2. **Content faithful**: No fabricated features, parameters, or version records; all important technical details from the source are preserved.
3. **Ready to use**: The final markdown output can be pasted directly into the target `.md` file and used as the official technical document.


