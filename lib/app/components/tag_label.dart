import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../data/services/tag_name_service.dart';

/// A tag as text: its name in the app language when tag names are on, and
/// its id otherwise.
class TagLabel extends StatelessWidget {
  const TagLabel(this.id, {super.key, this.style});

  final String id;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final TagNameService names = Get.find();
    return Obx(() => Text(names.label(id), style: style));
  }
}

/// A tag in a list to pick from. With tag names on, the id follows the name:
/// it is what the site knows the tag by, and it tells apart tags whose names
/// read alike.
class TagOptionTile extends StatelessWidget {
  const TagOptionTile(this.id, {super.key});

  final String id;

  @override
  Widget build(BuildContext context) {
    final TagNameService names = Get.find();
    final theme = Theme.of(context);
    return Obx(() {
      final name = names.label(id);
      return ListTile(
        title: Text.rich(
          TextSpan(
            text: name,
            children: [
              if (name != id)
                TextSpan(
                  text: '  $id',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
            ],
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      );
    });
  }
}
