import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:iwrqk/i18n/strings.g.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../components/buttons/follow_button/widget.dart';
import '../../components/buttons/friend_button/widget.dart';
import '../../components/load_fail.dart';
import '../../components/media_preview/media_preview.dart';
import '../../components/network_image.dart';
import '../../data/enums/types.dart';
import '../../routes/pages.dart';
import '../../utils/clipboard_util.dart';
import '../../utils/display_util.dart';
import 'controller.dart';
import 'guestbook/page.dart';
import 'profile_detail/page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ProfileController _controller = Get.find();

  Widget _buildJoinSeenAtDate() {
    Widget createdAtWidget = Text(
      "${t.profile.join_date}：${DisplayUtil.getDisplayDate(DateTime.parse(_controller.profile.user!.createdAt))}",
      style: const TextStyle(fontSize: 14),
    );

    String? seenAt = _controller.profile.user!.seenAt;

    if (seenAt != null) {
      Duration difference = DateTime.now().difference(DateTime.parse(seenAt));
      if (difference.inMinutes <= 5) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              createdAtWidget,
              const SizedBox(width: 8),
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.green,
                      ),
                    ),
                    Expanded(
                      child: AutoSizeText(
                        t.profile.online,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      } else {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              createdAtWidget,
              Text(
                "${t.profile.last_active_time}：${DisplayUtil.getDisplayDate(DateTime.parse(seenAt))}",
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        );
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: createdAtWidget,
    );
  }

  bool get _isMyself =>
      _controller.profile.user!.id == _controller.userService.user?.id;

  String get _profileUrl =>
      "https://www.iwara.tv/profile/${_controller.profile.user!.username}";

  Widget _buildActionButtons() {
    if (_isMyself) {
      return SizedBox(
        width: double.infinity,
        child: FilledButton.tonalIcon(
          onPressed: () async {
            await Get.toNamed(AppRoutes.accountSettings);
            _controller.loadData();
          },
          icon: const Icon(Icons.edit, size: 18),
          label: Text(t.profile.edit_profile),
        ),
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Expanded(
          child: FollowButton(isSmall: true, user: _controller.profile.user!),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: FriendButton(isSmall: true, user: _controller.profile.user!),
        ),
      ],
    );
  }

  /// Asks for a title and a first message, then opens the new conversation.
  Future<void> _startConversation() async {
    final titleController = TextEditingController();
    final bodyController = TextEditingController();
    final send = await Get.dialog<bool>(
      AlertDialog(
        title: Text(t.messages.new_conversation),
        content: SizedBox(
          width: Get.width * 0.8,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: t.messages.conversation_title,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: bodyController,
                minLines: 3,
                maxLines: 8,
                decoration: InputDecoration(labelText: t.messages.message_hint),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(t.notifications.cancel),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text(t.messages.send),
          ),
        ],
      ),
    );
    final title = titleController.text.trim();
    final body = bodyController.text.trim();
    titleController.dispose();
    bodyController.dispose();
    if (send != true) return;
    if (title.isEmpty || body.isEmpty) {
      SmartDialog.showToast(t.messages.fields_required);
      return;
    }
    final id = await _controller.userService.createConversation(
      userId: _controller.profile.user!.id,
      title: title,
      body: body,
    );
    if (id != null) {
      Get.toNamed("/conversationDetail?id=$id", arguments: {"title": title});
    }
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, top: 12),
          child: Row(
            children: [
              ClipOval(
                child: NetworkImg(
                  imageUrl: _controller.profile.user!.avatarUrl,
                  width: 96,
                  height: 96,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.mediumImpact();
                            Get.toNamed(
                              "/followersFollowing?type=following&userId=${_controller.profile.user!.id}",
                            );
                          },
                          child: Column(
                            children: [
                              Text(
                                DisplayUtil.compactBigNumber(
                                  _controller.followingNum,
                                ),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(t.profile.following),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.mediumImpact();
                            Get.toNamed(
                              "/followersFollowing?type=followers&userId=${_controller.profile.user!.id}",
                            );
                          },
                          child: Column(
                            children: [
                              Text(
                                DisplayUtil.compactBigNumber(
                                  _controller.followersNum,
                                ),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(t.profile.followers),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: _buildActionButtons(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            _controller.profile.user!.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            "@${_controller.profile.user!.username}",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 14),
          ),
        ),
        const SizedBox(height: 4),
        InkWell(
          onTap: () {
            Get.to(() => ProfileDetailPage(profile: _controller.profile));
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    _controller.profile.body.isEmpty
                        ? t.profile.no_description
                        : _controller.profile.body.trim(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                const Icon(Icons.chevron_right, size: 16),
              ],
            ),
          ),
        ),
        _buildJoinSeenAtDate(),
      ],
    );
  }

  List<Widget> _buildUserWorksPreviews() {
    return [
      if (_controller.popularVideos.count != 0) ...[
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Text(
              t.nav.videos,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          sliver: SliverGrid(
            delegate: SliverChildBuilderDelegate((context, index) {
              return MediaPreview(
                media: _controller.popularVideos.results[index],
              );
            }, childCount: _controller.popularVideos.results.length),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              childAspectRatio: _controller.configService.gridChildAspectRatio,
              crossAxisCount: _controller.configService.crossAxisCount,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
          ),
        ),
        if (_controller.popularVideos.results.length >= 8)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: OutlinedButton(
                onPressed: () {
                  Get.toNamed(
                    "/uploadedMedia?userId=${_controller.profile.user!.id}&type=uploaderVideos",
                    arguments: {
                      "user": _controller.profile.user,
                      "sourceType": MediaSourceType.uploaderVideos,
                    },
                    preventDuplicates: false,
                  );
                },
                child: Text(t.profile.view_more),
              ),
            ),
          ),
      ],
      if (_controller.popularImages.count != 0) ...[
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Text(
              t.nav.images,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          sliver: SliverGrid(
            delegate: SliverChildBuilderDelegate((context, index) {
              return MediaPreview(
                media: _controller.popularImages.results[index],
              );
            }, childCount: _controller.popularImages.results.length),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              childAspectRatio: _controller.configService.gridChildAspectRatio,
              crossAxisCount: _controller.configService.crossAxisCount,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
          ),
        ),
        if (_controller.popularImages.results.length >= 8)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: OutlinedButton(
                onPressed: () {
                  Get.toNamed(
                    "/uploadedMedia?userId=${_controller.profile.user!.id}&type=uploaderImages",
                    arguments: {
                      "user": _controller.profile.user,
                      "sourceType": MediaSourceType.uploaderImages,
                    },
                    preventDuplicates: false,
                  );
                },
                child: Text(t.profile.view_more),
              ),
            ),
          ),
      ],
    ];
  }

  Widget _buildTitle() {
    return ListTile(
      leading: ClipOval(
        child: NetworkImg(
          imageUrl: _controller.profile.user!.avatarUrl,
          width: 40,
          height: 40,
        ),
      ),
      title: Text(
        _controller.profile.user!.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildDataWidget() {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: Get.width / 3,
              pinned: true,
              iconTheme: innerBoxIsScrolled
                  ? null
                  : const IconThemeData(color: Colors.white),
              flexibleSpace: FlexibleSpaceBar(
                background: ColoredBox(
                  color: Colors.black,
                  child: Stack(
                    children: <Widget>[
                      Positioned.fill(
                        child: NetworkImg(
                          imageUrl: _controller.profile.bannerUrl,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const Positioned.fill(
                        child: Opacity(
                          opacity: 0.4,
                          child: ColoredBox(color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              centerTitle: false,
              title: AnimatedOpacity(
                opacity: innerBoxIsScrolled ? 1 : 0,
                duration: const Duration(milliseconds: 300),
                child: _buildTitle(),
              ),
              titleSpacing: 0,
              actions: [
                if (!_isMyself)
                  IconButton(
                    tooltip: t.messages.new_conversation,
                    onPressed: _startConversation,
                    icon: const Icon(Icons.message),
                  ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      onTap: () => ClipboardUtil.copy(_profileUrl),
                      child: Text(t.profile.copy_link),
                    ),
                    PopupMenuItem(
                      onTap: () => launchUrlString(
                        _profileUrl,
                        mode: LaunchMode.externalApplication,
                      ),
                      child: Text(t.profile.open_in_browser),
                    ),
                    if (!_isMyself && _controller.userService.canBlockUsers)
                      PopupMenuItem(
                        onTap: _controller.toggleBlocked,
                        child: Text(
                          _controller.blocked
                              ? t.profile.unblock
                              : t.profile.block,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ];
        },
        body: Obx(
          () => CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildHeader()),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: InkWell(
                    onTap: () {
                      Get.to(
                        () => GuestbookPage(user: _controller.profile.user!),
                      );
                    },
                    child: ListTile(
                      title: Text(
                        t.profile.guestbook,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      trailing: const Icon(Icons.arrow_forward),
                    ),
                  ),
                ),
              ),
              if (_controller.isFetchingWorksPreview)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 54),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                )
              else if (_controller.fetchWorksPreviewMessage != null)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 54),
                    child: LoadFail(
                      errorMessage: _controller.fetchWorksPreviewMessage!,
                      onRefresh: _controller.fetchWorksPreview,
                    ),
                  ),
                ),
              if (!_controller.isFetchingWorksPreview &&
                  _controller.fetchWorksPreviewMessage == null)
                ..._buildUserWorksPreviews(),
              SliverToBoxAdapter(
                child: SizedBox(height: Get.mediaQuery.padding.bottom + 32),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _controller.obx(
      (state) {
        return _buildDataWidget();
      },
      onError: (error) {
        return Scaffold(
          appBar: AppBar(title: Text(t.profile.profile)),
          body: LoadFail(
            errorMessage: error.toString(),
            onRefresh: _controller.loadData,
          ),
        );
      },
      onLoading: Scaffold(
        appBar: AppBar(title: Text(t.profile.profile)),
        body: const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
