// ignore_for_file: parameter_assignments, avoid_dynamic_calls

import 'dart:async';
import 'dart:convert';
import 'dart:developer';

//import 'package:alt_sms_autofill/alt_sms_autofill.dart';
import 'package:crypto/crypto.dart';
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
import 'package:pivotpay/utils/apis.dart';
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

class BankRecipientPage extends BasePage {
  String? billerId, billerCategory, billerName, billerLogo, serviceDescription;

  BankRecipientPage(this.billerId, this.billerCategory, this.billerName,
      this.billerLogo, this.serviceDescription);

  @override
  _BankRecipientPageState createState() => _BankRecipientPageState();
}

class _BankRecipientPageState extends BaseState<BankRecipientPage>
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
      packageDetails,
      senderAccount,
      pivotReferenceBulk,
      authCode,
      totalAmount;

  String sendMethod = '',
      service = '',
      accountUrl = '',
      pivotServiceFee = '0',
      tranCharge = '0',
      pivotTranCharge = '0';
  bool shimmer = false, validated = false;
  Timer? timer;
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _accountNumberController =
      TextEditingController();
  final _formWalletKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
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
    final versionInfo = await PackageInfo.fromPlatform();
    version = '${versionInfo.version}+${versionInfo.buildNumber}';
    final Position position =
        await determinePosition(_formWalletKey.currentContext!);
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
        ],
      ),
      body: IgnorePointer(
        ignoring: ignoreTaps,
        child: ProgressHUD(
          child: Builder(
            builder: (context) => Form(
              key: _formWalletKey,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const VSpace(25),
                    Text.rich(
                      TextSpan(
                        text:
                            'Deposit ${widget.serviceDescription!.split(' ')[0]} ${widget.serviceDescription!.split(' ')[1]} ',
                        style: TextStyle(
                          color: AppColors.primaryColor,
                          fontFamily: 'Lato',
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                        ),
                        children: <InlineSpan>[
                          TextSpan(
                            text: widget.serviceDescription!.split(' ')[2],
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
                        VSpace.md,
                        TextInputField(
                          labelText: 'Enter Bank Account number',
                          prefixIcon: Icon(
                            Icons.account_circle,
                            color: AppColors.pivotPayColorGreen,
                          ),
                          keyboardType: TextInputType.number,
                          onSaved: (value) {},
                          controller: _accountNumberController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter the Pivot Pay Account Number';
                            }
                            if (!validateSpecialCharacters(value)) {
                              return 'Please only use numbers (no spaces)';
                            }
                            if (!validateNumbers(value)) {
                              return 'Please only use numbers (no spaces)';
                            }
                            if (senderAccount == value) {
                              return 'Recipient cannot be same as sender';
                            }
                            return null;
                          },
                        ),
                        Visibility(visible: validated, child: VSpace.md),
                        Visibility(
                          visible: validated,
                          child: TextInputField(
                            readOnly: true,
                            labelText: 'Recipient Name',
                            onSaved: (value) {},
                            controller: _fullNameController,
                            validator: (value) {
                              return null;
                            },
                          ),
                        ),
                        VSpace.md,
                        TextInputField(
                          labelText: 'Enter amount',
                          controller: _amountController,
                          keyboardType: TextInputType.number,
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
                                  if (_formWalletKey.currentState!.validate()) {
                                    setState(() {
                                      _formWalletKey.currentState!.save();
                                    });
                                    validateWalletAccount();
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

  validateWalletAccount() async {
    final progress = ProgressHUD.of(_formWalletKey.currentContext!);
    progress!.showWithText('Validating Account...');
    setState(() {
      ignoreTaps = true;
    });
    final Codec<String, String> stringToBase64 = utf8.fuse(base64);
    final String stringToHash = '${widget.billerName}BANK_TRANSFERSTUMIA_APP';
    final key = utf8.encode(merchantSecret);
    final bytes = utf8.encode(stringToHash);
    final hmacSha512 = Hmac(sha512, key);
    final Digest sha512Result = hmacSha512.convert(bytes);
    reference = DateTime.now().millisecondsSinceEpoch.toString();
    reference = reference! + prefs!.getString('userName')!.toUpperCase();
    final getXPrefs = GetStorage();
    final Map data = {
      'accountNumber': _accountNumberController.text,
      'appVersion': version,
      'osType': getXPrefs.read('source'),
      'accountCategory': widget.billerCategory,
      'transactionAmount': _amountController.text,
      'accountType': 'BANK_TRANSFERS',
      'requestReference': reference,
      'requestSignature': base64.encode(sha512Result.bytes),
    };
    validateBankAccount(_formWalletKey.currentContext!, data)
        .then((value) async {
      if (value.status!) {
        progress.dismiss();
        setState(() {
          ignoreTaps = false;
          validated = true;
          _fullNameController.value =
              TextEditingValue(text: value.accountName!);
          _accountNumberController.value =
              TextEditingValue(text: _accountNumberController.text);
        });
        authCode = value.authCode;
        pivotServiceFee = value.serviceFee!;
        pivotTranCharge = value.tranCharge!;
        packageDetails = value.packageDetails;
        final double total = int.parse(pivotServiceFee).toDouble() +
            int.parse(pivotTranCharge).toDouble();
        totalAmount = total.toString();
        showInfoDialog();
      } else {
        progress.dismiss();
        setState(() {
          ignoreTaps = false;
        });
        responseDialog(
          'Sorry',
          'Okay',
          value.responseMessage!,
          _formWalletKey.currentContext!,
        );
      }
    });
  }

  showInfoDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topRight: Radius.circular(10), topLeft: Radius.circular(10)),
      ),
      builder: (context) => Wrap(
        children: [
          Container(
            padding: const EdgeInsets.only(
              left: 30,
              right: 20,
            ),
            margin: const EdgeInsets.only(bottom: 30),
            child: Column(
              children: [
                VSpace.md,
                InAppImage(
                  AppImages.ppLogoColored,
                  height: 50,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    VSpace.sm,
                    const Center(
                      child: MediumText(
                        'Transaction Summary',
                        size: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(top: 5, bottom: 5),
                      child: Divider(
                        color: Colors.black,
                        thickness: 0.1,
                      ),
                    ),
                    Row(
                      children: [
                        const MediumText(
                          'Recipient Name:',
                          size: 14,
                        ),
                        HSpace.sm,
                        Flexible(
                          child: MediumText(
                            _fullNameController.text,
                            fontWeight: FontWeight.w500,
                            size: 14,
                          ),
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.only(top: 5, bottom: 5),
                      child: Divider(
                        color: Colors.black,
                        thickness: 0.1,
                      ),
                    ),
                    Row(
                      children: [
                        const MediumText(
                          'Bank Name:',
                          size: 14,
                        ),
                        HSpace.sm,
                        Flexible(
                          child: MediumText(
                            widget.billerName!,
                            size: 14,
                          ),
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.only(top: 5, bottom: 5),
                      child: Divider(
                        color: Colors.black,
                        thickness: 0.1,
                      ),
                    ),
                    Row(
                      children: [
                        const MediumText(
                          'Transaction Ref.:',
                          size: 14,
                        ),
                        HSpace.sm,
                        Flexible(
                          child: MediumText(
                            reference!,
                            size: 14,
                          ),
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.only(top: 5, bottom: 5),
                      child: Divider(
                        color: Colors.black,
                        thickness: 0.1,
                      ),
                    ),
                    Row(
                      children: [
                        const MediumText(
                          'Tran. Charge:',
                          size: 14,
                        ),
                        HSpace.sm,
                        Flexible(
                          child: MediumText(
                            pivotTranCharge,
                            size: 14,
                          ),
                        ),
                      ],
                    ),
                    VSpace.lg,
                    ElevatedButton(
                      child: const MediumText(
                        'Confirm Payment',
                        color: AppColors.white,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        if (_formWalletKey.currentState!.validate()) {
                          setState(() {
                            _formWalletKey.currentState!.save();
                          });
                          if (_supportState == _SupportState.supported) {
                            _checkBiometrics().then((value) {
                              if (value) {
                                _authenticate().then((value) {
                                  if (value) {
                                    _processTransaction(
                                      _formWalletKey.currentContext!,
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
                                        _formWalletKey.currentContext!,
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
                                    _formWalletKey.currentContext!,
                                  );
                                }
                              },
                            );
                          }
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _processTransaction(
    BuildContext context,
  ) async {
    final progress = ProgressHUD.of(context);
    String? fromAccount;
    reference = DateTime.now().millisecondsSinceEpoch.toString();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final getXPrefs = GetStorage();
    progress!.showWithText('Processing Transaction...');
    setState(() {
      ignoreTaps = true;
    });
    senderAccount = prefs.getString('accountNumber');
    recipientPhone = prefs.getString('phoneNumber');
    if (recipientPhone!.startsWith('+')) {
      recipientPhone = recipientPhone!.replaceAll('+', '');
    }
    if (recipientPhone!.startsWith('0')) {
      recipientPhone = recipientPhone!.replaceFirst('0', '256');
    }
    senderPhone = prefs.getString('phoneNumber');
    if (senderPhone!.startsWith('+')) {
      senderPhone = senderPhone!.replaceAll('+', '');
    }
    paymentNetwork = 'PIVOTPAY WALLET';
    reference = reference! + prefs.getString('userName')!.toUpperCase();
    service = 'BANK_TRANSFERS';
    fromAccount = senderAccount!;
    sendMethod = 'WALLET';

    final Map data = {
      'fromAccount': fromAccount,
      'fromCurrency': currencyCode,
      'authCode': authCode,
      'tranCharge': pivotTranCharge,
      'serviceFee': pivotServiceFee,
      'utilityName': 'BANK_TRANSFERS',
      'customerCategory': widget.billerCategory,
      'fromAmount': _amountController.text,
      'toCurrency': prefs.getString('currencyCode'),
      'toAmount': _amountController.text,
      'toAccount': _accountNumberController.text,
      'appVersion': version,
      'osType': getXPrefs.read('source'),
      'debitType': sendMethod,
      'location': location,
      'transactionAmount': _amountController.text,
      'serviceName': service,
      'payment_method': sendMethod,
      'email': prefs.getString('email'),
      'phoneNumber': senderPhone,
      'senderName':
          '${prefs.getString('secondName')} ${prefs.getString('firstName')}',
      'receiverName': _fullNameController.text,
      'service_provider': paymentNetwork,
      'transactionId': reference,
      'walletId': prefs.getString('accountNumber'),
      'narration': 'Wallet payment Transaction',
    };
    processBillPayment(_formWalletKey.currentContext!, data).then((value) {
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
              PageRouter.fadeScale(
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
          _formWalletKey.currentContext!,
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
        '00007',
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
    getUserBalances(_formWalletKey.currentContext!, data).then((value) async {
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
          _formWalletKey.currentContext!,
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
        accountNumber: _accountNumberController.text,
        accountUrl: 'images/${widget.billerLogo!}',
        isLottie: true,
        imgUrl: AppImages.success,
      ),
    );
  }
}
