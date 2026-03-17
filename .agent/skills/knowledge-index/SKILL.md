---
name: knowledge-index
description: Generate and maintain a knowledge index (知识目录.md) from Markdown technical documentation. Use this skill whenever the user mentions generating outlines, knowledge indexes, or adding content to existing knowledge indexes for a directory or file.
---

# Knowledge Index Skill

This skill scans Markdown files and generates/maintains a "知识目录.md" (Knowledge Index) file for RAG-based technical Q&A systems.

## Workflow

### Step 0: Check Todo Tasks Status
Check if `knowledge-index-todotasks.md` exists in the target directory:
- **If exists with pending tasks**: Skip to Step 3 (resume from breakpoint)
- **If exists but all completed**: Delete the file, continue to Step 1
- **If doesn't exist**: Continue to Step 1

### Step 1: Scan Markdown Files
Execute the script to get all Markdown file paths:
```bash
./scripts/scan-md-files.sh <target_directory>
```
The script outputs sorted `.md` file paths (excluding `知识目录.md` and `knowledge-index-todotasks.md`).

### Step 2: Initialize Todo Tasks
Create `knowledge-index-todotasks.md` using the template from `references/todotasks-template.md`, listing all files as pending tasks.

### Step 3: Process Tasks Sequentially (STRICT SINGLE-TASK ONLY)
**ABSOLUTELY PROHIBITED**: Do NOT process multiple tasks in a single operation.
**MANDATORY**: Complete exactly ONE task per iteration - process ONLY the first pending task.

This strict sequential processing is essential for crash recovery and state consistency.

For each iteration, process ONLY the first pending task:

1. **Extract subject from FIRST task only**: Identify ONE main subject from the source file
   - Subject name must exist verbatim in the source file  
   - When unclear, ask the user for clarification
   - **DO NOT** look at other pending tasks
   
2. **Generate content for this single task**:
   - Introduction: 50-150 Chinese characters describing purpose and problems solved
   - Source path: Relative path from target directory
   - Dependencies: Extract from Markdown links `[xxx](other-file.md)` and content analysis

3. **Update files IMMEDIATELY**:
   - Add/update entry in `知识目录.md` (following `references/knowledge-index-template.md`)
   - Mark THIS task as completed in `knowledge-index-todotasks.md` (move to Completed section)
   - **Both files MUST be updated before proceeding to next iteration**

4. **STOP and wait for next iteration** - do not continue to other tasks

## Output Format

The "知识目录.md" follows the template structure with:
- `## 全局依赖图`: Mermaid graph showing dependencies
- `## 主体列表`: List of subjects with introductions and source paths

**Final output rules**:
- Remove example entries from template
- Remove HTML comments
- Ensure all subjects appear in the dependency graph

## Key Constraints

- **One subject per file**: Prevents knowledge fragmentation
- **Strict single-task processing**: Never batch process—complete one task fully before starting the next
- **Immediate updates**: Both files updated after each task completion
- **User consultation**: Ask when subject identification is ambiguous

## Processing Principles: Why Sequential Execution Matters

Sequential processing isn't a limitation—it's a critical safety mechanism:

**Crash Recovery**: Large knowledge bases may take hours to process. Sequential execution ensures you can resume from the last completed task if interrupted.

**State Consistency**: Keeps 知识目录.md and knowledge-index-todotasks.md perfectly synchronized at all times.

**Focused Processing**: Ensures each file receives full attention for accurate subject extraction.

**Transparent Progress**: Users can monitor exact progress and current status.

**Error Isolation**: Problems with individual files don't corrupt the entire process.

**Batch processing risks**:
- Lost progress on interruption (must restart completely)
- Inconsistent file states (partial updates)
- Reduced accuracy (divided attention)
- Hidden progress (users can't track real status)

## Files Created
- `知识目录.md` - Knowledge index output
- `knowledge-index-todotasks.md` - Task tracking file