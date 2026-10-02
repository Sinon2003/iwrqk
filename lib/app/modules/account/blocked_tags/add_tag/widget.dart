import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iwrqk/i18n/strings.g.dart';

import '../../../../components/suggestion_panel.dart';
import '../../../../components/tag_catalog.dart';
import '../../../../components/tag_label.dart';
import 'controller.dart';

class AddTagPage extends GetWidget<AddTagController> {
  final void Function(List<String> tags) onConfirm;
  const AddTagPage({super.key, required this.onConfirm});

  Widget _buildTagAutocomplete(BuildContext context) {
    return RawAutocomplete<String>(
      focusNode: controller.tagFocusNode,
      textEditingController: controller.tagEditingController,
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return const Iterable<String>.empty();
        }
        return controller.autoCompleteTags(textEditingValue.text);
      },
      fieldViewBuilder:
          (
            BuildContext context,
            TextEditingController textEditingController,
            FocusNode focusNode,
            VoidCallback onFieldSubmitted,
          ) {
            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.fromLTRB(4, 6, 16, 6),
              child: Theme(
                data: Theme.of(context).brightness == Brightness.light
                    ? ThemeData.light()
                    : ThemeData.dark(),
                child: TextFormField(
                  controller: textEditingController,
                  focusNode: focusNode,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return t.message.please_type_host;
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    hintText: t.filter.tag,
                    border: InputBorder.none,
                  ),
                ),
              ),
            );
          },
      optionsViewBuilder:
          (
            BuildContext context,
            AutocompleteOnSelected<String> onSelected,
            Iterable<String> options,
          ) {
            return SuggestionPanel<String>(
              options: options,
              itemBuilder: (context, option) => TagOptionTile(option),
              onPick: (option) {
                onSelected.call(option);
                controller.addTag(option);
              },
            );
          },
    );
  }

  Widget _buildTagClip(BuildContext context, int index) {
    String tag = controller.selectedTags[index];

    return InputChip(
      label: TagLabel(tag),
      onDeleted: () {
        controller.removeTag(tag);
      },
    );
  }

  Widget _buildContent(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(t.blocked_tags.add_blocked_tag),
        actions: [
          TextButton(
            onPressed: () {
              List<String> tags = controller.selectedTags;

              if (tags.isNotEmpty) {
                onConfirm(tags);
              }

              Get.back();
            },
            child: Text(t.notifications.confirm),
          ),
        ],
      ),
      body: CustomScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            sliver: SliverList.list(
              children: [
                _buildTagAutocomplete(context),
                Obx(
                  () => Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: List.generate(
                        controller.selectedTags.length,
                        (index) => _buildTagClip(context, index),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          TagCatalog(
            isPicked: controller.isSelected,
            onToggle: controller.toggleTag,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return OpenContainer(
      closedElevation: 0,
      openElevation: 0,
      openColor: Theme.of(context).colorScheme.surface,
      middleColor: Theme.of(context).colorScheme.surface,
      closedColor: Theme.of(context).colorScheme.surface,
      closedShape: const CircleBorder(),
      closedBuilder: (context, action) {
        return IconButton(onPressed: action, icon: const Icon(Icons.add));
      },
      openShape: Border.all(color: Colors.transparent),
      openBuilder: (context, action) {
        return _buildContent(context);
      },
    );
  }
}
