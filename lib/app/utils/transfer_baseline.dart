import 'dart:math';

/// Measures the existing stream, without issuing a speed-test request. Ignore
/// startup and require two recent, similar windows before spending connections
/// on a parallel trial. An unsettled route simply stays on its original stream.
class TransferBaseline {
  TransferBaseline(this.duration);

  final Duration duration;
  Duration _start = Duration.zero;
  int _bytes = 0;
  int _windows = 0;
  double? _previous;

  double? add(int bytes, Duration elapsed) {
    _bytes += bytes;
    final window = elapsed - _start;
    if (window.inMicroseconds < max(20000, duration.inMicroseconds ~/ 3)) {
      return null;
    }
    final speed = _bytes / (window.inMicroseconds / 1e6);
    _bytes = 0;
    _start = elapsed;
    // The first window includes any delay before useful data arrived.
    if (_windows++ == 0) return null;
    final previous = _previous;
    _previous = speed;
    if (elapsed < duration || previous == null || previous <= 0) return null;
    final ratio = speed / previous;
    if (ratio < .8 || ratio > 1.25) return null;
    return max(previous, speed);
  }

  bool expired(Duration elapsed) =>
      elapsed.inMicroseconds >= max(500000, duration.inMicroseconds * 3);
}
