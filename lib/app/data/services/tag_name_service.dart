import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iwrqk/i18n/strings.g.dart';

import '../../utils/log_util.dart';
import '../../utils/tag_groups.dart';
import '../../utils/tag_names.dart';
import 'config_service.dart';

/// Shows the site's tags by name instead of by id, in the app languages that
/// have a table of names, when the setting for it is on.
class TagNameService extends GetxService {
  final ConfigService _configService = Get.find();

  /// The tables shipped with the app, by app language.
  static const assets = {
    AppLocale.zhCn: 'assets/tags/zh-CN.json',
    AppLocale.zhTw: 'assets/tags/zh-TW.json',
  };

  /// The tags to browse, by group; the same table for every language.
  static const groupsAsset = 'assets/tags/groups.json';

  final Rx<TagNames> _names = TagNames.empty.obs;
  String? _asset;

  final Rx<TagGroups> _groups = TagGroups.empty.obs;
  bool _groupsRequested = false;

  /// Whether the current app language has names for tags at all.
  bool get available => assets.containsKey(LocaleSettings.currentLocale);

  // The setting is read first, so an `Obx` always has something to follow.
  bool get enabled => _configService.localizedTags && available;

  /// The table in use: the one of the app language, or an empty one while
  /// names are off or the language has none.
  TagNames get _current {
    if (!enabled) return TagNames.empty;
    _load();
    return _names.value;
  }

  /// What to show for the tag [id]: its name, or the id when names are off
  /// or the table does not have this tag. Read inside an `Obx`, it follows
  /// the setting and the table arriving.
  String label(String id) => _current.of(id) ?? id;

  /// Suggestions for a tag being typed; see [TagNames.complete].
  Future<List<String>> complete(
    String keyword,
    Future<List<String>> Function(String keyword) site,
  ) {
    return _current.complete(keyword, site);
  }

  /// The tags to browse, by group. Empty until the table has loaded; read
  /// inside an `Obx`, it follows the table arriving.
  TagGroups get groups {
    if (!_groupsRequested) {
      _groupsRequested = true;
      rootBundle
          .loadString(groupsAsset)
          .then((source) => _groups.value = TagGroups.fromJson(source))
          .catchError((Object e, StackTrace stackTrace) {
            LogUtil.warning('Tag groups failed to load', e, stackTrace);
            return TagGroups.empty;
          });
    }
    return _groups.value;
  }

  /// Loads the table of the current language, once per language.
  void _load() {
    final asset = assets[LocaleSettings.currentLocale];
    if (asset == null || asset == _asset) return;
    _asset = asset;
    rootBundle
        .loadString(asset)
        .then((source) {
          // The language may have changed again while this one loaded.
          if (_asset == asset) _names.value = TagNames.fromJson(source);
        })
        .catchError((Object e, StackTrace stackTrace) {
          LogUtil.warning('Tag names $asset failed to load', e, stackTrace);
        });
  }
}
