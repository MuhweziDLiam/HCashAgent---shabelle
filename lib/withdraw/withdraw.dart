// ignore_for_file: parameter_assignments, avoid_dynamic_calls

import 'dart:async';
import 'dart:developer';

//import 'package:alt_sms_autofill/alt_sms_autofill.dart';
import 'package:clevertap_plugin/clevertap_plugin.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:local_auth/local_auth.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pivotpay/common/pin.dart';
import 'package:pivotpay/common/transaction_status.dart';
import 'package:pivotpay/components/inputs/textfield.dart';
import 'package:pivotpay/components/others/image.dart';
import 'package:pivotpay/components/others/spacers.dart';
import 'package:pivotpay/components/others/text.dart';
import 'package:pivotpay/functions/shared_modules.dart';
import 'package:pivotpay/network/api_service.dart';
import 'package:pivotpay/utils/base_page.dart';
import 'package:pivotpay/utils/resources.dart';
import 'package:pivotpay/utils/routing.dart';
import 'package:pivotpay/utils/style.dart';
import 'package:pivotpay/validators/validators.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

enum _SupportState {
  unknown,
  supported,
  unsupported,
}

class WithdrawDetailsPage extends BasePage {
  WithdrawDetailsPage({
    super.key,
  });

  @override
  _WithdrawDetailsPageState createState() => _WithdrawDetailsPageState();
}

class _WithdrawDetailsPageState extends BaseState<WithdrawDetailsPage>
    with BasicPage {
  String? senderPhone,
      recipientPhone,
      paymentNetwork,
      reference,
      bulkReference,
      pivotReference,
      toCurrencyCode,
      version,
      currencyCode,
      senderAccount,
      pivotReferenceBulk;
  String accountName = '',
      phoneNumber = '',
      amount = '0',
      accountUrl = '',
      service = '',
      sendMethod = '',
      tranReference = '',
      accountNumber = '',
      transactionCharge = '0';
  bool shimmer = false, isVisible = false;
  Timer? timer, _debounce;
  bool? isAndroid;
  final TextEditingController _secretCodeController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final _formMobileKey = GlobalKey<FormState>();
  final TextEditingController _accountNumberController =
      TextEditingController();
  bool ignoreTaps = false;
  SharedPreferences? prefs;
  final String _comingSms = 'Unknown';
  String location = 'Unknown';
  String ipAddress = 'Unknown';

  final LocalAuthentication auth = LocalAuthentication();
  _SupportState _supportState = _SupportState.unknown;
  bool? _canCheckBiometrics;
  List<BiometricType>? _availableBiometrics;
  String _authorized = 'Not Authorized';
  bool _isAuthenticating = false;

  // Future<void> initSmsListener() async {
  //   String comingSms;
  //   try {
  //     comingSms = await AltSmsAutofill().listenForSms;
  //     comingSms = comingSms.replaceAll(RegExp('[^0-9]'), '');
  //   } on PlatformException {
  //     comingSms = 'Unknown';
  //   }
  // }

  @override
  void initState() {
    super.initState();
    getInfo();
    auth.isDeviceSupported().then(
          (bool isSupported) => _supportState =
              isSupported ? _SupportState.supported : _SupportState.unsupported,
        );
  }

  getInfo() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      currencyCode = prefs!.getString('currencyCode') ?? 'ETB';
    });
    senderAccount = prefs!.getString('accountNumber');
    accountUrl = prefs!.getString('profilePicture') ?? '';
    toCurrencyCode = currencyCode;
    final versionInfo = await PackageInfo.fromPlatform();
    version = '${versionInfo.version}+${versionInfo.buildNumber}';
    final Position position =
        await determinePosition(_formMobileKey.currentContext!);
    location = await getCountry(position);
  }

  @override
  void dispose() {
    if (_isAuthenticating) {
      _cancelAuthentication();
    }
    //AltSmsAutofill().unregisterListener();
    super.dispose();
  }

  Future<bool> _checkBiometrics() async {
    bool canCheckBiometrics;
    try {
      canCheckBiometrics = await auth.canCheckBiometrics;
    } on PlatformException catch (e) {
      canCheckBiometrics = false;
      return false;
    }
    if (!mounted) {
      return false;
    }
    _canCheckBiometrics = canCheckBiometrics;
    return _canCheckBiometrics!;
  }

  Future<void> _getAvailableBiometrics() async {
    List<BiometricType> availableBiometrics;
    try {
      availableBiometrics = await auth.getAvailableBiometrics();
    } on PlatformException catch (e) {
      availableBiometrics = <BiometricType>[];
    }
    if (!mounted) {
      return;
    }
    _availableBiometrics = availableBiometrics;
  }

  Future<bool> _authenticate() async {
    bool authenticated = false;
    try {
      setState(() {
        _isAuthenticating = true;
        _authorized = 'Authenticating';
      });
      authenticated = await auth.authenticate(
        localizedReason: 'Determining the OS Authentication type',
        options: const AuthenticationOptions(
          stickyAuth: true,
        ),
      );
      setState(() {
        _isAuthenticating = false;
      });
    } on PlatformException catch (e) {
      print(e.toString());
      setState(() {
        _isAuthenticating = false;
        _authorized = 'Error - ${e.message}';
      });
      return false;
    }
    if (!mounted) {
      return false;
    }
    print(_authorized);
    _authorized = authenticated ? 'Authorized' : 'Not Authorized';
    if (_authorized == 'Authorized') {
      return true;
    } else {
      return false;
    }
  }

  Future<void> _cancelAuthentication() async {
    await auth.stopAuthentication();
    setState(() => _isAuthenticating = false);
  }

  @override
  Widget rootWidget(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: const MediumText(
          'Withdraw Money',
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
          child: Builder(
            builder: (context) => Form(
              key: _formMobileKey,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const VSpace(25),
                    Text.rich(
                      TextSpan(
                        text: 'Withdraw ',
                        style: TextStyle(
                          color: AppColors.primaryColor,
                          fontFamily: 'Lato',
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                        ),
                        children: <InlineSpan>[
                          TextSpan(
                            text: 'Money',
                            style: TextStyle(
                                color: AppColors.pivotPayColorGreen,
                                fontFamily: 'Lato'),
                          )
                        ],
                      ),
                    ),
                    VSpace.sm,
                    SmallText(
                      'Enter the details',
                      size: FontSizes.s14,
                      align: TextAlign.center,
                    ),
                    Container(
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      margin: const EdgeInsets.only(
                          left: 20, right: 20, top: 20, bottom: 10),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.black, width: 0.2),
                        borderRadius: const BorderRadius.all(
                          Radius.circular(10.0),
                        ),
                      ),
                      child: Column(children: [
                        VSpace.md,
                        InAppImage(
                          AppImages.confirmDetails,
                          height: 100,
                        ),
                        TextInputField(
                          labelText: 'Account number',
                          prefixIcon: Icon(
                            Icons.account_circle,
                            color: AppColors.pivotPayColorGreen,
                          ),
                          onSaved: (value) {},
                          controller: _accountNumberController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter the Account Number';
                            }

                            return null;
                          },
                        ),
                        VSpace.md,
                        TextInputField(
                          prefixIcon: Icon(
                            Icons.password_outlined,
                            color: AppColors.pivotPayColorGreen,
                          ),
                          labelText: 'Secret Code',
                          readOnly: isVisible,
                          keyboardType: TextInputType.number,
                          controller: _secretCodeController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter the Secret Code';
                            }
                            return null;
                          },
                          onSaved: (value) {},
                        ),
                        Visibility(
                          visible: isVisible,
                          child: Column(
                            children: [
                              VSpace.md,
                              TextInputField(
                                readOnly: true,
                                labelText: 'Account Name',
                                prefixIcon: Icon(
                                  Icons.account_circle,
                                  color: AppColors.pivotPayColorGreen,
                                ),
                                onSaved: (value) {},
                                controller: _fullNameController,
                                validator: (value) {
                                  return null;
                                },
                              ),
                              VSpace.md,
                              TextInputField(
                                readOnly: true,
                                labelText: 'Phone Number',
                                prefixIcon: Icon(
                                  Icons.phone,
                                  color: AppColors.pivotPayColorGreen,
                                ),
                                onSaved: (value) {},
                                controller: _phoneNumberController,
                                validator: (value) {
                                  return null;
                                },
                              ),
                              VSpace.md,
                              TextInputField(
                                labelText: 'Enter amount',
                                controller: _amountController,
                                readOnly: true,
                                prefixIcon: Icon(
                                  Icons.account_balance_wallet_outlined,
                                  color: AppColors.pivotPayColorGreen,
                                ),
                                validator: (value) {
                                  return null;
                                },
                                onSaved: (value) {},
                              ),
                            ],
                          ),
                        ),
                        VSpace.lg,
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  minimumSize: Size.zero,
                                  backgroundColor:
                                      AppColors.black.withOpacity(0.1),
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
                                child: MediumText(
                                  isVisible ? 'Proceed' : 'Continue',
                                  color: AppColors.white,
                                ),
                                onPressed: () {
                                  if (_formMobileKey.currentState!.validate()) {
                                    setState(() {
                                      _formMobileKey.currentState!.save();
                                    });
                                    if (_supportState ==
                                        _SupportState.supported) {
                                      _checkBiometrics().then((value) {
                                        if (value) {
                                          _authenticate().then((value) {
                                            if (value) {
                                              if (isVisible) {
                                                _processTransaction(
                                                  _formMobileKey
                                                      .currentContext!,
                                                );
                                              } else {
                                                cashOutDetails(
                                                  _formMobileKey
                                                      .currentContext!,
                                                );
                                              }
                                            } else {
                                              _cancelAuthentication();
                                            }
                                          });
                                        } else {
                                          final pinValid = Navigator.push<bool>(
                                            context,
                                            PageRouter.fadeThrough(
                                              () => PinPage(),
                                            ),
                                          );
                                          pinValid.then(
                                            (value) {
                                              if (value!) {
                                                if (isVisible) {
                                                  _processTransaction(
                                                    _formMobileKey
                                                        .currentContext!,
                                                  );
                                                } else {
                                                  cashOutDetails(
                                                    _formMobileKey
                                                        .currentContext!,
                                                  );
                                                }
                                              }
                                            },
                                          );
                                        }
                                      });
                                    } else {
                                      final pinValid = Navigator.push<bool>(
                                        context,
                                        PageRouter.fadeThrough(
                                          () => PinPage(),
                                        ),
                                      );
                                      pinValid.then(
                                        (value) {
                                          if (value!) {
                                            if (isVisible) {
                                              _processTransaction(
                                                _formMobileKey.currentContext!,
                                              );
                                            } else {
                                              cashOutDetails(
                                                _formMobileKey.currentContext!,
                                              );
                                            }
                                          }
                                        },
                                      );
                                    }
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                        VSpace.lg
                      ]),
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

  cashOutDetails(BuildContext context) async {
    final progress = ProgressHUD.of(context);
    progress!.showWithText('Checking details...');
    setState(() {
      ignoreTaps = true;
    });
    final Map data = {
      'walletId': _accountNumberController.text,
      'secretCode': _secretCodeController.text,
    };
    getCashOutDetails(_formMobileKey.currentContext!, data).then((value) {
      if (value.status!) {
        progress.dismiss();
        setState(() {
          ignoreTaps = false;
          isVisible = true;
          amount = value.amount!;
          accountName = value.accountName!;
          tranReference = value.transactionId!;
          phoneNumber = value.phoneNumber!;
          _amountController.value = TextEditingValue(text: amount);
          _phoneNumberController.value = TextEditingValue(text: phoneNumber);
          _fullNameController.value = TextEditingValue(text: accountName);
        });
        //_processTransaction(_formMobileKey.currentContext!);
      } else {
        progress.dismiss();
        setState(() {
          ignoreTaps = false;
        });
        Get.to(
          () => TransactionStatusPage(
            title: 'Transaction Failed',
            reason: value.responseMessage!,
            templateId: 3,
            body: value.responseMessage,
            showStatement: false,
            transactionRef: tranReference,
            dateTime:
                DateFormat('E, d MMM yyyy HH:mm:ss').format(DateTime.now()),
            isLottie: true,
            imgUrl: AppImages.failed,
            btnText: 'OK',
          ),
        );
      }
    });
  }

  _processTransaction(BuildContext context) async {
    final progress = ProgressHUD.of(context);
    String? fromAccount;
    reference = DateTime.now().millisecondsSinceEpoch.toString();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final getXPrefs = GetStorage();
    progress!.showWithText('Processing Transaction...');
    setState(() {
      ignoreTaps = true;
    });

    reference = DateTime.now().millisecondsSinceEpoch.toString();
    final String senderAccount = prefs.getString('accountNumber')!;
    paymentNetwork = 'TBD';
    paymentNetwork = 'HCASH AGENT WALLET';
    service = 'CASH_OUT';
    fromAccount = senderAccount;
    sendMethod = 'AGENTWALLET';
    reference = reference! + prefs.getString('userName')!.toUpperCase();

    final Map data = {
      'fromAccount': _accountNumberController.text,
      'fromCurrency': currencyCode,
      'fromAmount': _amountController.text,
      'toCurrency': toCurrencyCode,
      'toAmount': _amountController.text,
      'toAccount': senderAccount,
      'debitType': sendMethod,
      'appVersion': version,
      'location': location,
      'osType': getXPrefs.read('source'),
      'transactionAmount': _amountController.text,
      'serviceName': service,
      'email': prefs.getString('email'),
      'payment_method': sendMethod,
      'phoneNumber': phoneNumber,
      'senderName': prefs.getString('agentName'),
      'receiverName': accountName,
      'service_provider': paymentNetwork,
      'transactionId': reference,
      'walletId': prefs.getString('accountNumber'),
      'narration': 'Cashout transaction',
    };
    processUserPayment(_formMobileKey.currentContext!, data).then((value) {
      if (value.status!) {
        progress.dismiss();
        setState(() {
          ignoreTaps = false;
        });
        switch (value.response) {
          case 'SUCCESS':
            getWalletBalance(
              prefs.getString('accountNumber')!,
              tranReference,
            );
            break;
          case 'FAILED':
            Get.to(
              () => TransactionStatusPage(
                title: 'Transaction Failed',
                reason: value.responseMessage!,
                templateId: 3,
                body: 'Failed to Withdraw Money.',
                showStatement: false,
                transactionRef: tranReference,
                dateTime:
                    DateFormat('E, d MMM yyyy HH:mm:ss').format(DateTime.now()),
                isLottie: true,
                imgUrl: AppImages.failed,
                btnText: 'OK',
              ),
            );
            break;
          default:
            Get.to(
              () => TransactionStatusPage(
                title: 'Transaction Failed',
                reason: value.responseMessage!,
                templateId: 3,
                body: 'Failed to Withdraw Money.',
                showStatement: false,
                transactionRef: tranReference,
                dateTime:
                    DateFormat('E, d MMM yyyy HH:mm:ss').format(DateTime.now()),
                isLottie: true,
                imgUrl: AppImages.failed,
                btnText: 'OK',
              ),
            );
        }
      } else {
        progress.dismiss();
        setState(() {
          ignoreTaps = false;
        });
        Get.to(
          () => TransactionStatusPage(
            title: 'Transaction Failed',
            reason: value.responseMessage!,
            templateId: 3,
            body: 'Failed to Withdraw Money.',
            showStatement: false,
            transactionRef: tranReference,
            dateTime:
                DateFormat('E, d MMM yyyy HH:mm:ss').format(DateTime.now()),
            isLottie: true,
            imgUrl: AppImages.failed,
            btnText: 'OK',
          ),
        );
      }
    });
  }

  getWalletBalance(
    String accountNumber,
    String tranRef,
  ) {
    final Map data = {'username': accountNumber};
    getUserBalances(_formMobileKey.currentContext!, data).then((value) async {
      if (value.status!) {
        _updateBalance(
          value.accountBalance.toString().replaceAll(',', ''),
          tranRef,
        );
      } else {
        responseDialog(
          'Sorry',
          'Okay',
          value.response!,
          _formMobileKey.currentContext!,
        );
      }
    });
  }

  _updateBalance(
    String balance,
    String tranRef,
  ) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString(
      'accountBalance',
      balance,
    );
    Get.off(
      () => TransactionStatusPage(
        body: 'Successfully withdrawn Money from ',
        templateId: 4,
        showStatement: false,
        title: 'Transaction Successful',
        dateTime: DateFormat('E, d MMM yyyy HH:mm:ss').format(DateTime.now()),
        amount: '$currencyCode. ${formatNumber(int.parse(amount))}',
        balance: '$currencyCode. ${formatNumber(int.parse(balance))}',
        transactionRef: tranRef,
        btnText: 'OK',
        accountName: accountName,
        accountNumber: _accountNumberController.text,
        accountUrl: accountUrl,
        isLottie: true,
        imgUrl: AppImages.success,
      ),
    );
  }
}
