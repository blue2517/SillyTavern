# Chat Completion 预设定位与分析

## 确定当前预设

1. 按 `config.yaml → dataRoot` 和账户设置确定当前用户目录。
2. 读取 `<用户目录>/settings.json`。
3. 先检查 `main_api`。只有当前主 API 为 `openai` 时，Chat Completion 预设选择才以 `oai_settings` 为主。
4. 读取 `oai_settings.preset_settings_openai`，其值是最后持久化的所选预设名称。
5. 将名称解析为 `<用户目录>/OpenAI Settings/<名称>.json`。名称和文件可能随导入、另存、重命名或切换而变化，因此不得在长期文档中固定。
6. 若网页截图或用户明确陈述与 `settings.json` 不同，先考虑网页状态尚未持久化或磁盘状态刚被覆盖；修改前必须重新核对。

代码依据：预设下拉框变更时，`public/scripts/openai.js` 的 `onSettingsPresetChange()` 会把选中名称写入 `oai_settings.preset_settings_openai`；导出也使用该名称生成文件名。

## 解析有效提示词顺序

Chat Completion 预设通常同时包含：

- `prompts`：提示词定义，以 `identifier` 建立身份；
- `prompt_order`：提示词引用、顺序和启用状态；
- 模型来源、模型名、上下文、最大回复、采样和连接参数；
- 扩展写入的附加配置。

分析时遵循以下规则：

1. 不以 `prompts` 数组中的物理顺序判断最终注入顺序。
2. 从 `public/scripts/openai.js` 的 `setupChatCompletionPromptManager()` 读取当前 `promptOrder.dummyId`，再在 `prompt_order` 中选择 `character_id` 与该值相同的顺序表。不要永久硬编码该数字，因为代码升级可能改变它。
3. 按所选顺序表中的 `identifier` 回查 `prompts`。
4. 最终启停状态以顺序表引用上的 `enabled` 为主；提示词对象本身的 `enabled` 可能是导入状态或冗余状态。
5. `marker: true` 的项目通常是角色描述、世界书、聊天记录等动态内容插槽，不能只看其空 `content` 就判断没有作用。
6. 对普通提示词同时检查 `role`、`injection_position`、`injection_depth`、`injection_order` 和触发条件。
7. 检查自定义标签是否成对闭合；移动模块时要连同承上启下的标签模块一起分析。
8. 检查同一约束是否在主提示词、世界书、角色卡、扩展和后置提示词中重复或冲突。

## 分析模型和请求参数

至少检查：

- `chat_completion_source` 与对应模型字段；
- `custom_url`、自定义请求体和排除字段，但不要在文档或回答中暴露凭据；
- `openai_max_context`、`openai_max_tokens`、流式传输、候选数；
- 温度、Top P、Top K、Min P、频率/存在/重复惩罚；
- `reasoning_effort`、`verbosity`、工具调用、网络搜索和多模态选项；
- `custom_prompt_post_processing`、系统消息合并和预填充行为；
- `extensions` 以及由第三方扩展嵌入的设置。

## 修改检查清单

- 修改前完整读取目标预设，确认它仍是当前选择或用户指定的目标。
- 保留所有 `identifier`；除非明确迁移，否则不要重新生成 UUID。
- 新增或删除提示词时同步维护有效 `prompt_order`。
- 保留未知字段和扩展配置。
- 修改结构标签时验证嵌套与闭合顺序。
- 修改参数时区分“模型不支持”“前端不发送”和“请求体被排除”三种情况。
- 保存后验证 JSON，并重新解析一次有效提示词顺序。

## 长期说明的建立条件

只有当某个预设家族具有稳定的模块架构、特殊衔接标签、互斥模式或扩展依赖时，才在本目录新增独立说明。说明应使用架构特征识别该家族，并写明如何从当前所选文件验证；不要把某个文件名永久称为“主预设”。
