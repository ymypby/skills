---
name: knowledge-index
description: Generate and maintain a knowledge index (知识目录.md) from Markdown technical documentation. Use this skill whenever the user mentions: knowledge indexes, 知识目录，generating outlines, documentation structure, technical documentation organization, or adding content to existing knowledge indexes for a directory or file. Make sure to use this skill whenever the user mentions any form of documentation indexing, knowledge organization, or creating/maintaining a knowledge base structure from Markdown files.
---

# Knowledge Index Skill

This skill scans Markdown files and generates/maintains a "知识目录.md" (Knowledge Index) file for RAG-based technical Q&A systems.

## Tool Usage

**Step 1 ONLY**: Use `scripts/scan-md-files.sh` script for file listing (NOT built-in tools)
**Other Steps**: Use built-in tools for reading/writing files

## Workflow

### Step 0: Check Todo Tasks Status
Check if `knowledge-index-todotasks.md` exists in the target directory and read its Status line:

**Status values:**
- `PHASE1_PENDING`: First phase (collect subjects) not started
- `PHASE1_COMPLETE`: First phase completed, ready for second phase
- `PHASE2_PENDING`: Second phase (build dependency graph) in progress
- `PHASE2_COMPLETE`: All phases completed

**Branch based on status:**
| Status | Action |
|--------|--------|
| `PHASE1_PENDING` or `PHASE2_PENDING` with pending tasks | Resume from breakpoint - continue current phase |
| `PHASE1_COMPLETE` | Start Phase 2 - reset tasks to pending, update status to `PHASE2_PENDING` |
| `PHASE2_COMPLETE` or all tasks completed | Delete the file, start fresh from Step 1 |
| File doesn't exist | Continue to Step 1 |

### Step 1: Scan Markdown Files
Execute the script to get all Markdown file paths:
```bash
./scripts/scan-md-files.sh <target_directory>
```

**CRITICAL: Use this script, NOT built-in tools**
- MUST use `scripts/scan-md-files.sh` to get file paths
- DO NOT use built-in file listing tools (list_files, etc.) for this step

**Why**: The custom script excludes specific files (知识目录.md，knowledge-index-todotasks.md) and provides sorted results.

The script outputs sorted `.md` file paths (excluding `知识目录.md` and `knowledge-index-todotasks.md`).

### Step 2: Initialize Todo Tasks
Create `knowledge-index-todotasks.md` following the template in `references/todotasks-template.md`.

**Task list format:**
- Each line represents ONE file to be processed
- Path format: Relative path from the user's target directory (e.g., `modules/auth/README.md`)
- DO NOT use absolute paths

**CRITICAL: Create ALL tasks at once**
- Add ALL scanned files to the task list in one operation
- Mark ALL tasks as `- [ ]` pending initially
- **Status MUST remain `PHASE1_PENDING`** - DO NOT change to `PHASE1_COMPLETE`

**PROHIBITED**:
- Setting status to `PHASE1_COMPLETE` during initialization
- Skipping task creation
- Using absolute paths in the task list

**Why**: A complete task list enables resume from breakpoint. If tasks are added incrementally, interruption causes loss of pending tasks not yet added. Status must remain `PHASE1_PENDING` to trigger Phase 1 processing.

### Step 3: Phase 1 - Collect Subjects (Batch Parallel Processing)

**Processing mode:** Process up to 5 tasks at a time using "batch read, sequential write" approach.

**CRITICAL: Update state after EACH task**
- After processing each task, IMMEDIATELY mark it as `- [x]` in knowledge-index-todotasks.md
- DO NOT proceed to next task without updating state
- This constraint applies to BOTH Phase 1 and Phase 2

**Workflow:**
1. Read `knowledge-index-todotasks.md` and check Status
2. If Status is `PHASE1_COMPLETE`, skip to Step 4
3. **Select up to 5 pending tasks**: Find the first 5 entries with `- [ ]` (topmost pending tasks in order)

**CRITICAL: Use task list as the single source of truth**
- **DO NOT re-scan the directory** to filter or validate files
- **DO NOT modify file paths** from the task list
- Use file paths directly from the task list - they are already relative paths

**PROHIBITED**:
- Re-scanning the directory to find files
- Filtering files from the task list
- Adding or removing files not in the original task list

4. **Read all 5 files' content in one batch operation**:
   - Read each file's full content
   - This enables efficient context loading

5. **For each file, extract the following information**:
   - **Subject name**: ONE main subject per file (must exist verbatim in source file)
   - **Introduction**: 50-150 Chinese characters describing purpose and problems solved
   - **Source path**: Relative path from target directory (use directly from task list)
   - When subject is unclear, ask the user for clarification

6. **Update 知识目录.md sequentially** (maintain order even if processed in parallel):
   - Append each subject entry to `知识目录.md` "主体列表" section
   - **Verify write success** before proceeding
   - **ONLY mark task as `- [x]` AFTER successful write**
   - If write fails, keep task as `- [ ]` and retry or report error

**CRITICAL: Write success is the precondition for marking task complete**
- DO NOT mark task as `- [x]` if the entry was not successfully added to 知识目录.md
- Skipping writes and marking complete is PROHIBITED

7. **Repeat** until all tasks are marked `- [x]`

8. Update Status to `PHASE1_COMPLETE`

**Key constraints for Phase 1:**
- **Batch size**: Maximum 5 tasks per batch
- **Order selection**: Always select topmost pending tasks first
- **Dependency graph**: Skip dependency extraction in this phase (will be done in Phase 2)
- **Processing pattern**: Batch read (5 files) → Sequential write (one at a time) → Immediate state update

### Step 4: Phase 2 - Build Dependency Graph (Batch Parallel Processing)

**Precondition:** Phase 1 must be complete (Status = `PHASE1_COMPLETE`)

**Setup:**
1. Read all completed subjects from `知识目录.md` to build the subject mapping
2. Reset all tasks in `knowledge-index-todotasks.md` to `- [ ]` pending state
3. Update Status to `PHASE2_PENDING`

**Workflow:**
1. Read `knowledge-index-todotasks.md` and check Status
2. If Status is `PHASE2_COMPLETE`, generation is finished
3. **Select up to 5 pending tasks**: Find the first 5 entries with `- [ ]` (topmost pending tasks in order)
4. **Read all 5 files' content in one batch operation**:
   - Read each file's full content
   - This enables efficient context loading
5. **For each file, extract dependencies**:
   - **Markdown links**: `[xxx](other-file.md)` → map to subject name from Phase 1
   - **Content analysis**: Identify referenced subjects by analyzing file content
   - Only include dependencies that exist in the known subject list (from Phase 1)
   - When dependency is unclear, skip it rather than guessing
6. **Update 知识目录.md sequentially** (maintain order):
   - For each processed file, update the Mermaid graph in `知识目录.md`
   - **Verify write success** before proceeding
   - Mark each task as `- [x]` immediately after successful update
   - If write fails, keep task as `- [ ]` and retry or report error
7. **Repeat** until all tasks are marked `- [x]`
8. Update Status to `PHASE2_COMPLETE`

**Key constraints for Phase 2:**
- **Batch size**: Maximum 5 tasks per batch
- **Order selection**: Always select topmost pending tasks first
- **Context window friendly**: Each batch loads at most 5 files
- **Complete subject list**: Dependencies only reference subjects collected in Phase 1
- **Processing pattern**: Batch read (5 files) → Sequential write (one at a time) → Immediate state update

## Output Format

The "知识目录.md" follows the template structure with:
- `## 全局依赖图`: Mermaid graph showing dependencies
- `## 主体列表`: List of subjects with introductions and source paths

**Final output rules**:
- Remove example entries from template
- Remove HTML comments
- Ensure all subjects appear in the dependency graph

## Key Constraints

### Processing Constraints
- **One subject per file**: Prevents knowledge fragmentation
- **Batch parallel processing**: Process up to 5 tasks at a time, always selecting in order
- **Order preservation**: Always select the first 5 pending tasks (topmost in todo file)
- **User consultation**: Ask when subject identification is ambiguous

### Two-Phase Design
- **Phase 1**: Collect all subjects first (populates 主体列表 section)
- **Phase 2**: Build dependency graph using known subjects (populates 全局依赖图 section)
- **Context window friendly**: Each batch loads at most 5 files

## Design Principles

### Task List as Single Source of Truth

The `knowledge-index-todotasks.md` file is the authoritative state tracker for the entire generation process:

- **Crash Recovery**: Preserves unprocessed files, enabling resume from exact breakpoint
- **State Persistence**: Survives session interruptions, unlike conversation context
- **Ordered Execution**: Task order determines processing sequence for deterministic results

**Key Rules:**
- Create ALL tasks at once before processing starts
- Update task state IMMEDIATELY after each task completion
- Never modify task order once created
- The task list (not memory) is the authoritative state tracker

### Two-Phase Design

- Phase 1 collects all subjects first, Phase 2 builds dependency graph using known subjects
- Ensures dependency accuracy by having complete subject list before building graph
- Status tracking (`PHASE1_PENDING` → `PHASE1_COMPLETE` → `PHASE2_PENDING` → `PHASE2_COMPLETE`) enables resume from any interruption point

### Batch Parallel Processing

- Process up to 5 tasks at a time for efficiency while staying context-window friendly
- Always select tasks in order for deterministic, reproducible results
- Limited batch size prevents context window overflow

**Processing Pattern: Batch Read → Sequential Write**

This skill uses a "batch read, sequential write" pattern for optimal performance:

1. **Batch Read**: Read all 5 files in a batch first
   - Enables the model to process all content in a single context window load
   
2. **Sequential Write**: Update output files one at a time
   - Ensures each write operation completes successfully before proceeding
   - Maintains deterministic order for reproducible results
   - Enables precise crash recovery (only completed writes are marked done)

3. **Immediate State Update**: Mark task as complete right after successful write
   - The task list file serves as the single source of truth
   - Enables resume from exact breakpoint after interruption
   - Prevents duplicate processing or skipped tasks

This pattern is especially important for models with limited reasoning capabilities, as it:
- Reduces cognitive load by separating read and write phases
- Provides clear, sequential steps that are easy to follow
- Minimizes the chance of errors from complex parallel operations

## Files Created
- `知识目录.md` - Knowledge index output
- `knowledge-index-todotasks.md` - Task tracking file