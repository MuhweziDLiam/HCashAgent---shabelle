import 'package:flutter/material.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:get_storage/get_storage.dart';
import 'package:pivotpay/components/inputs/textfield.dart';
import 'package:pivotpay/components/others/image.dart';
import 'package:pivotpay/components/others/spacers.dart';
import 'package:pivotpay/components/others/text.dart';
import 'package:pivotpay/functions/shared_modules.dart';
import 'package:pivotpay/home/home_screen.dart';
import 'package:pivotpay/models/user.dart';
import 'package:pivotpay/network/api_service.dart';
import 'package:pivotpay/register/otp.dart';
import 'package:pivotpay/register/register.dart';
import 'package:pivotpay/security/forgot_pin.dart';
import 'package:pivotpay/support/web.dart';
import 'package:pivotpay/utils/resources.dart';
import 'package:pivotpay/utils/routing.dart';
import 'package:pivotpay/utils/style.dart';
import 'package:pivotpay/validators/validators.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginScreen extends StatefulWidget {
  bool deviceIdExists;
  String deviceId, osType;
  bool fromMetaScreen;
  LoginScreen(
      {Key? key,
      this.deviceIdExists = false,
      this.deviceId = '',
      this.fromMetaScreen = false,
      this.osType = ''})
      : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  bool ignoreTaps = false;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: IgnorePointer(
        ignoring: ignoreTaps,
        child: ProgressHUD(
          child: Builder(
            builder: (context) => SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Stack(
                  children: [
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 80),
                          child: Center(
                            child: Column(
                              children: [
                                InAppImage(
                                  AppImages.hcaLogoColored,
                                  width: 150,
                                  fit: BoxFit.contain,
                                ),
                              ],
                            ),
                          ),
                        ),
                        // LottieBuilder.asset(
                        //   AppImages.loginLottie,
                        //   width: 200,
                        //   frameRate: FrameRate.composition,
                        //   fit: BoxFit.contain,
                        // ),
                        VSpace.md,
                        Container(
                          margin: const EdgeInsets.fromLTRB(10, 5, 10, 20),
                          padding: const EdgeInsets.only(bottom: 20),
                          child: Column(
                            children: [
                              InAppImage(
                                AppImages.loginFrame,
                                height: 250,
                              ),
                              VSpace.lg,
                              const MediumText(
                                'Please enter your details to continue',
                              ),
                              VSpace.md,
                              VSpace.sm,
                              Padding(
                                padding:
                                    EdgeInsets.symmetric(horizontal: Insets.lg),
                                child: TextInputField(
                                  hintText: 'Username',
                                  prefixIcon: Icon(
                                    Icons.account_circle,
                                    color: AppColors.pivotPayColorGreen,
                                  ),
                                  validator: (value) {
                                    value = value!.replaceAll(' ', '');
                                    if (value.isEmpty) {
                                      return 'Please enter your Username';
                                    }
                                    if (!validateSpecialCharacters(value)) {
                                      return 'Invalid username supplied';
                                    }
                                    return null;
                                  },
                                  controller: _usernameController,
                                  keyboardType: TextInputType.text,
                                  onTap: () {},
                                  onSaved: (value) {},
                                ),
                              ),
                              VSpace.md,
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: Insets.lg,
                                  vertical: 5,
                                ),
                                child: TextInputField(
                                  hintText: 'Pin',
                                  obsecureText: true,
                                  prefixIcon: Icon(
                                    Icons.lock,
                                    color: AppColors.pivotPayColorGreen,
                                  ),
                                  validator: (value) {
                                    value = value!.replaceAll(' ', '');
                                    if (value.isEmpty) {
                                      return 'Please enter your Pin';
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
                              ),
                              VSpace.sm,
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    PageRouter.fadeScale(
                                      () => ForgotPinPage(
                                        deviceId: widget.deviceId,
                                        osType: widget.osType,
                                        appVersion: widget.osType,
                                        deviceIdExists: widget.deviceIdExists,
                                      ),
                                    ),
                                  );
                                },
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: Insets.lg,
                                    vertical: 5,
                                  ),
                                  child: Align(
                                      child: MediumText(
                                    'Forgot PIN?',
                                    color: AppColors.primaryColor,
                                  )),
                                ),
                              ),
                              VSpace.md,
                              Padding(
                                padding:
                                    EdgeInsets.symmetric(horizontal: Insets.lg),
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
                                  onPressed: () {
                                    if (_formKey.currentState!.validate()) {
                                      setState(() {
                                        _formKey.currentState!.save();
                                      });
                                      login(
                                        _usernameController.text,
                                        _pinController.text,
                                        context,
                                      );
                                    }
                                  },
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      MediumText(
                                        'Login',
                                        color: AppColors.white,
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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

  void login(String userName, String pin, BuildContext context) async {
    final progress = ProgressHUD.of(context);
    progress!.showWithText('Logging In...');
    setState(() {
      ignoreTaps = true;
    });
    final preferences = GetStorage();
    final Map data = {
      'user_name': userName,
      'pin': pin,
      'deviceId': widget.deviceId.isEmpty
          ? preferences.read('deviceId')
          : widget.deviceId,
      'osType':
          widget.osType.isEmpty ? preferences.read('source') : widget.osType
    };
    if (!mounted) return;
    userLogin(context, data).then((value) {
      setState(() {
        ignoreTaps = false;
        progress.dismiss();
      });
      if (value.status!) {
        saveUserSession(value);
      } else {
        _pinController.text = '';
        responseDialog(
          'Sorry',
          'Okay',
          value.responseMessage!,
          _formKey.currentContext!,
        );
      }
    });
  }

  void saveUserSession(User value) {
    if (!mounted) return;
    final otpValid = Navigator.push<bool>(
      context,
      PageRouter.fadeThrough(
        () => OTPPage(
          state: OTPState.login,
          phoneNumber: value.phoneNumber,
        ),
      ),
    );
    otpValid.then(
      (otpValue) async {
        if (otpValue!) {
          final SharedPreferences preferences =
              await SharedPreferences.getInstance();
          preferences.setBool('isLoggedIn', true);
          preferences.setString('userName', _usernameController.text);
          preferences.setString('agentName', value.agentName!);
          preferences.setString('phoneNumber', value.phoneNumber!);
          preferences.setString('accountNumber', _usernameController.text);
          preferences.setString('accountBalance', value.accountBalance!);
          preferences.setString('pin', _pinController.text);
          preferences.setString('currencyCode', value.currencyCode!);
          Navigator.pushAndRemoveUntil(
            _formKey.currentContext!,
            PageRouter.fadeScale(() => const HomePage()),
            (route) => false,
          );
        }
      },
    );
  }
}
