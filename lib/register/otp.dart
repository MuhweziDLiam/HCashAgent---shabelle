import 'dart:async';
import 'dart:developer';
import 'dart:math';

//import 'package:alt_sms_autofill/alt_sms_autofill.dart';
import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:metamap_plugin_flutter/metamap_plugin_flutter.dart';
import 'package:pivotpay/components/inputs/pinfield.dart';
import 'package:pivotpay/components/others/image.dart';
import 'package:pivotpay/components/others/spacers.dart';
import 'package:pivotpay/components/others/text.dart';
import 'package:pivotpay/functions/shared_modules.dart';
import 'package:pivotpay/login/login_screen.dart';
import 'package:pivotpay/network/api_service.dart';
import 'package:pivotpay/register/complete.dart';
import 'package:pivotpay/utils/base_page.dart';
import 'package:pivotpay/utils/resources.dart';
import 'package:pivotpay/utils/routing.dart';
import 'package:pivotpay/utils/style.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum OTPState { register, resetPin, login }

class OTPPage extends BasePage {
  String? appVersion,
      phoneNumber,
      source,
      country,
      firstName,
      lastName,
      countryCode,
      currencyCode,
      imgUrl,
      email,
      dob,
      idNumber,
      pin,
      deviceId,
      userName,
      gender;
  bool? deviceIdExists;
  OTPState state;

  OTPPage({
    super.key,
    this.appVersion,
    this.source,
    this.phoneNumber,
    this.country,
    this.idNumber,
    this.currencyCode,
    this.countryCode,
    this.imgUrl,
    this.deviceId,
    this.dob,
    this.email,
    this.pin,
    this.deviceIdExists,
    this.userName,
    this.state = OTPState.register,
    this.gender,
    this.firstName,
    this.lastName,
  });

  @override
  _OTPPageState createState() => _OTPPageState();
}

class _OTPPageState extends BaseState<OTPPage> with BasicPage {
  final _formOtpKey = GlobalKey<FormState>();
  Timer? timer;
  int? otpCode;
  bool ignoreTaps = false;
  final TextEditingController _pinNumber = TextEditingController();
  final String _comingSms = 'Unknown';
  String location = 'Unknown';
  // Future<void> initSmsListener() async {
  //   String comingSms;
  //   try {
  //     comingSms = await AltSmsAutofill().listenForSms;
  //     comingSms = comingSms.replaceAll(RegExp('[^0-9]'), '');
  //     if (comingSms.isNotEmpty) {
  //       _pinNumber.value = TextEditingValue(text: comingSms);
  //     }
  //   } on PlatformException {
  //     comingSms = 'Unknown';
  //   }
  // }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getDetails();
      sendCode();
    });
  }

  getDetails() async {
    final Position position =
        await determinePosition(_formOtpKey.currentContext!);
    location = await getCountry(position);
  }

  @override
  void dispose() {
    //AltSmsAutofill().unregisterListener();
    super.dispose();
  }

  sendCode() {
    final progress = ProgressHUD.of(_formOtpKey.currentContext!);
    progress!.showWithText('Sending OTP...');
    setState(() {
      ignoreTaps = true;
    });
    otpCode = Random().nextInt(900000) + 100000;
    print(otpCode);
    final Map data = {
      'message': '$otpCode is your OTP code for HCash Agent App.',
      'email': widget.email ?? 'support@pivotpayts.com',
      'phoneNumber': widget.phoneNumber,
    };
    sendOTP(context, data).then((value) {
      if (value.status!) {
        progress.dismiss();
        setState(() {
          ignoreTaps = false;
        });
        successDialog(
          'Success',
          'Okay',
          'An Otp message has been sent to Phone Number ${widget.phoneNumber}.',
          _formOtpKey.currentContext!,
        );
      } else {
        progress.dismiss();
        setState(() {
          ignoreTaps = false;
        });
        responseDialog(
          'Sorry',
          'Okay',
          value.responseMessage!,
          _formOtpKey.currentContext!,
        );
      }
    });
  }

  @override
  Widget rootWidget(BuildContext context) {
    return Scaffold(
      body: IgnorePointer(
        ignoring: ignoreTaps,
        child: ProgressHUD(
          child: Builder(
            builder: (context) => Form(
              key: _formOtpKey,
              child: SingleChildScrollView(
                child: Container(
                  margin: const EdgeInsets.only(top: 50),
                  child: Column(
                    children: [
                      VSpace.md,
                      InAppImage(
                        AppImages.hcaLogoColored,
                        height: 60,
                      ),
                      VSpace.md,
                      Text.rich(
                        TextSpan(
                          text: 'Verify',
                          style: TextStyle(
                            color: AppColors.primaryColor,
                            fontFamily: 'Lato',
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                          ),
                          children: <InlineSpan>[
                            TextSpan(
                              text: ' your Phone Number',
                              style: TextStyle(
                                  color: AppColors.pivotPayColorGreen,
                                  fontFamily: 'Lato'),
                            )
                          ],
                        ),
                      ),
                      VSpace.md,
                      Container(
                        padding: const EdgeInsets.only(left: 10, right: 10),
                        margin: const EdgeInsets.only(
                            left: 10, right: 10, top: 10, bottom: 10),
                        decoration: BoxDecoration(
                          border:
                              Border.all(color: AppColors.black, width: 0.2),
                          borderRadius: const BorderRadius.all(
                            Radius.circular(10.0),
                          ),
                        ),
                        child: Column(
                          children: [
                            VSpace.lg,
                            InAppImage(
                              AppImages.otpFrame,
                              height: 280,
                              fit: BoxFit.contain,
                            ),
                            VSpace.lg,
                            Align(
                                child: Row(
                              children: [
                                LottieBuilder.asset(
                                  AppImages.notification,
                                  height: 50,
                                ),
                                HSpace.sm,
                                Flexible(
                                  child: Text.rich(
                                    TextSpan(
                                      text:
                                          'We have sent a one time password on this Mobile Number - ',
                                      style: TextStyle(
                                        color: AppColors.primaryColor,
                                        fontFamily: 'Lato',
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14,
                                      ),
                                      children: <InlineSpan>[
                                        TextSpan(
                                          text: widget.phoneNumber,
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: AppColors.pivotPayColorGreen,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            )),
                            VSpace.lg,
                            PinInputField(
                              count: 6,
                              controller: _pinNumber,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your OTP';
                                }
                                return null;
                              },
                            ),
                            const VSpace(50),
                            Container(
                              margin:
                                  const EdgeInsets.only(left: 15, right: 15),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            AppColors.black.withOpacity(0.1),
                                        minimumSize: Size.zero,
                                        padding: const EdgeInsets.fromLTRB(
                                          10,
                                          12,
                                          10,
                                          12,
                                        ),
                                      ),
                                      child: const MediumText('Cancel'),
                                      onPressed: () => Navigator.pop(context),
                                    ),
                                  ),
                                  const HSpace(20),
                                  Expanded(
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        minimumSize: Size.zero,
                                        padding: const EdgeInsets.fromLTRB(
                                          10,
                                          12,
                                          10,
                                          12,
                                        ),
                                      ),
                                      child: const MediumText(
                                        'Confirm',
                                        color: AppColors.white,
                                      ),
                                      onPressed: () {
                                        if (_formOtpKey.currentState!
                                            .validate()) {
                                          setState(() {
                                            _formOtpKey.currentState!.save();
                                          });
                                          if (_pinNumber.text.isEmpty) {
                                            responseDialog(
                                              'Sorry',
                                              'Okay',
                                              'Please enter your OTP code',
                                              _formOtpKey.currentContext!,
                                            );
                                          } else {
                                            if (otpCode.toString() ==
                                                _pinNumber.text) {
                                              if (widget.state ==
                                                  OTPState.register) {
                                                registerUser();
                                              } else if (widget.state ==
                                                  OTPState.login) {
                                                Navigator.pop(context, true);
                                              } else {
                                                reset();
                                              }
                                            } else {
                                              responseDialog(
                                                'Sorry',
                                                'Okay',
                                                'Invalid OTP supplied, please confirm and try again.',
                                                _formOtpKey.currentContext!,
                                              );
                                            }
                                          }
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            VSpace.lg,
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  registerUser() async {
    final progress = ProgressHUD.of(_formOtpKey.currentContext!);
    progress!.showWithText('Registering User...');
    setState(() {
      ignoreTaps = true;
    });
    final Map data = {
      'country': widget.country,
      'first_name': widget.firstName,
      'second_name': widget.lastName,
      'phone_number': widget.phoneNumber,
      'pin': widget.pin,
      'device_id': widget.deviceId,
      'appVersion': widget.appVersion,
      'osType': widget.source,
      'dob': widget.dob,
      'idNumber': widget.idNumber,
      'location': location,
      'gender': widget.gender,
      'user_name': widget.userName,
      'currency': widget.currencyCode,
      'country_code': widget.countryCode,
      'email': widget.email,
      'profile_img': widget.imgUrl,
    };
    registerUserAccount(context, data).then((value) {
      if (value.status!) {
        progress.dismiss();
        setState(() {
          ignoreTaps = false;
        });
        Navigator.pushAndRemoveUntil(
            context,
            PageRouter.fadeThrough(
              () => CompletePage(
                deviceIdExists: true,
                deviceId: widget.deviceId!,
                appVersion: widget.appVersion,
                phoneNumber: widget.phoneNumber,
                source: widget.source,
                userName: widget.userName!,
                accountNumber: value.accountNumber.toString(),
              ),
            ),
            (route) => false);
        //showSuccessDialog(value.accountNumber!.toString());
      } else {
        progress.dismiss();
        setState(() {
          ignoreTaps = false;
        });
        responseDialog(
          'Sorry',
          'Okay',
          value.responseMessage!,
          _formOtpKey.currentContext!,
        );
      }
    });
  }

  reset() async {
    final progress = ProgressHUD.of(_formOtpKey.currentContext!);
    progress!.showWithText('Reseting Pin...');
    final Map data = {
      'username': widget.userName,
      'pin': widget.pin,
    };
    setState(() {
      ignoreTaps = true;
    });
    resetPin(context, data).then((changePinResults) async {
      progress.dismiss();
      setState(() {
        ignoreTaps = false;
      });
      if (changePinResults.status!) {
        _saveSession(widget.pin!);
      } else {
        responseDialog(
          'Sorry',
          'Okay',
          changePinResults.reponseMessage!,
          _formOtpKey.currentContext!,
        );
      }
    });
  }

  _saveSession(
    String pin,
  ) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.clear();
    if (!mounted) return;
    showModal(
      context: context,
      builder: (context) => Dialog(
        shape: ContinuousRectangleBorder(
          borderRadius: BorderRadius.circular(44),
        ),
        child: Padding(
          padding: EdgeInsets.all(Insets.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              const MediumText(
                'Your pin has been reset successfully',
                align: TextAlign.center,
              ),
              VSpace.md,
              Container(
                height: 100,
                width: 100,
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: LottieBuilder.asset(
                  AppImages.success,
                ),
              ),
              VSpace.lg,
              Padding(
                padding: EdgeInsets.symmetric(horizontal: Insets.lg),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size.zero,
                    padding: const EdgeInsets.fromLTRB(
                      60,
                      12,
                      60,
                      12,
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushAndRemoveUntil(
                      context,
                      PageRouter.fadeScale(
                        () => LoginScreen(
                          deviceIdExists: widget.deviceIdExists!,
                          deviceId: widget.deviceId!,
                          osType: widget.source!,
                        ),
                      ),
                      (route) => false,
                    );
                  },
                  child: const MediumText(
                    'Okay',
                    color: AppColors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
