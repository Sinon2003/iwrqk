import 'package:auto_orientation_v2/auto_orientation_v2.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

//横屏
Future<void> landScape() async {
  try {
    await AutoOrientation.landscapeAutoMode(forceSensor: true);
  } catch (exception, stacktrace) {
    debugPrint(exception.toString());
    debugPrint(stacktrace.toString());
  }
}

//竖屏
Future<void> verticalScreen() async {
  await AutoOrientation.portraitUpMode();
}

Future<void> enterFullScreen() async {
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
}

//退出全屏显示
Future<void> exitFullScreen() async {
  late SystemUiMode mode = SystemUiMode.edgeToEdge;
  try {
    if ((await DeviceInfoPlugin().androidInfo).version.sdkInt < 29) {
      mode = SystemUiMode.manual;
    }
    await SystemChrome.setEnabledSystemUIMode(
      mode,
      overlays: SystemUiOverlay.values,
    );
    await SystemChrome.setPreferredOrientations([]);
  } catch (exception, stacktrace) {
    debugPrint(exception.toString());
    debugPrint(stacktrace.toString());
  }
}
