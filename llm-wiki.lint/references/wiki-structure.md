# Wiki 结构模板（Lint 参考）

本文档为 Lint 操作提供页面格式参考，重点关注 Front Matter 元数据和关系维护规则。

## Front Matter 元数据说明

每个 wiki 页面必须在顶部包含 YAML front matter，字段说明如下：

| 字段        | 类型   | 必填 | 说明                                                                 |
| ----------- | ------ | ---- | -------------------------------------------------------------------- |
| `title`     | string | 是   | 页面标题，用于显示和索引                                             |
| `type`      | string | 是   | 页面类型：`overview`、`entity`、`procedure`、`concept`、`synthesis`、`source` |
| `created`   | string | 是   | 页面创建日期，格式 `YYYY-MM-DD`                                      |
| `updated`   | string | 是   | 最后更新日期，格式 `YYYY-MM-DD`                                      |
| `relations` | array  | 是   | 关联关系数组，表示与本页面有关联的其他页面，每个元素包含 `path`（相对路径）和 `desc`（关系描述，≤50字）；如果不存在关联关系，值为 `[]` |

### relations 格式示例

```yaml
relations:
  - path: "wiki/entities/user.md"
    desc: "本文概述了用户实体的认证流程"
  - path: "wiki/concepts/authentication.md"
    desc: "本文使用了认证模式进行安全验证"
```

### 关系定义规则

`relations` 字段记录与本页面有关联的所有其他 wiki 页面，关联关系包括：
- **直接引用**：正文直接链接或提及了其他页面
- **被引用**：其他页面正文中提及了本页面
- **内容相关**：两个页面的内容存在语义上的关联

只要页面 A 和页面 B 之间存在上述任何一种关联，都应在 `relations` 中声明。

### 验证逻辑

Lint 在**阶段一（检查）**中执行以下验证：

```
路径验证：
  对于每个页面 P 的每个 relations 条目 R：
    1. 验证 R.path 路径是否有效（文件是否存在）
    2. 如果不存在 → 标记为"无效路径"

语义验证：
  对于每个页面 P 的每个 relations 条目 R：
    1. 读取 P 和 R.path 目标页面 T 的正文内容
    2. LLM 理解内容，判断 P 和 T 是否确实存在关联
    3. 如果不存在关联 → 标记为"关系误标"
    4. 如果关联存在但 desc 不准确 → 标记为"描述不准确"

遗漏检测：
  对于每个页面 P：
    1. 读取 P 的正文内容
    2. LLM 理解内容，判断 P 是否提及了其他 wiki 页面
    3. 如果提及了页面 X 但 relations 中未声明 → 标记为"关系遗漏"
```

## 页面类型摘要

| 类型       | 用途              |
| ---------- | ----------------- |
| overview   | 领域总体视图，高层次全局概览  |
| entity     | 领域核心实体，可识别的独立事物 |
| procedure  | 流程/操作，描述步骤和结果   |
| concept    | 抽象理念/模式/原则      |
| synthesis  | 综合分析/对比报告       |
| source     | 大文件或重要文档的摘要     |

## 页面命名规范

### 英文命名规则

- **必须小写**
- **单词间用 `-` 隔开**（kebab-case）
- 示例：`jwt-authentication.md`、`payment-service.md`、`agent-decision-loop.md`

## 文件大小控制

- **建议**每个文件不超过 **3000 字符**，以保持可读性和上下文窗口友好

## relations 维护最佳实践

### desc 撰写建议

1. **简洁明了**：控制在 50 字以内
2. **描述关联**：说明两页面间的关联类型或内容关系
3. **避免重复**：同一对页面只需在一方的 relations 中声明即可（双向关联会自动体现）

### 示例

```yaml
# 页面 wiki/procedures/login.md
relations:
  - path: "wiki/entities/user.md"
    desc: "登录流程依赖用户实体定义"
  - path: "wiki/concepts/session.md"
    desc: "登录成功后创建会话"
  - path: "wiki/overview/security.md"
    desc: "概览页面提及登录流程作为安全入口"
```

### 注意事项

- **路径格式**：使用相对路径，如 `wiki/entities/user.md`
- **不要重复声明**：如果 A 的 relations 包含 B，则 B 的 relations 也应包含 A，但 desc 可以不同（从各自视角描述）
- **保持同步**：新增或删除页面时，检查并更新相关页面的 relations