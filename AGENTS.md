# AGENTS 指南

## 沟通要求

- 始终使用中文简体回复。
- 提交 Git commit 信息时默认使用中文。

## 工作方式

- 优先按 SPEC 流程推进工作。
- 标准顺序为：需求规格说明 -> 详细设计 -> 实施计划 -> 编码实现。
- 若需求或规则发生变化，应优先更新文档，再调整实现。
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
- 截至 2026-04-13，`cargo test --manifest-path src-tauri\Cargo.toml` 已通过，当前共 8 个 Rust 测试通过。

## 当前文档约定

- 需求规格说明：`docs/01-requirements-spec.md`
- 详细设计：`docs/02-detailed-design.md`
- 实施计划：`docs/03-implementation-plan.md`

后续开发、讨论和实现应以上述文档为当前基线。
