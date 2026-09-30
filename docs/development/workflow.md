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
| 翻译生成 | `dart run slang` |

`mise` 只是任务快捷入口，不是执行上述命令的前提。当前 `mise run watch` 引用了 `build_runner`，但根 `pubspec.yaml` 没有此依赖；不能把它当作可用的常规生成步骤。`mise run format` 会格式化全仓，`mise run updateDeps` 会升级主要依赖版本，日常修复应使用定向命令。

## 修改与验证

1. 确认目标平台、复现步骤、预期行为及工作区已有改动。沿相关 controller、service / repository、provider 查找原因，区分客户端、网络与远端响应问题。
2. 修改必要文件，保持原有代码风格；涉及翻译时重新生成，涉及持久数据时验证旧记录读取。
3. 对本次修改的 Dart 文件运行 `dart format`。例如修改媒体详情控制器后执行 `dart format lib/app/modules/media_detail/controller.dart`；不要把示例路径当作每次固定格式化目标。
4. Dart 改动运行静态分析，并检查是否引入新诊断。历史问题单独记录，不扩大修改范围或降低检查规则来获得表面通过。
5. 按受影响行为选择测试、运行或目标平台构建，最后检查 diff。说明已验证结果和因环境限制未验证的部分。

当前没有应用 `test/`、`integration_test/` 或 `*_test.dart` 用例，虽然已声明 `flutter_test`。对解析、状态转换、缓存兼容等可隔离逻辑的修复补回归测试；有测试后再执行 `flutter test` 或指定相关测试文件。自动化暂时覆盖不到的平台行为，记录人工复现和验证结果。

| 改动范围 | 重点回归 |
| --- | --- |
| 登录 / 网络 / 站点切换 | 游客访问、正常登录、重启后的缓存登录、令牌过期、失败响应及目标站点请求 |
| 列表 / 搜索 | 首次加载、刷新、分页、空结果、错误提示和需要登录的状态 |
| 播放 / 画中画 | 播放暂停、清晰度、全屏、前后台、退出再进入；按平台检查画中画、窗口恢复和后台音频 |
| 下载 / 存储 | 创建、暂停、恢复、取消、完成、重启恢复、文件路径与旧记录读取 |
| 翻译 / 主题 / 布局 | 生成结果、语言切换、长文案、亮暗主题和相关屏幕尺寸 |
| 纯文档 | 链接、命令与源码事实、Markdown 格式及 diff；无需运行 Flutter 测试或打包 |

这张表用于挑选与本次修改相关的场景，不要求每次执行全量回归。

## 构建与发布现状

[.github/workflows/](../../.github/workflows/) 中的有效工作流是 Android、Windows、iOS 构建，均有 `v*` 标签触发和手动入口；当前未配置独立的 PR 分析 / 测试工作流。`release.yml.tmp` 是保留文件，不是有效 workflow。

| 平台 | 现有构建命令 | 相关条件 |
| --- | --- | --- |
| Android | `flutter build apk --release` | CI 使用 JDK 17；应用配置 `minSdk = 24`；release 启用 R8 代码与资源压缩，debug 不压缩 |
| Windows | `flutter build windows --release` | 在 Windows 上构建，分发整个 Release 产物目录 |
| iOS | `flutter build ios --release --no-codesign` | 需要 macOS / Xcode；当前工作流打包的是未签名产物 |

Android 签名从环境变量或被忽略的 `android/keystore.properties` 读取；具体行为见 [build.gradle.kts](../../android/app/build.gradle.kts)，缺少完整签名配置时 release 会回退到 debug 签名。当前 `applicationId` 为 `com.iwrqk.app.fork`，与 namespace `com.iwrqk.app` 不同，修改时考虑既有安装和数据。

工作流包含 GitHub Release 写入步骤。Android / Windows 的手动入口主要上传产物，iOS 工作流的发布步骤没有同样的标签条件；执行前阅读目标工作流，避免把它当作纯构建检查。接管正式发布还需核对版本、签名、更新源与发布目标。

## 本地资料与手册维护

- 测试账号从 [secrets/test_account.example.json](../../secrets/test_account.example.json) 的结构建立本地文件；真实值受 `.gitignore` 排除，不写进文档、示例、测试或日志。
- 本手册只记录可复用约定。临时排查日志、未证实的推断不写成架构事实；新增专题在 [AGENTS.md](../../AGENTS.md) 补一个带使用场景的链接即可。
- 代码、配置和文档发生偏差时先核对实现，修正文档。新增设计决定写清适用范围、原因、取舍及涉及的源码入口，避免重复整段代码。
