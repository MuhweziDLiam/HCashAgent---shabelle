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
import 'package:intl/intl.dart';
import 'package:local_auth/local_auth.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pivotpay/beneficiaries/beneficiary.dart';
import 'package:pivotpay/card/card_payment.dart';
import 'package:pivotpay/common/pin.dart';
import 'package:pivotpay/common/transaction_status.dart';
import 'package:pivotpay/components/inputs/textfield.dart';
import 'package:pivotpay/components/others/image.dart';
import 'package:pivotpay/components/others/spacers.dart';
import 'package:pivotpay/components/others/text.dart';
import 'package:pivotpay/functions/shared_modules.dart';
import 'package:pivotpay/models/beneficiary.dart';
import 'package:pivotpay/models/validate_account.dart';
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

class WalletCardPage extends BasePage {
  String? serviceDescription;

  WalletCardPage({this.serviceDescription});

  @override
  _WalletCardPageState createState() => _WalletCardPageState();
}

class _WalletCardPageState extends BaseState<WalletCardPage> with BasicPage {
  String? senderPhone,
      recipientPhone,
      paymentNetwork,
      reference,
      bulkReference,
      pivotReference,
      toCurrencyCode,
      version,
      phoneNumber,
      currencyCode,
      senderAccount,
      pivotReferenceBulk;
  List<String> supportedCurrencies = [];
  String sendMethod = '',
      service = '',
      accountUrl = '',
      convertedAmount = '0',
      conversionCharge = '0',
      singleUnitAmount = '0';
  bool shimmer = false, validated = false, isLoading = false, emptyList = true;
  Timer? timer, _debounce;
  bool? isAndroid;
  final TextEditingController _fullNameController = TextEditingController();
  String? accountNumber;
  final _formWalletKey = GlobalKey<FormState>();
  List<Beneficiary> beneficiariesList = [];
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _currencyController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _translatedAmountController =
      TextEditingController();
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
    getData();
    getInfo();
    getCurrencies();
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
    phoneNumber = prefs!.getString('phoneNumber');
    toCurrencyCode = currencyCode;
    _currencyController.value = TextEditingValue(text: currencyCode!);
    _emailController.value =
        const TextEditingValue(text: 'support@pivotpayts.com');
    _translatedAmountController.value =
        TextEditingValue(text: '$currencyCode : ');
    _translatedAmountController.value =
        TextEditingValue(text: '$currencyCode : ');
    final versionInfo = await PackageInfo.fromPlatform();
    version = '${versionInfo.version}+${versionInfo.buildNumber}';
    final Position position =
        await determinePosition(_formWalletKey.currentContext!);
    location = await getCountry(position);
  }

  getData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      ignoreTaps = true;
      isLoading = true;

      ProgressHUD.of(_formWalletKey.currentContext!)
          ?.showWithText('Please wait...');
    });
    final Map data = {'accountNumber': prefs.getString('accountNumber')};
    if (!mounted) return;
    getBeneficiaries(context, data).then((value) {
      setState(() {
        ignoreTaps = false;
        isLoading = false;
        ProgressHUD.of(_formWalletKey.currentContext!)?.dismiss();
        if (value.status!) {
          for (var elementOne in value.beneficiaryList!) {
            if (beneficiariesList
                .where((element) =>
                    element.beneficiaryAccount == elementOne.beneficiaryAccount)
                .isEmpty) {
              beneficiariesList.add(elementOne);
            }
          }
        }
      });
    });
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
              key: _formWalletKey,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const VSpace(25),
                    Text.rich(
                      TextSpan(
                        text:
                            '${widget.serviceDescription!.split(' ')[0]} ${widget.serviceDescription!.split(' ')[1]} ${widget.serviceDescription!.split(' ')[2]} ',
                        style: TextStyle(
                          color: AppColors.primaryColor,
                          fontFamily: 'Lato',
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                        ),
                        children: <InlineSpan>[
                          TextSpan(
                            text: widget.serviceDescription!.split(' ')[3],
                            style: TextStyle(
                                color: AppColors.pivotPayColorGreen,
                                fontWeight: FontWeight.w800,
                                fontFamily: 'Lato'),
                          )
                        ],
                      ),
                    ),
                    VSpace.sm,
                    SmallText(
                      'Enter the recipient details',
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
                        Autocomplete<Beneficiary>(
                          displayStringForOption: (option) {
                            return option.beneficiaryAccount!;
                          },
                          fieldViewBuilder: (context, textEditingController,
                              focusNode, onFieldSubmitted) {
                            return Focus(
                              onFocusChange: (value) {
                                if (value == false) {
                                  if (textEditingController.text.isNotEmpty) {
                                    accountNumber = textEditingController.text;
                                    if (textEditingController.text
                                            .startsWith('0') &&
                                        (textEditingController.text.length ==
                                            10)) {
                                      accountNumber = accountNumber!
                                          .replaceFirst('0', '+256');
                                    }
                                    if (textEditingController.text
                                            .startsWith('256') &&
                                        (textEditingController.text.length ==
                                            12)) {
                                      accountNumber = accountNumber!
                                          .replaceFirst('256', '+256');
                                    }
                                    validateWalletAccount();
                                  }
                                }
                              },
                              child: TextInputField(
                                labelText: 'Enter Pivot Pay Account number',
                                focusNode: focusNode,
                                optionField: emptyList,
                                prefixIcon: Icon(
                                  Icons.account_circle,
                                  color: AppColors.pivotPayColorGreen,
                                ),
                                onSaved: (value) {},
                                controller: textEditingController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter the Pivot Pay Account Number';
                                  }
                                  // if (!validateSpecialCharacters(value)) {
                                  //   return 'Please only use numbers (no spaces)';
                                  // }
                                  // if (!validateNumbers(value)) {
                                  //   return 'Please only use numbers (no spaces)';
                                  // }
                                  if (senderAccount == value) {
                                    return 'Recipient cannot be same as sender';
                                  }
                                  return null;
                                },
                              ),
                            );
                          },
                          optionsBuilder: (textEditingValue) {
                            if (textEditingValue.text.isEmpty) {
                              setState(() {
                                emptyList = true;
                              });
                              return [];
                            } else {
                              setState(
                                () {
                                  beneficiariesList
                                          .where((element) =>
                                              (element.serviceName ==
                                                  'WALLET_TO_WALLET') &&
                                              (element.beneficiaryAccount!
                                                      .contains(textEditingValue
                                                          .text) ||
                                                  element.beneficiaryName!
                                                      .toLowerCase()
                                                      .contains(textEditingValue
                                                          .text
                                                          .toLowerCase())))
                                          .isEmpty
                                      ? emptyList = true
                                      : emptyList = false;
                                },
                              );
                              return beneficiariesList
                                  .where((element) =>
                                      (element.serviceName ==
                                          'WALLET_TO_WALLET') &&
                                      (element.beneficiaryAccount!.contains(
                                              textEditingValue.text) ||
                                          element.beneficiaryName!
                                              .toLowerCase()
                                              .contains(textEditingValue.text
                                                  .toLowerCase())))
                                  .toList();
                            }
                          },
                          optionsViewBuilder: (context, onSelected, options) {
                            return Align(
                              alignment: Alignment.topLeft,
                              child: Material(
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 20),
                                  decoration: BoxDecoration(
                                      color: AppColors.white,
                                      borderRadius: const BorderRadius.only(
                                          bottomRight: Radius.circular(10.0),
                                          bottomLeft: Radius.circular(10.0)),
                                      border: Border.all(
                                          color: AppColors.pivotPayColorGreen,
                                          width: 0.5)),
                                  //color: AppColors.white,
                                  width: MediaQuery.of(context).size.width - 80,
                                  height: 200,
                                  child: SingleChildScrollView(
                                    child: Column(
                                      children: [
                                        Column(
                                          children: [
                                            VSpace.xs,
                                            ...options
                                                .map(
                                                  (e) => GestureDetector(
                                                    onTap: (() {
                                                      onSelected(e);
                                                    }),
                                                    child: BeneficiaryWidget(
                                                      walletOptions: true,
                                                      name: e.beneficiaryName
                                                          .toString(),
                                                      accountNumber: e
                                                          .beneficiaryAccount
                                                          .toString(),
                                                      accountUrl: e.accountUrl
                                                          .toString(),
                                                      serviceName: e.serviceName
                                                          .toString(),
                                                    ),
                                                  ),
                                                )
                                                .toList()
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                          onSelected: (option) {
                            setState(() {
                              emptyList = true;
                            });
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
                        Visibility(
                          visible: false,
                          child: Column(
                            children: [
                              TextInputField(
                                labelText: 'Enter your email address',
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter the your Email Address';
                                  }
                                  return null;
                                },
                                controller: _emailController,
                                onSaved: (value) {},
                              ),
                            ],
                          ),
                        ),
                        VSpace.md,
                        TextInputField(
                          labelText: 'Select currency',
                          hintText: 'UGX',
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
                            _debounce =
                                Timer(const Duration(milliseconds: 500), () {
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
                                          '1 ${_currencyController.text} = $toCurrencyCode ${formatNumber(double.parse(singleUnitAmount).round())}',
                                          color: AppColors.white,
                                        )
                                      ],
                                    )
                                  ],
                                ),
                              ),
                        const VSpace(10),
                        TextInputField(
                          labelText: 'They will receive',
                          readOnly: true,
                          controller: _translatedAmountController,
                          onTap: () {},
                          onSaved: (value) {},
                          validator: (value) {
                            return null;
                          },
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
                                  if (validated) {
                                    if (_formWalletKey.currentState!
                                        .validate()) {
                                      setState(() {
                                        _formWalletKey.currentState!.save();
                                      });
                                      if (_supportState ==
                                          _SupportState.supported) {
                                        _checkBiometrics().then((value) {
                                          if (value) {
                                            _authenticate().then((value) {
                                              if (value) {
                                                _processTransaction(
                                                  _formWalletKey
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
                                                    _formWalletKey
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
                                                _formWalletKey.currentContext!,
                                              );
                                            }
                                          },
                                        );
                                      }
                                    }
                                  } else {
                                    responseDialog(
                                      'Sorry',
                                      'Okay',
                                      'The Supplied account is not successfully validated.',
                                      _formWalletKey.currentContext!,
                                    );
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
    final Map data = {'username': accountNumber};
    validateHcashAccount(_formWalletKey.currentContext!, data)
        .then((value) async {
      if (value.status!) {
        progress.dismiss();
        if (accountNumber == phoneNumber) {
          setState(() {
            ignoreTaps = false;
            validated = false;
          });
          responseDialog(
            'Sorry',
            'Okay',
            'Recipient cannot be same as sender',
            _formWalletKey.currentContext!,
          );
        } else {
          setState(() {
            ignoreTaps = false;
            validated = true;
            _fullNameController.value =
                TextEditingValue(text: value.accountName!);
            accountUrl = value.accountUrl!;
            accountNumber = value.accountNumber;
          });
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
    paymentNetwork = 'CARD PAYMENT';
    service = 'CARD_TO_WALLET';
    fromAccount = senderAccount!;
    sendMethod = 'CARD';
    convertedAmount.isEmpty
        ? convertedAmount = _amountController.text
        : convertedAmount = convertedAmount;

    final Map data = {
      'fromAccount': fromAccount,
      'fromCurrency': _currencyController.text,
      'fromAmount': _amountController.text,
      'toCurrency': prefs.getString('currencyCode'),
      'toAmount': convertedAmount,
      'toAccount': accountNumber,
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
    processUserPayment(_formWalletKey.currentContext!, data).then((value) {
      if (value.status!) {
        progress.dismiss();
        setState(() {
          ignoreTaps = false;
        });
        timer = Timer.periodic(
          const Duration(seconds: 5),
          (Timer t) => _checkStatus(
            t,
            reference!,
            prefs.getString('accountNumber')!,
          ),
        );
        Navigator.push(
          _formWalletKey.currentContext!,
          PageRouter.fadeScale(
            () => CardPaymentPage(
              '${prefs.getString('cardUrl')}$reference&customerReference=$accountNumber&itempaidfor=CARDTOWALLET&tranamount=${_amountController.text}&usercurrency=${_currencyController.text}&phoneNumber=$senderPhone&email=${_emailController.text}&tranId=$reference&password=EVJ7O9V6Q6&vendorKey=KVZQK4ZS7G2B29051EQ9&returnUrl=https%3A%2F%2Fpivotpayts.com%2F&pivotId=$reference&requestSignature=testSignature&redirectUrl=https://dr-web.pivotpayts.com/pivot_pay_api/public/',
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
        '00004',
        'Send Money',
        'Send Money transaction',
        'Please note that your transaction is being processed, Incase there is a delay kindly Contact Customer Support',
      );
    }
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
    convertAmount(_formWalletKey.currentContext!, data).then((value) {
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
                (double.parse(convertedAmount) / double.parse(amountValue))
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
          _formWalletKey.currentContext!,
        );
      }
    });
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
            '${_currencyController.text}. ${formatNumber(int.parse(_amountController.text))}',
        balance: '$currencyCode. ${formatNumber(int.parse(balance))}',
        transactionRef: tranRef,
        btnText: 'OK',
        accountName: _fullNameController.text,
        accountNumber: accountNumber,
        accountUrl: accountUrl,
        isLottie: true,
        imgUrl: AppImages.success,
      ),
    );
  }
}
