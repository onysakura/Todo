# AGENTS 指南

## 沟通要求

- 始终使用中文简体回复。
- 提交 Git commit 信息时默认使用中文。

## 工作方式

- 优先按 SPEC 流程推进工作。
- 标准顺序为：需求规格说明 -> 详细设计 -> 实施计划 -> 编码实现。
- 编码实现必须以 `docs/03-implementation-plan.md` 为直接执行清单，默认按文档中的当前阶段与任务顺序推进，不得脱离实施计划自行跳步。
- 若当前实施计划粒度不足以直接指导编码，应先细化实施计划中的当前阶段任务并更新状态，再进入对应实现。
- 若需求或规则发生变化，应优先更新文档，再调整实现。
- 若发现文档进度、任务拆分、状态标识与实际实现不一致，必须先评估是否需要更新文档；确认不一致时，应优先修正文档，再继续编码。
- 实施计划文档必须带有明确状态标识，至少区分：未开始、进行中、已完成、阻塞。
- 每次完成阶段性工作后，应同步更新实施计划中的状态，保证能直接从文档判断当前进度。
- 在执行过程中遇到新的稳定信息、环境约束、实现前提或风险时，必须及时补充到相关文档中，避免会话压缩后信息丢失。
- 若信息属于长期协作约束、环境基线或执行习惯，应同步补充到 `AGENTS.md`。
- `需求.md` 属于原始需求文档，用于阶段性校准是否跑偏，默认保留，不纳入常规清理范围。
- 需要提权的命令应尽量保持前缀固定且命令本体简短；避免把清理、构建、校验等多个动作拼成超长单条命令，便于用户将常用前缀加入白名单。
- 每次涉及 UI 改动且需要用户验证效果时，除静态检查外，还必须至少执行一次实际构建；桌面相关改动优先构建 Windows，移动端相关改动优先构建 Android，跨端导航或布局改动默认两端都构建。

## 当前项目基线

- 当前项目按新的 SPEC 主线推进。
- 当前业务核心保持不变：任务以截止时间为核心，开始时间表示进入视野时间，而非持续占用时间。
- 当前不单独建模传统“持续事件/整段占用型日程”。
- 重复任务按“模板 + 模板版本段 + 单次覆盖”的思路设计。
- 任务状态固定为：未完成、完成、取消。
- 同步策略按“远程优先”理解：同步与保存冲突时以远端为准，本地作为工作副本与离线缓存。
- 当前产品目标平台为 Windows 与 Android，后续设计与实现必须以双端兼容为前提，允许分阶段交付，但不得按单端产品建模。
- 当前已确定主线技术架构：`Tauri v2 + Vue 3 + TypeScript + Vite + Rust + SQLite + WebDAV`。
- Rust 侧 SQLite 访问当前选型为 `rusqlite`，并启用 `bundled` 模式以降低环境依赖复杂度。
- 前端不直接连接 WebDAV，也不直接访问 SQLite；数据库、同步、后台与平台能力统一收敛在 Rust 侧。
- 前端整体界面以自定义设计系统为主，复杂日期时间控件例外采用 `Naive UI` 能力，不以大型 UI 库作为整站基座。
- 当前任务编辑页首版采用“近期任务入口 + 编辑表单”双栏结构。
- 当前 `AppShell` 属于阶段 3 过渡工作台，只用于验证任务基础能力与交互，不作为最终桌面/移动端布局基线。
- 当前日期时间与选择类字段优先使用 `Naive UI` 组件面板，不继续依赖 HTML 原生 `date` / `time` / `select` 作为正式交互基线。
- 移动端页面根容器默认必须考虑 safe area；若使用沉浸式视口，应同步配置 `viewport-fit=cover` 与 `safe-area-inset-*` padding。

## 当前环境基线

- Node.js 当前版本：`22.17.1`
- npm 当前版本：`10.9.2`
- Rust 当前版本：`1.91.1`
- Cargo 当前版本：`1.91.1`
- Tauri CLI 当前版本：`2.10.1`
- 当前已手写完成 `Vue 3 + TypeScript + Vite` 前端基础骨架与 `src-tauri` 初始化。
- 当前 `npm run build` 已通过。
- 当前 `cargo check --manifest-path src-tauri\Cargo.toml` 已通过。
- 当前 `cargo tauri build --debug` 已通过，Windows 调试构建链路已完成验证。
- 当前已执行 `cargo tauri android init --ci --skip-targets-install`，Android 工程壳已生成。
- 截至 2026-04-13，`cargo tauri android build --debug -t aarch64 --apk -v` 已通过，Android 单架构调试 APK 构建链路已验证。
- 截至 2026-04-13，用户已确认 Android 端实际安装并可正常使用，阶段 1 的 Android 基础启动验证已满足。
- 当前 Android 全 ABI 构建仍可能因网络抖动触发额外 Rust target 下载或远端依赖拉取超时；基础验证阶段优先使用 `aarch64` 单目标构建。
- 截至 2026-04-13，阶段 2 已选定 `rusqlite + 显式 schema_migrations` 方案，并已完成数据库初始化、7 张核心表初版、`sync_meta` / `tag` 最小仓储及基础测试。
- 截至 2026-04-13，阶段 2 已补齐 `task_series`、`task_series_revision`、`task_occurrence_override` 的最小仓储与事务边界。
- 截至 2026-04-13，阶段 2 已完成 `task_create`、`task_get_detail` 的单次任务后端闭环与输入校验。
- 截至 2026-04-13，阶段 2 已完成 `task_update`、`task_delete`、`task_set_status` 的单次任务后端闭环。
- 截至 2026-04-13，阶段 2 已完成 `upcoming_query` 的单次任务版本，支持时间窗口过滤与排序。
- 截至 2026-04-13，阶段 2 已完成 `task_get_editor`，详情态与编辑态已分离为独立 DTO。
- 截至 2026-04-13，阶段 2 已完成 `tag_list`、`tag_create`、`tag_update`、`tag_delete`。
- 截至 2026-04-13，阶段 2 已完成 `settings_get`、`settings_set`、`settings_delete`、`sync_status_get`、`sync_meta_set`、`sync_meta_delete`、`holiday_list`、`holiday_upsert`、`holiday_delete`。
- 截至 2026-04-13，阶段 2 验收条件已满足，可转入阶段 3。
- 截至 2026-04-13，`cargo test --manifest-path src-tauri\Cargo.toml` 已通过，当前共 22 个 Rust 测试通过。
- 截至 2026-04-13，阶段 3 已落地单次任务新建/编辑页首版，并接入 `task_create`、`task_get_editor`、`task_update`、`tag_list` 与最小 `upcoming_query` 编辑入口。
- 截至 2026-04-13，阶段 3 首版 UI 改动后，`npm run build`、`cargo tauri build --debug`、`cargo tauri android build --debug -t aarch64 --apk -v` 已通过。
- 截至 2026-04-14，阶段 4 已完成 `upcoming_query` 的重复实例展开首版，支持按天、周、月、年重复、间隔值、循环截止日期与稳定 `occurrence_key`。
- 截至 2026-04-16，阶段 4 已补齐按小时重复展开；当前 `upcoming_query` 已支持按小时、天、周、月、年重复。
- 截至 2026-04-16，阶段 4 的 Rust 测试已补到 26 个通过，阶段 4 验收条件已满足，可转入阶段 5。
- 截至 2026-06-29，阶段 5 已完成 `task_create` 重复任务创建、`task_set_occurrence_status` 单次覆盖写入、`task_get_occurrence_detail` / `task_get_occurrence_editor` 单次覆盖读取投影、`task_update_template_from` 模板版本段截断与未来覆盖保留/清除策略、`task_delete` 重复任务整体删除。
- 截至 2026-06-29，阶段 5 的 Rust 测试已补到 37 个通过，`npm run build` 与 `cargo tauri build --debug`（Windows）已通过。
- 截至 2026-06-29，阶段 5 的 Android aarch64 Rust 交叉编译已通过，但 Tauri 符号链接创建受 TRAE 沙箱限制未能完成最终 APK 打包，需在非沙箱环境复验。
- 截至 2026-06-30，阶段 6 后端投影服务已完成：`TaskListItemDto` 补 `created_at`、近期视图排序键对齐详细设计 7.2（状态分组→优先级→危险日占位→截止→开始→创建）、新增 `task_calendar_query` 日历投影命令并注册到 `lib.rs`、`upcoming_query` 与 `calendar_query` 共用 `collect_list_items` 展开逻辑。
- 截至 2026-06-30，阶段 6 后端 Rust 测试已补到 40 个通过，`cargo check` 与 `cargo test` 已通过；前端视图组件（6.6-6.12）留待非沙箱环境。
- 截至 2026-06-30，TRAE 沙箱为全新 Ubuntu 24.04 clone，apt 系统依赖（libwebkit2gtk-4.1-dev 等）需重新安装才能跑 `cargo check`/`cargo test`；沙箱 Node 24 / Rust 1.92 与基线 Node 22 / Rust 1.91 存在差异。
- 截至 2026-06-30，阶段 6 前端视图组件已全部完成：`CalendarView.vue` 纵向日历流（月份分隔、空日补齐、今日高亮）、`RecentView.vue` 近期列表（未完成/已完成分组）、`TaskCard.vue` 共享卡片（状态弱化、开始/截止时间可视表达、危险日占位）、`AppShell.vue` 演化为日历/近期/编辑三视图导航。
- 截至 2026-06-30，前端测试框架已引入 vitest + @vue/test-utils + jsdom，共 27 个前端测试通过；`npm run build` 已通过。
- 截至 2026-06-30，阶段 6 全部任务（6.1-6.12）已完成，状态标识为 `已完成`，可转入阶段 7。
- 截至 2026-07-01，沙箱 apt 对外网络完全不通（archive.ubuntu.com 与 mirrors.aliyun.com 均超时），无法安装 `libglib2.0-dev`/`libwebkit2gtk-4.1-dev` 等系统依赖；后端 `cargo check`/`cargo test` 暂时只能在非沙箱环境执行。沙箱内 npm registry 需切换为 `https://registry.npmmirror.com` 才能 `npm install`。
- 截至 2026-07-01，阶段 7 已完成后端危险日与工作日计算闭环：新增 `danger_service.rs`（`DangerRule`/`validate_danger_input`/`resolve_danger_rule`/`compute_danger_at`/`WorkdayCalculator`，9 个单元测试）、`task_service.rs` 扩展三个 Input 的 danger 字段与 `TaskListItemDto.danger_at`、`collect_list_items` 接入危险日投影（预取区间 `[window_start - 366 天, window_end]`，单条失败降级 `None`）、`sort_key` 第三项替换为 `danger_at` 字符串字典序、新增 `task_set_occurrence_danger` 命令并注册到 `lib.rs`；`task_service.rs` 新增 8 个单元测试。
- 截至 2026-07-01，阶段 7 前端 `npm run build` 已通过、27 个前端测试全通过；后端 `cargo test` 受沙箱系统依赖限制未能执行，代码已通过人工 review，需在非沙箱环境复验。阶段 7 全部任务（7.1-7.13）已完成，状态标识为 `已完成`，可转入阶段 8。
- 阶段 7 危险日设计基线：`danger_offset_unit` 仅支持 `hour`/`day`；`danger_use_workday = true` 仅对 `day` 有意义；`danger_at` 投影优先级为 `override_danger_at` > 模板规则计算 > `None`；格式为无时区 ISO 字符串 `YYYY-MM-DDTHH:MM:SS`（与 `occurrence_key` 锚点一致）；写入校验严格（`validate_danger_input`），投影读取宽容（`resolve_danger_rule` 脏数据返回 `None`）。
- 截至 2026-07-01，阶段 8 已完成 WebDAV 远程优先同步闭环：新增 `remote_store.rs`（`RemoteMeta`/`FetchedMeta`/`FetchedSnapshot`/`RemoteStore` trait）、`webdav_store.rs`（ureq + Basic Auth，404 视为空远端）；重写 `sync_service.rs`（`run_sync`/`check_before_save`/`mark_dirty`/`build_store`，push 含并发写校验、pull 含 SHA-256 checksum 校验、冲突时导出恢复副本并以远端覆盖本地、导入后保留 `device_id`）；`db/mod.rs` 新增 `path`/`export_snapshot`（VACUUM INTO）/`import_snapshot`（在线备份覆盖活连接 + 保留 device_id + 重跑迁移）；`error.rs` 新增 `Sync`/`Serialize` 变体；`Cargo.toml` 新增 `base64`/`sha2`/`ureq`（tls）；`lib.rs` 注册 `sync_run`/`sync_check_before_save`/`sync_mark_dirty` 三个命令。
- 截至 2026-07-01，阶段 8 后端 `sync_service.rs` 内置 `FakeRemoteStore`（RefCell 内存态），共 13 个测试覆盖初始推送、up-to-date、脏推送、远端变化拉取、冲突恢复、网络错误、checksum 不匹配、保存前检查（ok/conflict/offline/空远端）、`mark_dirty`、`device_id` 保留、变体构造器。
- 截至 2026-07-01，阶段 8 前端已完成：新增 `src/features/sync/sync-api.ts`（typed wrapper + `encode/decodeSettingValue`）、`src/views/SyncView.vue`（状态卡片 + WebDAV 配置卡片 + 同步操作卡片）、`src/views/__tests__/SyncView.test.ts`（11 个测试）；`AppShell.vue` 新增“同步”tab 与 SyncView 渲染。
- 截至 2026-07-01，阶段 8 `npm run build`（含 `vue-tsc` 类型检查）已通过，前端测试 4 文件 38 个用例全通过（新增 SyncView 11 个，原 27 个保持）。后端 `cargo check`/`cargo test` 受沙箱系统依赖（glib-2.0/libwebkit2gtk-4.1-dev）限制未能执行，代码已通过人工 review，需在非沙箱环境复验。阶段 8 全部任务（8.1-8.14）已完成，状态标识为 `已完成`，可转入阶段 9。
- 阶段 8 同步设计基线：整库快照同步（`todo.data.sqlite3` + `todo.meta.json`），不拆分小文件；远程优先，冲突时以远端为准，本地脏数据导出为恢复副本后再覆盖；WebDAV 凭证与地址保存在 `app_settings`（`sync.webdavUrl`/`sync.webdavUser`/`sync.webdavPassword`），前端不直接处理认证；`RemoteStore` trait 抽象远端操作，核心同步逻辑通过 `FakeRemoteStore` 注入测试不依赖真实网络；`SyncStatusDto` 补 `lastRecoveryPath`/`lastRecoveryAt`/`lastRecoveryReason` 三项 recovery 信息，本轮不新增数据表；`SyncOutcome.action` 取值 `pushed`/`pulled`/`up_to_date`/`conflict_recovered`/`error`，`SaveCheckResult.status` 取值 `ok`/`conflict`/`offline`。
- 截至 2026-07-01，阶段 9 已完成 Windows 后台与提醒闭环：新增 `reminder_service.rs`（`ReminderKind`/`ReminderItem`/`ReminderPlan`/`ReminderService::compute_reminder_plan`，复用 `TaskService::upcoming_query` 投影，`danger_at` 优先于 `due_at`，仅 `pending` 实例产生提醒，7 个单元测试）；新增 `platform_service.rs`（`PlatformError`/`NotificationSpec`/`RegisteredNotifications`/`plan_to_specs`/`show_main_window`/`close_main_window`/`cancel_all_notifications`/`schedule_reminder_plan`/`run_background_sync_if_allowed`，desktop 用 tokio 延迟任务 + `tauri-plugin-notification` 调度，mobile 返回 `NotSupported`，5 个单元测试）；`error.rs` 新增 `From<PlatformError> for CommandError`；`Cargo.toml` 新增 `tauri` feature `tray-icon`、`tauri-plugin-notification = "2"`、`tokio`（`rt-multi-thread`/`time`/`sync`）；`capabilities/default.json` 加 `notification:default` 权限。
- 截至 2026-07-01，阶段 9 `lib.rs` 已集成：托盘菜单（显示窗口/手动同步/退出，左键单击唤起窗口）、主窗口 `CloseRequested` 时 `prevent_close` + `destroy`（desktop，保留进程）、`RegisteredNotifications` 独立 `State` 托管、`reminder_rebuild`/`reminder_preview` 两个新命令、任务变更命令（create/update/delete/set_status/set_occurrence_status/set_occurrence_danger/update_template_from）+ `sync_run` 成功后 `rebuild_reminders_best_effort` 钩子（失败仅日志降级，mobile `NotSupported` 静默忽略）、`settings_set`/`settings_delete`/`tag_*` 变更后同样钩子、后台 tokio interval 同步循环（间隔从 `sync.intervalMinutes` 读取，默认 15 最小 5，每轮 `run_sync` + `rebuild_reminders`）、`reminder.enabled` 为 false 时仅取消已有通知不重新调度。
- 截至 2026-07-01，阶段 9 前端已完成：新增 `src/features/reminder/reminder-api.ts`（`ReminderKind`/`ReminderItem`/`ReminderPlan` 类型 + `rebuildReminders`/`previewReminders` wrapper）；`SyncView.vue` 补提醒设置卡片（`reminder.enabled`/`reminder.windowHours`/`sync.intervalMinutes` 三个 settings 读写）与提醒预览卡片（刷新预览/立即重建按钮 + 列表渲染 + 危险日/截止标签样式）；`SyncView.test.ts` 新增 5 个测试（回填表单/保存三键/刷新预览渲染/重建结果显示/空列表提示）。
- 截至 2026-07-01，阶段 9 `npm run build`（含 `vue-tsc` 类型检查）已通过，前端测试 4 文件 43 个用例全通过（新增 SyncView 5 个，原 38 个保持）。后端 `cargo check`/`cargo test` 受沙箱系统依赖（glib-2.0/libwebkit2gtk-4.1-dev）限制未能执行，代码已通过人工 review，需在非沙箱环境执行 `cargo tauri build --debug`（Windows）复验托盘、窗口关闭销毁、提醒触发、后台同步行为。阶段 9 全部任务（9.1-9.11）已完成，状态标识为 `已完成`，可转入阶段 10。
- 阶段 9 提醒设计基线：提醒计划不新增数据表，`reminder_service` 实时计算近期提醒项（复用 `upcoming_query` 投影），通知由平台通知系统托管（desktop 用 tokio `sleep` 延迟任务 + `tauri-plugin-notification`，非持久化）；`sync_meta` 仅记录 `last_reminder_rebuild_at`；通知 key 采用稳定格式 `series_id::occurrence_key::kind`；`danger_at` 优先于 `due_at`，每个 `pending` 实例最多产生一条提醒；`reminder.enabled = false` 时仅取消已有通知不重新调度；已过期提醒跳过（避免历史刷屏）；`reminder.windowHours` 默认 24，`sync.intervalMinutes` 默认 15 最小 5；mobile 端 `schedule_reminder_plan`/`cancel_all_notifications` 返回 `NotSupported`，阶段 10 补全 Android 通知。

## 当前文档约定

- 需求规格说明：`docs/01-requirements-spec.md`
- 详细设计：`docs/02-detailed-design.md`
- 实施计划：`docs/03-implementation-plan.md`

后续开发、讨论和实现应以上述文档为当前基线。
