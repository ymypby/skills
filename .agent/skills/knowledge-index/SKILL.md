---
name: knowledge-index
description: Generate and maintain a knowledge index (知识目录.md) from Markdown technical documentation. Use this skill whenever the user mentions generating outlines, knowledge indexes, or adding content to existing knowledge indexes for a directory or file.
---

# Knowledge Index Skill

This skill scans Markdown files and generates/maintains a "知识目录.md" (Knowledge Index) file for RAG-based technical Q&A systems.

## Workflow

### Step 0: Check for Existing Todo Tasks File

Check if `knowledge-index-todotasks.md` exists in the target directory:

- **If exists AND has pending tasks**: Continue processing from the first pending task (resume from breakpoint)
- **If exists BUT all tasks completed**: Delete the existing file and start fresh from Step 1
- **If does not exist**: Start fresh from Step 1

### Step 1: Get All Markdown File Paths

**Use the shell script `scripts/scan-md-files.sh` to scan the target directory.**

Execute the following command:
```bash
./scripts/scan-md-files.sh <target_directory>
```

The script will:
1. Recursively scan the target directory
2. Collect all paths ending with `.md`
3. Exclude `知识目录.md` and `knowledge-index-todotasks.md`
4. Output sorted file paths (one per line)

**Parse the script output and store as a list for iteration.**

**CRITICAL: Only collect file paths in this step. DO NOT read any file contents yet.**

**DO NOT read the content of any files in this step. File contents will only be read one at a time in Step 3.**

### Step 2: Create Todo Tasks File

Create `knowledge-index-todotasks.md` in the target directory following the template in `references/todotasks-template.md`. This file tracks processing progress and enables resume from breakpoint.

**Structure:**
- `## Pending` - Files waiting to be processed (marked with "- [ ]")
- `## Completed` - Files that have been processed (marked with "- [x]")

See `references/todotasks-template.md` for the full template.

### Step 3: Process Each File in Loop

**CRITICAL: Tasks MUST be processed sequentially (one at a time), NOT in parallel.**

**You MUST complete one task fully (including writing back to both files) before starting the next task.**

1. Read `knowledge-index-todotasks.md` file from the target directory
2. Extract all pending tasks (lines with "- [ ]") from the Pending section
3. **Process the FIRST pending task only**:
   - Extract the file path from the first pending task line
   - Read the Markdown file content
   - Identify **ONE main subject only** from the file:
     - What concrete module/component/other does this file describe?
     - **Subject name must exist in the source file** - Do NOT generate or create new subject names; extract the exact word phase from the original document.
     - **Extract only ONE subject per file** - This ensures each subject in the knowledge index has complete context and avoids knowledge fragmentation. Multiple subjects from one file would create shallow, disconnected entries.
     - **When unclear, ask the user**:
       - If the file content is ambiguous and you cannot determine the main subject
       - If the file appears to describe multiple subjects and you need help selecting the primary one
       - If dependency relationships are unclear
   - Generate introduction:
     - 50-150 Chinese characters
     - Describe purpose and problems solved
   - **Extract source path:**
     - Get the relative path from the target directory to the source file
     - Format as relative path (e.g., `modules/auth/README.md`)
   - Identify dependencies:
     - Extract from Markdown links: `[xxx](other-file.md)`
     - Infer from content analysis
   - Read existing `知识目录.md` (if exists) for incremental update:
     - Add new subject OR update existing entry
     - Remove entries for deleted source files if detected
   - Update subject list section:
     - Add new subject OR update existing entry
     - Include source path: `- 来源：`<relative-path>``
   - Update dependency graph section:
     - Add new dependency relationships
     - Ensure ALL subjects in the 主体列表 appear in the dependency graph
   - Write back to `知识目录.md` immediately - both subject list AND dependency graph must be updated together after processing each file
   - Mark this task as completed:
     - Move this task from Pending to Completed section
     - Change "- [ ]" to "- [x]"
     - Write back to `knowledge-index-todotasks.md` immediately
4. **After completing one task**, re-read `knowledge-index-todotasks.md` and repeat step 3 for the next pending task
5. **Continue this loop** until all pending tasks are completed


### Building the Dependency Graph

1. Extract explicit dependencies from Markdown links: `[xxx](other-file.md)`
2. Infer conceptual dependencies from content analysis
3. Build a directed graph

### Output Format

The "知识目录.md" must follow the template structure in `references/knowledge-index-template.md`, with the following differences for the final output:

**Final Output Rules:**
1. **Remove example entries** - Do not include the example subjects (认证模块，用户管理) from the template
2. **Remove HTML comments** - The final output must NOT contain any HTML comments (`<!-- ... -->`). Template comments are for guidance only.
3. **Include all subjects in dependency graph** - Every subject in the 主体列表 section must appear in the 全局依赖图 Mermaid graph.

**Template structure (for reference only):**
- `## 全局依赖图` - Mermaid graph showing dependencies between subjects
- `## 主体列表` - List of subjects with 50-150 character introductions

See `references/knowledge-index-template.md` for the full template with comments and examples (for reference only, do not copy them to output).

### Example Questions for User

When processing files, you may need to ask the user:

- "这个文件描述的主体是什么？"（如果无法从内容中确定）
- "这个文件是否包含多个候选主体，应该选择哪一个？"（当文件似乎描述多个主体时）
- "这个主体依赖于哪些其他主体？"（如果依赖关系不明确）

## Rules

### Maintenance Rules

1. **Language for comments and instructions**: Use English for template comments and skill instructions
2. **Language for examples**: Use Chinese for template examples and user questions
3. **No instructions in comments**: Template comments should only describe content meaning and format, never include operational instructions

## Files to Create

- `知识目录.md` - The output knowledge index file (created in the target directory)
- `knowledge-index-todotasks.md` - Task tracking file (created in the target directory, see `references/todotasks-template.md`)