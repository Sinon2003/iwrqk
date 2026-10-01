import 'package:flutter_test/flutter_test.dart';
import 'package:iwrqk/app/data/models/app_release.dart';

import '../tool/release.dart';

void main() {
  final notes = releaseNotes(
    version: '2.4.1',
    chinese: '## 更新内容\n - 修复登录\n\n## 注意\n - 只维护 Android 版。\n',
    english: '## Changelog\n - Fix login\n\n## Attention\n - Android only.\n',
  );
  final release = AppRelease(
    version: '2.4.1',
    notes: notes,
    pageUrl: '',
    assets: [],
  );

  test('links every download to its file', () {
    for (final file in [
      'iwrqk-2.4.1-arm64-v8a.apk',
      'iwrqk-2.4.1-armeabi-v7a.apk',
      'iwrqk-2.4.1-x86_64.apk',
      'iwrqk-2.4.1-universal.apk',
      'SHA256SUMS.txt',
    ]) {
      expect(
        notes,
        contains(
          '[$file](https://github.com/Sinon2003/iwrqk/releases/download/'
          'v2.4.1/$file)',
        ),
      );
    }
  });

  test('leads with Chinese and folds English', () {
    final fold = notes.indexOf('<details>');
    expect(notes.indexOf('## 更新内容'), inInclusiveRange(0, fold));
    expect(notes.indexOf('## Changelog'), greaterThan(fold));
    expect(notes.trimRight(), endsWith('</details>'));
  });

  test('the update dialog reads the changelog in its language', () {
    expect(
      release.changelog(chinese: true),
      '更新内容\n - 修复登录\n\n注意\n - 只维护 Android 版。',
    );
    expect(
      release.changelog(chinese: false),
      'Changelog\n - Fix login\n\nAttention\n - Android only.',
    );
  });

  test('the update dialog still reads notes that are only in English', () {
    final old = AppRelease(
      version: '2.3.1',
      notes: '## Downloads\n - a.apk\n\n## Changelog\n - Fix login\n',
      pageUrl: '',
      assets: [],
    );
    expect(old.changelog(chinese: true), 'Changelog\n - Fix login');
  });
}
