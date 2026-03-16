#!/bin/bash
# Scan all .md files in the target directory, excluding output files
# Usage: ./scan-md-files.sh <target_directory>

TARGET_DIR="$1"

if [ -z "$TARGET_DIR" ]; then
    echo "Error: Target directory is required" >&2
    exit 1
fi

if [ ! -d "$TARGET_DIR" ]; then
    echo "Error: Directory does not exist: $TARGET_DIR" >&2
    exit 1
fi

# Find all .md files, excluding output files
find "$TARGET_DIR" -type f -name "*.md" \
  ! -name "知识目录.md" \
  ! -name "knowledge-index-todotasks.md" \
  | sort