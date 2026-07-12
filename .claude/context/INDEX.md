# SillyTavern 配置上下文索引

本目录保存 AI 代理处理本地 SillyTavern 配置时需要的**稳定定位方法和结构知识**。实际用户数据始终以 `config.yaml` 指向的数据目录为准。

## 按任务读取

| 任务 | 指南 |
|---|---|
| Chat Completion 预设、提示词管理器、采样参数、模型连接 | [`presets/README.md`](presets/README.md) |
| 世界书、Lorebook、关键词触发、注入位置及绑定关系 | [`worldbooks/README.md`](worldbooks/README.md) |

## 使用流程

1. 按 `AGENTS.md` 解析实际 `dataRoot` 和当前用户目录。
2. 从 `settings.json`、当前角色或当前聊天元数据确定有效资产，不依赖固定文件名。
3. 读取对应源文件并确认其结构、启用状态和引用关系。
4. 只在存在长期且不直观的设计时新增专题说明。
5. 修改后验证 JSON/JSONL 或卡片元数据，并检查引用的标识符、文件名和绑定仍然有效。

## 可扩展主题

后续遇到反复维护需求时，可增加：

- `characters/`：角色卡字段、PNG 元数据与角色专属提示词
- `chats/`：JSONL 聊天头、聊天元数据和消息结构
- `extensions/`：第三方扩展设置与预设内嵌配置
- `regex/`：正则脚本、作用阶段和替换顺序
- `connections/`：连接配置与模型选择，但不得记录秘密

不要在本索引中记录“当前使用的是某某文件”；应记录**如何可靠确定当前使用项**。
