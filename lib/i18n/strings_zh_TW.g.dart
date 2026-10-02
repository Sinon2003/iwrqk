///
/// Generated file. Do not edit.
///
// coverage:ignore-file
// ignore_for_file: type=lint, unused_import
// dart format off

import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:slang/generated.dart';
import 'strings.g.dart';

// Path: <root>
class TranslationsZhTw extends Translations with BaseTranslations<AppLocale, Translations> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	TranslationsZhTw({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: AppLocale.zhTw,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <zh-TW>.
	final TranslationMetadata<AppLocale, Translations> _meta;
	@override TranslationMetadata<AppLocale, Translations> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key) ?? super[key];

	late final TranslationsZhTw _root = this; // ignore: unused_field

	@override 
	TranslationsZhTw $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => TranslationsZhTw(meta: meta ?? this.$meta);

	// Translations
	@override late final Translations$nav$zh_TW nav = Translations$nav$zh_TW.internal(_root);
	@override late final Translations$rules$zh_TW rules = Translations$rules$zh_TW.internal(_root);
	@override late final Translations$common$zh_TW common = Translations$common$zh_TW.internal(_root);
	@override late final Translations$refresh$zh_TW refresh = Translations$refresh$zh_TW.internal(_root);
	@override late final Translations$records$zh_TW records = Translations$records$zh_TW.internal(_root);
	@override late final Translations$account$zh_TW account = Translations$account$zh_TW.internal(_root);
	@override late final Translations$account_settings$zh_TW account_settings = Translations$account_settings$zh_TW.internal(_root);
	@override late final Translations$notification_list$zh_TW notification_list = Translations$notification_list$zh_TW.internal(_root);
	@override late final Translations$messages$zh_TW messages = Translations$messages$zh_TW.internal(_root);
	@override late final Translations$profile$zh_TW profile = Translations$profile$zh_TW.internal(_root);
	@override late final Translations$sort$zh_TW sort = Translations$sort$zh_TW.internal(_root);
	@override late final Translations$filter$zh_TW filter = Translations$filter$zh_TW.internal(_root);
	@override late final Translations$search$zh_TW search = Translations$search$zh_TW.internal(_root);
	@override late final Translations$time$zh_TW time = Translations$time$zh_TW.internal(_root);
	@override late final Translations$media$zh_TW media = Translations$media$zh_TW.internal(_root);
	@override late final Translations$player$zh_TW player = Translations$player$zh_TW.internal(_root);
	@override late final Translations$comment$zh_TW comment = Translations$comment$zh_TW.internal(_root);
	@override late final Translations$user$zh_TW user = Translations$user$zh_TW.internal(_root);
	@override late final Translations$friend$zh_TW friend = Translations$friend$zh_TW.internal(_root);
	@override late final Translations$blocked_tags$zh_TW blocked_tags = Translations$blocked_tags$zh_TW.internal(_root);
	@override late final Translations$download$zh_TW download = Translations$download$zh_TW.internal(_root);
	@override late final Translations$playlist$zh_TW playlist = Translations$playlist$zh_TW.internal(_root);
	@override late final Translations$channel$zh_TW channel = Translations$channel$zh_TW.internal(_root);
	@override late final Translations$create_thread$zh_TW create_thread = Translations$create_thread$zh_TW.internal(_root);
	@override late final Translations$thread$zh_TW thread = Translations$thread$zh_TW.internal(_root);
	@override late final Translations$notifications$zh_TW notifications = Translations$notifications$zh_TW.internal(_root);
	@override late final Translations$translation$zh_TW translation = Translations$translation$zh_TW.internal(_root);
	@override late final Translations$settings$zh_TW settings = Translations$settings$zh_TW.internal(_root);
	@override late final Translations$theme$zh_TW theme = Translations$theme$zh_TW.internal(_root);
	@override late final Translations$colors$zh_TW colors = Translations$colors$zh_TW.internal(_root);
	@override late final Translations$display_mode$zh_TW display_mode = Translations$display_mode$zh_TW.internal(_root);
	@override late final Translations$proxy$zh_TW proxy = Translations$proxy$zh_TW.internal(_root);
	@override late final Translations$message$zh_TW message = Translations$message$zh_TW.internal(_root);
	@override late final Translations$error$zh_TW error = Translations$error$zh_TW.internal(_root);
}

// Path: nav
class Translations$nav$zh_TW extends Translations$nav$en {
	Translations$nav$zh_TW.internal(TranslationsZhTw root) : this._root = root, super.internal(root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get subscriptions => '訂閱';
	@override String get videos => '影片';
	@override String get images => '圖片';
	@override String get forum => '論壇';
	@override String get search => '搜尋';
}

// Path: rules
class Translations$rules$zh_TW extends Translations$rules$en {
	Translations$rules$zh_TW.internal(TranslationsZhTw root) : this._root = root, super.internal(root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get title => '規則';
	@override String get accept => '接受';
	@override String get accept_desc => '我同意：已閱讀規則並且會隨時留意未來的規則變更。';
}

// Path: common
class Translations$common$zh_TW extends Translations$common$en {
	Translations$common$zh_TW.internal(TranslationsZhTw root) : this._root = root, super.internal(root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get video => '影片';
	@override String get image => '圖片';
	@override String get collapse => '收合';
	@override String get expand => '展開';
	@override String get translate => '翻譯';
	@override String get open => '打開';
}

// Path: refresh
class Translations$refresh$zh_TW extends Translations$refresh$en {
	Translations$refresh$zh_TW.internal(TranslationsZhTw root) : this._root = root, super.internal(root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get empty => '空空如也';
	@override String get drag_to_load => '下拉載入';
	@override String get release_to_load => '釋放載入';
	@override String get success => '載入成功';
	@override String get failed => '載入失敗';
	@override String get no_more => '沒有更多了';
	@override String get last_load => '上次載入於 %T';
}

// Path: records
class Translations$records$zh_TW extends Translations$records$en {
	Translations$records$zh_TW.internal(TranslationsZhTw root) : this._root = root, super.internal(root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get select_all => '全選';
	@override String get select_inverse => '反選';
	@override String selected_num({required Object num}) => '已選擇 ${num} 項';
	@override String get multiple_selection_mode => '多選模式';
	@override String get delete => '刪除';
	@override String get delete_all => '刪除所有';
	@override String get cloud_history => '雲端';
	@override String get local_history => '本機';
	@override String delete_selected_confirm({required Object num}) => '確定刪除選取的 ${num} 項嗎？';
	@override String get delete_all_history_confirm => '確定清空本機的歷史紀錄嗎？';
	@override String get delete_all_favorites_confirm => '確定將這個清單裡的內容全部取消收藏嗎？';
	@override String get delete_all_playlist_confirm => '確定移除這個播放清單裡的全部影片嗎？';
	@override String get cloud_history_desc => '帳號在所有裝置上的觀看紀錄';
	@override String get local_history_desc => '這台裝置上的觀看紀錄，可搜尋和刪除';
}

// Path: account
class Translations$account$zh_TW extends Translations$account$en {
	Translations$account$zh_TW.internal(TranslationsZhTw root) : this._root = root, super.internal(root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get captcha => '驗證碼';
	@override String get login => '登入';
	@override String get logout => '登出';
	@override String get register => '註冊';
	@override String get email => '電子郵件';
	@override String get email_or_username => '電子郵件或使用者名稱';
	@override String get password => '密碼';
	@override String get forgot_password => '忘記密碼';
	@override String get require_login => '請先登入';
}

// Path: account_settings
class Translations$account_settings$zh_TW extends Translations$account_settings$en {
	Translations$account_settings$zh_TW.internal(TranslationsZhTw root) : this._root = root, super.internal(root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get title => '帳號設定';
	@override String get profile => '個人資料';
	@override String get avatar => '頭像';
	@override String get header => '背景圖';
	@override String get tap_to_change => '點擊更換';
	@override String get not_set => '未填寫';
	@override String get content => '內容偏好';
	@override String get hide_sensitive => '隱藏敏感內容';
	@override String get hide_sensitive_desc => '隱藏帶有敏感標籤的影片和圖片';
	@override String get notifications => '通知設定';
	@override String get notify_comment => '有人評論我的內容時';
	@override String get notify_reply => '有人回覆我的評論時';
	@override String get notify_mention => '有人提到我時';
	@override String get security => '帳號安全';
	@override String get manage_on_web => '修改電子郵件、密碼或刪除帳號';
	@override String get manage_on_web_desc => '在 Iwara 網頁上操作';
	@override String get blocked_users => '封鎖的使用者';
}

// Path: notification_list
class Translations$notification_list$zh_TW extends Translations$notification_list$en {
	Translations$notification_list$zh_TW.internal(TranslationsZhTw root) : this._root = root, super.internal(root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get title => '通知';
	@override String get mark_read => '標為已讀';
	@override String get mark_all_read => '全部標為已讀';
	@override String get your_profile => '你的主頁';
	@override String get their_profile => '對方的主頁';
	@override String new_comment({required Object user, required Object item}) => '${user} 在 ${item} 發表了新評論';
	@override String new_reply({required Object user, required Object item}) => '${user} 回覆了你在 ${item} 的評論';
	@override String video_ready({required Object item}) => '你的影片 ${item} 已發布';
	@override String get warning => '你收到了一個警告，詳情請在網頁查看';
	@override String tag_approved({required Object item}) => '你建議的標籤 ${item} 已獲批准';
	@override String get joined_creator_program => '你已加入創作者計畫';
	@override String get review_approved => '你的內容已通過審核';
	@override String get review_rejected => '你的內容未通過審核';
	@override String get unknown => '新通知';
}

// Path: messages
class Translations$messages$zh_TW extends Translations$messages$en {
	Translations$messages$zh_TW.internal(TranslationsZhTw root) : this._root = root, super.internal(root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get title => '私訊';
	@override String get new_conversation => '發私訊';
	@override String get conversation_title => '標題';
	@override String get message_hint => '輸入訊息';
	@override String get send => '發送';
	@override String get load_older => '載入更早的訊息';
	@override String get delete_message => '刪除訊息';
	@override String get delete_confirm => '確定刪除這則訊息？';
	@override String get fields_required => '請填寫標題和內容';
}

// Path: profile
class Translations$profile$zh_TW extends Translations$profile$en {
	Translations$profile$zh_TW.internal(TranslationsZhTw root) : this._root = root, super.internal(root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get profile => '個人檔案';
	@override String get follow => '追蹤';
	@override String get followers => '粉絲';
	@override String get following => '正在追蹤';
	@override String get nickname => '暱稱';
	@override String get username => '使用者名稱';
	@override String get user_id => '使用者 ID';
	@override String get description => '個人簡介';
	@override String get no_description => '該使用者是個神秘人，不喜歡被人圍觀。';
	@override String get join_date => '加入日期';
	@override String get last_active_time => '最後上線時間';
	@override String get online => '在線上';
	@override String get message => '私訊';
	@override String get guestbook => '留言板';
	@override String get view_more => '查看更多';
	@override String get deleted_user => '已註銷的使用者';
	@override String get edit_profile => '編輯資料';
	@override String get copy_link => '複製主頁連結';
	@override String get open_in_browser => '在瀏覽器中開啟';
	@override String get block => '封鎖';
	@override String get unblock => '解除封鎖';
	@override String get user_blocked => '已封鎖該使用者';
	@override String get user_unblocked => '已解除封鎖';
}

// Path: sort
class Translations$sort$zh_TW extends Translations$sort$en {
	Translations$sort$zh_TW.internal(TranslationsZhTw root) : this._root = root, super.internal(root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get latest => '最新';
	@override String get trending => '趨勢';
	@override String get popularity => '熱門';
	@override String get most_views => '最多觀看';
	@override String get most_likes => '最多按讚';
	@override String get relevance => '相關度';
}

// Path: filter
class Translations$filter$zh_TW extends Translations$filter$en {
	Translations$filter$zh_TW.internal(TranslationsZhTw root) : this._root = root, super.internal(root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get all => '全部';
	@override String get filter => '篩選';
	@override String get rating => '分級';
	@override String get tag => '標籤';
	@override String get tags => '標籤';
	@override String get date => '日期';
	@override String get general => '普遍級';
	@override String get ecchi => '成人級';
	@override String get select_rating => '選擇分級';
	@override String get select_year => '選擇年份';
	@override String get select_month => '選擇月份';
}

// Path: search
class Translations$search$zh_TW extends Translations$search$en {
	Translations$search$zh_TW.internal(TranslationsZhTw root) : this._root = root, super.internal(root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get users => '使用者';
	@override String get threads => '帖子';
	@override String get search => '搜尋';
	@override late final Translations$search$history$zh_TW history = Translations$search$history$zh_TW.internal(_root);
}

// Path: time
class Translations$time$zh_TW extends Translations$time$en {
	Translations$time$zh_TW.internal(TranslationsZhTw root) : this._root = root, super.internal(root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String seconds_ago({required Object time}) => '${time} 秒前';
	@override String minutes_ago({required Object time}) => '${time} 分鐘前';
	@override String hours_ago({required Object time}) => '${time} 小時前';
	@override String days_ago({required Object time}) => '${time} 天前';
}

// Path: media
class Translations$media$zh_TW extends Translations$media$en {
	Translations$media$zh_TW.internal(TranslationsZhTw root) : this._root = root, super.internal(root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get private => '私人';
	@override String get add_to_playlist => '加入播放清單';
	@override String get external_video => '外部影片';
	@override String get share => '分享';
	@override String get download => '下載';
	@override String more_from({required Object username}) => '更多來自 ${username}';
	@override String get more_like_this => '類似作品';
	@override String updated_at({required Object time}) => '更新於 ${time}';
	@override String get detail => '詳細';
	@override String get comments => '評論';
}

// Path: player
class Translations$player$zh_TW extends Translations$player$en {
	Translations$player$zh_TW.internal(TranslationsZhTw root) : this._root = root, super.internal(root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String current_item({required Object item}) => '目前: ${item}';
	@override String get quality => '畫質';
	@override String get select_quality => '選擇畫質';
	@override String get playback_speed => '播放速度';
	@override String get select_playback_speed => '選擇播放速度';
	@override String get aspect_ratio => '長寬比';
	@override String get select_aspect_ratio => '選擇長寬比';
	@override late final Translations$player$aspect_ratios$zh_TW aspect_ratios = Translations$player$aspect_ratios$zh_TW.internal(_root);
	@override String seconds({required Object value}) => '${value} 秒';
	@override String get double_speed => '2 倍';
}

// Path: comment
class Translations$comment$zh_TW extends Translations$comment$en {
	Translations$comment$zh_TW.internal(TranslationsZhTw root) : this._root = root, super.internal(root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get comment => '評論';
	@override String get comments => '評論';
	@override String get comment_detail => '評論詳情';
	@override String get edit_comment => '編輯評論';
	@override String get delete_comment => '刪除評論';
	@override String get reply => '回覆';
	@override String replies_in_total({required Object numReply}) => '共 ${numReply} 條回覆';
	@override String show_all_replies({required Object numReply}) => '顯示全部 ${numReply} 條回覆';
}

// Path: user
class Translations$user$zh_TW extends Translations$user$en {
	Translations$user$zh_TW.internal(TranslationsZhTw root) : this._root = root, super.internal(root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get following => '正在關注';
	@override String get history => '歷史紀錄';
	@override String get blocked_tags => '封鎖標籤';
	@override String get friends => '好友';
	@override String get downloads => '下載';
	@override String get favorites => '收藏';
	@override String get playlists => '播放清單';
	@override String get settings => '系統設定';
	@override String get about => '關於';
}

// Path: friend
class Translations$friend$zh_TW extends Translations$friend$en {
	Translations$friend$zh_TW.internal(TranslationsZhTw root) : this._root = root, super.internal(root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get friend_requests => '好友請求';
	@override String get add_friend => '新增好友';
	@override String get pending => '待處理';
	@override String get unfriend => '解除好友關係';
	@override String get accept => '接受';
	@override String get reject => '拒絕';
	@override String unfriend_confirm({required Object name}) => '確定解除與 ${name} 的好友關係嗎？';
}

// Path: blocked_tags
class Translations$blocked_tags$zh_TW extends Translations$blocked_tags$en {
	Translations$blocked_tags$zh_TW.internal(TranslationsZhTw root) : this._root = root, super.internal(root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get add_blocked_tag => '新增封鎖標籤';
	@override String get blocked_tag => '封鎖標籤';
}

// Path: download
class Translations$download$zh_TW extends Translations$download$en {
	Translations$download$zh_TW.internal(TranslationsZhTw root) : this._root = root, super.internal(root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get create_download_task => '建立下載任務';
	@override String get unknown => '未知';
	@override String get enqueued => '等待中';
	@override String get downloading => '下載中';
	@override String get paused => '已暫停';
	@override String get finished => '已完成';
	@override String get failed => '下載失敗';
	@override String get retry => '重新下載';
	@override String get delete => '刪除下載任務';
	@override String get pause => '暫停';
	@override String get resume => '繼續';
	@override String get open_with => '用...開啟';
	@override String get jump_to_detail => '查看詳情';
	@override String get delete_confirm => '確定刪除這個下載嗎？已下載的檔案也會一併刪除。';
	@override String delete_selected_confirm({required Object num}) => '確定刪除選取的 ${num} 個下載嗎？已下載的檔案也會一併刪除。';
	@override String get delete_all_confirm => '確定刪除全部下載嗎？已下載的檔案也會一併刪除。';
}

// Path: playlist
class Translations$playlist$zh_TW extends Translations$playlist$en {
	Translations$playlist$zh_TW.internal(TranslationsZhTw root) : this._root = root, super.internal(root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get title => '播放清單標題';
	@override String get create => '創建播放清單';
	@override String get select => '選擇播放清單';
	@override String get edit_title => '編輯標題';
	@override String videos_count({required Object numVideo}) => '${numVideo} 個影片';
	@override String videos_count_plural({required Object numVideo}) => '${numVideo} 個影片';
	@override String get delete => '刪除播放清單';
	@override String get delete_confirm => '確定刪除這個播放清單嗎？清單裡的影片不會被刪除。';
	@override String delete_selected_confirm({required Object num}) => '確定刪除選取的 ${num} 個播放清單嗎？清單裡的影片不會被刪除。';
}

// Path: channel
class Translations$channel$zh_TW extends Translations$channel$en {
	Translations$channel$zh_TW.internal(TranslationsZhTw root) : this._root = root, super.internal(root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get administration => '管理者';
	@override String get announcements => '公告';
	@override String get feedback => '回饋';
	@override String get support => '支援';
	@override String get global => '全域';
	@override String get general => '一般';
	@override String get guides => '指南';
	@override String get questions => '幫助/問題';
	@override String get requests => '請求';
	@override String get sharing => '分享';
	@override String label({required Object numThread, required Object numPosts}) => '${numThread} 個帖子 ${numPosts} 個回覆';
}

// Path: create_thread
class Translations$create_thread$zh_TW extends Translations$create_thread$en {
	Translations$create_thread$zh_TW.internal(TranslationsZhTw root) : this._root = root, super.internal(root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get create_thread => '發帖';
	@override String get title => '標題';
	@override String get content => '內容';
}

// Path: thread
class Translations$thread$zh_TW extends Translations$thread$en {
	Translations$thread$zh_TW.internal(TranslationsZhTw root) : this._root = root, super.internal(root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get edit_title => '編輯標題';
	@override String get delete_thread_confirm => '這是首帖，刪除後整個主題都會被刪除，確定嗎？';
	@override String get thread_deleted => '主題已刪除';
	@override String get title_updated => '標題已更新';
}

// Path: notifications
class Translations$notifications$zh_TW extends Translations$notifications$en {
	Translations$notifications$zh_TW.internal(TranslationsZhTw root) : this._root = root, super.internal(root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get ok => '好的';
	@override String get success => '成功';
	@override String get error => '錯誤';
	@override String get loading => '載入中...';
	@override String get cancel => '取消';
	@override String get confirm => '確認';
	@override String get apply => '應用';
}

// Path: translation
class Translations$translation$zh_TW extends Translations$translation$en {
	Translations$translation$zh_TW.internal(TranslationsZhTw root) : this._root = root, super.internal(root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override late final Translations$translation$engines$zh_TW engines = Translations$translation$engines$zh_TW.internal(_root);
	@override late final Translations$translation$engine_notes$zh_TW engine_notes = Translations$translation$engine_notes$zh_TW.internal(_root);
	@override String get powered_by => '翻譯來源：';
	@override String get show => '顯示翻譯';
	@override String get hide => '收起翻譯';
	@override String get translating => '翻譯中…';
	@override String get choose_engine => '選擇翻譯來源';
	@override String get default_tag => '預設';
	@override String failed({required Object engine}) => '翻譯失敗（${engine}）';
	@override String get show_original => '顯示原文';
	@override late final Translations$translation$display_modes$zh_TW display_modes = Translations$translation$display_modes$zh_TW.internal(_root);
}

// Path: settings
class Translations$settings$zh_TW extends Translations$settings$en {
	Translations$settings$zh_TW.internal(TranslationsZhTw root) : this._root = root, super.internal(root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get appearance => '外觀設定';
	@override String get theme => '主題';
	@override String get theme_desc => '設定該軟體的主題';
	@override String get dynamic_color => '動態取色';
	@override String get dynamic_color_desc => '根據內容動態更改該軟體的顏色';
	@override String get custom_color => '自定義顏色';
	@override String get custom_color_desc => '自定義該軟體的主題色';
	@override String get language => '語言';
	@override String get language_desc => '設定該軟體的語言';
	@override String get display_mode => '顯示模式';
	@override String get display_mode_desc => '設定該軟體的顯示模式';
	@override String get work_mode => '工作模式';
	@override String get work_mode_desc => '隱藏所有 NSFW 內容的封面';
	@override String get to_ai_site => '切換到AI站點內容';
	@override String get to_ai_site_desc => '切換到AI站點查看AIGC內容';
	@override String get translation => '翻譯';
	@override String get default_translation_engine => '預設翻譯來源';
	@override String default_translation_engine_desc({required Object engine}) => '目前：${engine}';
	@override String get enabled_translation_engines => '啟用的翻譯來源';
	@override String enabled_translation_engines_desc({required Object engines}) => '長按翻譯時可選：${engines}';
	@override String get translation_display_mode => '翻譯顯示方式';
	@override String translation_display_mode_desc({required Object mode}) => '目前：${mode}';
	@override String get animated_preview => '動畫預覽';
	@override String get animated_preview_desc => '在懸停或長按時顯示可用的影片動畫預覽';
	@override String get network => '網路設定';
	@override String get enable_proxy => '啟用代理';
	@override String get enable_proxy_desc => '啟用代理服務';
	@override String get proxy => '代理設定';
	@override String get proxy_desc => '設定代理伺服器';
	@override String get player => '播放器設定';
	@override String get autoplay => '自動播放';
	@override String get autoplay_desc => '打開影片頁面時自動播放影片';
	@override String get background_play => '背景播放';
	@override String get background_play_desc => '允許該軟體在後台播放影片';
	@override String get discord_rich_presence => 'Discord Rich Presence';
	@override String get discord_rich_presence_desc => '在 Discord 中顯示軟體狀態與目前播放內容';
	@override String get download => '下載設定';
	@override String get download_path => '下載路徑';
	@override String get allow_media_scan => '允許媒體掃描';
	@override String get allow_media_scan_desc => '允許媒體掃描程式讀取下載的媒體檔案';
	@override String get logging => '日誌設定';
	@override String get enable_logging => '啟用日誌';
	@override String get enable_logging_desc => '啟用該軟體的日誌記錄';
	@override String get clear_log => '清除日誌';
	@override String clear_log_desc({required Object size}) => '目前日誌大小: ${size}';
	@override String get enable_verbose_logging => '啟用詳細日誌';
	@override String get enable_verbose_logging_desc => '記錄更詳細的日誌';
	@override String get about => '關於';
	@override String get check_update => '檢查更新';
	@override String get check_update_desc => '檢查是否有新版本可用';
	@override String get third_party_license => '第三方庫許可';
	@override String get third_party_license_desc => '查看第三方庫的許可證';
	@override String get experimental => '實驗性功能';
	@override String get accelerated_transfer => '加速下載與播放';
	@override String get accelerated_transfer_desc => '嘗試改善受限線路的播放和下載速度，並行沒有收益時自動使用單一連線。下載時需保持應用程式執行';
	@override String get preferred_quality => '預設畫質';
	@override String get quality_auto => '自動';
	@override String get quality_highest => '畫質優先';
	@override String get quality_smoothest => '流暢優先';
	@override String quality_fixed({required Object name}) => '指定 ${name}';
	@override String get quality_auto_desc => '依近期播放速度和影片大小選擇起始畫質，不額外消耗流量測速';
	@override String get quality_highest_desc => '總是選擇最高畫質';
	@override String get quality_smoothest_desc => '總是選擇最低畫質，適合慢速網路';
	@override String quality_fixed_desc({required Object name}) => '有 ${name} 時播放 ${name}，沒有則選低一檔';
}

// Path: theme
class Translations$theme$zh_TW extends Translations$theme$en {
	Translations$theme$zh_TW.internal(TranslationsZhTw root) : this._root = root, super.internal(root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get system => '跟隨系統';
	@override String get light => '淺色';
	@override String get dark => '深色';
}

// Path: colors
class Translations$colors$zh_TW extends Translations$colors$en {
	Translations$colors$zh_TW.internal(TranslationsZhTw root) : this._root = root, super.internal(root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get pink => '粉紅';
	@override String get red => '紅色';
	@override String get orange => '橙色';
	@override String get amber => '琥珀';
	@override String get yellow => '黃色';
	@override String get lime => '青檸';
	@override String get lightGreen => '淺綠';
	@override String get green => '綠色';
	@override String get teal => '青色';
	@override String get cyan => '藍綠';
	@override String get lightBlue => '淺藍';
	@override String get blue => '藍色';
	@override String get indigo => '藍靛';
	@override String get purple => '紫色';
	@override String get deepPurple => '深紫';
	@override String get blueGrey => '藍灰';
	@override String get brown => '棕色';
	@override String get grey => '灰色';
}

// Path: display_mode
class Translations$display_mode$zh_TW extends Translations$display_mode$en {
	Translations$display_mode$zh_TW.internal(TranslationsZhTw root) : this._root = root, super.internal(root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get no_available => '無可用顯示模式';
	@override String get auto => '自動';
	@override String get system => '系統';
}

// Path: proxy
class Translations$proxy$zh_TW extends Translations$proxy$en {
	Translations$proxy$zh_TW.internal(TranslationsZhTw root) : this._root = root, super.internal(root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get host => '主機名';
	@override String get port => '端口';
}

// Path: message
class Translations$message$zh_TW extends Translations$message$en {
	Translations$message$zh_TW.internal(TranslationsZhTw root) : this._root = root, super.internal(root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get exit_app => '再按一次退出該軟體';
	@override String get are_you_sure_to_do_that => '你確定要這麼做嗎？';
	@override String get restart_required => '重啟後生效';
	@override String get copied => '已複製到剪貼簿';
	@override String get please_type_host => '請輸入主機名';
	@override String get please_type_port => '請輸入端口';
	@override late final Translations$message$account$zh_TW account = Translations$message$account$zh_TW.internal(_root);
	@override late final Translations$message$comment$zh_TW comment = Translations$message$comment$zh_TW.internal(_root);
	@override late final Translations$message$create_thread$zh_TW create_thread = Translations$message$create_thread$zh_TW.internal(_root);
	@override late final Translations$message$blocked_tags$zh_TW blocked_tags = Translations$message$blocked_tags$zh_TW.internal(_root);
	@override late final Translations$message$playlist$zh_TW playlist = Translations$message$playlist$zh_TW.internal(_root);
	@override late final Translations$message$download$zh_TW download = Translations$message$download$zh_TW.internal(_root);
	@override late final Translations$message$update$zh_TW update = Translations$message$update$zh_TW.internal(_root);
}

// Path: error
class Translations$error$zh_TW extends Translations$error$en {
	Translations$error$zh_TW.internal(TranslationsZhTw root) : this._root = root, super.internal(root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get retry => '載入失敗，點擊重試';
	@override String get fetch_failed => '無法獲取影片連結';
	@override String get fetch_user_info_failed => '無法獲取使用者資訊';
	@override String get invalid_path => '無效的路徑';
	@override String get intercept_app_exit => '攔截應用程式退出';
	@override late final Translations$error$account$zh_TW account = Translations$error$account$zh_TW.internal(_root);
	@override late final Translations$error$network$zh_TW network = Translations$error$network$zh_TW.internal(_root);
}

// Path: search.history
class Translations$search$history$zh_TW extends Translations$search$history$en {
	Translations$search$history$zh_TW.internal(TranslationsZhTw root) : this._root = root, super.internal(root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get delete => '刪除所有紀錄';
	@override String get done => '完成';
}

// Path: player.aspect_ratios
class Translations$player$aspect_ratios$zh_TW extends Translations$player$aspect_ratios$en {
	Translations$player$aspect_ratios$zh_TW.internal(TranslationsZhTw root) : this._root = root, super.internal(root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get contain => '包含';
	@override String get cover => '覆蓋';
	@override String get fill => '填滿';
	@override String get fit_height => '適應高度';
	@override String get fit_width => '適應寬度';
	@override String get scale_down => '縮小適應';
}

// Path: translation.engines
class Translations$translation$engines$zh_TW extends Translations$translation$engines$en {
	Translations$translation$engines$zh_TW.internal(TranslationsZhTw root) : this._root = root, super.internal(root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get google => 'Google 翻譯';
	@override String get volcengine => '火山翻譯';
	@override String get tencent => '騰訊交互翻譯';
	@override String get yandex => 'Yandex 翻譯';
}

// Path: translation.engine_notes
class Translations$translation$engine_notes$zh_TW extends Translations$translation$engine_notes$en {
	Translations$translation$engine_notes$zh_TW.internal(TranslationsZhTw root) : this._root = root, super.internal(root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get google => '需要能連線到 Google';
	@override String get volcengine => '中國大陸可直連，速度快';
	@override String get tencent => '中國大陸可直連';
	@override String get yandex => '不支援輸出繁體中文';
}

// Path: translation.display_modes
class Translations$translation$display_modes$zh_TW extends Translations$translation$display_modes$en {
	Translations$translation$display_modes$zh_TW.internal(TranslationsZhTw root) : this._root = root, super.internal(root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get below => '顯示在原文下方';
	@override String get replace => '取代原文';
}

// Path: message.account
class Translations$message$account$zh_TW extends Translations$message$account$en {
	Translations$message$account$zh_TW.internal(TranslationsZhTw root) : this._root = root, super.internal(root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get login_success => '登入成功！';
	@override String get register_success => '註冊成功，請查看郵箱激活帳號。';
	@override String get login_password_longer_than_6 => '密碼長度至少為 6 位';
	@override String get please_type_email => '請輸入郵箱';
	@override String get please_type_email_or_username => '請輸入郵箱或用戶名';
	@override String get please_type_valid_email => '請輸入正確的郵箱';
	@override String get please_type_password => '請輸入密碼';
	@override String get please_type_captcha => '請輸入驗證碼';
}

// Path: message.comment
class Translations$message$comment$zh_TW extends Translations$message$comment$en {
	Translations$message$comment$zh_TW.internal(TranslationsZhTw root) : this._root = root, super.internal(root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get content_empty => '內容不能為空。';
	@override String get content_too_long => '內容不能超過 1000 個字符。';
	@override String get sent => '回覆已發送。';
}

// Path: message.create_thread
class Translations$message$create_thread$zh_TW extends Translations$message$create_thread$en {
	Translations$message$create_thread$zh_TW.internal(TranslationsZhTw root) : this._root = root, super.internal(root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get title_empty => '標題不能為空。';
	@override String get title_too_long => '標題不能太長。';
	@override String get content_empty => '內容不能為空。';
	@override String get content_too_long => '內容不能超過 20000 個字符。';
	@override String get created => '帖子已發送。';
}

// Path: message.blocked_tags
class Translations$message$blocked_tags$zh_TW extends Translations$message$blocked_tags$en {
	Translations$message$blocked_tags$zh_TW.internal(TranslationsZhTw root) : this._root = root, super.internal(root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get save_confirm => '確定保存屏蔽標籤嗎？';
	@override String get saved => '屏蔽標籤已保存。';
	@override String get reached_limit => '屏蔽標籤數量已達到上限。';
}

// Path: message.playlist
class Translations$message$playlist$zh_TW extends Translations$message$playlist$en {
	Translations$message$playlist$zh_TW.internal(TranslationsZhTw root) : this._root = root, super.internal(root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get empty_playlist_title => '播放列表標題不能為空。';
	@override String get playlist_created => '播放列表已創建。';
	@override String get playlist_title_edited => '播放列表標題已修改。';
	@override String get playlist_deleted => '播放清單已刪除。';
}

// Path: message.download
class Translations$message$download$zh_TW extends Translations$message$download$en {
	Translations$message$download$zh_TW.internal(TranslationsZhTw root) : this._root = root, super.internal(root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get no_provide_storage_permission => '未提供存儲權限。';
	@override String get task_already_exists => '下載任務已存在。';
	@override String get task_created => '下載任務已創建。';
	@override String get maximum_simultaneous_download_reached => '已達到最大同時下載數。';
}

// Path: message.update
class Translations$message$update$zh_TW extends Translations$message$update$en {
	Translations$message$update$zh_TW.internal(TranslationsZhTw root) : this._root = root, super.internal(root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get check_update_failed => '檢查更新失敗';
	@override String get update_available => '有新版本可用';
	@override String get already_latest_version => '已經是最新版本';
	@override String current_version({required Object version}) => '當前版本：${version}';
	@override String latest_version({required Object version}) => '最新版本：${version}';
	@override String downloading({required Object percent}) => '正在下載：${percent}%';
	@override String get download_in_background => '背景下載';
	@override String get download_failed => '更新下載失敗';
	@override String get install_failed => '無法開啟安裝程式';
	@override String download_size({required Object size}) => '下載大小：${size}';
	@override String get update_now => '立即更新';
	@override String get later => '稍後再說';
	@override String get skip_version => '跳過此版本';
}

// Path: error.account
class Translations$error$account$zh_TW extends Translations$error$account$en {
	Translations$error$account$zh_TW.internal(TranslationsZhTw root) : this._root = root, super.internal(root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get invalid_login => '郵箱或密碼錯誤';
	@override String get invalid_host => '無效的主機名';
	@override String get invalid_captcha => '驗證碼錯誤';
}

// Path: error.network
class Translations$error$network$zh_TW extends Translations$error$network$en {
	Translations$error$network$zh_TW.internal(TranslationsZhTw root) : this._root = root, super.internal(root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String offline({required Object cause}) => '網路或代理不通，其他網站也連不上。請檢查網路，或更換代理節點後重試（${cause}）';
	@override String site_unreachable({required Object cause}) => '連不上 Iwara，但其他網站正常。可能是 Iwara 暫時故障，或目前的代理節點無法存取 Iwara，請稍後重試或更換節點（${cause}）';
	@override String server({required Object status}) => 'Iwara 伺服器出錯（HTTP ${status}），請稍後重試';
	@override String get cause_handshake => 'TLS 交握失敗';
	@override String get cause_lookup => '網域解析失敗';
	@override String get cause_connection => '連線失敗';
	@override String get cause_timeout => '連線逾時';
}

/// The flat map containing all translations for locale <zh-TW>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on TranslationsZhTw {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'nav.subscriptions' => '訂閱',
			'nav.videos' => '影片',
			'nav.images' => '圖片',
			'nav.forum' => '論壇',
			'nav.search' => '搜尋',
			'rules.title' => '規則',
			'rules.accept' => '接受',
			'rules.accept_desc' => '我同意：已閱讀規則並且會隨時留意未來的規則變更。',
			'common.video' => '影片',
			'common.image' => '圖片',
			'common.collapse' => '收合',
			'common.expand' => '展開',
			'common.translate' => '翻譯',
			'common.open' => '打開',
			'refresh.empty' => '空空如也',
			'refresh.drag_to_load' => '下拉載入',
			'refresh.release_to_load' => '釋放載入',
			'refresh.success' => '載入成功',
			'refresh.failed' => '載入失敗',
			'refresh.no_more' => '沒有更多了',
			'refresh.last_load' => '上次載入於 %T',
			'records.select_all' => '全選',
			'records.select_inverse' => '反選',
			'records.selected_num' => ({required Object num}) => '已選擇 ${num} 項',
			'records.multiple_selection_mode' => '多選模式',
			'records.delete' => '刪除',
			'records.delete_all' => '刪除所有',
			'records.cloud_history' => '雲端',
			'records.local_history' => '本機',
			'records.delete_selected_confirm' => ({required Object num}) => '確定刪除選取的 ${num} 項嗎？',
			'records.delete_all_history_confirm' => '確定清空本機的歷史紀錄嗎？',
			'records.delete_all_favorites_confirm' => '確定將這個清單裡的內容全部取消收藏嗎？',
			'records.delete_all_playlist_confirm' => '確定移除這個播放清單裡的全部影片嗎？',
			'records.cloud_history_desc' => '帳號在所有裝置上的觀看紀錄',
			'records.local_history_desc' => '這台裝置上的觀看紀錄，可搜尋和刪除',
			'account.captcha' => '驗證碼',
			'account.login' => '登入',
			'account.logout' => '登出',
			'account.register' => '註冊',
			'account.email' => '電子郵件',
			'account.email_or_username' => '電子郵件或使用者名稱',
			'account.password' => '密碼',
			'account.forgot_password' => '忘記密碼',
			'account.require_login' => '請先登入',
			'account_settings.title' => '帳號設定',
			'account_settings.profile' => '個人資料',
			'account_settings.avatar' => '頭像',
			'account_settings.header' => '背景圖',
			'account_settings.tap_to_change' => '點擊更換',
			'account_settings.not_set' => '未填寫',
			'account_settings.content' => '內容偏好',
			'account_settings.hide_sensitive' => '隱藏敏感內容',
			'account_settings.hide_sensitive_desc' => '隱藏帶有敏感標籤的影片和圖片',
			'account_settings.notifications' => '通知設定',
			'account_settings.notify_comment' => '有人評論我的內容時',
			'account_settings.notify_reply' => '有人回覆我的評論時',
			'account_settings.notify_mention' => '有人提到我時',
			'account_settings.security' => '帳號安全',
			'account_settings.manage_on_web' => '修改電子郵件、密碼或刪除帳號',
			'account_settings.manage_on_web_desc' => '在 Iwara 網頁上操作',
			'account_settings.blocked_users' => '封鎖的使用者',
			'notification_list.title' => '通知',
			'notification_list.mark_read' => '標為已讀',
			'notification_list.mark_all_read' => '全部標為已讀',
			'notification_list.your_profile' => '你的主頁',
			'notification_list.their_profile' => '對方的主頁',
			'notification_list.new_comment' => ({required Object user, required Object item}) => '${user} 在 ${item} 發表了新評論',
			'notification_list.new_reply' => ({required Object user, required Object item}) => '${user} 回覆了你在 ${item} 的評論',
			'notification_list.video_ready' => ({required Object item}) => '你的影片 ${item} 已發布',
			'notification_list.warning' => '你收到了一個警告，詳情請在網頁查看',
			'notification_list.tag_approved' => ({required Object item}) => '你建議的標籤 ${item} 已獲批准',
			'notification_list.joined_creator_program' => '你已加入創作者計畫',
			'notification_list.review_approved' => '你的內容已通過審核',
			'notification_list.review_rejected' => '你的內容未通過審核',
			'notification_list.unknown' => '新通知',
			'messages.title' => '私訊',
			'messages.new_conversation' => '發私訊',
			'messages.conversation_title' => '標題',
			'messages.message_hint' => '輸入訊息',
			'messages.send' => '發送',
			'messages.load_older' => '載入更早的訊息',
			'messages.delete_message' => '刪除訊息',
			'messages.delete_confirm' => '確定刪除這則訊息？',
			'messages.fields_required' => '請填寫標題和內容',
			'profile.profile' => '個人檔案',
			'profile.follow' => '追蹤',
			'profile.followers' => '粉絲',
			'profile.following' => '正在追蹤',
			'profile.nickname' => '暱稱',
			'profile.username' => '使用者名稱',
			'profile.user_id' => '使用者 ID',
			'profile.description' => '個人簡介',
			'profile.no_description' => '該使用者是個神秘人，不喜歡被人圍觀。',
			'profile.join_date' => '加入日期',
			'profile.last_active_time' => '最後上線時間',
			'profile.online' => '在線上',
			'profile.message' => '私訊',
			'profile.guestbook' => '留言板',
			'profile.view_more' => '查看更多',
			'profile.deleted_user' => '已註銷的使用者',
			'profile.edit_profile' => '編輯資料',
			'profile.copy_link' => '複製主頁連結',
			'profile.open_in_browser' => '在瀏覽器中開啟',
			'profile.block' => '封鎖',
			'profile.unblock' => '解除封鎖',
			'profile.user_blocked' => '已封鎖該使用者',
			'profile.user_unblocked' => '已解除封鎖',
			'sort.latest' => '最新',
			'sort.trending' => '趨勢',
			'sort.popularity' => '熱門',
			'sort.most_views' => '最多觀看',
			'sort.most_likes' => '最多按讚',
			'sort.relevance' => '相關度',
			'filter.all' => '全部',
			'filter.filter' => '篩選',
			'filter.rating' => '分級',
			'filter.tag' => '標籤',
			'filter.tags' => '標籤',
			'filter.date' => '日期',
			'filter.general' => '普遍級',
			'filter.ecchi' => '成人級',
			'filter.select_rating' => '選擇分級',
			'filter.select_year' => '選擇年份',
			'filter.select_month' => '選擇月份',
			'search.users' => '使用者',
			'search.threads' => '帖子',
			'search.search' => '搜尋',
			'search.history.delete' => '刪除所有紀錄',
			'search.history.done' => '完成',
			'time.seconds_ago' => ({required Object time}) => '${time} 秒前',
			'time.minutes_ago' => ({required Object time}) => '${time} 分鐘前',
			'time.hours_ago' => ({required Object time}) => '${time} 小時前',
			'time.days_ago' => ({required Object time}) => '${time} 天前',
			'media.private' => '私人',
			'media.add_to_playlist' => '加入播放清單',
			'media.external_video' => '外部影片',
			'media.share' => '分享',
			'media.download' => '下載',
			'media.more_from' => ({required Object username}) => '更多來自 ${username}',
			'media.more_like_this' => '類似作品',
			'media.updated_at' => ({required Object time}) => '更新於 ${time}',
			'media.detail' => '詳細',
			'media.comments' => '評論',
			'player.current_item' => ({required Object item}) => '目前: ${item}',
			'player.quality' => '畫質',
			'player.select_quality' => '選擇畫質',
			'player.playback_speed' => '播放速度',
			'player.select_playback_speed' => '選擇播放速度',
			'player.aspect_ratio' => '長寬比',
			'player.select_aspect_ratio' => '選擇長寬比',
			'player.aspect_ratios.contain' => '包含',
			'player.aspect_ratios.cover' => '覆蓋',
			'player.aspect_ratios.fill' => '填滿',
			'player.aspect_ratios.fit_height' => '適應高度',
			'player.aspect_ratios.fit_width' => '適應寬度',
			'player.aspect_ratios.scale_down' => '縮小適應',
			'player.seconds' => ({required Object value}) => '${value} 秒',
			'player.double_speed' => '2 倍',
			'comment.comment' => '評論',
			'comment.comments' => '評論',
			'comment.comment_detail' => '評論詳情',
			'comment.edit_comment' => '編輯評論',
			'comment.delete_comment' => '刪除評論',
			'comment.reply' => '回覆',
			'comment.replies_in_total' => ({required Object numReply}) => '共 ${numReply} 條回覆',
			'comment.show_all_replies' => ({required Object numReply}) => '顯示全部 ${numReply} 條回覆',
			'user.following' => '正在關注',
			'user.history' => '歷史紀錄',
			'user.blocked_tags' => '封鎖標籤',
			'user.friends' => '好友',
			'user.downloads' => '下載',
			'user.favorites' => '收藏',
			'user.playlists' => '播放清單',
			'user.settings' => '系統設定',
			'user.about' => '關於',
			'friend.friend_requests' => '好友請求',
			'friend.add_friend' => '新增好友',
			'friend.pending' => '待處理',
			'friend.unfriend' => '解除好友關係',
			'friend.accept' => '接受',
			'friend.reject' => '拒絕',
			'friend.unfriend_confirm' => ({required Object name}) => '確定解除與 ${name} 的好友關係嗎？',
			'blocked_tags.add_blocked_tag' => '新增封鎖標籤',
			'blocked_tags.blocked_tag' => '封鎖標籤',
			'download.create_download_task' => '建立下載任務',
			'download.unknown' => '未知',
			'download.enqueued' => '等待中',
			'download.downloading' => '下載中',
			'download.paused' => '已暫停',
			'download.finished' => '已完成',
			'download.failed' => '下載失敗',
			'download.retry' => '重新下載',
			'download.delete' => '刪除下載任務',
			'download.pause' => '暫停',
			'download.resume' => '繼續',
			'download.open_with' => '用...開啟',
			'download.jump_to_detail' => '查看詳情',
			'download.delete_confirm' => '確定刪除這個下載嗎？已下載的檔案也會一併刪除。',
			'download.delete_selected_confirm' => ({required Object num}) => '確定刪除選取的 ${num} 個下載嗎？已下載的檔案也會一併刪除。',
			'download.delete_all_confirm' => '確定刪除全部下載嗎？已下載的檔案也會一併刪除。',
			'playlist.title' => '播放清單標題',
			'playlist.create' => '創建播放清單',
			'playlist.select' => '選擇播放清單',
			'playlist.edit_title' => '編輯標題',
			'playlist.videos_count' => ({required Object numVideo}) => '${numVideo} 個影片',
			'playlist.videos_count_plural' => ({required Object numVideo}) => '${numVideo} 個影片',
			'playlist.delete' => '刪除播放清單',
			'playlist.delete_confirm' => '確定刪除這個播放清單嗎？清單裡的影片不會被刪除。',
			'playlist.delete_selected_confirm' => ({required Object num}) => '確定刪除選取的 ${num} 個播放清單嗎？清單裡的影片不會被刪除。',
			'channel.administration' => '管理者',
			'channel.announcements' => '公告',
			'channel.feedback' => '回饋',
			'channel.support' => '支援',
			'channel.global' => '全域',
			'channel.general' => '一般',
			'channel.guides' => '指南',
			'channel.questions' => '幫助/問題',
			'channel.requests' => '請求',
			'channel.sharing' => '分享',
			'channel.label' => ({required Object numThread, required Object numPosts}) => '${numThread} 個帖子 ${numPosts} 個回覆',
			'create_thread.create_thread' => '發帖',
			'create_thread.title' => '標題',
			'create_thread.content' => '內容',
			'thread.edit_title' => '編輯標題',
			'thread.delete_thread_confirm' => '這是首帖，刪除後整個主題都會被刪除，確定嗎？',
			'thread.thread_deleted' => '主題已刪除',
			'thread.title_updated' => '標題已更新',
			'notifications.ok' => '好的',
			'notifications.success' => '成功',
			'notifications.error' => '錯誤',
			'notifications.loading' => '載入中...',
			'notifications.cancel' => '取消',
			'notifications.confirm' => '確認',
			'notifications.apply' => '應用',
			'translation.engines.google' => 'Google 翻譯',
			'translation.engines.volcengine' => '火山翻譯',
			'translation.engines.tencent' => '騰訊交互翻譯',
			'translation.engines.yandex' => 'Yandex 翻譯',
			'translation.engine_notes.google' => '需要能連線到 Google',
			'translation.engine_notes.volcengine' => '中國大陸可直連，速度快',
			'translation.engine_notes.tencent' => '中國大陸可直連',
			'translation.engine_notes.yandex' => '不支援輸出繁體中文',
			'translation.powered_by' => '翻譯來源：',
			'translation.show' => '顯示翻譯',
			'translation.hide' => '收起翻譯',
			'translation.translating' => '翻譯中…',
			'translation.choose_engine' => '選擇翻譯來源',
			'translation.default_tag' => '預設',
			'translation.failed' => ({required Object engine}) => '翻譯失敗（${engine}）',
			'translation.show_original' => '顯示原文',
			'translation.display_modes.below' => '顯示在原文下方',
			'translation.display_modes.replace' => '取代原文',
			'settings.appearance' => '外觀設定',
			'settings.theme' => '主題',
			'settings.theme_desc' => '設定該軟體的主題',
			'settings.dynamic_color' => '動態取色',
			'settings.dynamic_color_desc' => '根據內容動態更改該軟體的顏色',
			'settings.custom_color' => '自定義顏色',
			'settings.custom_color_desc' => '自定義該軟體的主題色',
			'settings.language' => '語言',
			'settings.language_desc' => '設定該軟體的語言',
			'settings.display_mode' => '顯示模式',
			'settings.display_mode_desc' => '設定該軟體的顯示模式',
			'settings.work_mode' => '工作模式',
			'settings.work_mode_desc' => '隱藏所有 NSFW 內容的封面',
			'settings.to_ai_site' => '切換到AI站點內容',
			'settings.to_ai_site_desc' => '切換到AI站點查看AIGC內容',
			'settings.translation' => '翻譯',
			'settings.default_translation_engine' => '預設翻譯來源',
			'settings.default_translation_engine_desc' => ({required Object engine}) => '目前：${engine}',
			'settings.enabled_translation_engines' => '啟用的翻譯來源',
			'settings.enabled_translation_engines_desc' => ({required Object engines}) => '長按翻譯時可選：${engines}',
			'settings.translation_display_mode' => '翻譯顯示方式',
			'settings.translation_display_mode_desc' => ({required Object mode}) => '目前：${mode}',
			'settings.animated_preview' => '動畫預覽',
			'settings.animated_preview_desc' => '在懸停或長按時顯示可用的影片動畫預覽',
			'settings.network' => '網路設定',
			'settings.enable_proxy' => '啟用代理',
			'settings.enable_proxy_desc' => '啟用代理服務',
			'settings.proxy' => '代理設定',
			'settings.proxy_desc' => '設定代理伺服器',
			'settings.player' => '播放器設定',
			'settings.autoplay' => '自動播放',
			'settings.autoplay_desc' => '打開影片頁面時自動播放影片',
			'settings.background_play' => '背景播放',
			'settings.background_play_desc' => '允許該軟體在後台播放影片',
			'settings.discord_rich_presence' => 'Discord Rich Presence',
			'settings.discord_rich_presence_desc' => '在 Discord 中顯示軟體狀態與目前播放內容',
			'settings.download' => '下載設定',
			'settings.download_path' => '下載路徑',
			'settings.allow_media_scan' => '允許媒體掃描',
			'settings.allow_media_scan_desc' => '允許媒體掃描程式讀取下載的媒體檔案',
			'settings.logging' => '日誌設定',
			'settings.enable_logging' => '啟用日誌',
			'settings.enable_logging_desc' => '啟用該軟體的日誌記錄',
			'settings.clear_log' => '清除日誌',
			'settings.clear_log_desc' => ({required Object size}) => '目前日誌大小: ${size}',
			'settings.enable_verbose_logging' => '啟用詳細日誌',
			'settings.enable_verbose_logging_desc' => '記錄更詳細的日誌',
			'settings.about' => '關於',
			'settings.check_update' => '檢查更新',
			'settings.check_update_desc' => '檢查是否有新版本可用',
			'settings.third_party_license' => '第三方庫許可',
			'settings.third_party_license_desc' => '查看第三方庫的許可證',
			'settings.experimental' => '實驗性功能',
			'settings.accelerated_transfer' => '加速下載與播放',
			'settings.accelerated_transfer_desc' => '嘗試改善受限線路的播放和下載速度，並行沒有收益時自動使用單一連線。下載時需保持應用程式執行',
			'settings.preferred_quality' => '預設畫質',
			'settings.quality_auto' => '自動',
			'settings.quality_highest' => '畫質優先',
			'settings.quality_smoothest' => '流暢優先',
			'settings.quality_fixed' => ({required Object name}) => '指定 ${name}',
			'settings.quality_auto_desc' => '依近期播放速度和影片大小選擇起始畫質，不額外消耗流量測速',
			'settings.quality_highest_desc' => '總是選擇最高畫質',
			'settings.quality_smoothest_desc' => '總是選擇最低畫質，適合慢速網路',
			'settings.quality_fixed_desc' => ({required Object name}) => '有 ${name} 時播放 ${name}，沒有則選低一檔',
			'theme.system' => '跟隨系統',
			'theme.light' => '淺色',
			'theme.dark' => '深色',
			'colors.pink' => '粉紅',
			'colors.red' => '紅色',
			'colors.orange' => '橙色',
			'colors.amber' => '琥珀',
			'colors.yellow' => '黃色',
			'colors.lime' => '青檸',
			'colors.lightGreen' => '淺綠',
			'colors.green' => '綠色',
			'colors.teal' => '青色',
			'colors.cyan' => '藍綠',
			'colors.lightBlue' => '淺藍',
			'colors.blue' => '藍色',
			'colors.indigo' => '藍靛',
			'colors.purple' => '紫色',
			'colors.deepPurple' => '深紫',
			'colors.blueGrey' => '藍灰',
			'colors.brown' => '棕色',
			'colors.grey' => '灰色',
			'display_mode.no_available' => '無可用顯示模式',
			'display_mode.auto' => '自動',
			'display_mode.system' => '系統',
			'proxy.host' => '主機名',
			'proxy.port' => '端口',
			'message.exit_app' => '再按一次退出該軟體',
			'message.are_you_sure_to_do_that' => '你確定要這麼做嗎？',
			'message.restart_required' => '重啟後生效',
			'message.copied' => '已複製到剪貼簿',
			'message.please_type_host' => '請輸入主機名',
			'message.please_type_port' => '請輸入端口',
			'message.account.login_success' => '登入成功！',
			'message.account.register_success' => '註冊成功，請查看郵箱激活帳號。',
			'message.account.login_password_longer_than_6' => '密碼長度至少為 6 位',
			'message.account.please_type_email' => '請輸入郵箱',
			'message.account.please_type_email_or_username' => '請輸入郵箱或用戶名',
			'message.account.please_type_valid_email' => '請輸入正確的郵箱',
			'message.account.please_type_password' => '請輸入密碼',
			'message.account.please_type_captcha' => '請輸入驗證碼',
			'message.comment.content_empty' => '內容不能為空。',
			'message.comment.content_too_long' => '內容不能超過 1000 個字符。',
			'message.comment.sent' => '回覆已發送。',
			'message.create_thread.title_empty' => '標題不能為空。',
			'message.create_thread.title_too_long' => '標題不能太長。',
			'message.create_thread.content_empty' => '內容不能為空。',
			'message.create_thread.content_too_long' => '內容不能超過 20000 個字符。',
			'message.create_thread.created' => '帖子已發送。',
			'message.blocked_tags.save_confirm' => '確定保存屏蔽標籤嗎？',
			'message.blocked_tags.saved' => '屏蔽標籤已保存。',
			'message.blocked_tags.reached_limit' => '屏蔽標籤數量已達到上限。',
			'message.playlist.empty_playlist_title' => '播放列表標題不能為空。',
			'message.playlist.playlist_created' => '播放列表已創建。',
			'message.playlist.playlist_title_edited' => '播放列表標題已修改。',
			'message.playlist.playlist_deleted' => '播放清單已刪除。',
			'message.download.no_provide_storage_permission' => '未提供存儲權限。',
			'message.download.task_already_exists' => '下載任務已存在。',
			'message.download.task_created' => '下載任務已創建。',
			'message.download.maximum_simultaneous_download_reached' => '已達到最大同時下載數。',
			'message.update.check_update_failed' => '檢查更新失敗',
			'message.update.update_available' => '有新版本可用',
			'message.update.already_latest_version' => '已經是最新版本',
			'message.update.current_version' => ({required Object version}) => '當前版本：${version}',
			'message.update.latest_version' => ({required Object version}) => '最新版本：${version}',
			'message.update.downloading' => ({required Object percent}) => '正在下載：${percent}%',
			'message.update.download_in_background' => '背景下載',
			'message.update.download_failed' => '更新下載失敗',
			'message.update.install_failed' => '無法開啟安裝程式',
			'message.update.download_size' => ({required Object size}) => '下載大小：${size}',
			'message.update.update_now' => '立即更新',
			'message.update.later' => '稍後再說',
			'message.update.skip_version' => '跳過此版本',
			'error.retry' => '載入失敗，點擊重試',
			'error.fetch_failed' => '無法獲取影片連結',
			'error.fetch_user_info_failed' => '無法獲取使用者資訊',
			'error.invalid_path' => '無效的路徑',
			'error.intercept_app_exit' => '攔截應用程式退出',
			'error.account.invalid_login' => '郵箱或密碼錯誤',
			'error.account.invalid_host' => '無效的主機名',
			'error.account.invalid_captcha' => '驗證碼錯誤',
			'error.network.offline' => ({required Object cause}) => '網路或代理不通，其他網站也連不上。請檢查網路，或更換代理節點後重試（${cause}）',
			'error.network.site_unreachable' => ({required Object cause}) => '連不上 Iwara，但其他網站正常。可能是 Iwara 暫時故障，或目前的代理節點無法存取 Iwara，請稍後重試或更換節點（${cause}）',
			'error.network.server' => ({required Object status}) => 'Iwara 伺服器出錯（HTTP ${status}），請稍後重試',
			'error.network.cause_handshake' => 'TLS 交握失敗',
			'error.network.cause_lookup' => '網域解析失敗',
			'error.network.cause_connection' => '連線失敗',
			'error.network.cause_timeout' => '連線逾時',
			_ => null,
		};
	}
}
