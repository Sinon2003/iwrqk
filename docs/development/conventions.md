# 编码惯例

[返回开发原则](../../AGENTS.md) · [架构与数据流](architecture.md)

以正在修改的文件及邻近模块为样例；以下归纳当前常见写法，并不要求批量改造旧代码。

## Dart 与文件组织

- 使用 Dart 的两空格缩进和 `dart format`。静态检查沿用 [analysis_options.yaml](../../analysis_options.yaml) 引入的 `flutter_lints`，不通过全局关闭规则掩盖局部问题。
- 文件 / 目录使用 `snake_case`，类用 `UpperCamelCase`，方法 / 字段用 `lowerCamelCase`，私有成员用 `_` 前缀。常见后缀有 `Page`、`Controller`、`Binding`、`Repository`、`Service`、`Provider`、`Model`。
- 导入通常按 `dart:`、`package:`、相对路径分组。仓库同时存在相对导入和 `package:iwrqk/...`，以及单引号和双引号；跟随所在文件，不进行无关替换。
- `async/await` 和 `.then()` 在旧代码中并存。新逻辑保持错误处理清楚，延续周围控制流；不要仅为个人偏好重写整段异步链。
- 注释解释业务约束、平台兼容或取舍。已有中英文注释均保留，避免翻译或重写与本次修改无关的内容。

## 页面、状态与生命周期

- 简单页面参考 [LoginPage](../../lib/app/modules/account/login/page.dart) 的 `GetView<Controller>` + Binding；有动画、路由观察或原生资源时沿用模块已有的 `StatefulWidget` 等实现。
- 新路由同时检查 [pages.dart](../../lib/app/routes/pages.dart) 和 [routes.dart](../../lib/app/routes/routes.dart)，参数保持现有 `Get.arguments` / `Get.parameters` 约定。局部组件不必注册成顶级路由。
- 常见状态形式是私有 `RxBool` / `RxInt` 等配合 getter / setter，UI 用 `Obx` 消费。按职责区分页面状态和 `GetxService` 中的共享状态。
- `Get.put`、`Get.lazyPut`、`Get.create` 以及 tag 的选择会改变实例生命周期；不把它们当作等价语法替换。
- 新增的监听、StreamSubscription、Timer、动画 / 输入控制器等，由拥有者在 `dispose` / `onClose` 等适当位置释放。播放器还需检查跨页面共享和前后台切换，避免提前销毁共享资源。
- UI 沿用 Material 3、`Theme.of(context).colorScheme`、现有公共组件和 `SmartDialog` 提示；列表优先复用 `IwrRefresh` 的加载、空态、失败与登录提示。
- 列表页的多选（下载、历史、收藏、播放列表）共用 [MultipleSelection](../../lib/app/components/multiple_selection.dart) 和 `selectionAppBar`：勾选的 id 是可观察的集合，列表的每一行在自己的 `Obx` 里读取，因为懒加载的行不在外层 `Obx` 的追踪范围内。同一份数据分标签显示时，“反选”只传当前标签显示的 id。
- 删除记录、文件或账号数据前用 [confirmDelete](../../lib/app/components/dialogs/confirm_delete.dart) 询问，文案写清会删掉什么。

## 模型与错误处理

- API 调用继续放在 provider，模块特定查询按需要放进 repository；Widget 中避免新增 HTTP 请求和持久化操作。
- 模型参考 [VideoModel](../../lib/app/data/models/media/video.dart) 的构造函数、手写 `fromJson` / `toJson`。当前没有 Freezed 或 JSON 序列化代码生成链，不为普通模型引入一套新机制。
- API 返回沿用 `ApiResult<T>`，分页沿用 `GroupResult<T>`。先检查 `success`，再按接口契约读取可能为空的 `data`；失败信息不能伪装成成功的空列表。
- 修改 JSON 字段、枚举序列化值或存储键时检查旧记录；有数据格式变更就补兼容读取或迁移及相应验证。
- 新增诊断优先使用 [LogUtil](../../lib/app/utils/log_util.dart)，错误保留必要上下文和堆栈，避免记录密码、授权头、令牌或完整敏感响应。

## 本地化与生成文件

[slang.yaml](../../slang.yaml) 指定英文为基础语言，并使用基础语言作为回退。当前源文件是：

- `lib/i18n/strings.i18n.json`：英文。
- `lib/i18n/strings_zh-CN.i18n.json`：简体中文。
- `lib/i18n/strings_zh-TW.i18n.json`：繁体中文。
- `lib/i18n/strings_ja.i18n.json`：日文。

新增或修改界面文案时维护对应 JSON 键和插值参数，检查其他语言的对应项；暂缺翻译明确说明并使用已有回退。Dart 中通过 `package:iwrqk/i18n/strings.g.dart` 提供的 `t.*` 引用。

在仓库根目录执行：

```sh
dart run slang
```

检查并一起提交源 JSON 与 `lib/i18n/strings*.g.dart`。这些 Dart 文件已被 Git 跟踪，禁止手改；生成差异较大时先核对 SDK 和锁定依赖，避免夹带生成器升级。

原生插件注册文件、图标及第三方 FFI bindings 也各有生成来源。涉及它们时先定位生成配置，不把机器生成内容当作手写业务代码维护。
