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

Create `knowledge-index-todotasks.md` in the target directory following the template in `references/todotasks-template.md`.

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
     - Must be the word phase from the source file
     - **Extract only ONE subject per file - do NOT extract multiple subjects from the same file**
   - Generate introduction:
     - 50-150 Chinese characters
     - Describe purpose and problems solved
   - **Extract source path:**
     - Get the relative path from the target directory to the source file
     - Format as relative path (e.g., `modules/auth/README.md`)
   - Identify dependencies:
     - Extract from Markdown links: `[xxx](other-file.md)`
     - Infer from content analysis
   - Read existing `知识目录.md` (if exists)
   - Update subject list section:
     - Add new subject OR update existing entry
     - Include source path: `- 来源：`<relative-path>``
   - Update dependency graph section:
     - Add new dependency relationships
   - Write back to `知识目录.md` immediately
   - Mark this task as completed:
     - Move this task from Pending to Completed section
     - Change "- [ ]" to "- [x]"
     - Write back to `knowledge-index-todotasks.md` immediately
4. **After completing one task**, re-read `knowledge-index-todotasks.md` and repeat step 3 for the next pending task
5. **Continue this loop** until all pending tasks are completed

**DO NOT batch process multiple tasks. DO NOT read multiple file contents before writing back. One task at a time.**

### Step 4: Final Validation

After all files are processed:

1. Verify dependency chains do not exceed 4 levels
2. Merge subjects if needed to comply with the 4-level constraint (while preserving semantics)

### Building the Dependency Graph

1. Extract explicit dependencies from Markdown links: `[xxx](other-file.md)`
2. Infer conceptual dependencies from content analysis
3. Build a directed graph with maximum 4 levels
4. If chains exceed 4 levels, merge related subjects while preserving semantics

### Output Format

The "知识目录.md" must follow the template structure in `references/knowledge-index-template.md`, with the following differences for the final output:

**Final Output Rules:**
1. **Remove all HTML comments** - The output file should NOT contain any `<!-- ... -->` comments
2. **Remove example entries** - Do not include the example subjects (认证模块，用户管理) from the template
3. **Global dependency graph must include ALL subjects** - Every subject in the 主体列表 section must appear in the dependency graph (either as a source or target of a dependency, or as a standalone node if it has no dependencies)

**Template structure (for reference only):**
- `## 全局依赖图` - Mermaid graph showing dependencies between subjects (must include all subjects)
- `## 主体列表` - List of subjects with 50-150 character introductions

See `references/knowledge-index-template.md` for the full template with comments and examples (for reference only, do not copy them to output).

### Example Questions for User

When processing files, you may need to ask the user:

- "这个文件描述的主体是什么？"（如果无法从内容中确定）
- "这个主体依赖于哪些其他主体？"（如果依赖关系不明确）
- "知识目录.md 已存在，是否要增量更新？"

## Rules

### Maintenance Rules

1. **Language for comments and instructions**: Use English for template comments and skill instructions
2. **Language for examples**: Use Chinese for template examples and user questions
3. **No instructions in comments**: Template comments should only describe content meaning and format, never include operational instructions

### Constraints

1. **Subject requirement**: Subjects must be concrete physical entities documented in source files, not abstract concepts
2. **Subject name requirement**: Subject names MUST exist in the original source documents - do NOT generate or create new subject names
3. **Subject abstraction level**: All subjects in the final output must be at the same abstraction level. If subjects are at different levels, merge lower-level subjects into higher-level ones
4. **One subject per file**: Each file should contribute exactly ONE subject only - do NOT extract multiple subjects from the same file
5. **Dependency depth**: Maximum 4 dependency levels in the mermaid graph
6. **Introduction length**: 50-150 Chinese characters for each subject introduction
7. **Incremental update**: Add new subjects, update existing ones, remove entries for deleted files
8. **Dynamic updates**: Both subject list AND dependency graph are updated immediately after processing each file
9. **Final output must NOT contain HTML comments**: Remove all `<!-- ... -->` comments from the output file
10. **Global dependency graph must include ALL subjects**: Every subject in the 主体列表 section must appear in the dependency graph
11. **Todo tasks file**: Must create and maintain `knowledge-index-todotasks.md` for tracking progress

## Files to Create

- `知识目录.md` - The output knowledge index file (created in the target directory)
- `knowledge-index-todotasks.md` - Task tracking file (created in the target directory, see `references/todotasks-template.md`)