import 'dart:async';

import 'package:get/get.dart';

class LoadingDialogController extends GetxController with StateMixin {
  bool _started = false;

  void init(FutureOr<void> Function() task) {
    if (_started || isClosed) return;
    _started = true;
    change(null, status: RxStatus.loading());
    _runTask(task);
  }

  Future<void> _runTask(FutureOr<void> Function() task) async {
    try {
      await task();
      if (!isClosed) change(null, status: RxStatus.success());
    } catch (e) {
      if (!isClosed) change(null, status: RxStatus.error(e.toString()));
    }
  }
}
