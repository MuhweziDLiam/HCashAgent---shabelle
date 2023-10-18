import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pivotpay/splash/splash_screen.dart';
import 'package:pivotpay/utils/theme.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:sizer/sizer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  await GlobalConfiguration().loadFromAsset('app_settings');
  PermissionStatus status = await Permission.notification.request();
  if (status.isGranted) {
    // notification permission is granted
  } else {
    // Open settings to enable notification permission
  }
  runApp(const PivotPay());
}

class PivotPay extends StatelessWidget {
  const PivotPay({super.key});
  @override
  Widget build(BuildContext context) {
    return Sizer(builder: (context, orientation, deviceType) {
      return GetMaterialApp(
        title: 'HCash Agent',
        theme: AppTheme.defaultTheme,
        home: const SplashScreen(),
        // routes: {
        //   'TransactionSuccessPage': (context) => TransactionSuccessPage(),
        // },
        debugShowCheckedModeBanner: false,
      );
    });
  }
}
