import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:iwrqk/i18n/strings.g.dart';

import '../data/services/tag_name_service.dart';
import '../utils/tag_groups.dart';

/// The tags the app knows, to browse and pick from: a row of groups and the
/// tags of the chosen one. It comes from the tables shipped with the app, so
/// nothing is fetched.
///
/// A sliver as wide as the page: it scrolls with what is above it, and the
/// groups stay in view once they reach the top.
class TagCatalog extends StatelessWidget {
  const TagCatalog({super.key, required this.isPicked, required this.onToggle});

  /// The space kept free at both sides of the page.
  static const double gutter = 16;

  /// Whether a tag is picked. It is asked inside an `Obx`, so the answer may
  /// come from something observable.
  final bool Function(String id) isPicked;

  /// Picks the tag, or drops it when it is picked.
  final void Function(String id) onToggle;

  @override
  Widget build(BuildContext context) {
    final TagNameService names = Get.find();
    return Obx(
      () => TagCatalogView(
        groups: names.groups,
        label: names.label,
        withIds: names.enabled,
        isPicked: isPicked,
        onToggle: onToggle,
      ),
    );
  }
}

/// [TagCatalog] without where its tags and their names come from.
class TagCatalogView extends StatefulWidget {
  const TagCatalogView({
    super.key,
    required this.groups,
    required this.label,
    required this.withIds,
    required this.isPicked,
    required this.onToggle,
  });

  final TagGroups groups;

  /// What to show for a tag; asked inside an `Obx`.
  final String Function(String id) label;

  /// Whether tags are shown by a name, with the id under it.
  final bool withIds;

  final bool Function(String id) isPicked;
  final void Function(String id) onToggle;

  @override
  State<TagCatalogView> createState() => _TagCatalogViewState();
}

class _TagCatalogViewState extends State<TagCatalogView> {
  final GlobalKey _top = GlobalKey();
  String? _group;

  void _show(String group) {
    setState(() => _group = group);

    // Another group starts at its beginning: scroll back to where the row of
    // groups sits, unless that is still below.
    final box = _top.currentContext?.findRenderObject();
    final position = Scrollable.maybeOf(context)?.position;
    if (box == null || position == null) return;
    final start = RenderAbstractViewport.of(box).getOffsetToReveal(box, 0);
    if (position.pixels > start.offset) position.jumpTo(start.offset);
  }

  @override
  Widget build(BuildContext context) {
    final keys = widget.groups.keys;
    if (keys.isEmpty) return const SliverToBoxAdapter();
    final group = keys.contains(_group) ? _group! : keys.first;
    final tags = widget.groups.of(group);

    final scaler = MediaQuery.textScalerOf(context);
    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(child: SizedBox(key: _top)),
        SliverPersistentHeader(
          pinned: true,
          delegate: _GroupBar(
            groups: keys,
            shown: group,
            onShow: _show,
            color: Theme.of(context).colorScheme.surface,
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            TagCatalog.gutter,
            0,
            TagCatalog.gutter,
            16,
          ),
          sliver: SliverGrid.builder(
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 240,
              mainAxisExtent: widget.withIds
                  ? scaler.scale(36) + 16
                  : scaler.scale(20) + 20,
              crossAxisSpacing: 8,
              mainAxisSpacing: 4,
            ),
            itemCount: tags.length,
            itemBuilder: (context, index) => _TagCell(
              // A cell keeps to its tag when the group changes under it.
              key: ValueKey(tags[index]),
              id: tags[index],
              label: widget.label,
              isPicked: widget.isPicked,
              onToggle: widget.onToggle,
            ),
          ),
        ),
      ],
    );
  }
}

/// What a group of the catalogue is called in the app language.
String tagGroupName(String group) => switch (group) {
  'common' => t.tag_groups.common,
  'acts' => t.tag_groups.acts,
  'kinks' => t.tag_groups.kinks,
  'body' => t.tag_groups.body,
  'outfits' => t.tag_groups.outfits,
  'roles' => t.tag_groups.roles,
  'scenes' => t.tag_groups.scenes,
  'music' => t.tag_groups.music,
  'production' => t.tag_groups.production,
  'series' => t.tag_groups.series,
  'characters' => t.tag_groups.characters,
  'others' => t.tag_groups.others,
  // A group the table has and this build has no word for.
  _ => group,
};

/// The row of groups, which stays at the top while the tags scroll under it.
class _GroupBar extends SliverPersistentHeaderDelegate {
  const _GroupBar({
    required this.groups,
    required this.shown,
    required this.onShow,
    required this.color,
  });

  static const double height = 56;

  final List<String> groups;
  final String shown;
  final void Function(String group) onShow;
  final Color color;

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return ColoredBox(
      color: color,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: TagCatalog.gutter,
          vertical: 8,
        ),
        itemCount: groups.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final group = groups[index];
          return ChoiceChip(
            label: Text(tagGroupName(group)),
            selected: group == shown,
            showCheckmark: false,
            onSelected: (_) => onShow(group),
          );
        },
      ),
    );
  }

  @override
  bool shouldRebuild(_GroupBar oldDelegate) =>
      oldDelegate.shown != shown ||
      oldDelegate.color != color ||
      !listEquals(oldDelegate.groups, groups);
}

/// One tag of the catalogue: its name over its id, marked when it is picked.
class _TagCell extends StatelessWidget {
  const _TagCell({
    super.key,
    required this.id,
    required this.label,
    required this.isPicked,
    required this.onToggle,
  });

  final String id;
  final String Function(String id) label;
  final bool Function(String id) isPicked;
  final void Function(String id) onToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Obx(() {
      final picked = isPicked(id);
      final name = label(id);
      return Material(
        color: picked
            ? theme.colorScheme.secondaryContainer
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => onToggle(id),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium,
                      ),
                      if (name != id)
                        Text(
                          id,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                    ],
                  ),
                ),
                if (picked)
                  Icon(
                    Icons.check,
                    size: 18,
                    color: theme.colorScheme.onSecondaryContainer,
                  ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
