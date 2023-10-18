import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:pivotpay/functions/shared_modules.dart';
import 'package:pivotpay/home/home_screen.dart';
import 'package:pivotpay/login/login_screen.dart';
import 'package:pivotpay/network/api_service.dart';
import 'package:pivotpay/utils/resources.dart';
import 'package:pivotpay/utils/routing.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    initApp();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(color: Colors.white),
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: Image.asset(
                    AppImages.hcaSplashImg,
                    height: 200,
                    width: 200,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void startTransition(
      bool deviceIdExists, String deviceId, String osType) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    if (!mounted) return;
    if (preferences.getBool('isLoggedIn') ?? false) {
      Navigator.pushAndRemoveUntil(
        context,
        PageRouter.fadeThrough(
          () => const HomePage(),
        ),
        (route) => false,
      );
    } else {
      Navigator.pushAndRemoveUntil(
        context,
        PageRouter.fadeThrough(
          () => LoginScreen(
            deviceIdExists: deviceIdExists,
            osType: osType,
            deviceId: deviceId,
          ),
        ),
        (route) => false,
      );
    }
  }

  initApp() {
    checkInstallationSource(context).then(
      (installSrcResult) {
        if (installSrcResult.canGetDetails) {
          getDetailInfo().then(
            (deviceId) {
              final Map data = {'deviceId': deviceId};
              checkDeviceId(context, data).then((deviceIdResults) {
                final preferences = GetStorage();
                preferences.write('deviceId', deviceId!);
                preferences.write('source', installSrcResult.source);
                if (deviceIdResults.status!) {
                  startTransition(true, deviceId, installSrcResult.source);
                } else {
                  startTransition(false, deviceId, installSrcResult.source);
                }
              });
            },
          );
        } else {
          storeVersionDialog(
            context,
            'Sorry',
            'Okay',
            'You are running a version of this App that is installed from an unknown source. Please Tap "Okay" to download the App from your corresponding Store',
          );
        }
      },
    );
  }
}
