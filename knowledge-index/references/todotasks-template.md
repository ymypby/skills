# Knowledge Index Todo Tasks

<!-- 
Task tracking file for knowledge index generation.
Used by knowledge-index skill to track progress across two phases.

Status values:
- PHASE1_PENDING: First phase (collect subjects) not started
- PHASE1_COMPLETE: First phase completed, ready for second phase
- PHASE2_PENDING: Second phase (build dependency graph) in progress
- PHASE2_COMPLETE: All phases completed

Format rules:
- Single task list (no separate Pending/Completed sections)
- Use "- [ ]" for pending tasks, "- [x]" for completed tasks
- Order matters: Always process the first 5 pending tasks (topmost "- [ ]" entries)
- Paths should be relative to the target directory
-->

## Status: PHASE1_PENDING

- [ ] relative/path/to/file1.md
- [ ] relative/path/to/file2.md
- [ ] relative/path/to/file3.md
- [x] relative/path/to/processed-file.md