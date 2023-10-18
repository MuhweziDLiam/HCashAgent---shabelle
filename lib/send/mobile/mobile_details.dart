// ignore_for_file: parameter_assignments, avoid_dynamic_calls

import 'dart:async';

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

enum _SupportState {
  unknown,
  supported,
  unsupported,
}

class MobileRecipientPage extends BasePage {
  String accountName, currencyCode;
  String? phoneNumber, serviceDescription;

  MobileRecipientPage(
      {super.key,
      this.phoneNumber,
      this.accountName = '',
      this.currencyCode = '',
      this.serviceDescription});

  @override
  _MobileRecipientPageState createState() => _MobileRecipientPageState();
}

class _MobileRecipientPageState extends BaseState<MobileRecipientPage>
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
  String sendMethod = '', service = '', accountUrl = '';
  bool shimmer = false;
  Timer? timer, _debounce;
  bool? isAndroid;
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final _formMobileKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  bool ignoreTaps = false;
  SharedPreferences? prefs;
  final String _comingSms = 'Unknown';
  String location = 'Unknown';

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
    currencyCode = prefs!.getString('currencyCode');
    senderAccount = prefs!.getString('accountNumber');
    toCurrencyCode = currencyCode;
    _phoneNumberController.value = TextEditingValue(text: widget.phoneNumber!);
    _fullNameController.value = TextEditingValue(text: widget.accountName);
    final versionInfo = await PackageInfo.fromPlatform();
    version = '${versionInfo.version}+${versionInfo.buildNumber}';
    getCurrencies();
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
          'Send Money',
          size: 18,
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
          IconButton(
            onPressed: (() {}),
            icon: InAppImage(
              AppImages.ugandaRound,
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
                        text:
                            '${widget.serviceDescription!.split(' ')[0]} ${widget.serviceDescription!.split(' ')[1]} ',
                        style: TextStyle(
                          color: AppColors.primaryColor,
                          fontFamily: 'Lato',
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                        ),
                        children: <InlineSpan>[
                          TextSpan(
                            text:
                                '${widget.serviceDescription!.split(' ')[2]} ${widget.serviceDescription!.split(' ')[3]}',
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
                          labelText: 'Recipient Phone number',
                          prefixIcon: Icon(
                            Icons.phone,
                            color: AppColors.pivotPayColorGreen,
                          ),
                          readOnly: true,
                          onSaved: (value) {},
                          controller: _phoneNumberController,
                          validator: (value) {
                            return null;
                          },
                        ),
                        VSpace.md,
                        TextInputField(
                          readOnly: widget.accountName.isNotEmpty,
                          labelText: 'Recipient Name',
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
                          labelText: 'Enter amount',
                          controller: _amountController,
                          prefixIcon: Icon(
                            Icons.account_balance_wallet_outlined,
                            color: AppColors.pivotPayColorGreen,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter the amount';
                            }
                            if (!validateAmount(value)) {
                              return 'Amount should only contain digits';
                            }

                            if (int.parse(value) <= 0) {
                              return 'Amount should be greater than 0';
                            }
                            return null;
                          },
                          onSaved: (value) {},
                        ),
                        VSpace.md,
                        TextInputField(
                          prefixIcon: Icon(
                            Icons.description,
                            color: AppColors.pivotPayColorGreen,
                          ),
                          labelText: 'Reason',
                          controller: _descriptionController,
                          validator: (value) {
                            if (value!.length > 15) {
                              return 'Maximum Reason length is 15 characters';
                            }
                            return null;
                          },
                          onSaved: (value) {},
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
                                child: const MediumText(
                                  'Continue',
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
                                              _processTransaction(
                                                _formMobileKey.currentContext!,
                                              );
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
                                                _processTransaction(
                                                  _formMobileKey
                                                      .currentContext!,
                                                );
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
                                            _processTransaction(
                                              _formMobileKey.currentContext!,
                                            );
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
    recipientPhone = _phoneNumberController.text;
    if (recipientPhone!.startsWith('+')) {
      recipientPhone = recipientPhone!.replaceAll('+', '');
    }
    if (recipientPhone!.startsWith('0')) {
      recipientPhone = recipientPhone!.replaceFirst('0', '256');
    }
    senderPhone = prefs.getString('phoneNumber')!;
    if (senderPhone!.startsWith('+')) {
      senderPhone = senderPhone!.replaceAll('+', '');
    }
    paymentNetwork = 'TBD';
    paymentNetwork = 'PIVOTPAY WALLET';
    service = 'WALLET_TO_MOBILEMONEY';
    fromAccount = senderAccount;
    sendMethod = 'MOBILE MONEY';
    reference = reference! + prefs.getString('userName')!.toUpperCase();

    final Map data = {
      'fromAccount': fromAccount,
      'fromCurrency': currencyCode,
      'fromAmount': _amountController.text,
      'toCurrency': widget.currencyCode.isEmpty
          ? prefs.getString('currencyCode')
          : widget.currencyCode,
      'toAmount': _amountController.text,
      'toAccount': recipientPhone,
      'debitType': sendMethod,
      'appVersion': version,
      'location': location,
      'osType': getXPrefs.read('source'),
      'transactionAmount': _amountController.text,
      'serviceName': service,
      'email': prefs.getString('email'),
      'payment_method': sendMethod,
      'phoneNumber': senderPhone,
      'senderName':
          '${prefs.getString('secondName')} ${prefs.getString('firstName')}',
      'receiverName': _fullNameController.text,
      'service_provider': paymentNetwork,
      'transactionId': reference,
      'walletId': prefs.getString('accountNumber'),
      'narration': _descriptionController.text.isEmpty
          ? _fullNameController.text
          : _descriptionController.text,
    };
    processUserPayment(_formMobileKey.currentContext!, data).then((value) {
      if (value.status!) {
        progress.dismiss();
        setState(() {
          ignoreTaps = false;
        });
        switch (value.response) {
          case 'RECEIVED':
            //initSmsListener();
            final pinValid = Navigator.push<bool>(
              context,
              PageRouter.fadeThrough(
                () => PinPage(
                  state: PinState.otp,
                  appVersion: version,
                  source: getXPrefs.read('source'),
                  accountNumber: prefs.getString('accountNumber'),
                  transactionId: value.transactionId,
                  phoneNumber: senderPhone,
                  serviceName: service,
                  otpCode: _comingSms,
                ),
              ),
            );
            pinValid.then(
              (value) {
                if (value!) {
                  timer = Timer.periodic(
                    const Duration(seconds: 5),
                    (Timer t) => _checkStatus(
                      t,
                      reference!,
                      prefs.getString('accountNumber')!,
                    ),
                  );

                  Navigator.push(
                    context,
                    PageRouter.fadeScale(
                      () => TransactionStatusPage(
                        title: 'Transaction is Processing',
                        body: 'Your transaction is being processed',
                        templateId: 1,
                        showStatement: false,
                        isLottie: true,
                        imgUrl: AppImages.loading,
                        btnText: 'OK',
                      ),
                    ),
                  );
                }
              },
            );
            break;
          case 'FAILED':
            responseDialog(
              'Sorry',
              'Okay',
              value.responseMessage!,
              context,
            );
            break;
          default:
            responseDialog(
              'Sorry',
              'Okay',
              value.responseMessage!,
              context,
            );
        }
      } else {
        progress.dismiss();
        setState(() {
          ignoreTaps = false;
        });
        responseDialog(
          'Sorry',
          'Okay',
          value.responseMessage!,
          _formMobileKey.currentContext!,
        );
      }
    });
  }

  _checkStatus(Timer t, String tranReference, String accountNumber) async {
    final Map data = {'transactionReference': tranReference};
    if (t.tick < 150) {
      getTransactionStatus(data).then((value) {
        if (value.status!) {
          switch (value.response) {
            case 'PROCESSING':
              break;
            case 'PENDING':
              break;
            case 'RECONNECT':
              break;
            case 'SUCCESS':
              t.cancel();
              getWalletBalance(
                accountNumber,
                tranReference,
              );
              break;
            case 'PROCESSED':
              t.cancel();
              getWalletBalance(
                accountNumber,
                tranReference,
              );
              break;
            case 'FAILED':
              t.cancel();
              Get.to(
                () => TransactionStatusPage(
                  title: 'Transaction Failed',
                  reason: value.responseMessage!,
                  templateId: 3,
                  body: 'Failed to Send Money.',
                  showStatement: false,
                  transactionRef: tranReference,
                  dateTime: DateFormat('E, d MMM yyyy HH:mm:ss')
                      .format(DateTime.now()),
                  isLottie: true,
                  imgUrl: AppImages.failed,
                  btnText: 'OK',
                ),
              );
              break;
            default:
              t.cancel();
              Get.to(
                () => TransactionStatusPage(
                  title: 'Transaction Failed',
                  reason: value.responseMessage!,
                  templateId: 3,
                  body: 'Failed to Send Money.',
                  showStatement: false,
                  transactionRef: tranReference,
                  dateTime: DateFormat('E, d MMM yyyy HH:mm:ss')
                      .format(DateTime.now()),
                  isLottie: true,
                  imgUrl: AppImages.failed,
                  btnText: 'OK',
                ),
              );
          }
        } else {
          t.cancel();
          Get.to(
            () => TransactionStatusPage(
              title: 'Transaction Failed',
              reason: value.responseMessage!,
              templateId: 3,
              body: 'Failed to Send Money.',
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
    } else {
      t.cancel();
      createNotification(
        '00006',
        'Send Money',
        'Send Money transaction',
        'Please note that your transaction is being processed, Incase there is a delay kindly Contact Customer Support',
      );
    }
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
    final now = DateTime.now();
    final eventData = {
      'Amount': _amountController.text,
      'Recipient Name': _fullNameController.text,
      'Recipient Account': recipientPhone,
      'Type': service,
      'Date': CleverTapPlugin.getCleverTapDate(now),
      'Payment Mode': paymentNetwork
    };
    CleverTapPlugin.recordEvent('Send Money', eventData);
    Get.off(
      () => TransactionStatusPage(
        body: 'Successfully sent money to ',
        templateId: 4,
        showStatement: false,
        title: 'Transaction Successful',
        dateTime: DateFormat('E, d MMM yyyy HH:mm:ss').format(DateTime.now()),
        amount:
            '$currencyCode. ${formatNumber(int.parse(_amountController.text))}',
        balance: '$currencyCode. ${formatNumber(int.parse(balance))}',
        transactionRef: tranRef,
        btnText: 'OK',
        accountName: _fullNameController.text,
        accountNumber: _phoneNumberController.text,
        accountUrl: accountUrl,
        isLottie: true,
        imgUrl: AppImages.success,
      ),
    );
  }
}
