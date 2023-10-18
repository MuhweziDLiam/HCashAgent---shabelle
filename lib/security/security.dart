import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:get_storage/get_storage.dart';
import 'package:lottie/lottie.dart';
import 'package:pivotpay/components/inputs/pinfield.dart';
import 'package:pivotpay/components/inputs/textfield.dart';
import 'package:pivotpay/components/others/buttons.dart';
import 'package:pivotpay/components/others/image.dart';
import 'package:pivotpay/components/others/spacers.dart';
import 'package:pivotpay/components/others/text.dart';
import 'package:pivotpay/functions/shared_modules.dart';
import 'package:pivotpay/login/login_screen.dart';
import 'package:pivotpay/network/api_service.dart';
import 'package:pivotpay/utils/base_page.dart';
import 'package:pivotpay/utils/resources.dart';
import 'package:pivotpay/utils/routing.dart';
import 'package:pivotpay/utils/style.dart';
import 'package:pivotpay/validators/validators.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SecurityPage extends BasePage {
  const SecurityPage({super.key});

  @override
  State<SecurityPage> createState() => _SecurityPageState();
}

class _SecurityPageState extends BaseState<SecurityPage> with BasicPage {
  String? oPin, deviceId, osType;
  final _formSecurityKey = GlobalKey<FormState>();
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _oldPinController = TextEditingController();
  final TextEditingController _confirmPinController = TextEditingController();
  int step = 0;
  bool ignoreTaps = false;

  @override
  Widget rootWidget(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: const MediumText(
          'Change Pin',
          size: 16,
          color: Colors.white,
        ),
        actions: [
          IconButton(
            onPressed: (() {}),
            icon: InAppImage(
              AppIcons.notification,
              height: 20,
            ),
          ),
          const HSpace(5),
        ],
      ),
      body: IgnorePointer(
        ignoring: ignoreTaps,
        child: ProgressHUD(
          child: SingleChildScrollView(
            child: Builder(
              builder: (context) => Form(
                key: _formSecurityKey,
                child: Column(
                  children: [
                    Column(
                      children: [
                        VSpace.lg,
                        Text.rich(
                          TextSpan(
                            text: 'Change your',
                            style: TextStyle(
                              color: AppColors.primaryColor,
                              fontFamily: 'Lato',
                              fontWeight: FontWeight.w800,
                              fontSize: 18,
                            ),
                            children: <InlineSpan>[
                              TextSpan(
                                text: ' Pin',
                                style: TextStyle(
                                    color: AppColors.pivotPayColorGreen,
                                    fontFamily: 'Lato'),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                    VSpace.md,
                    Container(
                      padding: const EdgeInsets.only(left: 15, right: 15),
                      margin: const EdgeInsets.only(
                          left: 20, right: 20, top: 20, bottom: 10),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.black, width: 0.2),
                        borderRadius: const BorderRadius.all(
                          Radius.circular(10.0),
                        ),
                      ),
                      child: Column(
                        children: [
                          VSpace.md,
                          InAppImage(
                            AppImages.changePin,
                            height: 200,
                          ),
                          VSpace.md,
                          TextInputField(
                            hintText: 'Old Pin',
                            obsecureText: true,
                            prefixIcon: Icon(
                              Icons.lock,
                              color: AppColors.pivotPayColorGreen,
                            ),
                            validator: (value) {
                              value = value!.replaceAll(' ', '');
                              if (value.isEmpty) {
                                return 'Please enter your Old Pin';
                              }
                              if (!validateNumbers(value)) {
                                return 'Invalid value supplied';
                              }
                              return null;
                            },
                            controller: _oldPinController,
                            keyboardType: TextInputType.number,
                            onTap: () {},
                            onSaved: (value) {},
                          ),
                          VSpace.lg,
                          TextInputField(
                            hintText: 'New Pin',
                            obsecureText: true,
                            prefixIcon: Icon(
                              Icons.lock,
                              color: AppColors.pivotPayColorGreen,
                            ),
                            validator: (value) {
                              value = value!.replaceAll(' ', '');
                              if (value.isEmpty) {
                                return 'Please enter your New Pin';
                              }
                              if (!validateNumbers(value)) {
                                return 'Invalid pin supplied';
                              }
                              return null;
                            },
                            controller: _pinController,
                            keyboardType: TextInputType.number,
                            onTap: () {},
                            onSaved: (value) {},
                          ),
                          VSpace.lg,
                          TextInputField(
                            hintText: 'Confirm New Pin',
                            obsecureText: true,
                            prefixIcon: Icon(
                              Icons.lock,
                              color: AppColors.pivotPayColorGreen,
                            ),
                            validator: (value) {
                              value = value!.replaceAll(' ', '');
                              if (value.isEmpty) {
                                return 'Please confirm your new Pin';
                              }
                              if (!validateNumbers(value)) {
                                return 'Invalid pin supplied';
                              }
                              return null;
                            },
                            controller: _confirmPinController,
                            keyboardType: TextInputType.number,
                            onTap: () {},
                            onSaved: (value) {},
                          ),
                          VSpace.lg,
                          Padding(
                            padding:
                                EdgeInsets.symmetric(horizontal: Insets.lg),
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
                                if (_formSecurityKey.currentState!.validate()) {
                                  setState(() {
                                    _formSecurityKey.currentState!.save();
                                  });
                                  SharedPreferences.getInstance().then(
                                    (value) {
                                      if (value.getString('pin') ==
                                          _oldPinController.text) {
                                        if (_oldPinController.text ==
                                            _pinController.text) {
                                          responseDialog(
                                            'Sorry',
                                            'Okay',
                                            'New pin cannot be the same as current pin',
                                            _formSecurityKey.currentContext!,
                                          );
                                        } else {
                                          if (_pinController.text.isEmpty) {
                                            responseDialog(
                                              'Sorry',
                                              'Okay',
                                              'New pin cannot be empty',
                                              _formSecurityKey.currentContext!,
                                            );
                                          } else {
                                            if (_pinController.text ==
                                                _confirmPinController.text) {
                                              _changePin(
                                                  value.getString('userName')!);
                                            } else {
                                              responseDialog(
                                                'Sorry',
                                                'Okay',
                                                'Please confirm pin.',
                                                _formSecurityKey
                                                    .currentContext!,
                                              );
                                            }
                                          }
                                        }
                                      } else {
                                        if (_oldPinController.text.isEmpty) {
                                          responseDialog(
                                            'Sorry',
                                            'Okay',
                                            'Old cannot be empty',
                                            _formSecurityKey.currentContext!,
                                          );
                                        } else {
                                          responseDialog(
                                            'Sorry',
                                            'Okay',
                                            'Old pin does not match',
                                            _formSecurityKey.currentContext!,
                                          );
                                        }
                                      }
                                    },
                                  );
                                }
                              },
                              child: const MediumText(
                                'Proceed',
                                color: AppColors.white,
                              ),
                            ),
                          ),
                          VSpace.md,
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
    );
  }

  _changePin(String userName) async {
    final progress = ProgressHUD.of(_formSecurityKey.currentContext!);
    progress!.showWithText('Changing Pin...');
    final Map data = {
      'username': userName,
      'pin': _pinController.text,
      'old_pin': _oldPinController.text
    };
    setState(() {
      ignoreTaps = true;
    });
    changePin(context, data).then((changePinResults) async {
      progress.dismiss();
      setState(() {
        ignoreTaps = false;
      });
      if (changePinResults.status!) {
        _saveSession(
          _pinController.text,
        );
      } else {
        responseDialog(
          'Sorry',
          'Okay',
          changePinResults.reponseMessage!,
          _formSecurityKey.currentContext!,
        );
      }
    });
  }

  _saveSession(
    String pin,
  ) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.clear();
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
                'Your pin has been changed successfully',
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
                    final deviceInfo = GetStorage();
                    deviceId = deviceInfo.read('deviceId');
                    osType = deviceInfo.read('source');
                    Navigator.pop(context);
                    Navigator.pushAndRemoveUntil(
                      context,
                      PageRouter.fadeScale(
                        () => LoginScreen(
                          deviceIdExists: true,
                          deviceId: deviceId!,
                          osType: osType!,
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
