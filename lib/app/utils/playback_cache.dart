/// A time target plus a memory budget. Full preloading keeps packet data in a
/// temporary file so seeking back does not require holding the video in RAM.
enum PlaybackPreload {
  seconds30(30, 32),
  minute1(60, 64),
  minutes3(180, 128),
  minutes10(600, 256),
  entireVideo(null, 128);

  const PlaybackPreload(this.seconds, this.forwardMiB);

  final int? seconds;
  final int forwardMiB;
  bool get diskCache => seconds == null;
  bool get eager => this != seconds30;
  int get forwardBytes => forwardMiB << 20;
  int get backwardBytes => diskCache ? forwardBytes : forwardBytes ~/ 4;

  static PlaybackPreload fromSetting(dynamic value) =>
      values.where((option) => option.name == value).firstOrNull ?? seconds30;

  Map<String, String> get properties => {
    'cache': 'yes',
    'cache-on-disk': diskCache ? 'yes' : 'no',
    'cache-secs': '${seconds ?? 360000000}',
    'demuxer-readahead-secs': '${seconds ?? 360000000}',
    'demuxer-max-bytes': '$forwardBytes',
    'demuxer-max-back-bytes': '$backwardBytes',
    'demuxer-seekable-cache': 'yes',
  };
}
