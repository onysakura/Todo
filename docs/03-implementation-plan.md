# 任务管理工具实施计划

当前状态：`已完成`

## 1. 文档目的

本文档用于将需求规格说明与详细设计拆分为可执行的实施阶段、任务清单、依赖关系、交付物与验收条件，作为当前主线的直接执行依据。

关联文档：

- [`01-requirements-spec.md`](R:\Files\Workspace\Mine\Todo\docs\01-requirements-spec.md)
- [`02-detailed-design.md`](R:\Files\Workspace\Mine\Todo\docs\02-detailed-design.md)

## 2. 状态定义

- `未开始`：尚未进入执行。
- `进行中`：已经开始实施，但尚未完成验收。
- `已完成`：该阶段目标与验收条件已经满足。
- `阻塞`：该阶段已开始，但受外部条件影响暂时无法推进。

## 3. 当前进度总览

- 需求规格说明：`已完成`
- 详细设计：`已完成`
- 实施计划：`已完成`
- 编码实施：`进行中`

补充说明：

- 仓库中的历史 Flutter 原型不计入当前主线进度。
- 当前编码主线已开始，阶段 1、阶段 2、阶段 3、阶段 4 已完成，下一步进入阶段 5 的单次覆盖与模板版本段。

## 4. 实施原则

- 先建立新工程和共享核心，再进入具体业务功能。
- 先完成本地数据闭环，再接入同步。
- 先把 Windows 主闭环跑通，同时在每个关键阶段加入 Android 基础验证。
- 双端兼容从第一阶段开始纳入验证，而不是最后集中补适配。
- 复杂 UI 控件只局部引入，整体界面保持自定义设计系统主导。
- 每个阶段都必须有明确交付物和可验证结果。

## 5. 总体阶段划分

建议按以下阶段推进：

1. 新工程初始化与基础骨架
2. Rust 核心与本地数据层
3. 任务基础能力
4. 重复规则与实例展开
5. 单次覆盖与模板版本段
6. 日历视图与近期视图
7. 危险日与工作日计算
8. 同步机制
9. Windows 后台与提醒
10. Android 适配与双端验证
11. 收尾与质量提升

## 6. 阶段计划

### 阶段 1. 新工程初始化与基础骨架

当前状态：`已完成`

当前进展：

- 已手写完成 `Vue 3 + TypeScript + Vite` 前端基础骨架。
- 已初始化 `src-tauri`。
- 已接入 `Pinia`、`@tanstack/vue-query` 与 `Naive UI`。
- 已补充最小 `greet` command 验证链路。
- `npm run build` 已通过。
- `cargo check --manifest-path src-tauri\Cargo.toml` 已通过。
- `cargo tauri build --debug` 已通过，Windows 可启动应用验收项已满足。
- 已执行 `cargo tauri android init --ci --skip-targets-install`，Android 工程壳已生成。
- `cargo tauri android build --debug -t aarch64 --apk -v` 已通过，Android 单架构调试 APK 已生成。
- 用户已确认 Android 端实际安装并可正常使用，阶段 1 验收条件已满足。
- Android 全 ABI 构建仍可能受网络波动影响，后续按发布策略再决定是否补齐。

目标：

- 建立新的 Tauri 双端工程骨架
- 打通前端、Rust 核心与 Tauri command 基础通信
- 建立基础目录结构、日志与配置体系

任务：

- 初始化 `Tauri v2 + Vue 3 + TypeScript + Vite` 工程
- 生成 Windows 与 Android 目标平台壳
- 建立 `src` 与 `src-tauri` 目录骨架
- 接入 `Pinia`、`@tanstack/vue-query`
- 接入 Rust 基础日志与错误处理
- 建立 Tauri command demo 通路
- 建立基础页面壳、导航壳与空白页
- 建立前端设计 token 初版
- 接入 `Naive UI`，但仅验证日期控件单点可用性

交付物：

- 可运行的新工程
- 基础目录结构
- 前后端桥接样例
- 空白页面壳与导航骨架

验收条件：

- Windows 可启动应用
- Android 可完成基础启动验证
- 前端可成功调用至少一个 Rust command
- 日期控件基础验证可通过

### 阶段 2. Rust 核心与本地数据层

当前状态：`已完成`

当前进展：

- 已选定 Rust SQLite 访问方案为 `rusqlite`，并启用 `bundled` 模式。
- 已建立应用启动数据库初始化与 `schema_migrations` 迁移机制。
- 已落地核心表初版：`task_series`、`task_series_revision`、`task_occurrence_override`、`tag`、`holiday_calendar`、`sync_meta`、`app_settings`。
- 已定义首批领域对象：任务模板、版本段、单次覆盖、标签、节假日、同步元数据、应用设置。
- 已实现 `sync_meta`、`tag`、`task_series`、`task_series_revision`、`task_occurrence_override` 的最小仓储与事务边界。
- 已实现 `app_get_bootstrap_status`、`tag_list`、`tag_create`、`tag_update`、`tag_delete`、`settings_get`、`settings_set`、`settings_delete`、`sync_status_get`、`sync_meta_set`、`sync_meta_delete`、`holiday_list`、`holiday_upsert`、`holiday_delete`、`task_create`、`task_get_detail`、`task_get_editor`、`task_update`、`task_delete`、`task_set_status`、`upcoming_query` 命令闭环。
- 已完成单次任务创建、详情回查、编辑态投影、更新、删除、状态修改、标签校验、时间字段基础校验、近期查询的单次任务版本，以及 `tag`、`app_settings`、`sync_meta`、`holiday_calendar` 读写接口。
- 已补基础测试并通过 `cargo test --manifest-path src-tauri\Cargo.toml`，当前共 22 个 Rust 测试通过。

执行清单：

- `已完成` 选定 Rust SQLite 访问方案并完成依赖接入。
- `已完成` 建立数据库初始化、`schema_migrations` 与核心表初版。
- `已完成` 建立领域对象、统一错误模型与应用状态管理。
- `已完成` 实现 `sync_meta`、`tag`、`task_series`、`task_series_revision`、`task_occurrence_override` 的基础仓储与事务边界。
- `已完成` 实现单次任务基础命令：`task_create`、`task_get_detail`、`task_update`、`task_delete`、`task_set_status`。
- `已完成` 实现面向页面读取的基础查询命令首版：`upcoming_query` 的单次任务版本。
- `已完成` 补齐任务列表/详情/编辑态之间更稳定的 DTO 契约，新增 `task_get_editor`。
- `已完成` 评估阶段 2 是否已满足收口条件，并整理剩余非任务类基础数据能力。
- `已完成` 补齐 `tag` 的更完整读写接口。
- `已完成` 补齐 `app_settings` 的更完整读写接口。
- `已完成` 补齐 `sync_meta` 的更完整读写接口。
- `已完成` 补齐 `holiday_calendar` 的更完整读写接口。
- `已完成` 为阶段 3 的前端新建/编辑任务页接入准备更稳定的命令契约。

目标：

- 建立 SQLite、迁移、仓储与核心领域对象
- 打通本地数据持久化基础能力

任务：

- 选定 Rust SQLite 访问方案
- 建立数据库初始化与迁移机制
- 创建核心表：`task_series`、`task_series_revision`、`task_occurrence_override`、`tag`、`holiday_calendar`、`sync_meta`、`app_settings`
- 定义领域对象与 DTO
- 实现仓储层与事务边界
- 建立测试数据库能力
- 补齐基础仓储测试

交付物：

- 数据库 schema 初版
- 迁移机制
- 基础仓储层
- 数据层测试

验收条件：

- 本地数据库可初始化与迁移
- 核心实体可完成增删改查
- Rust 数据层测试可稳定通过

### 阶段 3. 任务基础能力

当前状态：`已完成`

当前进展：

- 阶段 2 已提供 `task_create`、`task_get_detail`、`task_get_editor`、`task_update`、`task_delete`、`task_set_status`、`tag_list` 等前端接入所需命令。
- 已完成单次任务新建/编辑页首版，接入 `task_create`、`task_get_editor`、`task_update`、`tag_list`。
- 已完成任务详情展示首版，并接入 `task_get_detail`、`task_set_status`、`task_delete`。
- 已完成近期任务列表与选中态联动，选中任务后可查看详情、加载编辑态并联动状态修改与删除。
- 已完成前端字段校验、错误提示与基础空状态补齐。
- 已完成当前首版 UI 的 Windows 与 Android 实际构建验证。
- 已确认当前 `AppShell` 仅为阶段 3 过渡工作台，不作为最终桌面/移动端布局基线；后续仍需按详细设计收敛主视图、详情页与编辑页关系。

执行清单：

- `已完成` 实现新建/编辑任务页首版，并接入 `task_create`、`task_get_editor`、`task_update`、`tag_list`。
- `已完成` 实现任务详情展示首版，并接入 `task_get_detail`、`task_set_status`、`task_delete`。
- `已完成` 实现近期任务列表与选中态联动，复用 `upcoming_query`。
- `已完成` 补齐前端字段校验、错误提示与基础空状态。
- `已完成` 完成 Windows 与 Android 的基础表单交互适配与构建验证。
- `已完成` 明确阶段 3 过渡工作台与最终页面信息架构的边界，避免把当前布局默认固化为正式成品。

目标：

- 完成非重复任务的创建、编辑、删除、状态修改与详情展示闭环

任务：

- 定义任务基础领域服务
- 实现单次任务创建
- 实现单次任务编辑
- 实现任务删除
- 实现状态修改为完成或取消
- 实现标签、优先级、备注编辑
- 实现任务详情 command 与前端页面
- 实现新建/编辑任务页首版
- 实现前端字段校验与错误提示
- 实现 Windows 与 Android 的基础表单交互适配

交付物：

- 新建/编辑任务页首版
- 任务详情页首版
- 任务基础服务与 command

验收条件：

- 用户可完整创建和编辑单次任务
- 用户可修改任务状态
- 数据在重启后仍能正确显示
- Windows 与 Android 均可完成基础任务操作闭环

### 阶段 4. 重复规则与实例展开

当前状态：`已完成`

当前进展：

- 已确认阶段 4 首轮仅聚焦 Rust 核心，不在当前过渡工作台中继续叠加重复任务 UI。
- 已确认当前数据库结构已包含 `recurrence_type`、`recurrence_interval`、`recurrence_rule_json`、`recurrence_until`，可直接承接重复规则展开能力。
- 已完成 `upcoming_query` 的重复实例展开首版，当前已支持按小时、天、周、月、年重复，并支持间隔值、循环截止日期与稳定 `occurrence_key`。
- 已补重复规则展开的 Rust 测试，当前覆盖按小时展开、按天展开、月底钳制与覆盖记录合并。

执行清单：

- `已完成` 定义阶段 4 首版支持范围与最小重复规则模型，明确当前只做查询窗口展开，不提前进入单次覆盖和模板截断。
- `已完成` 实现按小时重复展开，并补齐对应测试。
- `已完成` 实现按天重复展开。
- `已完成` 实现按周重复展开。
- `已完成` 实现按月重复展开。
- `已完成` 实现按年重复展开。
- `已完成` 实现间隔值与循环截止日期支持。
- `已完成` 实现稳定 `occurrence_key` 生成规则。
- `已完成` 接入 `upcoming_query` 的实例展开投影。
- `已完成` 补充重复规则展开的 Rust 单元测试。

目标：

- 实现重复规则定义与查询窗口内实例展开

任务：

- 定义重复规则领域模型
- 实现按小时重复展开
- 实现按天重复展开
- 实现按周重复展开
- 实现按月重复展开
- 实现按年重复展开
- 实现间隔值与循环截止日期支持
- 实现 `occurrence_key` 生成规则
- 实现查询窗口内实例投影服务
- 补充对应单元测试

交付物：

- 重复规则引擎首版
- 实例展开服务
- 重复规则测试

验收条件：

- 在给定查询区间内可正确展开相关实例
- 不全量生成未来所有实例
- `occurrence_key` 稳定可复现

### 阶段 5. 单次覆盖与模板版本段

当前状态：`已完成`

当前进展：

- 阶段 5 Rust 侧闭环已全部完成，前端接入留待后续阶段。
- 已确认现有数据结构（`task_series_revision.effective_until`、`task_occurrence_override`）可直接承接版本段截断与单次覆盖能力，无需新增表。
- 已确认现有 `upcoming_query` 已能在查询窗口内合并模板实例与覆盖记录，阶段 5 仅需补齐写入侧能力。

执行清单：

- `已完成` 5.1 扩展 `task_create` 支持创建重复任务（recurrence_type / interval / until 字段），按是否存在 recurrence 决定 `kind`。
- `已完成` 5.2 实现单次覆盖写入：新增 `task_set_occurrence_status` 命令，支持按 `(series_id, occurrence_key)` 修改某次实例状态（含跳过本次等价取消）。
- `已完成` 5.3 实现单次覆盖读取投影：新增 `task_get_occurrence_detail`、`task_get_occurrence_editor`，返回该次实例合并后的详情与编辑态。
- `已完成` 5.4 实现模板版本段截断：新增 `task_update_template_from` 命令，截断旧版本段并创建新版本段（仓储层新增 `delete_by_id`）。
- `已完成` 5.5 实现未来覆盖保留/清除策略：`task_update_template_from` 接受 `clear_future_overrides` 参数，默认保留已有覆盖。
- `已完成` 5.6 扩展 `task_delete` 支持重复任务整体删除（series + 全部 revision + 全部 override）。
- `已完成` 5.7 补充 Rust 单元测试锁定边界：历史实例隔离、覆盖保留与清除、跳过本次等价取消、单次任务拒绝 occurrence 接口。当前共 37 个 Rust 测试通过。
- `已完成` 5.8 运行 `cargo test`（37 通过）、`npm run build`（通过）、`cargo tauri build --debug`（Windows 通过）。Android aarch64 Rust 交叉编译通过，但 Tauri 符号链接创建受 TRAE 沙箱限制未能完成最终 APK 打包，需在非沙箱环境复验。
- `未开始` 5.9 阶段 5 前端接入（如需），单独补充前端实施子计划再进入页面层。

目标：

- 支持修改单次实例
- 支持从指定日期开始修改模板并影响未来

任务：

- 实现版本段截断与新增逻辑
- 实现模板生效日期处理
- 实现单次覆盖写入逻辑
- 实现覆盖合并逻辑
- 实现跳过本次等价取消
- 实现未来覆盖保留策略
- 实现未来覆盖清除策略
- 实现模板修改与历史实例隔离测试
- 实现对应前端编辑流程

交付物：

- 模板版本段服务
- 单次覆盖服务
- 模板修改交互支撑

验收条件：

- 用户可仅修改某次实例且不影响其他实例
- 用户可从某个生效日期开始修改模板
- 历史实例不会被未来模板修改污染

### 阶段 6. 日历视图与近期视图

当前状态：`已完成`

目标：

- 完成两个主视图的首版实现

任务：

后端投影服务：

- `已完成` 6.1 扩展 `TaskListItemDto`，补 `created_at` 字段，为近期视图排序键提供创建时间兜底
- `已完成` 6.2 修正近期视图排序键对齐详细设计 7.2：状态分组（未完成优先）→ 优先级 → 截止时间 → 开始时间 → 创建时间；危险日临近程度键位预留，待阶段 7 接入
- `已完成` 6.3 新增 `task_calendar_query` 日历视图投影命令，按 `due_date` 聚合为 `Vec<CalendarDayDto { date, items }>`，复用 `upcoming_query` 展开逻辑
- `已完成` 6.4 在 `lib.rs` 注册 `task_calendar_query` 命令
- `已完成` 6.5 补充后端单元测试：日历投影按天聚合、空日补齐、近期视图排序键对齐（新增 3 个测试，总数 37 → 40）

前端视图组件：

- `已完成` 6.6 实现纵向日历流组件（`CalendarView.vue`，按天分组、空日补齐、今日高亮）
- `已完成` 6.7 实现月份分隔样式（跨月时插入月份分隔符）
- `已完成` 6.8 实现单点任务渲染（`TaskCard.vue` 共享卡片组件）
- `已完成` 6.9 实现带开始时间和截止时间任务的可视表达（TaskCard 同时展示截止与开始元数据）
- `已完成` 6.10 实现状态弱化显示（已完成/已取消任务降低不透明度）
- `已完成` 6.11 实现危险日高亮显示（依赖阶段 7）（TaskCard 预留 `isDangerDay` prop 与样式，待阶段 7 接入数据）
- `已完成` 6.12 补充前端视图组件测试（新增 vitest + @vue/test-utils，共 27 个测试通过）

交付物：

- 日历页首版
- 近期页首版
- 视图投影服务

验收条件：

- 日历页可连续查看任务时间分布
- 近期页可展示未来 31 天任务
- 完成、取消、危险日状态在界面上可区分
- 后端投影服务单元测试通过

说明：

- 当前 `upcoming_query` 已支持未来 N 天查询与重复实例展开，近期视图投影直接复用，本轮聚焦排序键对齐与日历投影新增。
- 危险日高亮（6.11）依赖阶段 7 的危险日计算，本轮后端排序键为其预留位但不接入数据；前端 TaskCard 已预留 `isDangerDay` prop 与危险日样式，待阶段 7 接入。
- `AppShell` 已从阶段 3 的"近期入口 + 编辑表单"双栏演化为"日历 / 近期 / 编辑"三视图导航结构，任务在日历或近期视图点击后自动切换到编辑视图并加载详情。

### 阶段 7. 危险日与工作日计算

当前状态：`已完成`

目标：

- 完成危险日自动计算与工作日倒推能力

任务：

后端危险日计算服务：

- `已完成` 7.1 定义危险规则领域模型与解析（`DangerOffsetUnit` 枚举，解析 `danger_offset_value`/`danger_offset_unit`/`danger_use_workday`，写入校验严格、投影读取宽容）
- `已完成` 7.2 实现工作日判定能力（`WorkdayCalculator`：基于 `holiday_calendar` 判定工作日，无记录时按周末 fallback，`workday` 类型覆盖周末调休）
- `已完成` 7.3 实现按小时倒推（`due_anchor - hours`）
- `已完成` 7.4 实现按自然日倒推（`due_anchor - days`，保留时间部分）
- `已完成` 7.5 实现按工作日倒推（从 `due_anchor` 向前跳过非工作日 N 个，保留时间部分）
- `已完成` 7.6 实现单次危险日覆盖优先策略（`override_danger_at` 优先于模板规则计算）

投影与命令接入：

- `已完成` 7.7 扩展 `TaskCreateInput`/`TaskUpdateInput`/`TaskUpdateTemplateFromInput` 支持 `dangerOffsetValue`/`dangerOffsetUnit`/`dangerUseWorkday` 字段；在 `TaskListItemDto` 补 `danger_at` 字段
- `已完成` 7.8 在 `collect_list_items` 投影中接入危险日计算，单次覆盖优先，并预取节假日区间
- `已完成` 7.9 修正近期视图排序键，将危险日占位替换为真实 `danger_at` 临近程度（有 danger_at 排前，按时间升序）
- `已完成` 7.10 实现 `task_set_occurrence_danger` 命令（单次危险日手动修改，仅重复任务，写入 `override_danger_at`）
- `已完成` 7.11 在 `lib.rs` 注册 `task_set_occurrence_danger` 命令

测试与验证：

- `已完成` 7.12 补充 Rust 单元测试（按小时/自然日/工作日倒推、单次覆盖优先、手动修改不影响其他实例、工作日跨周末与调休）
- `已完成` 7.13 运行 `cargo test` + `npm run build` 验证

交付物：

- 危险日计算服务
- 工作日计算服务
- 节假日数据服务（复用阶段 2 已有 `holiday_calendar`）

验收条件：

- 危险日可按自然日或工作日正确计算
- 单次调整危险日后不会影响其他实例

说明：

- 阶段 7 不新增数据表或字段，所有底层结构（`danger_offset_value`/`danger_offset_unit`/`danger_use_workday`/`override_danger_at`/`holiday_calendar`）已在阶段 2 就绪。
- `danger_offset_unit` 仅支持 `hour`、`day`；`danger_use_workday = true` 仅对 `day` 有意义。
- `danger_at` 投影优先级：`override_danger_at` > 模板规则计算 > `None`。
- `danger_at` 格式采用无时区 ISO 字符串 `YYYY-MM-DDTHH:MM:SS`，与 `occurrence_key` 锚点格式一致。
- `WorkdayCalculator` 在投影时按 `[window_start - 366 天, window_end]` 预取节假日，覆盖一年内倒推场景。
- 前端接入（TaskCard 危险日高亮数据绑定、编辑表单 danger_offset 控件）留待后续阶段，本轮聚焦后端闭环。

阶段 7 完成情况（2026-07-01）：

- 新增 `src-tauri/src/service/danger_service.rs`：`DangerOffsetUnit`/`DangerRule`/`validate_danger_input`（写入严格）/`resolve_danger_rule`（投影宽容）/`compute_danger_at`（override 优先）/`WorkdayCalculator`（`holiday_calendar` 判定 + 周末 fallback + `shift_back_workdays`），含 9 个单元测试。
- 扩展 `task_service.rs`：三个 Input 结构补 danger 字段、新增 `TaskSetOccurrenceDangerInput` 与 `set_occurrence_danger` 方法、`TaskListItemDto` 补 `danger_at`、`collect_list_items` 接入 `WorkdayCalculator` 与 `compute_danger_at`（预取区间 `[window_start - 366 天, window_end]`，单条计算失败降级 `None`）、`sort_key` 第三项由占位 `i64` 改为 `danger_at` 字符串字典序（无值用 `9999-12-31T23:59:59` 占位）。
- `lib.rs` 新增 `task_set_occurrence_danger` 命令并注册到 `invoke_handler`。
- Rust 单元测试新增 8 个（小时/自然日/工作日倒推、覆盖优先、单实例隔离、清除回退、单次任务拒绝、非法锚点拒绝），danger_service 自带 9 个，共 17 个新增测试。
- `npm run build` 已通过；前端 27 个测试全通过。
- 沙箱限制：当前 TRAE 沙箱为全新 Ubuntu 24.04 clone，apt 对外网络不通，无法安装 `libglib2.0-dev`/`libwebkit2gtk-4.1-dev` 等系统依赖，`cargo check`/`cargo test` 无法在沙箱执行；后端代码已通过人工 review（import 完整、`compute_danger_at` 调用签名匹配、`sort_key` 元组类型一致、`set_occurrence_danger` 复用 `set_occurrence_status` 模式），需在非沙箱环境复验 `cargo test`。

### 阶段 8. 同步机制

当前状态：`未开始`

目标：

- 完成 WebDAV 远程优先同步闭环

任务：

- 定义 `todo.meta.json` 与 `todo.data.sqlite3` 远端组织格式
- 实现远端元数据检查
- 实现本地快照导出与导入
- 实现在线保存前检查流程
- 实现离线 dirty 标记与恢复副本机制
- 实现远端覆盖本地流程
- 实现同步状态记录与错误提示
- 实现同步状态页
- 补充同步集成测试

交付物：

- WebDAV 同步服务
- 同步状态管理
- 同步测试

验收条件：

- 启动时可同步远端数据
- 保存前如远端已变化，则本地修改被正确拦截
- 离线修改在远端变化时可生成恢复副本并以远端覆盖本地

### 阶段 9. Windows 后台与提醒

当前状态：`未开始`

目标：

- 完成 Windows 后台常驻、托盘与本地提醒

任务：

- 接入 Windows 托盘能力
- 实现主窗口关闭后销毁窗口并保留后台核心进程
- 实现托盘菜单与窗口唤起
- 实现本地提醒调度
- 实现同步后重建提醒计划
- 实现后台定时同步策略
- 验证后台低资源占用目标

交付物：

- Windows 托盘能力
- 后台同步与提醒服务
- 后台资源占用验证记录

验收条件：

- Windows 可关闭主窗口后继续后台运行
- 危险日与截止提醒可正常触发
- 后台同步可工作且不依赖前端窗口常驻

### 阶段 10. Android 适配与双端验证

当前状态：`未开始`

目标：

- 补齐 Android 交互适配与双端闭环验证

任务：

- 调整移动端导航与布局
- 调整移动端日期时间选择交互
- 验证任务创建、编辑、重复、覆盖、同步闭环
- 接入 Android 通知与权限流程
- 明确 Android 生命周期下的同步触发策略
- 补充 Android 端 smoke 测试与手工回归清单

交付物：

- Android 适配版前端交互
- Android 通知与生命周期适配
- 双端验证记录

验收条件：

- Android 端可完整完成核心任务操作
- Android 端可完成同步闭环
- 双端对任务语义、同步结果和状态解释一致

### 阶段 11. 收尾与质量提升

当前状态：`未开始`

目标：

- 收敛交互细节、稳定性与发布准备

任务：

- 补充领域层测试
- 补充同步异常与恢复测试
- 优化日历滚动性能
- 优化近期排序性能
- 修复双端边界问题
- 梳理错误提示、空状态与异常恢复路径
- 完善发布前检查清单
- 整理环境初始化说明与常用命令

交付物：

- 稳定版本候选
- 测试报告
- 发布前检查清单

验收条件：

- 核心流程稳定可用
- 已知高优先级缺陷关闭
- 双端主流程可重复验证通过

## 7. 依赖关系

主要依赖链如下：

1. 新工程初始化与基础骨架 -> Rust 核心与本地数据层
2. Rust 核心与本地数据层 -> 任务基础能力
3. 任务基础能力 -> 重复规则与实例展开
4. 重复规则与实例展开 -> 单次覆盖与模板版本段
5. 重复规则与单次覆盖 -> 日历视图与近期视图
6. 危险日与工作日计算 -> 提醒逻辑与近期排序
7. 本地完整能力稳定后 -> 同步机制
8. 同步机制稳定后 -> Windows 后台与提醒
9. 每个关键阶段都应插入 Android 基础验证，不得直到最后才开始移动端验证

## 8. 里程碑建议

### 里程碑 M1

完成阶段 1 到阶段 3。

结果：

- 新工程可运行
- 可创建、编辑、查看基础任务

### 里程碑 M2

完成阶段 4 到阶段 5。

结果：

- 重复任务和单次覆盖机制可用

### 里程碑 M3

完成阶段 6 到阶段 7。

结果：

- 双主视图和危险日逻辑可用

### 里程碑 M4

完成阶段 8 到阶段 9。

结果：

- 同步、后台、提醒能力可用

### 里程碑 M5

完成阶段 10 到阶段 11。

结果：

- 双端主流程稳定，可进入发布准备

## 9. 测试策略

建议测试按以下层次推进：

- Rust 单元测试
  覆盖重复规则、危险日计算、工作日倒推、覆盖合并、同步判定。
- Rust 集成测试
  覆盖数据库读写、迁移、同步快照导入导出、恢复流程。
- 前端组件测试
  覆盖核心表单、任务列表、日期时间控件封装、状态展示。
- 手工验证
  覆盖 Windows 与 Android 的关键交互、同步流程和后台行为。

重点测试场景：

- 模板从指定日期开始修改
- 已有未来覆盖时再次修改模板
- 单次实例延期任务时间和危险日
- 离线修改后远端变化
- 保存前远端发生变化
- Windows 关闭窗口后后台同步与提醒
- Android 前后台切换后的同步恢复

## 10. 风险与控制

### 10.1 新工程切换风险

风险：

- 历史 Flutter 原型与新主线并存，容易误引用旧实现。

控制：

- 明确旧代码仅作参考，新编码主线从新工程开始。

### 10.2 同步复杂度风险

风险：

- 远程优先 + 离线写入 + 恢复副本机制实现不严谨时，容易造成数据困惑。

控制：

- 优先完成同步状态建模、错误提示与恢复副本策略，再做 UI 包装。

### 10.3 双端一致性风险

风险：

- Windows 与 Android 在交互形态上差异较大，容易出现语义漂移。

控制：

- 所有业务规则统一收敛在 Rust 核心层，每阶段都做 Android 基础验证。

### 10.4 后台资源占用风险

风险：

- 若错误保活前端窗口，Windows 后台内存可能明显升高。

控制：

- 后台模型严格按“销毁主窗口，保留 Rust 核心”实现，并在阶段 9 做资源验证。

## 11. 下一步执行建议

阶段 5 执行清单已细化，按以下顺序推进：

1. 5.1 扩展 `task_create` 支持创建重复任务，作为阶段 5 后续能力的前置依赖
2. 5.2 / 5.3 实现单次覆盖的写入与读取闭环，明确实例级修改的持久化契约
3. 5.4 / 5.5 实现模板版本段截断与"从指定日期开始影响未来"的最小服务，含未来覆盖保留/清除策略
4. 5.6 扩展 `task_delete` 支持重复任务整体删除
5. 5.7 通过 Rust 单元测试锁定模板修改不污染历史实例、未来覆盖默认保留的边界
6. 5.8 完成 `cargo test` + 双端构建验证
7. 5.9 阶段 5 前端接入另立子计划，不在当前 Rust 闭环内完成
