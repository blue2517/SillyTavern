# SillyTavern 本地配置工作指南

本文件用于帮助 AI 代理快速定位、理解和安全修改本机 SillyTavern 的预设、世界书、角色卡及相关配置。详细规则按主题放在 [`.claude/context/INDEX.md`](.claude/context/INDEX.md)，仅在任务相关时按需读取。

## 基本原则

1. **源文件是唯一事实来源。** `.claude/context/` 中的文档只记录定位方法、结构和长期约束，不能替代实际 JSON、JSONL、PNG 元数据或运行时设置。
2. **不硬编码“当前预设”或“当前世界书”的文件名。** 每次根据持久化选择字段和当前角色、聊天、用户身份解析有效配置。
3. **不按最近修改时间、文件排序、截图文字或相似名称猜测当前配置。** 截图可用于交叉验证，但不能替代持久化状态。
4. **先确认作用域再修改。** 区分全局设置、所选预设、角色绑定、聊天绑定、Persona 绑定和扩展配置。
5. **最小化修改。** 保留未知字段、标识符、提示词顺序及扩展数据；修改后验证语法和关键引用关系。
6. **避免并发覆盖。** SillyTavern 运行期间，网页保存设置可能覆盖磁盘修改。编辑前重新读取目标文件，编辑后不要同时在网页中保存旧状态。
7. **不把秘密写入说明文档。** API Key、密码、令牌、Cookie 和私有代理凭据不得复制到 `AGENTS.md` 或 `.claude/context/`。

## 定位用户数据

1. 读取仓库根目录的 `config.yaml`，以 `dataRoot` 为数据根目录。若启动命令、环境变量或其他配置覆盖了它，以实际运行配置为准。
2. 检查 `enableUserAccounts`：
   - 为 `false` 时，通常使用 `<dataRoot>/default-user/`；
   - 为 `true` 时，先确定当前登录账户对应的数据目录，不要默认使用 `default-user`。
3. 当前用户目录中的常见资产：
   - 主设置：`settings.json`
   - Chat Completion 预设：`OpenAI Settings/*.json`
   - KoboldAI、NovelAI、Text Completion 等预设：对应的 `* Settings/` 目录
   - 世界书：`worlds/*.json`
   - 角色卡：`characters/*.png` 或其他支持格式；PNG 的角色数据位于卡片元数据中
   - 单人聊天：`chats/<角色文件名>/*.jsonl`
   - 群聊与其他用户资产：使用对应用户目录下的专用目录

## 任务入口

- 修改或分析 Chat Completion 预设前，读取 [`.claude/context/presets/README.md`](.claude/context/presets/README.md)。
- 修改或分析世界书、世界书绑定或注入结果前，读取 [`.claude/context/worldbooks/README.md`](.claude/context/worldbooks/README.md)。
- 其他资产先查看 [`.claude/context/INDEX.md`](.claude/context/INDEX.md)；若没有对应文档，在完成首次结构分析后补充一份简短指南。

## 文档维护规则

- `INDEX.md` 只保存导航和通用解析入口，不保存某次会话的当前文件名。
- 仅当某套配置具有长期稳定、反复使用且无法从文件结构直接看出的设计时，才建立独立说明。
- 独立说明应描述识别特征、模块职责、依赖和约束；不要复制整份提示词正文。
- 若说明依赖具体版本，记录来源路径、检查日期及内容哈希；源文件变化后先重新核对再沿用结论。
- 临时分析、一次性文件列表和可从仓库或数据文件直接得到的信息不写入长期文档。
