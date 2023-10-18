import 'dart:async';

import 'package:get/get.dart';
import 'package:pivotpay/globals.dart' as globals;
import 'package:pivotpay/login/login_screen.dart';
import 'package:platform_device_id/platform_device_id.dart';

class SessionTimer {
  String? deviceId;
  void startTimer() {
    if (globals .logOutTimer != null) {
      globals.logOutTimer!.cancel();
    }

    globals.logOutTimer = Timer.periodic(const Duration(seconds: 1), (time) {
      if (time.tick > 300) {
        getDetailInfo();
      }
    });
  }

  Future<void> getDetailInfo() async {
    deviceId = await PlatformDeviceId.getDeviceId;
    timedOut();
  }

  void userActivityDetected([_]) {
    if (globals.logOutTimer != null) {
      globals.logOutTimer!.cancel();
      startTimer();
    }
    return;
  }

  Future<void> timedOut() async {
    globals.logOutTimer!.cancel();
    Get.off(
      () => LoginScreen(
      ),
    );
  }
}
