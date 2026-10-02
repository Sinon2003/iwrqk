# 架构与数据流

[返回开发原则](../../AGENTS.md) · [目录地图](project-structure.md)

本文描述当前实现及维护时需要保留的行为约定。仓库采用按功能分组的 GetX 结构，各模块的分层深度并不完全一致。

## 启动与依赖

[main.dart](../../lib/main.dart) 的顺序是：

1. 初始化 Flutter binding 和 `MediaKit`。
2. 初始化 `PathUtil` → `StorageProvider` → `LogUtil`，再设置代理、音频服务和 `ConfigProvider`。
3. 调用 [initGetx()](../../lib/getx.dart) 注册配置、标签名称、Discord RPC、账号、下载、预览、用户服务，以及共享对话框控制器。
4. 设置屏幕方向、系统栏、语言；桌面端初始化窗口。
5. 用 `TranslationProvider` 包裹 `MainApp`，由 `GetMaterialApp` 加载主题和路由，初始路由为 splash。

[SplashController](../../lib/app/modules/splash/controller.dart) 处理规则确认、缓存登录与用户初始化，随后进入首页或登录页。初始化顺序存在依赖：例如日志依赖路径和存储，网络令牌拦截器通过 `Get.find()` 获取 `AccountService`。

全局服务使用 `Get.put`；页面通常由 Binding 使用 `Get.lazyPut`，媒体详情等使用 `Get.create`。列表、评论等多实例组件使用 tag 区分。调整注册方式时检查实例的拥有者、获取位置和释放时机。

## 页面与数据访问

```mermaid
flowchart LR
    UI[Page / Widget] --> C[Controller]
    C --> R[Repository 按模块需要]
    C --> S[GetxService]
    R --> A[ApiProvider]
    S --> A
    A --> N[NetworkProvider / Dio]
    A --> H[http 登录与令牌请求]
    N --> I[Iwara API]
    H --> I
    S --> P[StorageProvider]
```

- 页面渲染状态、转发交互；controller 组织页面状态和业务流程。常见 `Rx` 字段、getter / setter、`Obx`，列表还使用 `StateMixin`。
- repository 位于使用它的模块或组件旁边，组装查询并转换返回值；简单模块也会由 controller 直接调用 service 或 provider，无需为了层数补空壳。
- [ApiResult / GroupResult](../../lib/app/data/enums/result.dart) 表达请求结果和带总数的列表；模型使用手写 `fromJson` / `toJson`。
- [IwrRefreshController](../../lib/app/components/iwr_refresh/controller.dart) 集中处理刷新、页码、登录要求及加载状态，子类实现 `getNewData()`。其 UI 状态还依赖 `state` 字段中的 `loading`、`empty`、`fail`、`requireLogin`，不能只根据 `RxStatus` 判断。

可沿 [MediaPreviewGridController](../../lib/app/components/media_preview/media_preview_grid/controller.dart) → 同目录 repository → `ApiProvider.getMedia()` 阅读一个完整列表链路。

## 网络与会话

[NetworkProvider](../../lib/app/data/providers/network/network_provider.dart) 是 Dio 单例，配置超时、Cookie、Cloudflare 和令牌拦截器。`MainApp.build()` 为它提供 `BuildContext`，用于配置 Cloudflare 拦截器。

[RefreshTokenInterceptor](../../lib/app/data/providers/network/refresh_token_interceptor.dart) 添加授权头，遇到 401 或访问令牌过期时通过队列刷新并重发请求。[AccountService](../../lib/app/data/services/account_service.dart) 管理持久令牌、内存访问令牌和登录状态；用户资料及用户相关操作由 [UserService](../../lib/app/data/services/user_service.dart) 管理。

修改网络代码前注意这些现状：

- `ApiProvider.login()` 和 `getAccessToken()` 保留独立的 `package:http` 兼容路径，由 [AuthClient](../../lib/app/data/providers/network/auth_client.dart) 管理连接。一次密码登录和访问令牌交换共用 20 秒总网络预算，包含连接、响应头和完整正文；超时 / 取消关闭客户端，重试新建客户端并沿用 `HttpOverrides` / 系统 VPN。两步都成功后才保存会话，迟到或取消的尝试不能发布登录结果。独立的令牌刷新也使用有时限的客户端。
- [NetworkFailure](../../lib/app/data/providers/network/network_failure.dart) 将当前请求的网络异常转为“网络或代理不通”的操作提示，HTTP 错误保留状态码；不再向外站探测，也不缓存连通性结论。认证日志仅记录阶段、用时和异常类型，不记录账号密码、令牌或响应正文。
- 登录 / 注册共用的 [LoadingDialog](../../lib/app/components/dialogs/loading_dialog/widget.dart) 自己持有控制器，每次打开只在 `initState` 启动一次任务；重建不会重新发请求。关闭正在登录的弹窗会取消该次认证，关闭后的异步结果不再更新界面。它不再注册为全局 `Get.create`。
- `NetworkProvider` 接受小于 500 的 HTTP 状态，业务失败仍需检查响应状态、响应体及 `ApiResult.success`。
- GET / POST 的完整 URL 方法会转换部分 HTML 包裹的 JSON，并根据设置添加 `X-Site`；PUT / DELETE 没有同样的处理。站点切换修复要检查各请求路径，不能假设行为一致。
- 内容翻译由 [TranslateProvider](../../lib/app/data/providers/translate_provider.dart) 调用免 Key 的网页翻译接口，翻译源见 [TranslationEngine](../../lib/app/data/enums/translation_engine.dart)（Google、火山、腾讯交互翻译、Yandex）。目标语言跟随 App 语言并按各源映射；长文本按行切分，每个源有各自的单次上限。这些都是非官方接口，可能随时变化，失败时提示并写日志。默认源、启用列表与显示方式（替换原文或显示在原文下方，默认替换）存于 `ConfigService`，默认源始终处于启用状态。界面状态由 [TranslationMixin](../../lib/app/components/translation_mixin.dart) 管理：按源缓存、收起与展开（替换模式下为显示原文）、换源；译文由 [TranslatedContent](../../lib/app/components/translated_content.dart) 显示。视频简介、评论、论坛帖子共用这一套。
- 应用内更新由 [UpdateService](../../lib/app/data/services/update_service.dart) 负责。更新地址在 [const/config.dart](../../lib/app/const/config.dart)，指向本仓库 `Sinon2003/iwrqk` 的 GitHub Releases。[ConfigProvider](../../lib/app/data/providers/config_provider.dart) 取列表第一项（预发布版本也算），去掉标签的 `v` 后按段比较整数，所以发布标签须为 `vX.Y.Z` 纯数字格式；没有任何 Release 时提示检查失败。
    - 有新版时按设备支持的 ABI 找附件 `iwrqk-<版本>-<ABI>.apk`，找不到再用 `iwrqk-<版本>-universal.apk`，都没有才打开 Release 页面。发布时附件须保持这个命名。
    - 找到新版后先弹窗询问，列出版本、下载大小和更新说明，用户确认才下载；手动检查（系统设置 → 检查更新）对任何更新的版本都询问。
    - 首页就绪时调用 `offerOnLaunch` 主动提示，只针对版本号前两位领先的发布（如 2.4.x → 2.5.0），只改第三位的修复版本留给手动检查。每 24 小时最多向 GitHub 查询一次；“稍后再说”或直接关掉弹窗后 3 天内不再提示该版本，“跳过此版本”之后不再提示该版本，更新的版本照常提示。这些记忆存在 `StorageKey.update*` 几个键里。用户已经离开首页或有其他弹窗时这次不弹，下次启动再问。
    - APK 用 Dio 下载到临时目录（沿用应用代理），核对大小后用 `open_file` 调起系统安装器覆盖安装；应用不在前台时等回到前台再调起。manifest 为此声明 `REQUEST_INSTALL_PACKAGES`，首次安装要用户允许"安装未知应用"。

## 存储与配置

[StorageProvider](../../lib/app/data/providers/storage_provider.dart) 统一封装两类存储：

| 内容 | 实现 |
| --- | --- |
| 配置、浏览 / 搜索历史、视频下载记录 | `GetStorage`，经 `GStorageConfig` / `GStorageRecord` 编码为 JSON |
| 用户令牌、保存的账号密码、锁屏配置 | `FlutterSecureStorage`，经 `SecStorageObject` / `SecStorageMap` 访问 |

[ConfigService](../../lib/app/data/services/config_service.dart) 将部分设置映射为响应式状态；持久化键分布在 `StorageKey`、`PLPlayerConfigKey`、`ConfigKey` 和 `DynamicConfigKey`。例如 `accpetedRules` 是现有存储键，修正拼写需要同时设计旧数据读取或迁移。

历史和下载模型在 `data/models/offline/` 及 `data/models/download_task.dart`。修改模型要检查缓存 JSON 和重启后的恢复路径，而不只检查新 API 响应。

## 标签名称

站点的标签只有英文 id（如 `school_swimsuit`），没有显示名。应用自带按语言的名称表 `assets/tags/<语言>.json`，目前有 zh-CN 和 zh-TW，各覆盖站点 `GET /tags` 列出的全部标签。[TagNameService](../../lib/app/data/services/tag_name_service.dart) 在第一次用到时按当前界面语言加载，[TagNames](../../lib/app/utils/tag_names.dart) 负责查名称和按名称查找。

- 名称表不走 Slang。标签是站点的数据而不是界面文案：三千多个，是界面文案（每种语言四百多条）的数倍，并随站点增长；要按 id 动态查、按名称反查，查不到时回退到 id 而不是英文文案。放进 Slang 的话，作为基准语言的英文和没有译名的日文也得各带一张没有内容的表，整张表会编进每种语言的生成代码，按名称反查仍然要另外实现。
- 名称只影响显示和查找。筛选条件、屏蔽列表、请求参数和点击标签复制的内容始终是 id；表里没有的标签（例如站点新增的）直接显示 id。
- 开关是 `ConfigService.localizedTags`（设置里的“标签显示中文”，默认开），只在有名称表的界面语言下出现。界面统一用 [TagLabel / TagOptionTile](../../lib/app/components/tag_label.dart) 显示标签；它们在 `Obx` 中读取，开关变化、语言切换和名称表加载完成都会刷新。
- 筛选页与屏蔽标签的输入框共用 `TagNames.complete`：输入含非 ASCII 字符时只在名称表里查找（站点的补全接口只认识 id），其余情况先列站点补全的结果，再补上名称表里按名称或 id 匹配到的标签。候选项同时显示名称和 id，用来区分名称相近的标签。

## 播放、下载与平台行为

- 在线视频的清晰度由 [QualityPicker](../../lib/app/utils/quality_picker.dart) 在打开视频时选择：画质优先、流畅优先、指定清晰度（没有就选低一档）或自动。自动模式用吞吐的七成作预算；Source 优先按 API 已返回的 `file.size × 8 / duration` 计算平均码率，其他档位缺少大小时采用经验值。无有效观测时用 2.5 Mbps 初始预算，通常从 540 开始。没有测速下载、逐档 HEAD 探测或播放中自动换源，手动选择仍只影响当前视频。
    - [PlaybackMonitor](../../lib/app/components/plugin/pl_player/utils/playback_monitor.dart) 在填充缓存时每秒读取本机状态，每轮最多 12 次；三个以上有效窗口取次高值以过滤尖峰。初次填充只有零到两个窗口时，用打开源以来实际缓存的字节 / 总用时约束估计，避免快线路因窗口太少而记住慢启动。读取完整的 `demuxer-cache-state` JSON；目标 Android mpv 不支持 `fw-bytes` 子路径。内存模式读取包字节，完整预加载读取临时文件字节，缓存是否已满按本次预加载策略判断。普通播放使用原生 `raw-input-rate`；加速播放使用代理的上游独立窗口，包含请求 / 重试等待，不减去下游等待，也不采 localhost 突发速度。
    - 一轮结束后每 15 秒检查一次本机状态，只有正在读取且缓存终点实际前进才开始新一轮；后续短补充不足三个窗口不刷新估计，避免把视频码率当作容量。暂停、全缓存和重复上游窗口不续期。监控随源切换 / 页面关闭释放。
    - [PlaybackBandwidth](../../lib/app/utils/playback_bandwidth.dart) 按 CDN 主机和加速模式最多保存 8 项。前 5 分钟保持原置信度，随后逐渐衰减，到 30 分钟过期，避免看长视频后在第 5 分钟突然退回初始预算；读记录和缓存播放不会刷新采样时间。Iwara 会轮换各档 CDN，未知主机参考同模式最新观测的八成，已知主机优先使用自己的记录。沿用 `playbackBandwidth` 存储结构，旧 `playbackThroughput` 数字不参与决策。外部 VPN 节点变化无法直接感知，实际新观测与持续卡顿反馈修正估计；不追加测速。
    - 持续缓冲至少 2 秒且没有可播放缓存才下调后续视频的预算；首播、暂停、结束和跳转后 3 秒内的等待不算卡顿。先结算旧样本再降低估计，避免随后被旧数据覆盖；换源前销毁旧监控，回调固定捕获当时的源和模式。
- [媒体详情](../../lib/app/modules/media_detail/controller.dart) 负责在线 / 离线媒体加载、清晰度、收藏、历史和播放入口，并像网页端一样记录播放过的 1/16 段，离开页面时上报观看（`POST video/{id}/view`），这也构成网站端的观看记录；[pl_player](../../lib/app/components/plugin/pl_player/controller.dart) 基于 `media_kit` 管理播放器、控制栏、流订阅和定时器，音频会话在 `data/services/plugin/pl_player/`。
- Android 画中画使用 `floating`；Windows 画中画在媒体详情中通过 `window_manager` 调整并恢复窗口。退出详情、全屏切换、前后台切换都涉及资源生命周期。
- [DownloadService](../../lib/app/data/services/download_service.dart) 使用 `background_downloader`，注册顶层状态 / 进度回调，并维护任务状态与持久记录。回调带有 `@pragma('vm:entry-point')`；修改下载逻辑时检查后台回调、权限、路径和任务恢复。下载按文件路径写入用户选择的目录：Android 11+ 依赖 `MANAGE_EXTERNAL_STORAGE`，Android 10 依赖 manifest 中的 `requestLegacyExternalStorage`；目录选择不能改用返回 `content://` 的 SAF 方式。删除下载统一走 `DownloadService.removeTask`：先取消任务，等下载器把取消写进它的记录，再删记录和文件；记录删得太早会被随后到达的状态更新写回，只删记录不取消则任务会在后台继续下载。
- 实验性"加速下载与播放"（`ConfigService.acceleratedTransfer`，默认关）由 [ParallelRangeProxy](../../lib/app/utils/parallel_range_proxy.dart) 实现，在 127.0.0.1 为播放器与下载器提供可 seek 的 HTTP 文件。先发送一个连续 Range 请求，同时取得大小和正文，GET 不再额外探测文件长度。上游不支持 Range 时按原状态流式转发；本机 HEAD 则通过单字节 GET 获得大小，以兼容拒绝 HEAD 的文件服务器。
    - [TransferBaseline](../../lib/app/utils/transfer_baseline.dart) 观察当前连续传输，丢弃起步窗口；至少 3 秒且 512 KiB 后，以最近两个相近窗口中较高的速度作为单流基线。持续爬升 / 抖动时先等待，9 秒仍不稳定则保持原连接。小文件或剩余不足两段时也不试探。段大小约为 2 秒的数据量，生产范围 1–4 MiB，先试两路，有收益再增至最多四路；低于单流基线的 115% 或明显低于上一轮时，从已交付偏移继续单流。每个读取方保留普通连接，同主机共享最多三条额外连接，拿不到名额就继续单流。预取最多约三段 / 12 MiB，不因预加载时长增加并行数。
    - 默认预加载时，播放器传入媒体时长，单流达到所选文件平均码率的 1.5 倍就跳过试探。更长 / 完整预加载传入 `eager=1`，仍要求实际并行收益，但不会因为单流够播放就放弃加快预加载；下载继续按吞吐判断。参数兼容旧本机 URL。策略逐次传输判断，不修改 Clash / NekoBox 设置；试探有请求成本，并行不保证每条线路都更快。
    - 每段核对 `206`、`Content-Range` 的起止位置和总长、声明长度及已有 ETag；有强 ETag 时续传附带 `If-Range`，下载器原有的 `If-Range` 也透传，上游文件改变时保留其 `200` 完整响应，不能将新内容误接到旧文件后。超时或截断按已收到字节重试，只累计连续无进展的失败（最多三次），收到新字节就重置额度；校验失败会关闭响应，不把错误分段当成功文件。连接建立与响应头共用 10 秒预算，正文停滞看门狗为 5 秒；读取方断开或半关闭时取消请求并释放本机连接，读取方背压时暂停取数和正文看门狗。
    - 本机地址内含上游 URL，端口固定为 38291（被占用时换随机端口）。`DownloadService` 启动时若有未完成的加速任务会先启动代理，恢复 / 重试时按当前端口改写任务地址。
    - 开关在创建播放源和下载任务时读取；已有下载任务保留原 URL，开关不会自动切换正在进行的传输。旧的本机 URL 兼容新的调度方式。
    - 下载器经明文 HTTP 访问代理，manifest 引用的 `res/xml/network_security_config.xml` 仅对 127.0.0.1 放开明文。
    - 加速模式下播放器直连本机代理（清空 mpv 的 `http-proxy`），代理向上游的请求沿用应用代理（`HttpOverrides`）或系统 VPN。
    - [PlaybackPreload](../../lib/app/utils/playback_cache.dart) 定义两种模式共用的预加载策略，存于 `ConfigKey.playbackPreload`，新打开的视频生效。默认 30 秒、前向 32 MiB / 后向 8 MiB；1 / 3 / 10 分钟分别为 64+16 / 128+32 / 256+64 MiB，先碰到时间或内存上限就停止提前读取。完整视频使用应用临时目录保存包数据，前 / 后各 128 MiB 只限制元数据，保留已缓存片段供快进回看，关闭该媒体后由 mpv 清理；它不是离线下载，尚未加载的区间仍需网络。参见 [mpv 缓存文档](https://mpv.io/manual/stable/#cache)。换源时重新应用所有参数，完整模式切回默认不会残留磁盘设置。代理看门狗 5 秒，加速播放等待 20 秒，为重试留出时间。
    - 代理运行在应用进程内，进程结束后加速下载会失败，回到应用后可重试续传。
- [DiscordRpcService](../../lib/app/data/services/discord_rpc_service.dart) 通过本地插件发布播放状态，目前仅在 Windows / Linux 启用，由设置控制。

平台目录、条件导出或单项插件适配都不代表整个应用已验证。当前源码有 `dart:io` 和多项原生插件，Web 等平台需单独验证。
