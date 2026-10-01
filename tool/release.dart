// Prepares a GitHub release from the build output:
//
//   flutter build apk --release
//   dart run tool/release.dart
//
// It reads the version from pubspec.yaml (or takes one, such as 2.4.0+3) and
// fills build/release/v<version>/ with
//   - the APKs under the names the in-app updater looks for,
//   - SHA256SUMS.txt,
//   - notes.md: download links that point at the files, the Chinese
//     changelog, and the English one folded below it.
// Without a fresh build it still writes notes.md, to refresh the notes of a
// published release.
import 'dart:io';

import 'package:crypto/crypto.dart';

const repository = 'https://github.com/Sinon2003/iwrqk';

/// The APKs of a release with whom each is for, in Chinese and in English.
const apks = {
  'arm64-v8a': ('大多数手机', 'Most phones'),
  'armeabi-v7a': ('较旧的 32 位手机', 'Older 32-bit phones'),
  'x86_64': ('x86_64 设备和模拟器', 'x86_64 devices and emulators'),
  'universal': ('不确定选哪个', 'Not sure'),
};

/// The name the in-app updater expects for the APK of [abi].
String apkName(String version, String abi) => 'iwrqk-$version-$abi.apk';

/// Builds the notes of the release of [version], such as "2.4.0": download
/// links first, then the [chinese] changelog, with the [english] one folded.
String releaseNotes({
  required String version,
  required String chinese,
  required String english,
}) {
  String link(String file) =>
      '[$file]($repository/releases/download/v$version/$file)';
  String downloads({required bool inChinese}) => [
    for (final MapEntry(key: abi, value: (zh, en)) in apks.entries)
      if (abi == 'universal')
        inChinese
            ? ' - $zh：${link(apkName(version, abi))}（通用，体积更大）'
            : ' - $en: ${link(apkName(version, abi))} (works on all of them, '
                  'but larger)'
      else
        inChinese
            ? ' - $zh：${link(apkName(version, abi))}'
            : ' - $en: ${link(apkName(version, abi))}',
    inChinese
        ? ' - 校验和：${link('SHA256SUMS.txt')}'
        : ' - Checksums: ${link('SHA256SUMS.txt')}',
  ].join('\n');

  return '''
## 下载
${downloads(inChinese: true)}

已经装了 2.4.0 或更新版本的，在应用的「系统设置 → 检查更新」里可以直接更新。

${chinese.trim()}

<details>
<summary>English</summary>

## Downloads
${downloads(inChinese: false)}

With 2.4.0 or later installed, "App settings → Check Update" updates from within the app.

${english.trim()}

</details>
''';
}

void main(List<String> arguments) {
  final fullVersion = arguments.isNotEmpty
      ? arguments.first
      : RegExp(
          r'^version:\s*(\S+)',
          multiLine: true,
        ).firstMatch(File('pubspec.yaml').readAsStringSync())!.group(1)!;
  final version = fullVersion.split('+').first;

  final chinese = File('changelogs/v$fullVersion.md');
  final english = File('changelogs/v$fullVersion.en.md');
  for (final changelog in [chinese, english]) {
    if (!changelog.existsSync()) {
      stderr.writeln('Missing ${changelog.path}');
      exit(1);
    }
  }

  final output = Directory('build/release/v$version')
    ..createSync(recursive: true);

  final checksums = StringBuffer();
  for (final abi in apks.keys) {
    final built = File(
      'build/app/outputs/apk/release/iwrqk-$fullVersion-$abi-release.apk',
    );
    if (!built.existsSync()) continue;
    final name = apkName(version, abi);
    built.copySync('${output.path}/$name');
    checksums.writeln('${sha256.convert(built.readAsBytesSync())}  $name');
  }
  final hasApks = checksums.isNotEmpty;
  if (hasApks) {
    File('${output.path}/SHA256SUMS.txt').writeAsStringSync('$checksums');
  }

  File('${output.path}/notes.md').writeAsStringSync(
    releaseNotes(
      version: version,
      chinese: chinese.readAsStringSync(),
      english: english.readAsStringSync(),
    ),
  );

  stdout.writeln('Wrote ${output.path}');
  if (hasApks) {
    stdout.writeln(
      'Publish with: gh release create v$version --verify-tag '
      '--title v$version --notes-file ${output.path}/notes.md '
      '${output.path}/*.apk ${output.path}/SHA256SUMS.txt',
    );
  } else {
    stdout.writeln(
      'No APKs for $fullVersion in build/; only notes.md was written. '
      'Refresh a release with: gh release edit v$version '
      '--notes-file ${output.path}/notes.md',
    );
  }
}
