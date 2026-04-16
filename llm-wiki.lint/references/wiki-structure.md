# Wiki 结构模板（Lint 参考）

本文档为 Lint 操作提供页面格式参考，重点关注 Front Matter 元数据和关系维护规则。

## Front Matter 元数据说明

每个 wiki 页面必须在顶部包含 YAML front matter，字段说明如下：


| 字段              | 类型     | 必填  | 说明                                                             |
| --------------- | ------ | --- | -------------------------------------------------------------- |
| `title`         | string | 是   | 页面标题，用于显示和索引                                                   |
| `type`          | string | 是   | 页面类型：`overview`、`entity`、`procedure`、`concept`、`synthesis`、`source` |
| `created`       | string | 是   | 页面创建日期，格式 `YYYY-MM-DD`                                         |
| `updated`       | string | 是   | 最后更新日期，格式 `YYYY-MM-DD`                                         |
| `references`    | array  | 是   | 引用关系数组，表示"我引用了谁"，每个元素包含 `page`（相对路径）和 `description`（关系描述，≤50字）；如果不存在该关系，值为[] |
| `referenced_by` | array  | 是   | 引用关系数组，表示"我被谁引用了"，每个元素包含 `page`（相对路径）和 `description`（关系描述，≤50字）；如果不存在该关系，值为[]        |


### references 和 referenced_by 格式示例

```yaml
references:
  - page: "../entities/user.md"
    description: "本文描述了用户实体的认证流程"
  - page: "../concepts/authentication.md"
    description: "本文使用了认证模式"
referenced_by:
  - page: "../overview/auth.md"
    description: "概览页面引用了本文作为认证流程参考"
  - page: "../synthesis/security-analysis.md"
    description: "综合分析引用了本文的安全最佳实践"
```


### 双向验证逻辑

Lint 在**阶段一（检查）**中执行以下双向验证：

```
正向验证（references → referenced_by）:
  对于每个页面 P 的每个 references 条目 R：
    1. 验证 R.page 路径是否有效
    2. 检查目标页面 T 的 referenced_by 是否包含 P
    3. 验证两边的 description 是否一致

反向验证（referenced_by → references）:
  对于每个页面 T 的每个 referenced_by 条目 B：
    1. 验证 B.page 路径是否有效
    2. 检查源页面 P 的 references 是否包含 T
    3. 验证两边的 description 是否一致
```



## 页面类型摘要


| 类型        | 用途              |
| --------- | --------------- |
| overview  | 领域总体视图，高层次全局概览  |
| entity    | 领域核心实体，可识别的独立事物 |
| procedure | 流程/操作，描述步骤和结果   |
| concept   | 抽象理念/模式/原则      |
| synthesis | 综合分析/对比报告       |
| source    | 大文件或重要文档的摘要     |


## 页面命名规范

### 英文命名规则

- **必须小写**
- **单词间用 `-` 隔开**（kebab-case）
- 示例：`jwt-authentication.md`、`payment-service.md`、`agent-decision-loop.md`

## 文件大小控制

- **建议**每个文件不超过 **3000 字符**，以保持可读性和上下文窗口友好