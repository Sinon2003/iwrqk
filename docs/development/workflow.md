# 开发与验证

[返回开发原则](../../AGENTS.md) · [编码惯例](conventions.md)

下述基线在 2026-10-01 根据当前源码、配置及本机版本查询整理。工具可调用不代表应用已经构建或运行通过；后续以仓库配置与实际验证结果为准。

## 环境与依赖

- [pubspec.yaml](../../pubspec.yaml) 的 Dart 约束为 `^3.11.0-93.1.beta`；当前 [pubspec.lock](../../pubspec.lock) 记录 Flutter 下限 `>=3.38.4`。
- 开发基线为 Flutter `3.47.5` stable / Dart `3.13.4`，[mise.toml](../../mise.toml) 与 CI 工作流均锁定该版本，`pubspec.lock` 按它解析。排查构建差异时先确认实际使用的 Flutter 版本，不随意切换 SDK 或整体升级依赖。
- Android 构建工具与 Flutter 3.47.5 模板一致：Gradle 9.3.1、AGP 9.1.0、Kotlin 2.4.0，JDK 17 及以上（CI 使用 17）。`android/gradle.properties` 保留 `android.newDsl=false` 与 `android.builtInKotlin=false` 以兼容尚未迁移的插件；Kotlin 插件由 Flutter Gradle 插件按需应用，应用模块不再显式声明。根 [android/build.gradle.kts](../../android/build.gradle.kts) 对插件模块做两项统一处理：compileSdk 至少提到 App 的值，因为部分插件仍声明旧版本，会被 AGP 9 的 AAR 元数据检查拒绝，这只影响编译期，不改变 minSdk / targetSdk；Kotlin `jvmTarget` 对齐该模块的 Java `targetCompatibility`，因为已迁移到内置 Kotlin 的插件不再自行设置它，而关闭内置 Kotlin 时由 KGP 默认取 JDK 版本，会与 Java 目标不一致。
- 暂缓的大版本升级：
  - animations 3、dynamic_color 2、cached_network_image 4、flutter_smart_dialog 5.2 及以上都依赖 `material_ui`。它是从 Flutter 拆出的 Material 库，类型与 `package:flutter/material.dart` 不同。App 依赖 GetX 的 `GetMaterialApp`，暂不能迁移，混用两套 Material 会带来主题问题且没有功能收益，因此用版本约束挡住，等整体迁移时一起处理。
  - permission_handler 13 要求 compileSdk 37 与 AGP 9.1.1 以上。它会使所有插件按 37 编译，而我们只使用 `isGranted`，因此等 Flutter 默认 compileSdk 升到 37 后再升级。
- 插件源码位于带版本号的 pub 缓存路径，构建目录却按模块名固定，所以升级插件后 Kotlin 增量编译会复用过期状态，报出插件模块内符号"找不到"、`GeneratedPluginRegistrant` 找不到插件类等与代码无关的错误。因此 `android/gradle.properties` 设置了 `kotlin.incremental=false`；插件只在升级时变化，全量编译的代价很小。若仍遇到同类错误，先执行 `flutter clean` 再完整构建。
- 保留 `pubspec.lock`、`third_party/dart_discord_rpc` 的本地路径依赖，以及 `third_party/flutter_inappwebview_android` 的依赖覆盖（AGP 9 兼容修补，移除条件见其 `IWRQK_PATCH.md`）；新增依赖应说明必要性及受影响平台。

从仓库根目录运行，按需要选择命令：

| 目的 | 命令 / 说明 |
| --- | --- |
| 确认版本 | `flutter --version`、`dart --version` |
| 初次准备或依赖变更后解析依赖 | `flutter pub get`，随后检查锁文件差异 |
| 查设备 | `flutter devices` |
| Android 真机调试（主要方式） | `flutter run -d <设备 ID>`，ID 取自 `flutter devices`；也可在 Android Studio 中选择设备后启动 Debug |
| 其他平台调试 | 如 `flutter run -d windows`；Windows 桌面端不是主要目标，需要时再安装桌面构建工具链并执行 `flutter config --enable-windows-desktop` |
| 静态分析 | `flutter analyze`；已解析依赖且本次未改依赖时可用 `flutter analyze --no-pub` |
| 单元测试 | `flutter test`，或指定文件如 `flutter test test/translate_provider_test.dart` |
| 翻译生成 | `dart run slang` |

`mise` 只是任务快捷入口，不是执行上述命令的前提。当前 `mise run watch` 引用了 `build_runner`，但根 `pubspec.yaml` 没有此依赖；不能把它当作可用的常规生成步骤。`mise run format` 会格式化全仓，`mise run updateDeps` 会升级主要依赖版本，日常修复应使用定向命令。

## 修改与验证

1. 确认目标平台、复现步骤、预期行为及工作区已有改动。沿相关 controller、service / repository、provider 查找原因，区分客户端、网络与远端响应问题。
2. 修改必要文件，保持原有代码风格；涉及翻译时重新生成，涉及持久数据时验证旧记录读取。
3. 对本次修改的 Dart 文件运行 `dart format`。例如修改媒体详情控制器后执行 `dart format lib/app/modules/media_detail/controller.dart`；不要把示例路径当作每次固定格式化目标。
4. Dart 改动运行静态分析，并检查是否引入新诊断。历史问题单独记录，不扩大修改范围或降低检查规则来获得表面通过。
5. 按受影响行为选择测试、运行或目标平台构建，最后检查 diff。说明已验证结果和因环境限制未验证的部分。

单元测试位于 `test/`，目前覆盖翻译的文本切分、语言映射与各翻译源响应解析；尚无 `integration_test/`。对解析、状态转换、缓存兼容等可隔离逻辑补回归测试，把被测的纯函数标记为 `@visibleForTesting` 暴露。自动化暂时覆盖不到的平台行为，记录人工复现和验证结果。

| 改动范围 | 重点回归 |
| --- | --- |
| 登录 / 网络 / 站点切换 | 游客访问、正常登录、重启后的缓存登录、令牌过期、失败响应及目标站点请求 |
| 列表 / 搜索 | 首次加载、刷新、分页、空结果、错误提示和需要登录的状态 |
| 播放 / 画中画 | 播放暂停、清晰度、全屏、前后台、退出再进入；按平台检查画中画、窗口恢复和后台音频 |
| 下载 / 存储 | 创建、暂停、恢复、取消、完成、重启恢复、文件路径与旧记录读取 |
| 翻译 / 主题 / 布局 | 生成结果、语言切换、长文案、亮暗主题和相关屏幕尺寸 |
| 翻译 | 两种显示方式（替换原文、原文下方）下的翻译、显示原文或收起与再展开、长按或菜单中换源、设置里的默认源与启用列表、长文本、翻译失败提示 |
| 标签名称 | `flutter test test/tag_names_test.dart`；真机检查设置里的开关、视频详情的标签、筛选页与屏蔽标签中用中文和英文查找、切换界面语言后的显示 |
| 纯文档 | 链接、命令与源码事实、Markdown 格式及 diff；无需运行 Flutter 测试或打包 |

这张表用于挑选与本次修改相关的场景，不要求每次执行全量回归。

### 登录回归

- `flutter test test/auth_client_test.dart test/account_login_test.dart test/loading_dialog_test.dart test/network_failure_test.dart` 验证总网络时限、正文不结束、取消与实际连接释放、失败后重试、迟到响应、令牌交换失败不保存半成品会话、界面重建只运行一次任务，以及网络提示与账号错误的区分。
- Android 真机验证断网 / 关闭 VPN 后登录能结束等待并提示错误；恢复网络后在同一进程再次登录，确认重新发送 `/user/login` 和 `/user/token`。测试后恢复代理与账号状态。不要用重启应用掩盖重试失败，也不要把节点立即拒绝连接等同于应用未发请求。

### 加速传输回归

- `flutter test test/parallel_range_proxy_test.dart test/parallel_range_proxy_adaptive_test.dart test/playback_monitor_test.dart` 覆盖续传、断流、超时、Range 校验、无 Range 服务、并行收益与降级，以及测速和卡顿反馈。
- `flutter test test/parallel_range_proxy_regression_test.dart` 使用 4 MiB 段验证真实预取（小段容易全落在套接字缓冲里），并覆盖六个读取方、额外连接预算、多次有进展的断流、无进展重试上限、FIN 半关闭和初始非法响应清理。
- `flutter test test/transfer_baseline_test.dart test/parallel_range_proxy_startup_test.dart` 检查慢启动后的稳定基线，以及共享带宽下默认预加载保持单流、完整预加载试探后无收益回退。后者采用生产 3 秒窗口与 MiB 级分段，不用瞬时小文件代替。
- `flutter test test/playback_cache_test.dart test/playback_monitor_test.dart test/playback_bandwidth_test.dart` 检查预加载配置兼容、缓存 JSON 字节与时间阈值、短填充下限、真正网络进展才重新采样，以及长视频后逐步衰减的置信度。
- `flutter test test/quality_picker_test.dart test/playback_bandwidth_test.dart test/playback_monitor_test.dart test/file_model_test.dart` 覆盖实际 Source 码率、缓存填满后停止采样、重复上游窗口、网速估计的主机 / 模式隔离和过期、旧记录兼容。自动清晰度是起播选择；验证时分别关闭 / 开启加速，观察正常播放的填充样本和下个视频的选择，不为取样主动下载其他档位。
- 真机测速固定资源、清晰度、字节区间和 VPN 节点，交替测量原始连续请求与应用代理。检查响应状态、字节数和散列一致后再比较用时；同时记录首段正文到达时间，HTTP 响应头到达时间不能代替它。
- 区分“单连接限速”“整条线路共享带宽”“建连 / 请求延迟高”：它们对并行的反应不同。对照请求必须走同一出口；切换节点后重新采样，避免把线路变化归因于代码。
- 加速下载仍依赖应用进程内的代理，测试前后台、暂停 / 恢复和进程重启；它不等价于可脱离应用进程持续运行的原生后台多线程下载。
- 预加载真机验证需覆盖默认 → 更长 → 完整 → 默认，以及开 / 关加速。完整模式等待缓存覆盖整段后断开测试上游，再前跳 / 回看并核对没有新请求；区分解码等待与网络缓冲。核对实际 mpv 参数、缓存范围、临时文件生命周期和切换后的恢复，不能只看进度条。缓存测试服务可用本机文件；实际代理 / CDN 另用适量真实样本验证。

### 标签名称表的维护

- 站点的标签全集来自 `GET https://apiq.iwara.tv/tags?page=<N>&limit=50`：每页最多 50 个，响应里的 `count` 是总数。接口在 Cloudflare 之后，要在已打开 iwara.tv 的浏览器里请求，不要绕过校验。
- 核对译名时用 `GET /videos?tags=<id>&rating=all&sort=views` 看该标签下的视频标题和同时出现的标签。不少 id 在站内的实际用法与字面不同，例如拼错的角色名、与歌曲同名的动作；名称要对得上实际用法。
- 到官网或 wiki 查官方译名时，一次只查一个站，页面之间留间隔，优先找能覆盖多个名字的列表页；不要并行或用脚本批量抓取，出现拦截页或人机验证就停。2026-10 曾因并行抓取触发 `wiki.biligame.com` 的防护，本机 IP 被拦。
- 补完后运行 `flutter test test/tag_names_test.dart`，确认两个文件的 id 一致且有序。书写约定见[编码惯例](conventions.md#标签名称表)。

## 构建与发布现状

[.github/workflows/](../../.github/workflows/) 中的有效工作流是 Android、Windows 构建：Android 由 `v*` 标签触发，也可手动运行；Windows 不在维护范围，只能手动运行，且目前构建失败（`flutter_inappwebview_windows` 不兼容新版 MSVC 移除的 `<experimental/coroutine>`）。当前未配置独立的 PR 分析 / 测试工作流。`release.yml.tmp` 是保留文件，不是有效 workflow。

| 平台 | 现有构建命令 | 相关条件 |
| --- | --- | --- |
| Android | `flutter build apk --release` | CI 使用 JDK 17；应用配置 `minSdk = 24`；release 启用 R8 代码与资源压缩，debug 不压缩 |
| Windows | `flutter build windows --release` | 在 Windows 上构建，分发整个 Release 产物目录 |

Android 签名从环境变量或被忽略的 `android/keystore.properties` 读取；具体行为见 [build.gradle.kts](../../android/app/build.gradle.kts)，缺少完整签名配置时 release 会回退到 debug 签名。Android 工作流在仓库没有配置签名 secrets（`ENCODED_KEYSTORE` 等）时跳过构建，避免把临时密钥签名的 APK 附到 Release。目前 Release 中的 APK 在开发机构建后上传，使用开发机的 debug 签名，与此前的测试安装一致；更换签名后，已安装的用户无法直接覆盖升级。当前 `applicationId` 为 `com.iwrqk.app.sinon`，与 namespace `com.iwrqk.app` 不同，修改时考虑既有安装和数据。

工作流包含 GitHub Release 写入步骤。手动运行时 Android / Windows 只上传产物；执行前仍应阅读目标工作流。接管正式发布还需核对版本、签名、更新源与发布目标。

### 发布步骤

1. 改 `pubspec.yaml` 的 `version`（如 `2.4.1+4`）。版本号前两位有变化的发布，应用会在用户启动时主动提示更新；只改第三位的不会，所以按这次发布想不想打扰用户来定版本号。再写两份更新日志：`changelogs/v<完整版本>.md`（中文，标题为"更新内容""注意"）和 `changelogs/v<完整版本>.en.md`（英文，标题为 Changelog、Attention）。
2. `flutter build apk --release`，把新包装到测试机上验证。
3. `dart run tool/release.dart`：在 `build/release/v<版本>/` 生成按 `iwrqk-<版本>-<ABI>.apk` 命名的 APK、`SHA256SUMS.txt` 和 `notes.md`。应用内更新按这个文件名找安装包。
4. 打 `v<版本>` 标签（不带 `+N`）并推送，再用脚本打印的 `gh release create` 命令发布。

发布说明以中文为主：最上面是直接指向文件的下载链接，然后是中文更新日志，英文折叠在 `<details>` 里。应用内的更新弹窗按界面语言从中取对应的一段（见 `AppRelease.changelog`），所以两份日志的标题不要改。只想刷新已发布版本的说明时，运行 `dart run tool/release.dart <完整版本>` 后用 `gh release edit` 更新。

## 本地资料与手册维护

- 测试账号从 [secrets/test_account.example.json](../../secrets/test_account.example.json) 的结构建立本地文件；真实值受 `.gitignore` 排除，不写进文档、示例、测试或日志。
- 本手册只记录可复用约定。临时排查日志、未证实的推断不写成架构事实；新增专题在 [AGENTS.md](../../AGENTS.md) 补一个带使用场景的链接即可。
- 代码、配置和文档发生偏差时先核对实现，修正文档。新增设计决定写清适用范围、原因、取舍及涉及的源码入口，避免重复整段代码。
