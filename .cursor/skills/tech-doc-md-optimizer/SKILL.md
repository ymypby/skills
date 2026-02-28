---
name: tech-doc-md-optimizer
description: Optimizes existing Chinese technical markdown documents to follow a standard "技术文档.md" template. Use when improving, rewriting, or standardizing markdown 技术文档 documents, especially when the user mentions "技术文档模版.md" or asks to align docs to that template.
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
   - You may rewrite sentences, rearrange sections, and delete meaningless filler
   - You must NOT invent new features, APIs, constraints, version history records, metrics, or other technical facts

2. **Template alignment first, content polish second**
   - First, align the document’s structure to the `技术文档.md` template (see template section below)
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
   - Pay attention to **section order**, **English comments in `<!-- COMMENT: ... -->`**, and **Chinese example content**
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

In the output document, ensure at least the following **top-level sections** appear in this order (you may add more later if needed).  
The section names should follow the Chinese headings defined in `references/技术文档.md`:

1. `# [系统名称] 技术文档`（或类似标题）
2. `## 版本说明`
3. `## 功能描述`

After that, you may include other sections from the reference template that match the source content, such as:

- `## Context and Background`
- `## Architecture`
- `## API Design`
- `## Data Model`
- `## Workflow`
- `## Configuration and Deployment`
- `## Non-Functional Requirements`
- `## Risks and Open Questions`

For each section:

- Map relevant content from the source document into the most appropriate section
- If a section in the template has **no corresponding information** in the source:
  - Leave it out, OR
  - Keep the section heading with a short placeholder note (e.g. “TBD”) **without inventing details**

### Step 3: Build a proper version history table

Under `## 版本说明`:

- Use a **markdown table** consistent with the template in `references/技术文档.md`, typically with four columns:
  - `发布日期`、`修改人`、`版本号`、`修改内容`
- Extract any available version/change information from the source document and map it into table rows
- If the source has **no clear version info**:
  - Do NOT fabricate real-looking version records
  - You may:
    - Keep the table header with no data rows, OR
    - Add a single placeholder row with clearly non-final values (e.g. `TBD`)

### Step 4: Rewrite and structure the content

While keeping all true technical information:

- **Normalize headings**
  - Use a consistent hierarchy (`#` for title, `##` for main sections, `###` for subsections, etc.)
- **Use lists and tables**
  - Convert long enumerations into bullet lists
  - Use tables for structured data (parameters, configuration, status codes, etc.)
- **Improve clarity**
  - Remove empty phrases (“this section briefly introduces…”)
  - Split very long sentences into shorter, clearer ones
  - Highlight key constraints, preconditions, and caveats with headings or list items

### Step 5: Ensure information completeness and safety

Before finalizing:

- Verify that all meaningful technical content from the source document is preserved
- Do not change numeric values, thresholds, time windows, quotas, or other precise parameters
- If something in the source is ambiguous:
  - Use a neutral, safe phrasing
  - Avoid adding new assumptions

### Step 6: Produce the final markdown document

The final output should:

- Be a **single markdown document** with:
  - A clear Chinese title following the template (for example `# [系统名称] 技术文档`)
  - A `## 版本说明` section that contains a correctly formatted version history table
  - A `## 功能描述` section summarizing what the system/module does
- Contain **no** explanatory text about the transformation or your reasoning
- Be ready to paste directly into a `.md` file

## Summary Checklist

When using this skill, ensure:

1. **Structure aligned**: The document follows the `references/技术文档.md` template with at least `## 版本说明` and `## 功能描述`.
2. **Content faithful**: No fabricated features, parameters, or version records; all important technical details from the source are preserved.
3. **Ready to use**: The final markdown output can be pasted directly into the target `.md` file and used as the official technical document.


