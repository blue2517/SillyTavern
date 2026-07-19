# 世界书定位、绑定与分析

## 世界书源文件

世界书通常位于 `<用户目录>/worlds/*.json`。文件名是世界书名称，但“当前生效的世界书”可能来自多个作用域，不能只看编辑器当前打开的文件。

## 快速读取流程

用户只要求“读取这个世界书”时，先区分任务范围，不要默认执行完整的生效注入审计：

- **读取编辑器中明确展示的世界书**：截图或界面标题只能作为候选名称。先验证 `<用户目录>/worlds/<候选名称>.json` 确实存在；若同时涉及当前角色，再核对角色卡 `data.extensions.world` 是否指向同名世界书。验证成功后直接读取该 JSON，不必先枚举全部角色、聊天和资产。
- **分析当前实际生效或本轮注入的世界书**：再按下文完整解析全局、角色、聊天、Persona、群聊和扩展作用域。

推荐的最短路径：

1. 读取仓库根目录 `config.yaml`，确认 `dataRoot`、`enableUserAccounts` 和实际用户目录。
2. 读取 `<用户目录>/settings.json` 中的 `active_character`、`active_group`、`world_info_settings.world_info` 与 `power_user.persona_description_lorebook`。
3. 若有活动角色，直接解析 `<用户目录>/characters/<active_character>`，读取 `data.extensions.world`；不要为了查找 PNG 元数据重新搜索实现，固定使用项目的 `src/character-card-parser.js`：

   ```bash
   node --input-type=module -e "import { parse } from './src/character-card-parser.js'; const card=JSON.parse(await parse(process.argv[1], 'png')); const data=card.data ?? card; console.log(JSON.stringify({ name:data.name, world:data.extensions?.world }, null, 2));" "<角色卡路径>"
   ```

4. 若 `data.extensions.world` 非空，直接读取 `<用户目录>/worlds/<world>.json`。世界书条目是 `entries` 对象，应使用 `Object.values(entries)` 统计和遍历，不要假定 UID 连续。
5. 只有用户要求当前聊天绑定或实际注入时，才定位聊天 JSONL；聊天元数据在首行，优先只解析首行的 `chat_metadata.world_info`，不要读取整段聊天正文。

### 工具使用注意

- 直接候选路径优先于扫描整个 `<用户目录>`；该目录可能包含数千项资产。
- 使用 Glob 查找资产时，优先把 `path` 指向具体资产目录（如 `worlds/`、`characters/`、目标角色的 `chats/`），再使用 `**/*.json`、`**/*.png` 或 `**/*.jsonl`。这对包含空格和非 ASCII 文件名的路径更稳妥。
- PNG 角色卡必须通过上述解析器读取元数据，不能把图片可视内容或缩略图当成角色数据。
- 角色卡中的 `data.character_book` 是卡内嵌世界书，可能是导入时的旧副本；当 `data.extensions.world` 已绑定外部世界书时，运行时内容以 `worlds/<名称>.json` 为准。除非用户要求比较版本，否则不要因内嵌副本条目数不同而转去分析它。

### 完成读取时至少确认

- 实际源文件路径和绑定来源；
- 条目总数、启用/禁用数、常驻与关键词触发数；
- 注入位置、深度、顺序、概率和递归相关字段；
- 世界观主体、状态记录/记忆条目及其触发关系；
- 是否存在全局、聊天、Persona 或附加世界书叠加。

## 确定生效的世界书集合

按以下来源分别解析，再去重：

### 1. 全局世界书

读取：

`settings.json → world_info_settings.world_info.globalSelect`

数组中的名称对应 `worlds/<名称>.json`。

### 2. 当前角色主世界书

1. 从 `settings.json → active_character` 确定最后持久化的活动角色卡文件。
2. 读取对应角色卡的元数据。
3. 主世界书名称位于角色数据的 `data.extensions.world`。

PNG 角色卡不能按普通文本读取；应使用项目已有的角色卡解析逻辑或可靠的 PNG 文本块解析方式取得角色数据。

### 3. 当前角色附加世界书

读取：

`settings.json → world_info_settings.world_info.charLore[]`

用当前角色的实际文件名匹配其中的 `name`，将对应 `extraBooks` 加入角色世界书集合。不要用角色显示名代替文件名。

### 4. 当前聊天世界书

当前聊天的 `chat_metadata.world_info` 可以绑定聊天专属世界书。需要先确定实际打开的聊天 JSONL，而不能仅凭最新文件推断；随后读取聊天头部元数据。

### 5. Persona 世界书

读取：

`settings.json → power_user.persona_description_lorebook`

若为空则没有 Persona 世界书。

### 6. 群聊和扩展来源

群聊可能涉及多个角色的主世界书和附加世界书；第三方扩展也可能额外注入世界书或提示词。遇到群聊或扩展任务时，应继续检查对应群组数据和扩展设置。

SillyTavern 的 `public/scripts/world-info.js → getSortedEntries()` 会汇总全局、角色、聊天和 Persona 四类条目，并避免同名世界书重复加载。

## 分析世界书条目

不要把“存在于已绑定世界书”直接等同于“本轮一定注入”。每个条目至少检查：

- 是否禁用、是否常驻；
- 主关键词和次关键词；
- 选择逻辑及大小写、整词匹配设置；
- 扫描深度、递归和递归次数限制；
- 概率开关及概率值；
- 排序值、分组、组权重和组评分；
- 注入位置、深度、角色和顺序；
- Token 预算、预算上限及最小激活数；
- 条目内容中的宏、正则、标签和结构化输出要求；
- 与角色卡、预设提示词及其他世界书条目的覆盖、重复和冲突。

全局世界书与角色世界书的合并先后还受 `world_info_character_strategy` 影响。

## 修改检查清单

- 先确认用户要改的是世界书源内容还是绑定关系。
- 修改前确认所有引用该世界书的全局、角色、聊天和 Persona 绑定。
- 重命名世界书时同步迁移所有绑定，不能只重命名 JSON 文件。
- 保留条目 UID；新增条目时避免 UID 冲突。
- 保留未知字段及扩展添加的元数据。
- 检查常驻、关键词触发、概率和递归组合是否会造成意外注入。
- 验证 JSON 后，按实际绑定和触发条件重新推导有效条目。

## 长期说明的建立条件

仅为长期复用且结构不直观的世界书建立独立说明，例如状态机、变量协议、跨条目递归链或严格输出格式。说明应记录识别特征和依赖关系，不应把某个文件永久标记为“当前世界书”。
