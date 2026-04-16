# Workspace Outline Skill

为工作区（Git 仓库、项目文件夹）创建和维护分层目录文件的技能。

## 功能

此技能用于**协助用户**为工作区创建分层目录文件，帮助 LLM 在主动探索工作区时有迹可循，避免盲目探索导致上下文超限和处理时间过长。

## 核心理念

- **协助维护**：技能的目标是协助用户维护目录结构，而非自动生成整个工作区的目录
- **迭代更新**：交互过程是不断迭代的，LLM 识别上下文中的重要目录，融合到现有结构中
- **灵活组织**：除基本格式约束外，内容由用户自由组织

## 强制性约束

只有以下约束是必须的：

| 约束 | 说明 |
|------|------|
| YAML front matter | 入口文件必须包含 YAML front matter（version, updated, description） |
| 相对路径 | 所有文件路径使用相对于工作区根目录的路径 |
| Markdown 格式 | 所有目录文件使用 `.md` 扩展名 |
| 文件大小 | 每个文件 ≤ 3000 字符 |
| 层级深度 | 整个层级 ≤ 6 层 |

## 目录结构

```
workspace-root/
├── WORKSPACE_OUTLINE.md          # 入口文件（根目录，含 YAML front matter）
└── outlines/                     # 子大纲文件（层级目录结构）
    ├── src.md
    ├── src/
    │   └── fs_explorer.md
    └── docs.md
```

## 使用方法

### 让 LLM 协助创建

告诉 LLM 你想要为项目创建大纲文件，LLM 会：
1. 检测是否已存在 `WORKSPACE_OUTLINE.md`
2. 如不存在，从创建入口文件开始
3. 根据你提供的上下文，迭代更新大纲内容

### 验证文件

使用提供的 shell 脚本验证大纲文件格式：

```bash
chmod +x workspace-outline-skill/scripts/validate.sh
./workspace-outline-skill/scripts/validate.sh /path/to/workspace
```

## 文件结构

```
workspace-outline-skill/
├── SKILL.md                 # 技能主文档
├── README.md                # 使用说明
└── scripts/
    └── validate.sh          # 验证脚本