import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:get_storage/get_storage.dart';
import 'package:lottie/lottie.dart';
import 'package:pivotpay/common/pin.dart';
import 'package:pivotpay/components/inputs/pinfield.dart';
import 'package:pivotpay/components/inputs/textfield.dart';
import 'package:pivotpay/components/others/buttons.dart';
import 'package:pivotpay/components/others/image.dart';
import 'package:pivotpay/components/others/spacers.dart';
import 'package:pivotpay/components/others/text.dart';
import 'package:pivotpay/functions/shared_modules.dart';
import 'package:pivotpay/login/login_screen.dart';
import 'package:pivotpay/network/api_service.dart';
import 'package:pivotpay/register/otp.dart';
import 'package:pivotpay/utils/base_page.dart';
import 'package:pivotpay/utils/resources.dart';
import 'package:pivotpay/utils/routing.dart';
import 'package:pivotpay/utils/style.dart';
import 'package:pivotpay/validators/validators.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ForgotPinPage extends BasePage {
  String? deviceId, osType, appVersion;
  bool? deviceIdExists;
  ForgotPinPage({
    super.key,
    this.deviceId,
    this.osType,
    this.appVersion,
    this.deviceIdExists,
  });

  @override
  State<ForgotPinPage> createState() => _ForgotPinPageState();
}

class _ForgotPinPageState extends BaseState<ForgotPinPage> with BasicPage {
  final _formResetKey = GlobalKey<FormState>();
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _confirmPinController = TextEditingController();
  bool ignoreTaps = false;

  @override
  Widget rootWidget(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: const MediumText(
          'Forgot Pin',
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
                key: _formResetKey,
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
                            AppImages.forgot,
                            height: 200,
                          ),
                          VSpace.md,
                          TextInputField(
                            hintText: 'Username',
                            prefixIcon: Icon(
                              Icons.account_circle_rounded,
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
                                if (_formResetKey.currentState!.validate()) {
                                  setState(() {
                                    _formResetKey.currentState!.save();
                                  });
                                  SharedPreferences.getInstance().then(
                                    (value) {
                                      if (_pinController.text.isEmpty) {
                                        responseDialog(
                                          'Sorry',
                                          'Okay',
                                          'New pin cannot be empty',
                                          _formResetKey.currentContext!,
                                        );
                                      } else {
                                        if (_pinController.text ==
                                            _confirmPinController.text) {
                                          checkUserDetails();
                                        } else {
                                          responseDialog(
                                            'Sorry',
                                            'Okay',
                                            'Please confirm pin.',
                                            _formResetKey.currentContext!,
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

  checkUserDetails() {
    final progress = ProgressHUD.of(_formResetKey.currentContext!);
    progress!.showWithText('Checking Username...');
    final Map data = {
      'user': _usernameController.text,
    };
    checkUserName(context, data).then((value) {
      if (value.status!) {
        progress.dismiss();
        setState(() {
          ignoreTaps = false;
        });
        Navigator.push(
          context,
          PageRouter.fadeScale(
            () => OTPPage(
              source: widget.osType,
              appVersion: widget.appVersion,
              deviceIdExists: widget.deviceIdExists!,
              deviceId: widget.deviceId,
              userName: _usernameController.text,
              state: OTPState.resetPin,
              pin: _pinController.text,
              phoneNumber: value.phoneNumber,
            ),
          ),
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
          _formResetKey.currentContext!,
        );
      }
    });
  }
}
