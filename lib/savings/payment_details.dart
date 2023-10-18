// ignore_for_file: parameter_assignments, avoid_dynamic_calls

import 'dart:async';
import 'dart:math';

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
import 'package:pivotpay/card/card_payment.dart';
import 'package:pivotpay/common/pin.dart';
import 'package:pivotpay/common/transaction_status.dart';
import 'package:pivotpay/components/inputs/textfield.dart';
import 'package:pivotpay/components/others/clip_painter.dart';
import 'package:pivotpay/components/others/image.dart';
import 'package:pivotpay/components/others/spacers.dart';
import 'package:pivotpay/components/others/text.dart';
import 'package:pivotpay/functions/shared_modules.dart';
import 'package:pivotpay/models/validate_account.dart';
import 'package:pivotpay/network/api_service.dart';
import 'package:pivotpay/utils/base_page.dart';
import 'package:pivotpay/utils/resources.dart';
import 'package:pivotpay/utils/routing.dart';
import 'package:pivotpay/utils/style.dart';
import 'package:pivotpay/validators/validators.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:timelines/timelines.dart';

enum _SupportState {
  unknown,
  supported,
  unsupported,
}

class PaymentDetailsPage extends BasePage {
  String? providerLogo,
      providerName,
      providerCode,
      packageName,
      currency,
      packageMonths,
      providerColor;

  int? installmentAmount;

  PaymentDetailsPage({
    super.key,
    this.providerLogo,
    this.providerCode,
    this.providerName,
    this.providerColor,
    this.packageName,
    this.currency,
    this.installmentAmount = 0,
    this.packageMonths,
  });

  @override
  _PaymentDetailsPageState createState() => _PaymentDetailsPageState();
}

class _PaymentDetailsPageState extends BaseState<PaymentDetailsPage>
    with BasicPage {
  String? senderPhone,
      recipientPhone,
      reference,
      toCurrencyCode,
      version,
      currencyCode,
      senderAccount;
  String sendMethod = '',
      service = '',
      accountUrl = '',
      convertedAmount = '0',
      conversionCharge = '0',
      singleUnitAmount = '0';
  bool shimmer = false;
  Timer? timer, _debounce;
  List<String> supportedCurrencies = [];
  bool? isAndroid;
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _packageDetailsController =
      TextEditingController();
  final _formMobileKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _currencyController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _translatedAmountController =
      TextEditingController();
  bool ignoreTaps = false;
  SharedPreferences? prefs;
  final String _comingSms = 'Unknown';
  String location = 'Unknown';
  int position = 2;
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
    currencyCode = widget.currency!;
    senderAccount = prefs!.getString('accountNumber');
    senderPhone = prefs!.getString('phoneNumber');
    toCurrencyCode = prefs!.getString('currencyCode');
    _packageDetailsController.value = TextEditingValue(
        text: '${widget.packageName!} - ${widget.packageMonths!} Months');
    _fullNameController.value =
        TextEditingValue(text: '${widget.providerName!} Travel Agency');
    _amountController.value =
        TextEditingValue(text: widget.installmentAmount.toString());
    _currencyController.value = TextEditingValue(text: currencyCode!);
    _translatedAmountController.value =
        TextEditingValue(text: '$currencyCode : ');
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
        backgroundColor: Color(int.parse(widget.providerColor!)),
        title: const MediumText(
          'Payment Details',
          size: 18,
          color: Colors.white,
        ),
        actions: [
          IconButton(
            onPressed: (() {}),
            icon: InAppImage(
              AppIcons.notification,
              height: 25,
            ),
          ),
          const HSpace(5),
          IconButton(
            onPressed: (() {}),
            icon: InAppImage(
              AppImages.ugandaRound,
              height: 25,
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
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Text.rich(
                    //   TextSpan(
                    //     text:
                    //         '${widget.serviceDescription!.split(' ')[0]} ${widget.serviceDescription!.split(' ')[1]} ',
                    //     style: TextStyle(
                    //       color: AppColors.primaryColor,
                    //       fontFamily: 'Lato',
                    //       fontWeight: FontWeight.w900,
                    //       fontSize: 18,
                    //     ),
                    //     children: <InlineSpan>[
                    //       TextSpan(
                    //         text:
                    //             '${widget.serviceDescription!.split(' ')[2]} ${widget.serviceDescription!.split(' ')[3]}',
                    //         style: TextStyle(
                    //             color: AppColors.pivotPayColorGreen,
                    //             fontFamily: 'Lato'),
                    //       )
                    //     ],
                    //   ),
                    // ),
                    VSpace.md,
                    SmallText(
                      'Payment Progress Indicator',
                      size: FontSizes.s14,
                      align: TextAlign.center,
                    ),
                    Center(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxHeight: 80,
                          ),
                          child: FixedTimeline.tileBuilder(
                            theme: TimelineThemeData(
                              direction: Axis.horizontal,
                              nodePosition: 0.2,
                              color: AppColors.primaryColor,
                              indicatorTheme: const IndicatorThemeData(
                                  position: 0.5, size: 10),
                            ),
                            builder: TimelineTileBuilder.connected(
                              connectionDirection: ConnectionDirection.before,
                              itemCount: int.parse(widget.packageMonths!),
                              contentsBuilder: (context, index) {
                                return Column(
                                  children: [
                                    Transform.rotate(
                                      angle: -pi / 1,
                                      child: ClipPath(
                                        clipper: TriangleClipper(),
                                        child: Container(
                                          color: Color((int.parse(
                                              widget.providerColor!))),
                                          height: 10,
                                          width: 5,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Color(
                                          int.parse(widget.providerColor!),
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      margin: const EdgeInsets.only(top: 0),
                                      padding: const EdgeInsets.all(8.0),
                                      child: SmallText(
                                        '${widget.currency!}. ${(widget.installmentAmount! * (index + 1))}',
                                        color: AppColors.white,
                                      ),
                                    ),
                                  ],
                                );
                              },
                              indicatorBuilder: (_, index) {
                                return DotIndicator(
                                  size: 10,
                                  color: Color(
                                    int.parse(widget.providerColor!),
                                  ),
                                  child: const Padding(
                                    padding: EdgeInsets.all(8.0),
                                  ),
                                );
                              },
                              connectorBuilder: (_, index, ___) =>
                                  SolidLineConnector(
                                thickness: 1,
                                color: Color(
                                  int.parse(widget.providerColor!),
                                ),
                              ),
                              itemExtentBuilder: (_, index) => 100,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      margin: const EdgeInsets.only(
                          left: 10, right: 10, top: 10, bottom: 10),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.black, width: 0.2),
                        borderRadius: const BorderRadius.all(
                          Radius.circular(10.0),
                        ),
                      ),
                      child: Column(children: [
                        VSpace.md,
                        InAppImage(
                          AppImages.savings,
                          height: 100,
                        ),
                        VSpace.sm,
                        TextInputField(
                          readOnly: true,
                          labelText: 'Provider Name',
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
                          labelText: 'Package details',
                          prefixIcon: Icon(
                            Icons.phone,
                            color: AppColors.pivotPayColorGreen,
                          ),
                          readOnly: true,
                          onSaved: (value) {},
                          controller: _packageDetailsController,
                          validator: (value) {
                            return null;
                          },
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
                        TextInputField(
                          prefixIcon: Icon(
                            Icons.description,
                            color: AppColors.pivotPayColorGreen,
                          ),
                          labelText: 'Reason',
                          controller: _descriptionController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter the Reason';
                            }
                            if (value.length > 15) {
                              return 'Maximum Reason length is 15 characters';
                            }
                            if (value.length < 5) {
                              return 'Your Reason must have at least 5 characters';
                            }
                            if (!validateSentence(value)) {
                              return 'Reason must only contain letters and numbers';
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
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(
                                    AppColors.black.withOpacity(0.1),
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
                                    backgroundColor: Color(
                                        int.parse(widget.providerColor!))),
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

    reference = DateTime.now().millisecondsSinceEpoch.toString();
    final String senderAccount = prefs.getString('accountNumber')!;
    senderPhone = prefs.getString('phoneNumber')!;
    if (senderPhone!.startsWith('+')) {
      senderPhone = senderPhone!.replaceAll('+', '');
    }
    if (senderPhone!.startsWith('0')) {
      senderPhone = senderPhone!.replaceFirst('0', '256');
    }
    service = 'HIJJA_TRANSFER';
    fromAccount = senderAccount;
    sendMethod = 'WALLET';
    convertedAmount.isEmpty
        ? convertedAmount = _amountController.text
        : convertedAmount = convertedAmount;
    reference = reference! + prefs.getString('userName')!.toUpperCase();

    final Map data = {
      'fromAccount': fromAccount,
      'fromCurrency': _currencyController.text,
      'fromAmount': _amountController.text,
      'toCurrency': prefs.getString('currencyCode'),
      'toAmount': convertedAmount,
      'toAccount': widget.providerCode,
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
      'service_provider': 'PIVOTPAY WALLET',
      'transactionId': reference,
      'walletId': prefs.getString('accountNumber'),
      'narration': '${widget.providerName!} - ${widget.packageName!}',
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
                  body: 'Failed to process transaction.',
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
                  body: 'Failed to process transaction.',
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
              body: 'Failed to process transaction.',
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
        '00011',
        'Halal Savings',
        'Halal Savings transaction',
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
    convertAmount(_formMobileKey.currentContext!, data).then((value) {
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
          _formMobileKey.currentContext!,
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
    final now = DateTime.now();
    final eventData = {
      'Amount': _amountController.text,
      'Recipient Name': _fullNameController.text,
      'Recipient Account': recipientPhone,
      'Type': service,
      'Date': CleverTapPlugin.getCleverTapDate(now),
      'Payment Mode': 'PIVOTPAY WALLET'
    };
    CleverTapPlugin.recordEvent('Send Money', eventData);
    Get.off(
      () => TransactionStatusPage(
        body:
            'You have successfully paid ${widget.providerName!} - ${widget.packageName}',
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
        accountNumber: widget.providerCode,
        accountUrl: widget.providerLogo,
        isLottie: true,
        imgUrl: AppImages.success,
      ),
    );
  }
}
