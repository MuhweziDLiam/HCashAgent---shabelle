// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:metamap_plugin_flutter/metamap_plugin_flutter.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:pivotpay/components/others/image.dart';
import 'package:pivotpay/components/others/spacers.dart';
import 'package:pivotpay/utils/resources.dart';
import 'package:platform_device_id/platform_device_id.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:store_checker/store_checker.dart';

import 'package:pivotpay/components/dialogs/dialog.dart';
import 'package:pivotpay/components/others/text.dart';
import 'package:pivotpay/globals.dart';
import 'package:pivotpay/models/installation_source.dart';
import 'package:pivotpay/utils/notification_service.dart';

Future<InstallationSource> checkInstallationSource(BuildContext context) async {
  Source installationSource;
  String source = 'UNKNOWN';
  bool canGetDetails = false;
  try {
    installationSource = await StoreChecker.getSource;
    switch (installationSource) {
      case Source.IS_INSTALLED_FROM_PLAY_STORE:
        source = "ANDROID";
        canGetDetails = true;
        break;
      case Source.IS_INSTALLED_FROM_LOCAL_SOURCE:
        //source = "Local Source";
        source = 'ANDROID';
        canGetDetails = true;
        // storeVersionDialogSplash(
        //   'Sorry',
        //   'Okay',
        //   'You are running a version of this App that is installed from an unknown source. Please Tap "Okay" to download the App from your corresponding Store',
        // );
        break;
      case Source.IS_INSTALLED_FROM_AMAZON_APP_STORE:
        source = 'ANDROID';
        canGetDetails = true;
        break;
      case Source.IS_INSTALLED_FROM_HUAWEI_APP_GALLERY:
        source = "HUAWEI";
        canGetDetails = true;
        break;
      case Source.IS_INSTALLED_FROM_SAMSUNG_GALAXY_STORE:
        source = 'ANDROID';
        canGetDetails = true;
        break;
      case Source.IS_INSTALLED_FROM_XIAOMI_GET_APPS:
        source = 'ANDROID';
        canGetDetails = true;
        break;
      case Source.IS_INSTALLED_FROM_OPPO_APP_MARKET:
        source = 'ANDROID';
        canGetDetails = true;
        break;
      case Source.IS_INSTALLED_FROM_VIVO_APP_STORE:
        source = 'ANDROID';
        canGetDetails = true;
        break;
      case Source.IS_INSTALLED_FROM_OTHER_SOURCE:
        source = 'ANDROID';
        canGetDetails = true;
        // source = 'OTHER SOURCE';
        // storeVersionDialogSplash(
        //   context,
        //   'Sorry',
        //   'Okay',
        //   'You are running a version of this App that is installed from an unknown source. Please Tap "Okay" to download the App from your corresponding Store',
        // );
        break;
      case Source.IS_INSTALLED_FROM_APP_STORE:
        source = 'IOS';
        canGetDetails = true;
        break;
      case Source.IS_INSTALLED_FROM_TEST_FLIGHT:
        source = 'TEST FLIGHT';
        storeVersionDialogSplash(
          context,
          'Sorry',
          'Okay',
          'You are running a version of this App that is installed from an unknown source. Please Tap "Okay" to download the App from your corresponding Store',
        );
        break;
      case Source.UNKNOWN:
        source = 'ANDROID';
        canGetDetails = true;
        // storeVersionDialogSplash(
        //   context,
        //   'Sorry',
        //   'Okay',
        //   'You are running a version of this App that is installed from an unknown source. Please Tap "Okay" to download the App from your corresponding Store',
        // );
        break;
      case Source.IS_INSTALLED_FROM_SAMSUNG_SMART_SWITCH_MOBILE:
        source = 'ANDROID';
        canGetDetails = true;
        break;
      case Source.IS_INSTALLED_FROM_PLAY_PACKAGE_INSTALLER:
        source = 'ANDROID';
        canGetDetails = true;
        break;
    }
  } on PlatformException {
    source = 'NO SOURCE';
    storeVersionDialogSplash(
      context,
      'Sorry',
      'Okay',
      'You are running a version of this App that is installed from an unknown source. Please Tap "Okay" to download the App from your corresponding Store',
    );
  }
  return InstallationSource(source, canGetDetails);
}

Future<String?> getDetailInfo() async {
  String? deviceId = '';
  deviceId = await PlatformDeviceId.getDeviceId;
  return deviceId;
}

Future storeVersionDialogSplash(
  BuildContext context,
  String title,
  String response,
  String dialogMessage,
) {
  return StylishDialog(
    context: context,
    alertType: StylishDialogType.ERROR,
    titleText: 'Sorry',
    dismissOnTouchOutside: false,
    confirmButton: ElevatedButton(
      onPressed: () async {},
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.fromLTRB(20, 1, 20, 1), // Set padding
      ),
      child: const SmallText(
        'Okay',
        color: Colors.white,
      ),
    ),
    animationLoop: true,
    contentText: dialogMessage,
  ).show();
}

Future storeVersionDialog(
  BuildContext context,
  String title,
  String response,
  String dialogMessage,
) {
  return StylishDialog(
    context: context,
    alertType: StylishDialogType.ERROR,
    titleText: title,
    dismissOnTouchOutside: false,
    confirmButton: ElevatedButton(
      onPressed: () async {},
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.fromLTRB(20, 1, 20, 1), // Set padding
      ),
      child: SmallText(
        response,
        color: Colors.white,
      ),
    ),
    animationLoop: true,
    contentText: dialogMessage,
  ).show();
}

Future<dynamic> customNetworkPostCall(
  Map data,
  String url, {
  BuildContext? context,
  bool showMessage = true,
}) async {
  final Codec<String, String> stringToBase64 = utf8.fuse(base64);
  final String auth = stringToBase64.encode('admin:secret123');
  try {
    final response = await http
        .post(
          Uri.parse(url),
          headers: {
            HttpHeaders.authorizationHeader: 'Basic $auth',
          },
          body: data,
        )
        .timeout(
          const Duration(seconds: 30),
        );
    if (response.statusCode == 200) {
      final responseResult = jsonDecode(response.body);
      return responseResult;
    } else {
      // if (showMessage) {
      //   networkResponseDialog(
      //     context!,
      //     'Sorry',
      //     'Okay',
      //     'Connection timeout failure at Pivot Payments. Please try again',
      //   );
      // }
      return null;
    }
  } catch (e) {
    if (showMessage) {
      // networkResponseDialog(
      //   context!,
      //   'Sorry',
      //   'Okay',
      //   'Network connection attempt failure, Check your internet connection or try again.',
      // );
    }
    return null;
  }
}

Future<dynamic> customNetworkGetCall(
  BuildContext context,
  String url, {
  bool showMessage = true,
}) async {
  final Codec<String, String> stringToBase64 = utf8.fuse(base64);
  final String auth = stringToBase64.encode('admin:secret123');
  try {
    final response = await http.get(
      Uri.parse(url),
      headers: {
        HttpHeaders.authorizationHeader: 'Basic $auth',
      },
    ).timeout(
      const Duration(seconds: 30),
    );

    if (response.statusCode == 200) {
      final responseResult = jsonDecode(response.body);
      return responseResult;
    } else {
      // if (showMessage) {
      //   networkResponseDialog(
      //     context,
      //     'Sorry',
      //     'Okay',
      //     'Connection timeout failure at Pivot Payments. Please try again',
      //   );
      // }
      return null;
    }
  } catch (e) {
    if (showMessage) {
      // networkResponseDialog(
      //   context,
      //   'Sorry',
      //   'Okay',
      //   'Network connection attempt failure, Check your internet connection or try again.',
      // );
    }
    return null;
  }
}

Future<dynamic> customGooglePeopleApi(
  BuildContext context,
  GoogleSignInAccount user,
  String url, {
  bool showMessage = true,
}) async {
  final Codec<String, String> stringToBase64 = utf8.fuse(base64);
  final String auth = stringToBase64.encode('admin:secret123');
  try {
    final response = await http
        .get(
          Uri.parse(url),
          headers: await user.authHeaders,
        )
        .timeout(
          const Duration(seconds: 30),
        );

    if (response.statusCode == 200) {
      final responseResult = jsonDecode(response.body);
      return responseResult;
    } else {
      // if (showMessage) {
      //   networkResponseDialog(
      //     context,
      //     'Sorry',
      //     'Okay',
      //     'Connection timeout failure at Pivot Payments. Please try again',
      //   );
      // }
      return null;
    }
  } catch (e) {
    if (showMessage) {
      // networkResponseDialog(
      //   context,
      //   'Sorry',
      //   'Okay',
      //   'Network connection attempt failure, Check your internet connection or try again.',
      // );
    }
    return null;
  }
}

Future infoDialog(
  BuildContext context,
  String title,
  String dialogMessage,
  String accountNumber,
  String userName,
  String source,
  String currentVersion,
) {
  return StylishDialog(
    context: context,
    alertType: StylishDialogType.INFO,
    titleText: title,
    dismissOnTouchOutside: false,
    confirmButton: Row(
      children: [
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            final metaData = {
              'metaStage': 'registration',
              'accountHolder': accountNumber,
              'osType': source,
              'appVersion': currentVersion
            };
            MetaMapFlutter.showMetaMapFlow(
              '63299e2ba5371d001da50a34',
              '63299e2ba5371d001da50a33',
              metaData,
            );
            MetaMapFlutter.resultCompleter.future.then(
              (result) async {
                final SharedPreferences prefs =
                    await SharedPreferences.getInstance();
                if (result is ResultSuccess) {
                  prefs.setString('verificationStatus', 'Pending');
                } else {
                  infoDialog(
                    context,
                    'Account Verification',
                    'Hello $userName, your account verification is incomplete. Please verify your account details now to avoid any transactional inconveniences.',
                    accountNumber,
                    userName,
                    source,
                    currentVersion,
                  );
                }
              },
            );
          },
          style: ElevatedButton.styleFrom(
            minimumSize: Size.zero,
            padding: const EdgeInsets.fromLTRB(
              60,
              10,
              60,
              10,
            ),
          ),
          child: const MediumText(
            'Verify',
            color: Colors.white,
          ),
        ),
      ],
    ),
    animationLoop: true,
    contentText: dialogMessage,
  ).show();
}

Future networkResponseDialog(
  BuildContext context,
  String title,
  String response,
  String dialogMessage,
) {
  return StylishDialog(
    context: context,
    alertType: StylishDialogType.ERROR,
    titleText: 'Sorry',
    dismissOnTouchOutside: false,
    confirmButton: Row(
      children: [
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            minimumSize: Size.zero,
            padding: const EdgeInsets.fromLTRB(
              60,
              10,
              60,
              10,
            ),
          ),
          child: const MediumText(
            'Okay',
            color: Colors.white,
          ),
        ),
      ],
    ),
    animationLoop: true,
    contentText: dialogMessage,
  ).show();
}

Future successDialog(
  String title,
  String response,
  String dialogMessage,
  BuildContext context,
) {
  return StylishDialog(
    context: context,
    alertType: StylishDialogType.SUCCESS,
    titleText: 'Success',
    dismissOnTouchOutside: false,
    confirmButton: Row(
      children: [
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            minimumSize: Size.zero,
            padding: const EdgeInsets.fromLTRB(
              60,
              10,
              60,
              10,
            ),
          ),
          child: const MediumText(
            'Okay',
            color: Colors.white,
          ),
        ),
      ],
    ),
    animationLoop: true,
    contentText: dialogMessage,
  ).show();
}

Future responseDialog(
  String title,
  String response,
  String dialogMessage,
  BuildContext context,
) {
  return StylishDialog(
    context: context,
    alertType: StylishDialogType.ERROR,
    titleText: 'Sorry',
    dismissOnTouchOutside: false,
    titleStyle: const TextStyle(
        fontFamily: 'WorkSans', fontSize: 18, fontWeight: FontWeight.bold),
    contentStyle: const TextStyle(fontFamily: 'WorkSans', fontSize: 12),
    confirmButton: Row(
      children: [
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            minimumSize: Size.zero,
            padding: const EdgeInsets.fromLTRB(
              60,
              10,
              60,
              10,
            ),
          ),
          child: const MediumText(
            'Okay',
            color: Colors.white,
          ),
        ),
      ],
    ),
    animationLoop: true,
    contentText: dialogMessage,
  ).show();
}

String formatNumber(int number) {
  NumberFormat format = NumberFormat("###,###", "en_US");
  return format.format(number);
}

Future<List<String>> getCurrencies() async {
  List<String> supportedCurrencies = [];
  SharedPreferences preferences = await SharedPreferences.getInstance();
  supportedCurrencies =
      preferences.getString('supportedCurrencies')!.split(',');
  return supportedCurrencies;
}

createNotification(
  String channelId,
  String channelName,
  String channelDescription,
  String data,
) async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().init();

  final AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    channelId,
    channelName,
    channelDescription: channelDescription,
  );

  final NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);

  const int max = 1000000;
  final int randomNumber = Random().nextInt(max);
  await FlutterLocalNotificationsPlugin().show(
    randomNumber,
    channelName,
    'Please note that your transaction is being processed, Incase there is a delay kindly Contact Customer Support',
    platformChannelSpecifics,
    payload: 'data',
  );
}

Future<String> getCountry(Position position) async {
  final List<Placemark> newPlace =
      await placemarkFromCoordinates(position.latitude, position.longitude);
  final Placemark placeMark = newPlace[0];
  return placeMark.country!;
}

Future<Position> determinePosition(BuildContext context) async {
  bool serviceEnabled;
  LocationPermission permission;
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    responseDialog(
      'Sorry',
      'Okay',
      'Please enable location services to proceed',
      context,
    );
    return Future.error('Location services are disabled.');
  }
  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      responseDialog(
        'Sorry',
        'Okay',
        'Please enable location services to proceed',
        context,
      );
      return Future.error('Location permissions are denied');
    }
  }
  if (permission == LocationPermission.deniedForever) {
    responseDialog(
      'Sorry',
      'Okay',
      'Please enable location services to proceed',
      context,
    );
    return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
  }
  return Geolocator.getCurrentPosition();
}

showComingSoonDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.primaryColor,
          borderRadius: const BorderRadius.all(
            Radius.circular(10.0),
          ),
        ),
        child: const Center(
          child: MediumText(
            'Coming Soon',
            size: 16,
            color: AppColors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          VSpace.md,
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              VSpace.sm,
              InAppImage(
                AppImages.construction,
                height: 250,
              ),
              VSpace.md,
              const MediumText(
                'Sorry, this feature is still under development, you will be notified when it is fully available',
              ),
            ],
          ),
        ],
      ),
      actions: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.pivotPayColorGreen,
              borderRadius: const BorderRadius.all(
                Radius.circular(10.0),
              ),
            ),
            child: const Center(
              child: MediumText(
                'Okay',
                size: 16,
                color: AppColors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
      actionsPadding: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
    ),
  );
}
