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

## 当前项目基线

- 客户端技术栈：Flutter
- 路由方案：go_router
- 日志方案：logging
- 时间处理基础库：intl + timezone
- 本地存储：SQLite
- 同步方式：WebDAV
- 目标平台：Windows、Android

## 当前环境基线

- Flutter 通过 Scoop 安装。
- Flutter SDK 当前路径：`R:\Files\Scoop\Scoop\apps\flutter\current\bin\flutter.bat`
- Android SDK 当前路径：`R:\Files\Android\Sdk`
- 系统默认 Java 保持为 Java 25，不做全局替换。
- 当前项目的 Android 构建单独固定到 JDK 21。
- 项目专用 JDK 21 路径：`R:\Files\Scoop\Scoop\apps\temurin21-jdk\current`
- `android/gradle.properties` 已设置 `org.gradle.java.home` 指向 JDK 21。
- 当前 Android toolchain 已通过 `flutter doctor` 检查。
- 当前 `flutter` / `dart` 尚未加入全局 PATH；执行 Flutter 命令时优先使用 Flutter 完整路径。
- 某些 Flutter 命令会写入 Scoop 下的 Flutter SDK 缓存目录，必要时需要提权执行。
- 在当前环境下，`flutter` / `dart` / `build_runner` 等命令默认应优先按提权方式执行，否则容易因 SDK 缓存写入受限而表现为卡住或超时。
- 由于当前网络环境对 GitHub 二进制下载不稳定，`sqlite3` 优先使用系统 SQLite 库而不是构建时下载预编译二进制。
- 当前 Windows 构建已通过。
- 当前 Android `app-debug.apk` 已生成。
- 当前 Android 构建链仍存在 Maven TLS 握手风险，后续遇到 `repo.maven.apache.org` 相关握手失败时，应优先按网络/TLS 问题处理，而不是误判为业务代码问题。
- 若 Flutter 命令异常中断，需要优先检查并清理 `R:\Files\Scoop\Scoop\apps\flutter\current\bin\cache\flutter.bat.lock`。
- 当前本地正常校验流程 `dart run build_runner build -> dart format -> flutter analyze -> flutter test` 已可在提权后直接跑通。
- 就当前项目本地校验而言，翻墙不是默认前置条件；若再次出现“像卡住”的现象，优先检查是否未提权、是否存在 `flutter.bat.lock`，再判断是否为网络问题。

## 当前业务语义

- 任务以截止时间为核心。
- 开始时间表示任务进入视野的时间，不表示该任务持续占满该时间段。
- 当前不单独建模传统“持续事件/整段占用型日程”。
- 重复任务通过“模板 + 模板版本段 + 单次覆盖”实现。
- 任务状态固定为：未完成、完成、取消。

## 当前文档约定

- 需求规格说明：`docs/01-requirements-spec.md`
- 详细设计：`docs/02-detailed-design.md`
- 实施计划：`docs/03-implementation-plan.md`

后续开发、讨论和实现应以上述文档为当前基线。
