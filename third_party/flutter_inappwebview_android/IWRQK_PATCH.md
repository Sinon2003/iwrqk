# IwrQk patch notes

This directory is a copy of [`flutter_inappwebview_android`](https://pub.dev/packages/flutter_inappwebview_android) **1.1.3** from pub.dev (Apache License 2.0, see [LICENSE](LICENSE)). It is used through `dependency_overrides` in the root `pubspec.yaml`.

It is pulled in by `cloudflare_interceptor` → `flutter_inappwebview` 6.1.5, whose latest stable release (2024-10) cannot be built with Android Gradle Plugin 9.

## Changes

- `android/build.gradle`: `getDefaultProguardFile('proguard-android.txt')` → `getDefaultProguardFile('proguard-android-optimize.txt')`. AGP 9 fails at configuration time on the former.
- `android/proguard-dontoptimize.pro` (new): restores `-dontoptimize` for this library's own release build, so the behavior matches the original configuration. It is not a consumer rule and does not affect the app.

No Dart, Java or Kotlin source was changed.

## Removal

Delete this directory and the `dependency_overrides` entry once a stable `flutter_inappwebview` release ships an Android implementation built for AGP 9 (upstream already made this change in `6.2.0-beta.x` / `flutter_inappwebview_android 1.2.0-beta.x`), or once `cloudflare_interceptor` no longer depends on it.
