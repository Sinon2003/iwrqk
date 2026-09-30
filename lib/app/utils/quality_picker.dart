import 'dart:math';

/// Chooses which resolution of a video to play, and learns how fast the
/// connection is for the automatic choice.
///
/// A preference is [auto], [highest], [smoothest], or the name of a
/// resolution in [fixedChoices]. Resolution names come sorted best first,
/// the way the resolution list is.
class QualityPicker {
  static const auto = "auto";
  static const highest = "highest";
  static const smoothest = "smoothest";

  /// Resolutions the site encodes, offered as fixed choices.
  static const fixedChoices = ["Source", "540", "360"];

  /// Share of the measured throughput a stream may use, which leaves room
  /// for the speed to dip.
  static const _headroom = 0.7;

  /// Bitrate budget before anything has been measured: enough for 540 but
  /// not for Source, so the first video starts smoothly and later ones move
  /// up once the connection is known.
  static const _unmeasuredBudget = 2.5e6;

  /// Returns the index in [names] to play for [preference]. [throughput] is
  /// the learned download speed in bytes per second, if any.
  static int pick(List<String> names, String preference, {double? throughput}) {
    final last = names.length - 1;
    switch (preference) {
      case highest:
        return 0;
      case smoothest:
        return last;
      case auto:
        final budget = throughput == null
            ? _unmeasuredBudget
            : throughput * 8 * _headroom;
        final index = names.indexWhere((name) => bitrateOf(name) <= budget);
        return index == -1 ? last : index;
      default:
        // A fixed resolution, or the next one below it when it is missing.
        final index = names.indexOf(preference);
        if (index != -1) return index;
        final below = names.indexWhere(
          (name) => rankOf(name) < rankOf(preference),
        );
        return below == -1 ? last : below;
    }
  }

  /// Orders resolutions: Source above every numbered one.
  static double rankOf(String name) =>
      name == "Source" ? double.infinity : double.tryParse(name) ?? 0;

  /// Typical bitrate in bits per second, from the site's encodes: about
  /// 0.8 Mbps at 360, 1.5 Mbps at 540, and up to 5 Mbps for Source.
  static double bitrateOf(String name) {
    final height = double.tryParse(name);
    if (height == null) return 5e6;
    return 1.5e6 * pow(height / 540, 1.5);
  }

  /// Folds a new speed [sample] into the [previous] estimate, both in bytes
  /// per second, so one slow or fast video does not swing the choice.
  static double blend(double? previous, double sample) =>
      previous == null ? sample : previous * 0.7 + sample * 0.3;

  /// Lowers the estimate after playback stalled at [resolution], so the next
  /// automatic choice is below it.
  static double afterStall(double? previous, String resolution) {
    final justTooSlow = bitrateOf(resolution) / 8 / _headroom * 0.9;
    return previous == null ? justTooSlow : min(previous, justTooSlow);
  }
}
