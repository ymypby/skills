#!/bin/bash
#
# Workspace Outline Validator
# 验证概念目录格式和引用正确性
#
# 使用方式:
#   ./validate.sh [workspace_root]
#
# 功能:
#   1. 验证 YAML front matter 格式
#   2. 检查文件引用是否有效
#   3. 验证路径正确性
#   4. 检查概念文件格式（摘要、物理位置映射、相关概念）

set -e

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 工作区根目录
WORKSPACE_ROOT="${1:-.}"
OUTLINES_DIR="$WORKSPACE_ROOT/outlines"
OUTLINE_FILE="$WORKSPACE_ROOT/WORKSPACE_OUTLINE.md"

# 错误计数
ERRORS=0
WARNINGS=0

echo "================================"
echo "Workspace Outline Validator"
echo "================================"
echo "工作区：$WORKSPACE_ROOT"
echo ""

# 检查入口文件是否存在
echo "检查入口文件..."
if [ ! -f "$OUTLINE_FILE" ]; then
    echo -e "${RED}[错误]${NC} WORKSPACE_OUTLINE.md 不存在"
    ERRORS=$((ERRORS + 1))
else
    echo -e "${GREEN}[OK]${NC} WORKSPACE_OUTLINE.md 存在"
fi

# 验证 YAML front matter
echo ""
echo "验证 YAML front matter..."
if [ -f "$OUTLINE_FILE" ]; then
    # 检查是否以 --- 开头
    FIRST_LINE=$(head -n 1 "$OUTLINE_FILE")
    if [ "$FIRST_LINE" != "---" ]; then
        echo -e "${RED}[错误]${NC} YAML front matter 必须以 --- 开头"
        ERRORS=$((ERRORS + 1))
    else
        # 检查是否有 version, updated, description
        if ! grep -q "^version:" "$OUTLINE_FILE"; then
            echo -e "${RED}[错误]${NC} 缺少 version 字段"
            ERRORS=$((ERRORS + 1))
        else
            echo -e "${GREEN}[OK]${NC} version 字段存在"
        fi

        if ! grep -q "^updated:" "$OUTLINE_FILE"; then
            echo -e "${RED}[错误]${NC} 缺少 updated 字段"
            ERRORS=$((ERRORS + 1))
        else
            echo -e "${GREEN}[OK]${NC} updated 字段存在"
        fi

        if ! grep -q "^description:" "$OUTLINE_FILE"; then
            echo -e "${RED}[错误]${NC} 缺少 description 字段"
            ERRORS=$((ERRORS + 1))
        else
            echo -e "${GREEN}[OK]${NC} description 字段存在"
        fi

        # 检查 YAML 结束标记
        if ! grep -q "^---$" "$OUTLINE_FILE"; then
            echo -e "${RED}[错误]${NC} 缺少 YAML front matter 结束标记 ---"
            ERRORS=$((ERRORS + 1))
        else
            echo -e "${GREEN}[OK]${NC} YAML front matter 格式正确"
        fi
    fi
fi

# 检查 outlines/ 目录
echo ""
echo "检查 outlines/ 目录..."
if [ ! -d "$OUTLINES_DIR" ]; then
    echo -e "${YELLOW}[警告]${NC} outlines/ 目录不存在"
    WARNINGS=$((WARNINGS + 1))
else
    echo -e "${GREEN}[OK]${NC} outlines/ 目录存在"

    # 检查 outlines/ 下的 .md 文件
    MD_FILES=$(find "$OUTLINES_DIR" -name "*.md" -type f 2>/dev/null | wc -l)
    echo "  找到 $MD_FILES 个 Markdown 文件"
fi

# 检查文件引用
echo ""
echo "检查文件引用..."
if [ -f "$OUTLINE_FILE" ]; then
    # 提取所有 markdown 链接
    LINKS=$(grep -oE '\]\([^)]+\)' "$OUTLINE_FILE" 2>/dev/null | sed 's/]//' | sed 's/(//' | sed 's/)//' || true)

    for link in $LINKS; do
        # 跳过外部链接
        if [[ "$link" == http* ]]; then
            continue
        fi

        # 解析相对于根目录的路径
        if [[ "$link" == outlines/* ]]; then
            target="$WORKSPACE_ROOT/$link"
        else
            target="$WORKSPACE_ROOT/$link"
        fi

        if [ -f "$target" ]; then
            echo -e "${GREEN}[OK]${NC} $link"
        else
            echo -e "${RED}[错误]${NC} 引用文件不存在：$link"
            ERRORS=$((ERRORS + 1))
        fi
    done
fi

# 检查 outlines/ 下的文件引用
if [ -d "$OUTLINES_DIR" ]; then
    for md_file in $(find "$OUTLINES_DIR" -name "*.md" -type f 2>/dev/null); do
        rel_path="${md_file#$WORKSPACE_ROOT/}"
        echo ""
        echo "检查 $rel_path 的引用..."

        # 提取链接
        LINKS=$(grep -oE '\]\([^)]+\)' "$md_file" 2>/dev/null | sed 's/]//' | sed 's/(//' | sed 's/)//' || true)

        for link in $LINKS; do
            # 跳过外部链接
            if [[ "$link" == http* ]]; then
                continue
            fi

            # 处理相对路径
            if [[ "$link" == ../* ]]; then
                # 相对于当前文件的路径
                dir=$(dirname "$md_file")
                target=$(cd "$dir" && realpath -m "$link" 2>/dev/null || echo "")
            elif [[ "$link" == /* ]]; then
                # 绝对路径
                target="$WORKSPACE_ROOT$link"
            else
                # 相对于工作区根目录
                target="$WORKSPACE_ROOT/$link"
            fi

            if [ -f "$target" ]; then
                echo -e "${GREEN}[OK]${NC} $link"
            else
                echo -e "${YELLOW}[警告]${NC} 引用文件可能不存在：$link"
                WARNINGS=$((WARNINGS + 1))
            fi
        done
    done
fi

# 检查概念文件格式
echo ""
echo "检查概念文件格式..."

check_concept_format() {
    local file="$1"
    local rel_path="${file#$WORKSPACE_ROOT/}"
    
    # 跳过入口文件
    if [ "$file" = "$WORKSPACE_ROOT/WORKSPACE_OUTLINE.md" ]; then
        return
    fi
    
    local has_error=0
    
    # 检查是否有"摘要"章节
    if ! grep -q "## .*摘要\|## .*Summary\|## .*概述" "$file" 2>/dev/null; then
        echo -e "${YELLOW}[警告]${NC} $rel_path 缺少"摘要"章节"
        WARNINGS=$((WARNINGS + 1))
        has_error=1
    fi
    
    # 检查是否有"物理位置映射"或类似章节
    if ! grep -q "## .*物理位置\|## .*Physical\|## .*位置映射" "$file" 2>/dev/null; then
        echo -e "${YELLOW}[警告]${NC} $rel_path 缺少"物理位置映射"章节"
        WARNINGS=$((WARNINGS + 1))
        has_error=1
    fi
    
    # 检查是否有"相关概念"或类似章节
    if ! grep -q "## .*相关概念\|## .*Related\|## .*关联" "$file" 2>/dev/null; then
        echo -e "${YELLOW}[警告]${NC} $rel_path 缺少"相关概念"章节"
        WARNINGS=$((WARNINGS + 1))
        has_error=1
    fi
    
    # 检查是否有原文引用（代码块形式的路径引用）
    if ! grep -qE '\`[a-zA-Z0-9_/.:-]+\`' "$file" 2>/dev/null; then
        echo -e "${YELLOW}[警告]${NC} $rel_path 缺少原文引用（文件路径格式）"
        WARNINGS=$((WARNINGS + 1))
        has_error=1
    fi
    
    if [ $has_error -eq 0 ]; then
        echo -e "${GREEN}[OK]${NC} $rel_path 格式正确"
    fi
}

if [ -d "$OUTLINES_DIR" ]; then
    for md_file in $(find "$OUTLINES_DIR" -name "*.md" -type f 2>/dev/null); do
        check_concept_format "$md_file"
    done
fi

# 检查字符数限制
echo ""
echo "检查文件大小..."
check_file_size() {
    local file="$1"
    local max_size=3000
    local size=$(wc -c < "$file")

    if [ "$size" -gt "$max_size" ]; then
        echo -e "${YELLOW}[警告]${NC} $file 超过 $max_size 字符 (当前：$size)"
        WARNINGS=$((WARNINGS + 1))
    else
        echo -e "${GREEN}[OK]${NC} $file ($size 字符)"
    fi
}

if [ -f "$OUTLINE_FILE" ]; then
    check_file_size "$OUTLINE_FILE"
fi

if [ -d "$OUTLINES_DIR" ]; then
    for md_file in $(find "$OUTLINES_DIR" -name "*.md" -type f 2>/dev/null); do
        check_file_size "$md_file"
    done
fi

# 总结
echo ""
echo "================================"
echo "验证完成"
echo "================================"
echo -e "错误：${RED}$ERRORS${NC}"
echo -e "警告：${YELLOW}$WARNINGS${NC}"

if [ $ERRORS -gt 0 ]; then
    exit 1
else
    exit 0
fi