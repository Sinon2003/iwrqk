import 'package:flutter_test/flutter_test.dart';
import 'package:iwrqk/app/utils/quality_picker.dart';

void main() {
  const all = ['Source', '540', '360'];

  test('picks the best or the smoothest', () {
    expect(QualityPicker.pick(all, QualityPicker.highest), 0);
    expect(QualityPicker.pick(all, QualityPicker.smoothest), 2);
  });

  test('picks a fixed resolution, or the next one below it', () {
    expect(QualityPicker.pick(all, '540'), 1);
    expect(QualityPicker.pick(['Source', '360'], '540'), 1);
    // Nothing below: the lowest there is.
    expect(QualityPicker.pick(['Source', '540'], '360'), 1);
    expect(QualityPicker.pick(['540', '360'], 'Source'), 0);
  });

  group('auto', () {
    test('starts at 540 before the connection is known', () {
      expect(QualityPicker.pick(all, QualityPicker.auto), 1);
    });

    test('follows the measured speed', () {
      // 2 MB/s is plenty for Source.
      expect(QualityPicker.pick(all, QualityPicker.auto, throughput: 2e6), 0);
      // 400 kB/s fits 540 but not Source.
      expect(QualityPicker.pick(all, QualityPicker.auto, throughput: 4e5), 1);
      // 100 kB/s fits nothing: the lowest.
      expect(QualityPicker.pick(all, QualityPicker.auto, throughput: 1e5), 2);
    });

    test('steps below a resolution that stalled', () {
      final after = QualityPicker.afterStall(2e6, 'Source');
      expect(QualityPicker.pick(all, QualityPicker.auto, throughput: after), 1);
      final again = QualityPicker.afterStall(after, '540');
      expect(QualityPicker.pick(all, QualityPicker.auto, throughput: again), 2);
    });

    test('blends new speeds into the estimate', () {
      expect(QualityPicker.blend(null, 1000), 1000);
      expect(QualityPicker.blend(1000, 2000), closeTo(1300, 1e-9));
    });
  });
}
