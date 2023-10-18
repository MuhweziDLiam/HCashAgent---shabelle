// ignore_for_file: parameter_assignments, avoid_dynamic_calls

import 'dart:async';

//import 'package:alt_sms_autofill/alt_sms_autofill.dart';
import 'package:clevertap_plugin/clevertap_plugin.dart';
import 'package:currency_picker/currency_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:group_radio_button/group_radio_button.dart';
import 'package:intl/intl.dart';
import 'package:local_auth/local_auth.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pivotpay/card/card_payment.dart';
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

class PivotSchoolLoanPage extends BasePage {
  String? providerId, providerName, providerLogo;
  PivotSchoolLoanPage({
    this.providerId,
    this.providerName,
    this.providerLogo,
  });
  @override
  _PivotSchoolLoanPageState createState() => _PivotSchoolLoanPageState();
}

class _PivotSchoolLoanPageState extends BaseState<PivotSchoolLoanPage>
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
  String customerCode = '';
  List<String> supportedCurrencies = [];
  String optionSelected = 'Wallet';
  final options = ['Wallet', 'Card', 'Mobile Money'];
  String sendMethod = '',
      service = '',
      accountUrl = '',
      pivotServiceFee = '0',
      tranCharge = '0',
      pivotTranCharge = '0',
      convertedAmount = '0',
      conversionCharge = '0',
      singleUnitAmount = '0';
  Timer? timer, _debounce;
  bool shimmer = false, validated = false;
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _accountNumberController =
      TextEditingController();
  final TextEditingController _currencyController = TextEditingController();
  final TextEditingController _translatedAmountController =
      TextEditingController();
  final _formSchoolKey = GlobalKey<FormState>();
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
    _currencyController.addListener(() {
      _convertTextCurrency(
          _amountController.text, toCurrencyCode!, _currencyController.text);
    });
    auth.isDeviceSupported().then(
          (bool isSupported) => _supportState =
              isSupported ? _SupportState.supported : _SupportState.unsupported,
        );
  }

  getInfo() async {
    supportedCurrencies = await getCurrencies();
    supportedCurrencies.removeWhere((element) => element.isEmpty);
    prefs = await SharedPreferences.getInstance();
    currencyCode = prefs!.getString('currencyCode');
    senderAccount = prefs!.getString('accountNumber');
    _accountNumberController.value = TextEditingValue(text: senderAccount!);
    _fullNameController.value = TextEditingValue(
        text:
            '${prefs!.getString('firstName')!} ${prefs!.getString('secondName')!}');
    toCurrencyCode = currencyCode;
    _currencyController.value = TextEditingValue(text: currencyCode!);
    _translatedAmountController.value =
        TextEditingValue(text: '$currencyCode : ');

    final versionInfo = await PackageInfo.fromPlatform();
    version = '${versionInfo.version}+${versionInfo.buildNumber}';
    getCurrencies();
    final Position position =
        await determinePosition(_formSchoolKey.currentContext!);
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
          'Pay Pivot School Fees Loan',
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
              key: _formSchoolKey,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const VSpace(25),
                    Text.rich(
                      TextSpan(
                        text: 'We are Almost',
                        style: TextStyle(
                          color: AppColors.primaryColor,
                          fontFamily: 'Lato',
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                        ),
                        children: <InlineSpan>[
                          TextSpan(
                            text: ' There!',
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
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            VSpace.md,
                            Center(
                              child: InAppImage(
                                AppImages.confirmDetails,
                                height: 100,
                              ),
                            ),
                            VSpace.md,
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.primaryColor,
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(10.0),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    height: 30,
                                    width: 30,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.white,
                                      // borderRadius: Corners.lgBorder,
                                      image: DecorationImage(
                                        image: Image.asset(
                                          widget.providerLogo!,
                                        ).image,
                                      ),
                                    ),
                                    padding: const EdgeInsets.all(10),
                                  ),
                                  HSpace.sm,
                                  Flexible(
                                    child: MediumText(
                                      widget.providerName!,
                                      color: AppColors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            VSpace.md,
                            TextInputField(
                              labelText: 'Wallet Account Number',
                              readOnly: true,
                              prefixIcon: Icon(
                                Icons.account_circle,
                                color: AppColors.pivotPayColorGreen,
                              ),
                              onSaved: (value) {},
                              controller: _accountNumberController,
                              validator: (value) {
                                return null;
                              },
                            ),
                            VSpace.md,
                            TextInputField(
                              readOnly: true,
                              labelText: 'Recipient Name',
                              onSaved: (value) {},
                              controller: _fullNameController,
                              validator: (value) {
                                return null;
                              },
                            ),
                            VSpace.md,
                            TextInputField(
                              labelText: 'Select currency',
                              hintText: 'UGX',
                              readOnly: true,
                              controller: _currencyController,
                              onTap: () {
                                showCurrencyPicker(
                                  context: context,
                                  showFlag: true,
                                  currencyFilter: supportedCurrencies,
                                  showCurrencyName: true,
                                  showCurrencyCode: true,
                                  onSelect: (Currency currency) {
                                    setState(() {
                                      currencyCode = currency.code;
                                      _currencyController.value =
                                          TextEditingValue(text: currencyCode!);
                                    });
                                  },
                                );
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please select the currency';
                                }
                                return null;
                              },
                              onSaved: (value) {},
                            ),
                            VSpace.md,
                            TextInputField(
                              labelText: 'Enter amount',
                              controller: _amountController,
                              prefixIcon: Icon(
                                Icons.account_balance_wallet_outlined,
                                color: AppColors.pivotPayColorGreen,
                              ),
                              onChanged: (value) {
                                if (_debounce?.isActive ?? false) {
                                  _debounce!.cancel();
                                }
                                _debounce = Timer(
                                    const Duration(milliseconds: 500), () {
                                  _convertTextCurrency(
                                    _amountController.text,
                                    toCurrencyCode!,
                                    _currencyController.text,
                                  );
                                });
                                return value!;
                              },
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
                            const VSpace(20),
                            shimmer
                                ? Shimmer.fromColors(
                                    enabled: shimmer,
                                    baseColor: AppColors.pivotPayColorGreen
                                        .withOpacity(0.3),
                                    highlightColor: AppColors.pivotPayColorGreen
                                        .withOpacity(0.1),
                                    child: Container(
                                        padding: const EdgeInsets.all(15),
                                        decoration: BoxDecoration(
                                          borderRadius: const BorderRadius.all(
                                            Radius.circular(5.0),
                                          ),
                                          color: AppColors.pivotPayColorGreen,
                                        ),
                                        child: Container()),
                                  )
                                : Container(
                                    padding: const EdgeInsets.all(15),
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.all(
                                        Radius.circular(5.0),
                                      ),
                                      color: AppColors.pivotPayColorGreen,
                                    ),
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            const MediumText(
                                              'Transfer Fee',
                                              color: AppColors.white,
                                            ),
                                            MediumText(
                                              '$toCurrencyCode. ${formatNumber(double.parse(conversionCharge).round())}',
                                              color: AppColors.white,
                                            )
                                          ],
                                        ),
                                        VSpace.xs,
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            const MediumText(
                                              'Exchange Rate',
                                              color: AppColors.white,
                                            ),
                                            MediumText(
                                              '1 $toCurrencyCode = ${_currencyController.text} ${formatNumber(double.parse(singleUnitAmount).round())}',
                                              color: AppColors.white,
                                            )
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                            const VSpace(10),
                            TextInputField(
                              labelText: 'You are paying',
                              readOnly: true,
                              controller: _translatedAmountController,
                              onTap: () {},
                              onSaved: (value) {},
                              validator: (value) {
                                return null;
                              },
                            ),
                            VSpace.md,
                            const Divider(
                              color: Colors.black,
                              thickness: 0.5,
                            ),
                            Center(
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                margin: const EdgeInsets.only(top: 10),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryColor,
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(10.0),
                                  ),
                                ),
                                child: const SmallText(
                                  'Select Payment Method',
                                  color: AppColors.white,
                                ),
                              ),
                            ),
                            VSpace.sm,
                            RadioGroup<String>.builder(
                              direction: Axis.horizontal,
                              groupValue: optionSelected,
                              activeColor: AppColors.primaryColor,
                              textStyle: const TextStyle(
                                  fontFamily: 'WorkSans', fontSize: 12),
                              onChanged: (value) => setState(() {
                                optionSelected = value!;
                              }),
                              items: options,
                              itemBuilder: (item) => RadioButtonBuilder(
                                item,
                              ),
                            ),
                            VSpace.md,
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
                                      if (_formSchoolKey.currentState!
                                          .validate()) {
                                        setState(() {
                                          _formSchoolKey.currentState!.save();
                                        });
                                        if (optionSelected.isNotEmpty) {
                                          if (_supportState ==
                                              _SupportState.supported) {
                                            _checkBiometrics().then((value) {
                                              if (value) {
                                                _authenticate().then((value) {
                                                  if (value) {
                                                    _processTransaction(
                                                      _formSchoolKey
                                                          .currentContext!,
                                                    );
                                                  } else {
                                                    _cancelAuthentication();
                                                  }
                                                });
                                              } else {
                                                final pinValid =
                                                    Navigator.push<bool>(
                                                  context,
                                                  PageRouter.fadeThrough(
                                                    () => PinPage(),
                                                  ),
                                                );
                                                pinValid.then(
                                                  (value) {
                                                    if (value!) {
                                                      _processTransaction(
                                                        _formSchoolKey
                                                            .currentContext!,
                                                      );
                                                    }
                                                  },
                                                );
                                              }
                                            });
                                          } else {
                                            final pinValid =
                                                Navigator.push<bool>(
                                              context,
                                              PageRouter.fadeThrough(
                                                () => PinPage(),
                                              ),
                                            );
                                            pinValid.then(
                                              (value) {
                                                if (value!) {
                                                  _processTransaction(
                                                    _formSchoolKey
                                                        .currentContext!,
                                                  );
                                                }
                                              },
                                            );
                                          }
                                        } else {
                                          responseDialog(
                                            'Sorry',
                                            'Okay',
                                            'Please select a payment Method',
                                            context,
                                          );
                                        }
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                            VSpace.md
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
    paymentNetwork = 'TBD';
    reference = reference! + prefs.getString('userName')!.toUpperCase();
    service = 'SCHOOL_LOAN_REPAYMENT';
    paymentNetwork = 'TBD';

    switch (optionSelected) {
      case 'Wallet':
        fromAccount = senderAccount!;
        sendMethod = 'WALLET';
        break;
      case 'Mobile Money':
        fromAccount = senderPhone!;
        sendMethod = 'MOBILE MONEY';
        break;
      case 'Card':
        fromAccount = senderAccount!;
        sendMethod = 'CARD';
        break;
    }

    final Map data = {
      'fromAccount': fromAccount,
      'fromCurrency': _currencyController.text,
      'authCode': 'authCode',
      'proposalNumber': 'proposalNumber',
      'tranCharge': pivotTranCharge,
      'serviceFee': pivotServiceFee,
      'customerCategory': customerCode,
      'fromAmount': _amountController.text,
      'toCurrency': prefs.getString('currencyCode'),
      'toAmount': convertedAmount,
      'toAccount': _accountNumberController.text,
      'appVersion': version,
      'osType': getXPrefs.read('source'),
      'debitType': sendMethod,
      'location': location,
      'transactionAmount': _amountController.text,
      'serviceName': service,
      'paymentType': 'Payment Type',
      'payment_method': sendMethod,
      'email': prefs.getString('email'),
      'phoneNumber': senderPhone,
      'senderName':
          '${prefs.getString('secondName')} ${prefs.getString('firstName')}',
      'receiverName': _fullNameController.text,
      'service_provider': paymentNetwork,
      'transactionId': reference,
      'walletId': prefs.getString('accountNumber'),
      'narration': 'School Fees Transaction',
    };
    processLoanRepayment(_formSchoolKey.currentContext!, data).then((value) {
      if (value.status!) {
        progress.dismiss();
        setState(() {
          ignoreTaps = false;
        });
        switch (optionSelected) {
          case 'Wallet':
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
                      phoneNumber: recipientPhone,
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
            break;
          case 'Card':
            timer = Timer.periodic(
              const Duration(seconds: 5),
              (Timer t) => _checkStatus(
                t,
                reference!,
                prefs.getString('accountNumber')!,
              ),
            );
            Navigator.push(
              _formSchoolKey.currentContext!,
              PageRouter.fadeScale(
                () => CardPaymentPage(
                  '${prefs.getString('cardUrl')}$reference&customerReference=${_accountNumberController.text}&itempaidfor=SCHOOLPAY&tranamount=${_amountController.text}&usercurrency=${_currencyController.text}&phoneNumber=$senderPhone&email=support@pivotpayts.com&tranId=$reference&password=EVJ7O9V6Q6&vendorKey=KVZQK4ZS7G2B29051EQ9&returnUrl=https%3A%2F%2Fpivotpayts.com%2F&pivotId=$reference&requestSignature=testSignature&redirectUrl=https://dr-web.pivotpayts.com/pivot_pay_api/public/',
                ),
              ),
            );
            break;
          case 'Mobile Money':
            timer = Timer.periodic(
              const Duration(seconds: 5),
              (Timer t) => _checkStatus(
                t,
                reference!,
                prefs.getString('accountNumber')!,
              ),
            );

            Navigator.push(
              _formSchoolKey.currentContext!,
              PageRouter.fadeScale(
                () => TransactionStatusPage(
                  title: 'Transaction is Processing',
                  body: 'Please enter your pin in the phone number supplied.',
                  templateId: 1,
                  showStatement: false,
                  isLottie: true,
                  imgUrl: AppImages.loading,
                  btnText: 'OK',
                ),
              ),
            );
            break;
          default:
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
          _formSchoolKey.currentContext!,
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
                  body: 'Failed to Process ${widget.providerName} Payment.',
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
                  body: 'Failed to Process ${widget.providerName} Payment.',
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
              body: 'Failed to Process ${widget.providerName} Payment.',
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
        '00009',
        'Pay Water',
        'Pay Water transaction',
        'Please note that your transaction is being processed, Incase there is a delay kindly Contact Customer Support',
      );
    }
  }

  getWalletBalance(
    String accountNumber,
    String tranRef,
  ) {
    final Map data = {'username': accountNumber};
    getUserBalances(_formSchoolKey.currentContext!, data).then((value) async {
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
          _formSchoolKey.currentContext!,
        );
      }
    });
  }

  _convertTextCurrency(
      String amountValue, String toCurrency, String fromCurrency) async {
    if (amountValue.isEmpty) {
      amountValue = '0';
    }
    final Map data = {
      'baseAmount': amountValue,
      'fromCurrency': fromCurrency,
      'toCurrency': toCurrency,
    };
    setState(() {
      shimmer = true;
    });
    convertAmount(_formSchoolKey.currentContext!, data).then((value) {
      if (value.status!) {
        _translatedAmountController.value = TextEditingValue(
          text:
              '$toCurrency : ${formatNumber(double.parse(value.convertedAmount.toString()).round()).toString()}',
        );
        final String currencyAmount = value.convertedAmount.toString();
        final double doubleAmount = double.parse(currencyAmount);
        final int intAmount = doubleAmount.round();
        convertedAmount = intAmount.toString();
        setState(() {
          shimmer = false;
          conversionCharge = value.conversionCharge!;
          if (double.parse(amountValue) > 0) {
            singleUnitAmount =
                (double.parse(amountValue) / double.parse(convertedAmount))
                    .toString();
          } else {
            singleUnitAmount = '0';
          }
        });
      } else {
        setState(() {
          shimmer = false;
          singleUnitAmount = '0';
          conversionCharge = '0';
        });
        responseDialog(
          'Sorry',
          'Okay',
          value.response!,
          _formSchoolKey.currentContext!,
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
    CleverTapPlugin.recordEvent('School Pay', eventData);
    Get.off(
      () => TransactionStatusPage(
        body:
            'You have successfully paid ${widget.providerName!} for account holder',
        templateId: 5,
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
        accountUrl: widget.providerLogo,
        isLottie: true,
        imgUrl: AppImages.success,
      ),
    );
  }
}
