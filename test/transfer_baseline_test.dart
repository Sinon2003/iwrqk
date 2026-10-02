import 'package:flutter_test/flutter_test.dart';
import 'package:iwrqk/app/utils/transfer_baseline.dart';

void main() {
  test('ignores startup and compares two recent stable windows', () {
    final baseline = TransferBaseline(const Duration(seconds: 3));
    expect(baseline.add(1, const Duration(milliseconds: 2400)), isNull);
    expect(baseline.add(4 << 20, const Duration(milliseconds: 3400)), isNull);
    expect(baseline.add(4 << 20, const Duration(milliseconds: 4400)), 4 << 20);
  });

  test('waits through rising speed instead of using its startup average', () {
    final baseline = TransferBaseline(const Duration(seconds: 3));
    expect(baseline.add(1 << 16, const Duration(seconds: 1)), isNull);
    expect(baseline.add(1 << 20, const Duration(seconds: 2)), isNull);
    expect(baseline.add(2 << 20, const Duration(seconds: 3)), isNull);
    expect(baseline.add(4 << 20, const Duration(seconds: 4)), isNull);
    expect(baseline.add(4 << 20, const Duration(seconds: 5)), 4 << 20);
    expect(baseline.expired(const Duration(seconds: 8)), isFalse);
    expect(baseline.expired(const Duration(seconds: 9)), isTrue);
  });

  test('uses the stronger stable window as the conservative comparison', () {
    final baseline = TransferBaseline(const Duration(seconds: 3));
    baseline.add(10, const Duration(seconds: 1));
    baseline.add(1100000, const Duration(seconds: 2));
    expect(baseline.add(1000000, const Duration(seconds: 3)), 1100000);
  });
}
