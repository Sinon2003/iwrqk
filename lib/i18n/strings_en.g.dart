///
/// Generated file. Do not edit.
///
// coverage:ignore-file
// ignore_for_file: type=lint, unused_import
// dart format off

part of 'strings.g.dart';

// Path: <root>
typedef TranslationsEn = Translations; // ignore: unused_element
class Translations with BaseTranslations<AppLocale, Translations> {
	/// Returns the current translations of the given [context].
	///
	/// Usage:
	/// final t = Translations.of(context);
	static Translations of(BuildContext context) => InheritedLocaleData.of<AppLocale, Translations>(context).translations;

	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	Translations({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: AppLocale.en,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <en>.
	final TranslationMetadata<AppLocale, Translations> _meta;
	@override TranslationMetadata<AppLocale, Translations> get $meta => _meta;

	/// Access flat map
	dynamic operator[](String key) => _meta.getTranslation(key);

	late final Translations _root = this; // ignore: unused_field

	Translations $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => Translations(meta: meta ?? this.$meta);

	// Translations
	Map<String, String> get locales => {
		'en': 'English',
		'ja': '日本語',
		'zh-CN': '简体中文',
		'zh-TW': '繁體中文',
	};
	late final Translations$rules$en rules = Translations$rules$en.internal(_root);
	late final Translations$nav$en nav = Translations$nav$en.internal(_root);
	late final Translations$common$en common = Translations$common$en.internal(_root);
	late final Translations$refresh$en refresh = Translations$refresh$en.internal(_root);
	late final Translations$records$en records = Translations$records$en.internal(_root);
	late final Translations$account$en account = Translations$account$en.internal(_root);
	late final Translations$profile$en profile = Translations$profile$en.internal(_root);
	late final Translations$sort$en sort = Translations$sort$en.internal(_root);
	late final Translations$filter$en filter = Translations$filter$en.internal(_root);
	late final Translations$search$en search = Translations$search$en.internal(_root);
	late final Translations$time$en time = Translations$time$en.internal(_root);
	late final Translations$media$en media = Translations$media$en.internal(_root);
	late final Translations$player$en player = Translations$player$en.internal(_root);
	late final Translations$comment$en comment = Translations$comment$en.internal(_root);
	late final Translations$user$en user = Translations$user$en.internal(_root);
	late final Translations$friend$en friend = Translations$friend$en.internal(_root);
	late final Translations$blocked_tags$en blocked_tags = Translations$blocked_tags$en.internal(_root);
	late final Translations$download$en download = Translations$download$en.internal(_root);
	late final Translations$playlist$en playlist = Translations$playlist$en.internal(_root);
	late final Translations$channel$en channel = Translations$channel$en.internal(_root);
	late final Translations$create_thread$en create_thread = Translations$create_thread$en.internal(_root);
	late final Translations$notifications$en notifications = Translations$notifications$en.internal(_root);
	late final Translations$translation$en translation = Translations$translation$en.internal(_root);
	late final Translations$settings$en settings = Translations$settings$en.internal(_root);
	late final Translations$theme$en theme = Translations$theme$en.internal(_root);
	late final Translations$colors$en colors = Translations$colors$en.internal(_root);
	late final Translations$display_mode$en display_mode = Translations$display_mode$en.internal(_root);
	late final Translations$proxy$en proxy = Translations$proxy$en.internal(_root);
	late final Translations$message$en message = Translations$message$en.internal(_root);
	late final Translations$error$en error = Translations$error$en.internal(_root);
}

// Path: rules
class Translations$rules$en {
	Translations$rules$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Rules'
	String get title => 'Rules';

	/// en: 'I accept the rules'
	String get accept => 'I accept the rules';

	/// en: 'I agree to have read the rules and will stay up to date with any future rule changes.'
	String get accept_desc => 'I agree to have read the rules and will stay up to date with any future rule changes.';
}

// Path: nav
class Translations$nav$en {
	Translations$nav$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Subscriptions'
	String get subscriptions => 'Subscriptions';

	/// en: 'Videos'
	String get videos => 'Videos';

	/// en: 'Images'
	String get images => 'Images';

	/// en: 'Forum'
	String get forum => 'Forum';

	/// en: 'Search'
	String get search => 'Search';
}

// Path: common
class Translations$common$en {
	Translations$common$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Video'
	String get video => 'Video';

	/// en: 'Image'
	String get image => 'Image';

	/// en: 'Collapse'
	String get collapse => 'Collapse';

	/// en: 'Expand'
	String get expand => 'Expand';

	/// en: 'Translate'
	String get translate => 'Translate';

	/// en: 'Open'
	String get open => 'Open';
}

// Path: refresh
class Translations$refresh$en {
	Translations$refresh$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Nothing here'
	String get empty => 'Nothing here';

	/// en: 'Pull to load'
	String get drag_to_load => 'Pull to load';

	/// en: 'Release to load'
	String get release_to_load => 'Release to load';

	/// en: 'Succeeded'
	String get success => 'Succeeded';

	/// en: 'Failed'
	String get failed => 'Failed';

	/// en: 'No more'
	String get no_more => 'No more';

	/// en: 'Last updated at %T'
	String get last_load => 'Last updated at %T';
}

// Path: records
class Translations$records$en {
	Translations$records$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Select all'
	String get select_all => 'Select all';

	/// en: 'Select inverse'
	String get select_inverse => 'Select inverse';

	/// en: '$num selected'
	String selected_num({required Object num}) => '${num} selected';

	/// en: 'Multiple selection mode'
	String get multiple_selection_mode => 'Multiple selection mode';

	/// en: 'Delete'
	String get delete => 'Delete';

	/// en: 'Delete all'
	String get delete_all => 'Delete all';
}

// Path: account
class Translations$account$en {
	Translations$account$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Captcha'
	String get captcha => 'Captcha';

	/// en: 'Login'
	String get login => 'Login';

	/// en: 'Logout'
	String get logout => 'Logout';

	/// en: 'Register'
	String get register => 'Register';

	/// en: 'Email'
	String get email => 'Email';

	/// en: 'Email or username'
	String get email_or_username => 'Email or username';

	/// en: 'Password'
	String get password => 'Password';

	/// en: 'Forgot password?'
	String get forgot_password => 'Forgot password?';

	/// en: 'You must be logged in to do that.'
	String get require_login => 'You must be logged in to do that.';
}

// Path: profile
class Translations$profile$en {
	Translations$profile$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Profile'
	String get profile => 'Profile';

	/// en: 'Follow'
	String get follow => 'Follow';

	/// en: 'Followers'
	String get followers => 'Followers';

	/// en: 'Following'
	String get following => 'Following';

	/// en: 'Nickname'
	String get nickname => 'Nickname';

	/// en: 'Username'
	String get username => 'Username';

	/// en: 'User ID'
	String get user_id => 'User ID';

	/// en: 'Description'
	String get description => 'Description';

	/// en: 'This user prefers to keep an air of mystery around them.'
	String get no_description => 'This user prefers to keep an air of mystery around them.';

	/// en: 'Join date'
	String get join_date => 'Join date';

	/// en: 'Last active time'
	String get last_active_time => 'Last active time';

	/// en: 'Online'
	String get online => 'Online';

	/// en: 'Message'
	String get message => 'Message';

	/// en: 'Guestbook'
	String get guestbook => 'Guestbook';

	/// en: 'View more'
	String get view_more => 'View more';

	/// en: 'Deleted user'
	String get deleted_user => 'Deleted user';
}

// Path: sort
class Translations$sort$en {
	Translations$sort$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Latest'
	String get latest => 'Latest';

	/// en: 'Trending'
	String get trending => 'Trending';

	/// en: 'Popularity'
	String get popularity => 'Popularity';

	/// en: 'Most views'
	String get most_views => 'Most views';

	/// en: 'Most likes'
	String get most_likes => 'Most likes';

	/// en: 'Relevance'
	String get relevance => 'Relevance';
}

// Path: filter
class Translations$filter$en {
	Translations$filter$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'All'
	String get all => 'All';

	/// en: 'Filter'
	String get filter => 'Filter';

	/// en: 'Rating'
	String get rating => 'Rating';

	/// en: 'Tag'
	String get tag => 'Tag';

	/// en: 'Tags'
	String get tags => 'Tags';

	/// en: 'Date'
	String get date => 'Date';

	/// en: 'General'
	String get general => 'General';

	/// en: 'Ecchi'
	String get ecchi => 'Ecchi';

	/// en: 'Select rating'
	String get select_rating => 'Select rating';

	/// en: 'Select year'
	String get select_year => 'Select year';

	/// en: 'Select month'
	String get select_month => 'Select month';
}

// Path: search
class Translations$search$en {
	Translations$search$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Users'
	String get users => 'Users';

	/// en: 'Thread'
	String get threads => 'Thread';

	/// en: 'Search'
	String get search => 'Search';

	late final Translations$search$history$en history = Translations$search$history$en.internal(_root);
}

// Path: time
class Translations$time$en {
	Translations$time$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: '$time seconds ago'
	String seconds_ago({required Object time}) => '${time} seconds ago';

	/// en: '$time minutes ago'
	String minutes_ago({required Object time}) => '${time} minutes ago';

	/// en: '$time hours ago'
	String hours_ago({required Object time}) => '${time} hours ago';

	/// en: '$time days ago'
	String days_ago({required Object time}) => '${time} days ago';
}

// Path: media
class Translations$media$en {
	Translations$media$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Private'
	String get private => 'Private';

	/// en: 'Add to playlist'
	String get add_to_playlist => 'Add to playlist';

	/// en: 'External video'
	String get external_video => 'External video';

	/// en: 'Share'
	String get share => 'Share';

	/// en: 'Download'
	String get download => 'Download';

	/// en: 'More from $username'
	String more_from({required Object username}) => 'More from ${username}';

	/// en: 'More like this'
	String get more_like_this => 'More like this';

	/// en: 'Updated at $time'
	String updated_at({required Object time}) => 'Updated at ${time}';

	/// en: 'Detail'
	String get detail => 'Detail';

	/// en: 'Comments'
	String get comments => 'Comments';
}

// Path: player
class Translations$player$en {
	Translations$player$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Current: $item'
	String current_item({required Object item}) => 'Current: ${item}';

	/// en: 'Quality'
	String get quality => 'Quality';

	/// en: 'Select quality'
	String get select_quality => 'Select quality';

	/// en: 'Playback speed'
	String get playback_speed => 'Playback speed';

	/// en: 'Select playback speed'
	String get select_playback_speed => 'Select playback speed';

	/// en: 'Aspect ratio'
	String get aspect_ratio => 'Aspect ratio';

	/// en: 'Select aspect ratio'
	String get select_aspect_ratio => 'Select aspect ratio';

	late final Translations$player$aspect_ratios$en aspect_ratios = Translations$player$aspect_ratios$en.internal(_root);

	/// en: '${value}s'
	String seconds({required Object value}) => '${value}s';

	/// en: '2x'
	String get double_speed => '2x';
}

// Path: comment
class Translations$comment$en {
	Translations$comment$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Comment'
	String get comment => 'Comment';

	/// en: 'Comments'
	String get comments => 'Comments';

	/// en: 'Comment detail'
	String get comment_detail => 'Comment detail';

	/// en: 'Edit comment'
	String get edit_comment => 'Edit comment';

	/// en: 'Delete comment'
	String get delete_comment => 'Delete comment';

	/// en: 'Reply'
	String get reply => 'Reply';

	/// en: '$numReply replies in total'
	String replies_in_total({required Object numReply}) => '${numReply} replies in total';

	/// en: 'Show all $numReply replies'
	String show_all_replies({required Object numReply}) => 'Show all ${numReply} replies';
}

// Path: user
class Translations$user$en {
	Translations$user$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Following'
	String get following => 'Following';

	/// en: 'History'
	String get history => 'History';

	/// en: 'Blocked Tags'
	String get blocked_tags => 'Blocked Tags';

	/// en: 'Friends'
	String get friends => 'Friends';

	/// en: 'Downloads'
	String get downloads => 'Downloads';

	/// en: 'Favorites'
	String get favorites => 'Favorites';

	/// en: 'Playlists'
	String get playlists => 'Playlists';

	/// en: 'Settings'
	String get settings => 'Settings';

	/// en: 'About'
	String get about => 'About';
}

// Path: friend
class Translations$friend$en {
	Translations$friend$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Friend Requests'
	String get friend_requests => 'Friend Requests';

	/// en: 'Add friend'
	String get add_friend => 'Add friend';

	/// en: 'Pending'
	String get pending => 'Pending';

	/// en: 'Unfriend'
	String get unfriend => 'Unfriend';

	/// en: 'Accept'
	String get accept => 'Accept';

	/// en: 'Reject'
	String get reject => 'Reject';
}

// Path: blocked_tags
class Translations$blocked_tags$en {
	Translations$blocked_tags$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Add blocked tag'
	String get add_blocked_tag => 'Add blocked tag';

	/// en: 'Blocked tag'
	String get blocked_tag => 'Blocked tag';
}

// Path: download
class Translations$download$en {
	Translations$download$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Create download task'
	String get create_download_task => 'Create download task';

	/// en: 'Unknown'
	String get unknown => 'Unknown';

	/// en: 'Enqueued'
	String get enqueued => 'Enqueued';

	/// en: 'Downloading'
	String get downloading => 'Downloading';

	/// en: 'Paused'
	String get paused => 'Paused';

	/// en: 'Finished'
	String get finished => 'Finished';

	/// en: 'Failed'
	String get failed => 'Failed';

	/// en: 'Retry'
	String get retry => 'Retry';

	/// en: 'Delete'
	String get delete => 'Delete';

	/// en: 'Pause'
	String get pause => 'Pause';

	/// en: 'Resume'
	String get resume => 'Resume';

	/// en: 'Open with'
	String get open_with => 'Open with';

	/// en: 'Jump to detail page'
	String get jump_to_detail => 'Jump to detail page';
}

// Path: playlist
class Translations$playlist$en {
	Translations$playlist$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Playlist title'
	String get title => 'Playlist title';

	/// en: 'Create playlist'
	String get create => 'Create playlist';

	/// en: 'Select playlist'
	String get select => 'Select playlist';

	/// en: 'Edit title'
	String get edit_title => 'Edit title';

	/// en: '$numVideo video'
	String videos_count({required Object numVideo}) => '${numVideo} video';

	/// en: '$numVideo videos'
	String videos_count_plural({required Object numVideo}) => '${numVideo} videos';
}

// Path: channel
class Translations$channel$en {
	Translations$channel$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Administration'
	String get administration => 'Administration';

	/// en: 'Announcements'
	String get announcements => 'Announcements';

	/// en: 'Feedback'
	String get feedback => 'Feedback';

	/// en: 'Support'
	String get support => 'Support';

	/// en: 'Global'
	String get global => 'Global';

	/// en: 'General'
	String get general => 'General';

	/// en: 'Guides'
	String get guides => 'Guides';

	/// en: 'Questions'
	String get questions => 'Questions';

	/// en: 'Requests'
	String get requests => 'Requests';

	/// en: 'Sharing'
	String get sharing => 'Sharing';

	/// en: '$numThread Threads $numPosts Posts'
	String label({required Object numThread, required Object numPosts}) => '${numThread} Threads ${numPosts} Posts';
}

// Path: create_thread
class Translations$create_thread$en {
	Translations$create_thread$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Create thread'
	String get create_thread => 'Create thread';

	/// en: 'Title'
	String get title => 'Title';

	/// en: 'Content'
	String get content => 'Content';
}

// Path: notifications
class Translations$notifications$en {
	Translations$notifications$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'OK'
	String get ok => 'OK';

	/// en: 'Success'
	String get success => 'Success';

	/// en: 'Error'
	String get error => 'Error';

	/// en: 'Loading...'
	String get loading => 'Loading...';

	/// en: 'Cancel'
	String get cancel => 'Cancel';

	/// en: 'Confirm'
	String get confirm => 'Confirm';

	/// en: 'Apply'
	String get apply => 'Apply';
}

// Path: translation
class Translations$translation$en {
	Translations$translation$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$translation$engines$en engines = Translations$translation$engines$en.internal(_root);
	late final Translations$translation$engine_notes$en engine_notes = Translations$translation$engine_notes$en.internal(_root);

	/// en: 'Powered by '
	String get powered_by => 'Powered by ';

	/// en: 'Show translation'
	String get show => 'Show translation';

	/// en: 'Hide translation'
	String get hide => 'Hide translation';

	/// en: 'Translating…'
	String get translating => 'Translating…';

	/// en: 'Choose translation source'
	String get choose_engine => 'Choose translation source';

	/// en: 'Default'
	String get default_tag => 'Default';

	/// en: 'Translation failed ($engine)'
	String failed({required Object engine}) => 'Translation failed (${engine})';

	/// en: 'Show original'
	String get show_original => 'Show original';

	late final Translations$translation$display_modes$en display_modes = Translations$translation$display_modes$en.internal(_root);
}

// Path: settings
class Translations$settings$en {
	Translations$settings$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Appearance'
	String get appearance => 'Appearance';

	/// en: 'Theme'
	String get theme => 'Theme';

	/// en: 'Change the theme of the App'
	String get theme_desc => 'Change the theme of the App';

	/// en: 'Dynamic Color'
	String get dynamic_color => 'Dynamic Color';

	/// en: 'Change the color of the App according to the content'
	String get dynamic_color_desc => 'Change the color of the App according to the content';

	/// en: 'Custom Color'
	String get custom_color => 'Custom Color';

	/// en: 'Customize the color of the App'
	String get custom_color_desc => 'Customize the color of the App';

	/// en: 'Language'
	String get language => 'Language';

	/// en: 'Change the language of the App'
	String get language_desc => 'Change the language of the App';

	/// en: 'Display Mode'
	String get display_mode => 'Display Mode';

	/// en: 'Change the display mode of the App'
	String get display_mode_desc => 'Change the display mode of the App';

	/// en: 'Work Mode'
	String get work_mode => 'Work Mode';

	/// en: 'Hide all covers of NSFW content'
	String get work_mode_desc => 'Hide all covers of NSFW content';

	/// en: 'Switch to AI site content'
	String get to_ai_site => 'Switch to AI site content';

	/// en: 'Switch to AI site to see AIGC contents'
	String get to_ai_site_desc => 'Switch to AI site to see AIGC contents';

	/// en: 'Translation'
	String get translation => 'Translation';

	/// en: 'Default translation source'
	String get default_translation_engine => 'Default translation source';

	/// en: 'Current: $engine'
	String default_translation_engine_desc({required Object engine}) => 'Current: ${engine}';

	/// en: 'Enabled translation sources'
	String get enabled_translation_engines => 'Enabled translation sources';

	/// en: 'Offered when long-pressing Translate: $engines'
	String enabled_translation_engines_desc({required Object engines}) => 'Offered when long-pressing Translate: ${engines}';

	/// en: 'Translation display'
	String get translation_display_mode => 'Translation display';

	/// en: 'Current: $mode'
	String translation_display_mode_desc({required Object mode}) => 'Current: ${mode}';

	/// en: 'Animated preview'
	String get animated_preview => 'Animated preview';

	/// en: 'Show animated video preview on hover or long press (when available)'
	String get animated_preview_desc => 'Show animated video preview on hover or long press (when available)';

	/// en: 'Network'
	String get network => 'Network';

	/// en: 'Enable Proxy'
	String get enable_proxy => 'Enable Proxy';

	/// en: 'Enable proxy for the App'
	String get enable_proxy_desc => 'Enable proxy for the App';

	/// en: 'Proxy'
	String get proxy => 'Proxy';

	/// en: 'Set the host and port of the proxy'
	String get proxy_desc => 'Set the host and port of the proxy';

	/// en: 'Player'
	String get player => 'Player';

	/// en: 'Autoplay'
	String get autoplay => 'Autoplay';

	/// en: 'Autoplay video when opening a video page'
	String get autoplay_desc => 'Autoplay video when opening a video page';

	/// en: 'Background Play'
	String get background_play => 'Background Play';

	/// en: 'Allow the App to play video in the background'
	String get background_play_desc => 'Allow the App to play video in the background';

	/// en: 'Discord Rich Presence'
	String get discord_rich_presence => 'Discord Rich Presence';

	/// en: 'Show app status and current playback on Discord'
	String get discord_rich_presence_desc => 'Show app status and current playback on Discord';

	/// en: 'Download'
	String get download => 'Download';

	/// en: 'Download Path'
	String get download_path => 'Download Path';

	/// en: 'Allow Media Scan'
	String get allow_media_scan => 'Allow Media Scan';

	/// en: 'Allow media scanner to read downloaded media files'
	String get allow_media_scan_desc => 'Allow media scanner to read downloaded media files';

	/// en: 'Logging'
	String get logging => 'Logging';

	/// en: 'Enable Logging'
	String get enable_logging => 'Enable Logging';

	/// en: 'Enable logging for the App'
	String get enable_logging_desc => 'Enable logging for the App';

	/// en: 'Clear Log'
	String get clear_log => 'Clear Log';

	/// en: 'Current log size: $size'
	String clear_log_desc({required Object size}) => 'Current log size: ${size}';

	/// en: 'Enable Verbose Logging'
	String get enable_verbose_logging => 'Enable Verbose Logging';

	/// en: 'Record more detailed logs'
	String get enable_verbose_logging_desc => 'Record more detailed logs';

	/// en: 'About'
	String get about => 'About';

	/// en: 'Check Update'
	String get check_update => 'Check Update';

	/// en: 'Check if there is a new version available'
	String get check_update_desc => 'Check if there is a new version available';

	/// en: 'Third Party License'
	String get third_party_license => 'Third Party License';

	/// en: 'View the license of third party libraries'
	String get third_party_license_desc => 'View the license of third party libraries';
}

// Path: theme
class Translations$theme$en {
	Translations$theme$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'System'
	String get system => 'System';

	/// en: 'Light'
	String get light => 'Light';

	/// en: 'Dark'
	String get dark => 'Dark';
}

// Path: colors
class Translations$colors$en {
	Translations$colors$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Pink'
	String get pink => 'Pink';

	/// en: 'Red'
	String get red => 'Red';

	/// en: 'Orange'
	String get orange => 'Orange';

	/// en: 'Amber'
	String get amber => 'Amber';

	/// en: 'Yellow'
	String get yellow => 'Yellow';

	/// en: 'Lime'
	String get lime => 'Lime';

	/// en: 'Light Green'
	String get lightGreen => 'Light Green';

	/// en: 'Green'
	String get green => 'Green';

	/// en: 'Teal'
	String get teal => 'Teal';

	/// en: 'Cyan'
	String get cyan => 'Cyan';

	/// en: 'Light Blue'
	String get lightBlue => 'Light Blue';

	/// en: 'Blue'
	String get blue => 'Blue';

	/// en: 'Indigo'
	String get indigo => 'Indigo';

	/// en: 'Purple'
	String get purple => 'Purple';

	/// en: 'Deep Purple'
	String get deepPurple => 'Deep Purple';

	/// en: 'Blue Grey'
	String get blueGrey => 'Blue Grey';

	/// en: 'Brown'
	String get brown => 'Brown';

	/// en: 'Grey'
	String get grey => 'Grey';
}

// Path: display_mode
class Translations$display_mode$en {
	Translations$display_mode$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'No available display mode'
	String get no_available => 'No available display mode';

	/// en: 'Auto'
	String get auto => 'Auto';

	/// en: 'System'
	String get system => 'System';
}

// Path: proxy
class Translations$proxy$en {
	Translations$proxy$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Host'
	String get host => 'Host';

	/// en: 'Port'
	String get port => 'Port';
}

// Path: message
class Translations$message$en {
	Translations$message$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Press again to exit the App'
	String get exit_app => 'Press again to exit the App';

	/// en: 'Are you sure to do that?'
	String get are_you_sure_to_do_that => 'Are you sure to do that?';

	/// en: 'Restart the App to apply the changes.'
	String get restart_required => 'Restart the App to apply the changes.';

	/// en: 'Copied to clipboard'
	String get copied => 'Copied to clipboard';

	/// en: 'Please type the host'
	String get please_type_host => 'Please type the host';

	/// en: 'Please type the port'
	String get please_type_port => 'Please type the port';

	late final Translations$message$account$en account = Translations$message$account$en.internal(_root);
	late final Translations$message$comment$en comment = Translations$message$comment$en.internal(_root);
	late final Translations$message$create_thread$en create_thread = Translations$message$create_thread$en.internal(_root);
	late final Translations$message$blocked_tags$en blocked_tags = Translations$message$blocked_tags$en.internal(_root);
	late final Translations$message$playlist$en playlist = Translations$message$playlist$en.internal(_root);
	late final Translations$message$download$en download = Translations$message$download$en.internal(_root);
	late final Translations$message$update$en update = Translations$message$update$en.internal(_root);
}

// Path: error
class Translations$error$en {
	Translations$error$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Load failed, click to retry.'
	String get retry => 'Load failed, click to retry.';

	/// en: 'Failed to fetch video links.'
	String get fetch_failed => 'Failed to fetch video links.';

	/// en: 'Failed to fetch user info.'
	String get fetch_user_info_failed => 'Failed to fetch user info.';

	/// en: 'Invalid path.'
	String get invalid_path => 'Invalid path.';

	/// en: 'Intercept app exit'
	String get intercept_app_exit => 'Intercept app exit';

	late final Translations$error$account$en account = Translations$error$account$en.internal(_root);
}

// Path: search.history
class Translations$search$history$en {
	Translations$search$history$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Delete All'
	String get delete => 'Delete All';

	/// en: 'Done'
	String get done => 'Done';
}

// Path: player.aspect_ratios
class Translations$player$aspect_ratios$en {
	Translations$player$aspect_ratios$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Contain'
	String get contain => 'Contain';

	/// en: 'Cover'
	String get cover => 'Cover';

	/// en: 'Fill'
	String get fill => 'Fill';

	/// en: 'Fit height'
	String get fit_height => 'Fit height';

	/// en: 'Fit width'
	String get fit_width => 'Fit width';

	/// en: 'Scale down'
	String get scale_down => 'Scale down';
}

// Path: translation.engines
class Translations$translation$engines$en {
	Translations$translation$engines$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Google Translate'
	String get google => 'Google Translate';

	/// en: 'Volcengine Translate'
	String get volcengine => 'Volcengine Translate';

	/// en: 'Tencent TranSmart'
	String get tencent => 'Tencent TranSmart';

	/// en: 'Yandex Translate'
	String get yandex => 'Yandex Translate';
}

// Path: translation.engine_notes
class Translations$translation$engine_notes$en {
	Translations$translation$engine_notes$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Requires access to Google'
	String get google => 'Requires access to Google';

	/// en: 'Fast, reachable from mainland China'
	String get volcengine => 'Fast, reachable from mainland China';

	/// en: 'Reachable from mainland China'
	String get tencent => 'Reachable from mainland China';

	/// en: 'No Traditional Chinese output'
	String get yandex => 'No Traditional Chinese output';
}

// Path: translation.display_modes
class Translations$translation$display_modes$en {
	Translations$translation$display_modes$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Below the original'
	String get below => 'Below the original';

	/// en: 'Replace the original'
	String get replace => 'Replace the original';
}

// Path: message.account
class Translations$message$account$en {
	Translations$message$account$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Login success.'
	String get login_success => 'Login success.';

	/// en: 'Register success, further instructions have been sent to your email.'
	String get register_success => 'Register success, further instructions have been sent to your email.';

	/// en: 'Password must be longer than 6 characters'
	String get login_password_longer_than_6 => 'Password must be longer than 6 characters';

	/// en: 'Please type your email'
	String get please_type_email => 'Please type your email';

	/// en: 'Please type your email or username'
	String get please_type_email_or_username => 'Please type your email or username';

	/// en: 'Please type a valid email'
	String get please_type_valid_email => 'Please type a valid email';

	/// en: 'Please type your password'
	String get please_type_password => 'Please type your password';

	/// en: 'Please type the captcha'
	String get please_type_captcha => 'Please type the captcha';
}

// Path: message.comment
class Translations$message$comment$en {
	Translations$message$comment$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Content can not be empty.'
	String get content_empty => 'Content can not be empty.';

	/// en: 'Content can not be longer than 1000 characters.'
	String get content_too_long => 'Content can not be longer than 1000 characters.';

	/// en: 'Reply sent.'
	String get sent => 'Reply sent.';
}

// Path: message.create_thread
class Translations$message$create_thread$en {
	Translations$message$create_thread$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Title can not be empty.'
	String get title_empty => 'Title can not be empty.';

	/// en: 'Title is too long.'
	String get title_too_long => 'Title is too long.';

	/// en: 'Content can not be empty.'
	String get content_empty => 'Content can not be empty.';

	/// en: 'Content can not be longer than 20000 characters.'
	String get content_too_long => 'Content can not be longer than 20000 characters.';

	/// en: 'Thread Created.'
	String get created => 'Thread Created.';
}

// Path: message.blocked_tags
class Translations$message$blocked_tags$en {
	Translations$message$blocked_tags$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Are you sure to save the blocked tags?'
	String get save_confirm => 'Are you sure to save the blocked tags?';

	/// en: 'Blocked tags saved.'
	String get saved => 'Blocked tags saved.';

	/// en: 'Blocked tags reached limit.'
	String get reached_limit => 'Blocked tags reached limit.';
}

// Path: message.playlist
class Translations$message$playlist$en {
	Translations$message$playlist$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Playlist title can not be empty.'
	String get empty_playlist_title => 'Playlist title can not be empty.';

	/// en: 'Playlist created.'
	String get playlist_created => 'Playlist created.';

	/// en: 'Playlist title edited.'
	String get playlist_title_edited => 'Playlist title edited.';
}

// Path: message.download
class Translations$message$download$en {
	Translations$message$download$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'No storage permission provided.'
	String get no_provide_storage_permission => 'No storage permission provided.';

	/// en: 'Download task already exists.'
	String get task_already_exists => 'Download task already exists.';

	/// en: 'Download task created.'
	String get task_created => 'Download task created.';

	/// en: 'Maximum simultaneous download reached.'
	String get maximum_simultaneous_download_reached => 'Maximum simultaneous download reached.';
}

// Path: message.update
class Translations$message$update$en {
	Translations$message$update$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Failed to check update.'
	String get check_update_failed => 'Failed to check update.';

	/// en: 'Update available'
	String get update_available => 'Update available';

	/// en: 'Already the latest version'
	String get already_latest_version => 'Already the latest version';

	/// en: 'Current version: $version'
	String current_version({required Object version}) => 'Current version: ${version}';

	/// en: 'Latest version: $version'
	String latest_version({required Object version}) => 'Latest version: ${version}';

	/// en: 'View update'
	String get view_update => 'View update';
}

// Path: error.account
class Translations$error$account$en {
	Translations$error$account$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Invalid email or password.'
	String get invalid_login => 'Invalid email or password.';

	/// en: 'Invalid host.'
	String get invalid_host => 'Invalid host.';

	/// en: 'Invalid captcha.'
	String get invalid_captcha => 'Invalid captcha.';
}

/// The flat map containing all translations for locale <en>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on Translations {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'locales.en' => 'English',
			'locales.ja' => '日本語',
			'locales.zh-CN' => '简体中文',
			'locales.zh-TW' => '繁體中文',
			'rules.title' => 'Rules',
			'rules.accept' => 'I accept the rules',
			'rules.accept_desc' => 'I agree to have read the rules and will stay up to date with any future rule changes.',
			'nav.subscriptions' => 'Subscriptions',
			'nav.videos' => 'Videos',
			'nav.images' => 'Images',
			'nav.forum' => 'Forum',
			'nav.search' => 'Search',
			'common.video' => 'Video',
			'common.image' => 'Image',
			'common.collapse' => 'Collapse',
			'common.expand' => 'Expand',
			'common.translate' => 'Translate',
			'common.open' => 'Open',
			'refresh.empty' => 'Nothing here',
			'refresh.drag_to_load' => 'Pull to load',
			'refresh.release_to_load' => 'Release to load',
			'refresh.success' => 'Succeeded',
			'refresh.failed' => 'Failed',
			'refresh.no_more' => 'No more',
			'refresh.last_load' => 'Last updated at %T',
			'records.select_all' => 'Select all',
			'records.select_inverse' => 'Select inverse',
			'records.selected_num' => ({required Object num}) => '${num} selected',
			'records.multiple_selection_mode' => 'Multiple selection mode',
			'records.delete' => 'Delete',
			'records.delete_all' => 'Delete all',
			'account.captcha' => 'Captcha',
			'account.login' => 'Login',
			'account.logout' => 'Logout',
			'account.register' => 'Register',
			'account.email' => 'Email',
			'account.email_or_username' => 'Email or username',
			'account.password' => 'Password',
			'account.forgot_password' => 'Forgot password?',
			'account.require_login' => 'You must be logged in to do that.',
			'profile.profile' => 'Profile',
			'profile.follow' => 'Follow',
			'profile.followers' => 'Followers',
			'profile.following' => 'Following',
			'profile.nickname' => 'Nickname',
			'profile.username' => 'Username',
			'profile.user_id' => 'User ID',
			'profile.description' => 'Description',
			'profile.no_description' => 'This user prefers to keep an air of mystery around them.',
			'profile.join_date' => 'Join date',
			'profile.last_active_time' => 'Last active time',
			'profile.online' => 'Online',
			'profile.message' => 'Message',
			'profile.guestbook' => 'Guestbook',
			'profile.view_more' => 'View more',
			'profile.deleted_user' => 'Deleted user',
			'sort.latest' => 'Latest',
			'sort.trending' => 'Trending',
			'sort.popularity' => 'Popularity',
			'sort.most_views' => 'Most views',
			'sort.most_likes' => 'Most likes',
			'sort.relevance' => 'Relevance',
			'filter.all' => 'All',
			'filter.filter' => 'Filter',
			'filter.rating' => 'Rating',
			'filter.tag' => 'Tag',
			'filter.tags' => 'Tags',
			'filter.date' => 'Date',
			'filter.general' => 'General',
			'filter.ecchi' => 'Ecchi',
			'filter.select_rating' => 'Select rating',
			'filter.select_year' => 'Select year',
			'filter.select_month' => 'Select month',
			'search.users' => 'Users',
			'search.threads' => 'Thread',
			'search.search' => 'Search',
			'search.history.delete' => 'Delete All',
			'search.history.done' => 'Done',
			'time.seconds_ago' => ({required Object time}) => '${time} seconds ago',
			'time.minutes_ago' => ({required Object time}) => '${time} minutes ago',
			'time.hours_ago' => ({required Object time}) => '${time} hours ago',
			'time.days_ago' => ({required Object time}) => '${time} days ago',
			'media.private' => 'Private',
			'media.add_to_playlist' => 'Add to playlist',
			'media.external_video' => 'External video',
			'media.share' => 'Share',
			'media.download' => 'Download',
			'media.more_from' => ({required Object username}) => 'More from ${username}',
			'media.more_like_this' => 'More like this',
			'media.updated_at' => ({required Object time}) => 'Updated at ${time}',
			'media.detail' => 'Detail',
			'media.comments' => 'Comments',
			'player.current_item' => ({required Object item}) => 'Current: ${item}',
			'player.quality' => 'Quality',
			'player.select_quality' => 'Select quality',
			'player.playback_speed' => 'Playback speed',
			'player.select_playback_speed' => 'Select playback speed',
			'player.aspect_ratio' => 'Aspect ratio',
			'player.select_aspect_ratio' => 'Select aspect ratio',
			'player.aspect_ratios.contain' => 'Contain',
			'player.aspect_ratios.cover' => 'Cover',
			'player.aspect_ratios.fill' => 'Fill',
			'player.aspect_ratios.fit_height' => 'Fit height',
			'player.aspect_ratios.fit_width' => 'Fit width',
			'player.aspect_ratios.scale_down' => 'Scale down',
			'player.seconds' => ({required Object value}) => '${value}s',
			'player.double_speed' => '2x',
			'comment.comment' => 'Comment',
			'comment.comments' => 'Comments',
			'comment.comment_detail' => 'Comment detail',
			'comment.edit_comment' => 'Edit comment',
			'comment.delete_comment' => 'Delete comment',
			'comment.reply' => 'Reply',
			'comment.replies_in_total' => ({required Object numReply}) => '${numReply} replies in total',
			'comment.show_all_replies' => ({required Object numReply}) => 'Show all ${numReply} replies',
			'user.following' => 'Following',
			'user.history' => 'History',
			'user.blocked_tags' => 'Blocked Tags',
			'user.friends' => 'Friends',
			'user.downloads' => 'Downloads',
			'user.favorites' => 'Favorites',
			'user.playlists' => 'Playlists',
			'user.settings' => 'Settings',
			'user.about' => 'About',
			'friend.friend_requests' => 'Friend Requests',
			'friend.add_friend' => 'Add friend',
			'friend.pending' => 'Pending',
			'friend.unfriend' => 'Unfriend',
			'friend.accept' => 'Accept',
			'friend.reject' => 'Reject',
			'blocked_tags.add_blocked_tag' => 'Add blocked tag',
			'blocked_tags.blocked_tag' => 'Blocked tag',
			'download.create_download_task' => 'Create download task',
			'download.unknown' => 'Unknown',
			'download.enqueued' => 'Enqueued',
			'download.downloading' => 'Downloading',
			'download.paused' => 'Paused',
			'download.finished' => 'Finished',
			'download.failed' => 'Failed',
			'download.retry' => 'Retry',
			'download.delete' => 'Delete',
			'download.pause' => 'Pause',
			'download.resume' => 'Resume',
			'download.open_with' => 'Open with',
			'download.jump_to_detail' => 'Jump to detail page',
			'playlist.title' => 'Playlist title',
			'playlist.create' => 'Create playlist',
			'playlist.select' => 'Select playlist',
			'playlist.edit_title' => 'Edit title',
			'playlist.videos_count' => ({required Object numVideo}) => '${numVideo} video',
			'playlist.videos_count_plural' => ({required Object numVideo}) => '${numVideo} videos',
			'channel.administration' => 'Administration',
			'channel.announcements' => 'Announcements',
			'channel.feedback' => 'Feedback',
			'channel.support' => 'Support',
			'channel.global' => 'Global',
			'channel.general' => 'General',
			'channel.guides' => 'Guides',
			'channel.questions' => 'Questions',
			'channel.requests' => 'Requests',
			'channel.sharing' => 'Sharing',
			'channel.label' => ({required Object numThread, required Object numPosts}) => '${numThread} Threads ${numPosts} Posts',
			'create_thread.create_thread' => 'Create thread',
			'create_thread.title' => 'Title',
			'create_thread.content' => 'Content',
			'notifications.ok' => 'OK',
			'notifications.success' => 'Success',
			'notifications.error' => 'Error',
			'notifications.loading' => 'Loading...',
			'notifications.cancel' => 'Cancel',
			'notifications.confirm' => 'Confirm',
			'notifications.apply' => 'Apply',
			'translation.engines.google' => 'Google Translate',
			'translation.engines.volcengine' => 'Volcengine Translate',
			'translation.engines.tencent' => 'Tencent TranSmart',
			'translation.engines.yandex' => 'Yandex Translate',
			'translation.engine_notes.google' => 'Requires access to Google',
			'translation.engine_notes.volcengine' => 'Fast, reachable from mainland China',
			'translation.engine_notes.tencent' => 'Reachable from mainland China',
			'translation.engine_notes.yandex' => 'No Traditional Chinese output',
			'translation.powered_by' => 'Powered by ',
			'translation.show' => 'Show translation',
			'translation.hide' => 'Hide translation',
			'translation.translating' => 'Translating…',
			'translation.choose_engine' => 'Choose translation source',
			'translation.default_tag' => 'Default',
			'translation.failed' => ({required Object engine}) => 'Translation failed (${engine})',
			'translation.show_original' => 'Show original',
			'translation.display_modes.below' => 'Below the original',
			'translation.display_modes.replace' => 'Replace the original',
			'settings.appearance' => 'Appearance',
			'settings.theme' => 'Theme',
			'settings.theme_desc' => 'Change the theme of the App',
			'settings.dynamic_color' => 'Dynamic Color',
			'settings.dynamic_color_desc' => 'Change the color of the App according to the content',
			'settings.custom_color' => 'Custom Color',
			'settings.custom_color_desc' => 'Customize the color of the App',
			'settings.language' => 'Language',
			'settings.language_desc' => 'Change the language of the App',
			'settings.display_mode' => 'Display Mode',
			'settings.display_mode_desc' => 'Change the display mode of the App',
			'settings.work_mode' => 'Work Mode',
			'settings.work_mode_desc' => 'Hide all covers of NSFW content',
			'settings.to_ai_site' => 'Switch to AI site content',
			'settings.to_ai_site_desc' => 'Switch to AI site to see AIGC contents',
			'settings.translation' => 'Translation',
			'settings.default_translation_engine' => 'Default translation source',
			'settings.default_translation_engine_desc' => ({required Object engine}) => 'Current: ${engine}',
			'settings.enabled_translation_engines' => 'Enabled translation sources',
			'settings.enabled_translation_engines_desc' => ({required Object engines}) => 'Offered when long-pressing Translate: ${engines}',
			'settings.translation_display_mode' => 'Translation display',
			'settings.translation_display_mode_desc' => ({required Object mode}) => 'Current: ${mode}',
			'settings.animated_preview' => 'Animated preview',
			'settings.animated_preview_desc' => 'Show animated video preview on hover or long press (when available)',
			'settings.network' => 'Network',
			'settings.enable_proxy' => 'Enable Proxy',
			'settings.enable_proxy_desc' => 'Enable proxy for the App',
			'settings.proxy' => 'Proxy',
			'settings.proxy_desc' => 'Set the host and port of the proxy',
			'settings.player' => 'Player',
			'settings.autoplay' => 'Autoplay',
			'settings.autoplay_desc' => 'Autoplay video when opening a video page',
			'settings.background_play' => 'Background Play',
			'settings.background_play_desc' => 'Allow the App to play video in the background',
			'settings.discord_rich_presence' => 'Discord Rich Presence',
			'settings.discord_rich_presence_desc' => 'Show app status and current playback on Discord',
			'settings.download' => 'Download',
			'settings.download_path' => 'Download Path',
			'settings.allow_media_scan' => 'Allow Media Scan',
			'settings.allow_media_scan_desc' => 'Allow media scanner to read downloaded media files',
			'settings.logging' => 'Logging',
			'settings.enable_logging' => 'Enable Logging',
			'settings.enable_logging_desc' => 'Enable logging for the App',
			'settings.clear_log' => 'Clear Log',
			'settings.clear_log_desc' => ({required Object size}) => 'Current log size: ${size}',
			'settings.enable_verbose_logging' => 'Enable Verbose Logging',
			'settings.enable_verbose_logging_desc' => 'Record more detailed logs',
			'settings.about' => 'About',
			'settings.check_update' => 'Check Update',
			'settings.check_update_desc' => 'Check if there is a new version available',
			'settings.third_party_license' => 'Third Party License',
			'settings.third_party_license_desc' => 'View the license of third party libraries',
			'theme.system' => 'System',
			'theme.light' => 'Light',
			'theme.dark' => 'Dark',
			'colors.pink' => 'Pink',
			'colors.red' => 'Red',
			'colors.orange' => 'Orange',
			'colors.amber' => 'Amber',
			'colors.yellow' => 'Yellow',
			'colors.lime' => 'Lime',
			'colors.lightGreen' => 'Light Green',
			'colors.green' => 'Green',
			'colors.teal' => 'Teal',
			'colors.cyan' => 'Cyan',
			'colors.lightBlue' => 'Light Blue',
			'colors.blue' => 'Blue',
			'colors.indigo' => 'Indigo',
			'colors.purple' => 'Purple',
			'colors.deepPurple' => 'Deep Purple',
			'colors.blueGrey' => 'Blue Grey',
			'colors.brown' => 'Brown',
			'colors.grey' => 'Grey',
			'display_mode.no_available' => 'No available display mode',
			'display_mode.auto' => 'Auto',
			'display_mode.system' => 'System',
			'proxy.host' => 'Host',
			'proxy.port' => 'Port',
			'message.exit_app' => 'Press again to exit the App',
			'message.are_you_sure_to_do_that' => 'Are you sure to do that?',
			'message.restart_required' => 'Restart the App to apply the changes.',
			'message.copied' => 'Copied to clipboard',
			'message.please_type_host' => 'Please type the host',
			'message.please_type_port' => 'Please type the port',
			'message.account.login_success' => 'Login success.',
			'message.account.register_success' => 'Register success, further instructions have been sent to your email.',
			'message.account.login_password_longer_than_6' => 'Password must be longer than 6 characters',
			'message.account.please_type_email' => 'Please type your email',
			'message.account.please_type_email_or_username' => 'Please type your email or username',
			'message.account.please_type_valid_email' => 'Please type a valid email',
			'message.account.please_type_password' => 'Please type your password',
			'message.account.please_type_captcha' => 'Please type the captcha',
			'message.comment.content_empty' => 'Content can not be empty.',
			'message.comment.content_too_long' => 'Content can not be longer than 1000 characters.',
			'message.comment.sent' => 'Reply sent.',
			'message.create_thread.title_empty' => 'Title can not be empty.',
			'message.create_thread.title_too_long' => 'Title is too long.',
			'message.create_thread.content_empty' => 'Content can not be empty.',
			'message.create_thread.content_too_long' => 'Content can not be longer than 20000 characters.',
			'message.create_thread.created' => 'Thread Created.',
			'message.blocked_tags.save_confirm' => 'Are you sure to save the blocked tags?',
			'message.blocked_tags.saved' => 'Blocked tags saved.',
			'message.blocked_tags.reached_limit' => 'Blocked tags reached limit.',
			'message.playlist.empty_playlist_title' => 'Playlist title can not be empty.',
			'message.playlist.playlist_created' => 'Playlist created.',
			'message.playlist.playlist_title_edited' => 'Playlist title edited.',
			'message.download.no_provide_storage_permission' => 'No storage permission provided.',
			'message.download.task_already_exists' => 'Download task already exists.',
			'message.download.task_created' => 'Download task created.',
			'message.download.maximum_simultaneous_download_reached' => 'Maximum simultaneous download reached.',
			'message.update.check_update_failed' => 'Failed to check update.',
			'message.update.update_available' => 'Update available',
			'message.update.already_latest_version' => 'Already the latest version',
			'message.update.current_version' => ({required Object version}) => 'Current version: ${version}',
			'message.update.latest_version' => ({required Object version}) => 'Latest version: ${version}',
			'message.update.view_update' => 'View update',
			'error.retry' => 'Load failed, click to retry.',
			'error.fetch_failed' => 'Failed to fetch video links.',
			'error.fetch_user_info_failed' => 'Failed to fetch user info.',
			'error.invalid_path' => 'Invalid path.',
			'error.intercept_app_exit' => 'Intercept app exit',
			'error.account.invalid_login' => 'Invalid email or password.',
			'error.account.invalid_host' => 'Invalid host.',
			'error.account.invalid_captcha' => 'Invalid captcha.',
			_ => null,
		};
	}
}
