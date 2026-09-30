# IwrQk

[简体中文](./README.md) | English

<img src="./doc/icon.png" alt="logo" width="144" height="144" align="right" />

IwrQk is an Android app built with Flutter for the new version of Iwara (a video sharing platform).

Now with [Material Design 3](https://m3.material.io/).

## 📌 Origin

This project continues the development of [iwrqk/iwrqk](https://github.com/iwrqk/iwrqk) (archived), which is no longer maintained, and remains licensed under [GPL-3.0](./LICENSE).

**Only the Android app is maintained, and there is no iOS app.** Windows, macOS and Linux still use the original project's code and have not been updated or tested.

## 📥 Download

Get the APK from [Releases](https://github.com/Sinon2003/iwrqk/releases):

- Most phones: `iwrqk-<version>-arm64-v8a.apk`
- Older 32-bit phones: `iwrqk-<version>-armeabi-v7a.apk`
- Not sure: `iwrqk-<version>-universal.apk` (works everywhere, but larger)

Once installed, "App settings → Check Update" downloads and installs new versions from within the app.

## 🚩 Features

- ✅ Video player and gallery viewer, with a preferred quality (auto, best, smoothest or fixed)
- ✅ Download manager (only for videos), with experimental accelerated downloads and playback
- ✅ Follow, subscription, favorite, playlist, comments
- ✅ Forum
- ✅ Notifications and private messages
- ✅ Friends manager
- ✅ Account settings: avatar, profile header, nickname, description, content and notification preferences
- ✅ Blocklist for tags; premium members can block users
- ✅ Watch history, both the account's on the site and this device's
- ✅ Translation of video descriptions, comments and posts (Google, Volcengine, Tencent TranSmart, Yandex)
- ✅ Login, logout, register
- ✅ In-app updates
- ⬜ Advanced search

## 📱 Screenshots

| ![Preview](./doc/1.png) | ![Preview](./doc/2.png) | ![Preview](./doc/3.png) |
| :---------------------: | :---------------------: | :---------------------: |

## 💻 Contributions

If you are a developer eager to contribute to this project, feel free to submit a pull request! The project also utilizes `slang` for localization, and [contributions to translation](/lib/i18n/strings.i18n.json) are appreciated.

In case you come across any bugs, please report them after ensuring they are not caused by network issues, as Iwara's servers may encounter errors.

Let's collaborate to enhance the Iwara experience together!

Special thanks to [guozhigq/pilipala](https://github.com/guozhigq/pilipala) for the inspiration and player implementation.

## 📄 License

IwrQk is free and open-source software released under [GPL-3.0](./LICENSE). Anyone is free to use it. Modified or redistributed versions must also be released under GPL-3.0.
