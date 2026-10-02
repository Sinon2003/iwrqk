import 'package:flutter_test/flutter_test.dart';
import 'package:iwrqk/app/data/services/update_service.dart';

void main() {
  final now = DateTime(2026, 10, 2, 12);

  bool offered(
    String latest, {
    String current = '2.4.2',
    String? skipped,
    String? laterVersion,
    DateTime? laterUntil,
  }) => UpdateService.shouldOffer(
    current: current,
    latest: latest,
    skipped: skipped,
    laterVersion: laterVersion,
    laterUntil: laterUntil,
    now: now,
  );

  group('a release with new features', () {
    test('is one whose first or second number moved ahead', () {
      expect(UpdateService.isFeatureRelease('2.4.2', '2.5.0'), isTrue);
      expect(UpdateService.isFeatureRelease('2.4.2', '3.0.0'), isTrue);
      expect(UpdateService.isFeatureRelease('2.4.2', 'v2.10.1'), isTrue);
    });

    test('is not one that only counts fixes, nor an older one', () {
      expect(UpdateService.isFeatureRelease('2.4.2', '2.4.3'), isFalse);
      expect(UpdateService.isFeatureRelease('2.4.2', '2.4.2'), isFalse);
      expect(UpdateService.isFeatureRelease('2.4.2', '2.3.9'), isFalse);
      expect(UpdateService.isFeatureRelease('2.4.2', '1.9.0'), isFalse);
    });

    test('is not read into versions it cannot parse', () {
      expect(UpdateService.isFeatureRelease('2.4.2', '2.5'), isFalse);
      expect(UpdateService.isFeatureRelease('2.4.2', '2.5.0-beta'), isFalse);
      expect(UpdateService.isFeatureRelease('', '2.5.0'), isFalse);
    });
  });

  group('the offer on launch', () {
    test('comes for a release with new features', () {
      expect(offered('2.5.0'), isTrue);
      expect(offered('2.5.1', current: '2.4.0'), isTrue);
    });

    test('leaves releases that only fix things to the manual check', () {
      expect(offered('2.4.3'), isFalse);
    });

    test('never comes back for a skipped version, but does for the next', () {
      expect(offered('2.5.0', skipped: '2.5.0'), isFalse);
      expect(offered('2.5.1', skipped: '2.5.0'), isTrue);
    });

    test('waits out "later", for that version only', () {
      final until = now.add(const Duration(days: 1));
      expect(
        offered('2.5.0', laterVersion: '2.5.0', laterUntil: until),
        isFalse,
      );
      expect(
        offered(
          '2.5.0',
          laterVersion: '2.5.0',
          laterUntil: now.subtract(const Duration(minutes: 1)),
        ),
        isTrue,
      );
      expect(
        offered('2.6.0', laterVersion: '2.5.0', laterUntil: until),
        isTrue,
      );
    });
  });
}
