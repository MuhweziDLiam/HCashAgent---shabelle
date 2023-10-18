//import 'package:alt_sms_autofill/alt_sms_autofill.dart';
import 'package:flutter/material.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:lottie/lottie.dart';
import 'package:metamap_plugin_flutter/metamap_plugin_flutter.dart';
import 'package:pivotpay/components/others/image.dart';
import 'package:pivotpay/components/others/spacers.dart';
import 'package:pivotpay/components/others/text.dart';
import 'package:pivotpay/functions/shared_modules.dart';
import 'package:pivotpay/login/login_screen.dart';
import 'package:pivotpay/utils/base_page.dart';
import 'package:pivotpay/utils/resources.dart';
import 'package:pivotpay/utils/routing.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CompletePage extends BasePage {
  String? appVersion, phoneNumber, source, deviceId, userName, accountNumber;
  bool? deviceIdExists;
  CompletePage({
    super.key,
    this.appVersion,
    this.source,
    this.phoneNumber,
    this.deviceId,
    this.deviceIdExists,
    this.userName,
    this.accountNumber,
  });

  @override
  _CompletePageState createState() => _CompletePageState();
}

class _CompletePageState extends BaseState<CompletePage> with BasicPage {
  final _formCompleteKey = GlobalKey<FormState>();
  bool ignoreTaps = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget rootWidget(BuildContext context) {
    return Scaffold(
      body: IgnorePointer(
        ignoring: ignoreTaps,
        child: ProgressHUD(
          child: SingleChildScrollView(
            child: Container(
              margin: const EdgeInsets.only(top: 50),
              child: Column(
                children: [
                  VSpace.md,
                  InAppImage(
                    AppImages.ppImgColored,
                    height: 40,
                  ),
                  VSpace.md,
                  Text.rich(
                    TextSpan(
                      text: 'Verification',
                      style: TextStyle(
                        color: AppColors.primaryColor,
                        fontFamily: 'Lato',
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                      ),
                      children: <InlineSpan>[
                        TextSpan(
                          text: ' Complete!',
                          style: TextStyle(
                              color: AppColors.pivotPayColorGreen,
                              fontFamily: 'Lato'),
                        )
                      ],
                    ),
                  ),
                  VSpace.lg,
                  Container(
                    padding: const EdgeInsets.only(top: 10, bottom: 10),
                    margin: const EdgeInsets.only(left: 10, right: 10),
                    decoration: BoxDecoration(
                      color: AppColors.pivotPayColorGreen,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(
                          10.0,
                        ),
                        topRight: Radius.circular(
                          10.0,
                        ),
                      ),
                    ),
                    child: const Center(
                      child: Padding(
                        padding: EdgeInsets.all(5.0),
                        child: MediumText(
                          'Congratulations!',
                          color: AppColors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    margin: const EdgeInsets.only(
                        left: 10, right: 10, top: 0, bottom: 10),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.black, width: 0.2),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(
                          10.0,
                        ),
                        bottomRight: Radius.circular(
                          10.0,
                        ),
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(
                              Radius.circular(12.0),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              VSpace.sm,
                              Container(
                                padding: const EdgeInsets.all(10),
                                margin:
                                    const EdgeInsets.fromLTRB(10, 10, 10, 5),
                                decoration: BoxDecoration(
                                  color: AppColors.pivotPayColorGreen,
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(5),
                                  ),
                                ),
                                child: const Center(
                                  child: MediumText(
                                    'Your Pivot Pay account has successfully been created!',
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.white,
                                    size: 14,
                                  ),
                                ),
                              ),
                              InAppImage(
                                AppImages.complete,
                                height: 300,
                                fit: BoxFit.contain,
                              ),
                              Container(
                                padding: const EdgeInsets.all(10),
                                margin:
                                    const EdgeInsets.fromLTRB(10, 10, 10, 10),
                                decoration: BoxDecoration(
                                  color: AppColors.black.withOpacity(0.08),
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(5),
                                  ),
                                ),
                                child: const Center(
                                  child: MediumText(
                                    'Click the button below to verify your account and unlock our unlimited services.',
                                    fontWeight: FontWeight.w400,
                                    size: 14,
                                  ),
                                ),
                              ),
                              VSpace.sm,
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      margin: const EdgeInsets.only(
                                          left: 15, bottom: 10, right: 15),
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
                                          Navigator.of(context).pop();
                                          final metaData = {
                                            'metaStage': 'profile',
                                            'accountHolder':
                                                widget.accountNumber,
                                            'osType': widget.source,
                                            'appVersion': widget.appVersion
                                          };
                                          MetaMapFlutter.showMetaMapFlow(
                                            '63299e2ba5371d001da50a34',
                                            '63299e2ba5371d001da50a33',
                                            metaData,
                                          );
                                          MetaMapFlutter.resultCompleter.future
                                              .then(
                                            (result) async {
                                              final SharedPreferences prefs =
                                                  await SharedPreferences
                                                      .getInstance();
                                              if (result is ResultSuccess) {
                                                prefs.setString(
                                                    'verificationStatus',
                                                    'Pending');
                                                Navigator.pushAndRemoveUntil(
                                                  _formCompleteKey
                                                      .currentContext!,
                                                  PageRouter.fadeScale(() =>
                                                      LoginScreen(
                                                        deviceId:
                                                            widget.deviceId!,
                                                        osType: widget.source!,
                                                        fromMetaScreen: true,
                                                        deviceIdExists: widget
                                                            .deviceIdExists!,
                                                      )),
                                                  (route) => false,
                                                );
                                              } else {
                                                infoDialog(
                                                  _formCompleteKey
                                                      .currentContext!,
                                                  'Account Verification',
                                                  'Hello ${widget.userName}, your account verification is incomplete. Please verify your account details now to avoid any transactional inconveniences.',
                                                  widget.accountNumber!,
                                                  widget.userName!,
                                                  widget.source!,
                                                  widget.appVersion!,
                                                );
                                              }
                                            },
                                          );
                                        },
                                        child: const MediumText(
                                          'Proceed',
                                          color: AppColors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              VSpace.sm,
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
