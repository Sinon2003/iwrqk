# 项目结构

[返回开发原则](../../AGENTS.md)

IwrQk 是适配 Iwara 的 Flutter 客户端，界面采用 Material 3，GetX 负责状态、依赖与路由。以下是当前仓库的定位地图，具体流程见[架构与数据流](architecture.md)。

## 目录地图

```text
lib/
  main.dart                    应用启动、主题、语言、桌面窗口
  getx.dart                    全局服务及共享控制器注册
  app/
    modules/                   按功能组织的页面及局部组件
    components/                可复用 UI、列表、对话框、播放器
    data/
      models/                  API 模型、配置及离线记录模型
      enums/                   枚举及 ApiResult / GroupResult
      providers/               API、网络、存储、更新与翻译访问
      services/                账号、用户、配置、下载等共享状态
    routes/                    路由名称与 GetPage 注册
    const/                     站点地址、配置、颜色与界面常量
    utils/                     路径、日志、代理、URL、显示等工具
  i18n/                        Slang JSON 源文件及生成的 Dart 文件
test/                          单元测试（flutter test）
third_party/dart_discord_rpc/   通过 path 引用的本地插件
third_party/flutter_inappwebview_android/  依赖覆盖：兼容 AGP 9 的上游副本
android/ ios/ windows/         平台工程；有对应构建工作流
linux/ macos/ web/             其他平台工程；可用性需分别验证
assets/launcher/              应用图标源素材
doc/                          README 使用的截图和图标
docs/development/             本开发手册的主题文档
changelogs/                    历史更新记录
.github/workflows/            构建、产物上传与发布工作流
secrets/                      被忽略的本地凭据；仅提交示例模板
```

`build/`、`.dart_tool/` 和平台生成缓存是本地产物。不要把缓存中的文件作为业务代码修改入口。

## 功能入口

下表路径均相对于 `lib/app/`。

| 功能 | 从哪里开始 |
| --- | --- |
| 启动分流、规则确认 | [modules/splash/controller.dart](../../lib/app/modules/splash/controller.dart)、`modules/rules/` |
| 首页、订阅、视频、图集、论坛标签页 | [modules/home/controller.dart](../../lib/app/modules/home/controller.dart)、`modules/tabs/` |
| 媒体列表、筛选、分页、搜索结果 | `components/media_preview/media_preview_grid/`、`components/iwr_refresh/`、`modules/search/`、`modules/search_result/` |
| 视频 / 图集详情、播放、评论、收藏 | [modules/media_detail/controller.dart](../../lib/app/modules/media_detail/controller.dart)、`components/comments_list/`、`components/plugin/pl_player/` |
| 登录、注册、收藏、历史、下载、好友、屏蔽标签 | `modules/account/`；共享行为见 `data/services/` |
| 用户主页与上传内容 | `modules/profile/` |
| 播放列表与论坛帖子 | `modules/playlists/`、`modules/forum/` |
| 设置、主题、语言、代理、站点切换 | [modules/settings/controller.dart](../../lib/app/modules/settings/controller.dart)、[data/services/config_service.dart](../../lib/app/data/services/config_service.dart) |

## 文件职责与入口选择

- 页面模块常见 `binding.dart`、`controller.dart`、`page.dart`，按需要增加 `repository.dart` 和 `widgets/`。已有 `view.dart` 等例外，不为统一命名而搬动文件。
- `components/` 中复杂组件也有自己的 controller 和 repository；只有被多处使用或职责独立的组件才上移，页面私有组件留在该模块的 `widgets/`。
- [routes/pages.dart](../../lib/app/routes/pages.dart) 注册页面与 Binding，[routes/routes.dart](../../lib/app/routes/routes.dart) 通过 `part` 定义名称。常量存在不代表页面已经注册或功能已经完成。
- [pubspec.yaml](../../pubspec.yaml) 定义依赖、版本、图标生成配置；[pubspec.lock](../../pubspec.lock) 锁定解析结果；[analysis_options.yaml](../../analysis_options.yaml)、[slang.yaml](../../slang.yaml)、[mise.toml](../../mise.toml) 分别管理分析、翻译生成和任务快捷方式。
- 本地 `dart_discord_rpc` 包包含平台适配与原生库，通过根 `pubspec.yaml` 的 `path` 引用。升级前比较本地改动，不直接替换成托管版本。
- `third_party/flutter_inappwebview_android` 是上游 1.1.3 的副本，仅修改构建脚本以兼容 AGP 9，通过根 `pubspec.yaml` 的 `dependency_overrides` 生效，并已从静态分析中排除。不在其中改业务逻辑；修改内容与移除条件见其 [IWRQK_PATCH.md](../../third_party/flutter_inappwebview_android/IWRQK_PATCH.md)。

新增页面时找同类模块作为样例；新增 API 从 `data/providers/api_provider.dart` 与对应模型开始；修改平台行为时再进入相应平台工程。
