# Todo

一个以截止时间为核心的个人任务管理工具。

## 当前状态

项目当前按新的 SPEC 主线推进。

- 当前有效需求基线：`docs/01-requirements-spec.md`
- 详细设计：已完成
- 实施计划：已完成
- 编码实现：阶段 2 进行中

## 当前原则

- 任务以截止时间为核心
- 开始时间表示进入视野时间，不表示持续占用
- 同步按远程优先语义理解
- 当前要求为 Windows 与 Android 双端兼容，允许分阶段实施但不按单端产品设计
- 当前主线技术架构：`Tauri v2 + Vue 3 + TypeScript + Vite + Rust + SQLite + WebDAV`
- 前端整体界面以自定义设计系统为主，复杂日期时间控件例外采用 `Naive UI`

## 当前进展

- 已手写完成 `Vue 3 + TypeScript + Vite` 前端基础骨架
- 已初始化 `src-tauri`
- 已通过 `npm run build`、`cargo check --manifest-path src-tauri\Cargo.toml` 与 `cargo tauri build --debug`
- Windows 调试构建链路已验证通过
- 已完成 `cargo tauri android init --ci --skip-targets-install`
- 已通过 `cargo tauri android build --debug -t aarch64 --apk -v`
- 用户已确认 Android 实际安装与基础功能正常
- 阶段 1 已完成
- 已完成 `rusqlite` 数据层接入、数据库初始化与迁移机制
- 已落地 7 张核心表初版、最小仓储层与事务边界
- 已完成 `task_create`、`task_get_detail`、`task_update`、`task_delete`、`task_set_status` 的单次任务后端闭环
- 已通过 `cargo check --manifest-path src-tauri\Cargo.toml` 与 `cargo test --manifest-path src-tauri\Cargo.toml`，当前共 11 个 Rust 测试通过
- 当前正在推进阶段 2 的更多查询能力与阶段 3 的前端对接准备

## 文档

- `docs/01-requirements-spec.md`
- `docs/02-detailed-design.md`
- `docs/03-implementation-plan.md`
