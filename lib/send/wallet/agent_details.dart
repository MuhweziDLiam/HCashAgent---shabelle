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
import 'package:pivotpay/beneficiaries/beneficiary.dart';
import 'package:pivotpay/common/pin.dart';
import 'package:pivotpay/common/transaction_status.dart';
import 'package:pivotpay/components/inputs/textfield.dart';
import 'package:pivotpay/components/others/image.dart';
import 'package:pivotpay/components/others/spacers.dart';
import 'package:pivotpay/components/others/text.dart';
import 'package:pivotpay/functions/shared_modules.dart';
import 'package:pivotpay/models/beneficiary.dart';
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

class AgentRecipientPage extends BasePage {
  String? serviceName, paymentNetwork, serviceDescription;

  AgentRecipientPage(
      {super.key,
      this.paymentNetwork,
      this.serviceName,
      this.serviceDescription});

  @override
  _AgentRecipientPageState createState() => _AgentRecipientPageState();
}

class _AgentRecipientPageState extends BaseState<AgentRecipientPage>
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
      phoneNumber,
      senderAccount,
      pivotReferenceBulk;
  String sendMethod = '', service = '', accountUrl = '';
  bool shimmer = false, validated = false, isLoading = false, emptyList = true;
  Timer? timer;
  List<Beneficiary> beneficiariesList = [];
  final TextEditingController _fullNameController = TextEditingController();
  String? accountNumber;
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
    getData();
    getInfo();
    auth.isDeviceSupported().then(
          (bool isSupported) => _supportState =
              isSupported ? _SupportState.supported : _SupportState.unsupported,
        );
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

  getInfo() async {
    prefs = await SharedPreferences.getInstance();
    currencyCode = prefs!.getString('currencyCode');
    senderAccount = prefs!.getString('accountNumber');
    phoneNumber = prefs!.getString('phoneNumber');
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
              key: _formWalletKey,
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
                                '${widget.serviceDescription!.split(' ')[2]} ${widget.serviceDescription!.split(' ').length > 3 ? widget.serviceDescription!.split(' ')[3] : ''}',
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
                          height: 150,
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
                                    validateWalletAccount();
                                  }
                                }
                              },
                              child: TextInputField(
                                labelText: 'Enter HCash Agent Id',
                                focusNode: focusNode,
                                optionField: emptyList,
                                prefixIcon: Icon(
                                  Icons.account_circle,
                                  color: AppColors.pivotPayColorGreen,
                                ),
                                onSaved: (value) {
                                  //accountNumber = value;
                                },
                                controller: textEditingController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter the HCash Agent Id';
                                  }
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
                                                  'CASH_IN') &&
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
                                      (element.serviceName == 'CASH_IN') &&
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

  showInfoDialog(String accountNumber, String accountName) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25.0),
        ),
      ),
      builder: (context) => AlertDialog(
        title: Container(
          decoration: BoxDecoration(
            color: AppColors.primaryColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(10.0),
              topRight: Radius.circular(10.0),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Align(
              child: Column(
                children: [
                  // InAppImage(
                  //   AppImages.verifyAccount,
                  //   height: 150,
                  // ),
                  VSpace.sm,
                  const MediumText(
                    'Account validation',
                    size: 16,
                    color: AppColors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ],
              ),
            ),
          ),
        ),
        titlePadding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const MediumText(
                  'Recipient Name:',
                  size: 16,
                ),
                Flexible(
                  child: MediumText(
                    accountName,
                    fontWeight: FontWeight.w500,
                    size: 14,
                  ),
                ),
              ],
            ),
            VSpace.md,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const MediumText(
                  'Account Number:',
                  size: 16,
                ),
                Flexible(
                  child: MediumText(
                    accountNumber,
                    size: 14,
                  ),
                ),
              ],
            ),
          ],
        ),
        contentPadding: const EdgeInsets.all(25),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(10.0),
          ),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              backgroundColor: AppColors.black.withOpacity(0.1),
              padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
            ),
            child: MediumText(
              'Cancel',
              color: AppColors.primaryColor,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              backgroundColor: AppColors.primaryColor,
              padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
            ),
            child: const MediumText(
              'Confirm',
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
        elevation: 30,
        actionsPadding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
        actionsAlignment: MainAxisAlignment.spaceBetween,
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
    service = widget.serviceName!;
    paymentNetwork = widget.paymentNetwork!;
    switch (widget.serviceName) {
      case 'AGENT_TO_AGENT':
        fromAccount = senderAccount!;
        sendMethod = 'AGENTWALLET';
        break;
      case 'MOMO_TO_WALLET':
        fromAccount = senderPhone!;
        sendMethod = 'MOBILE MONEY';
        break;
    }

    final Map data = {
      'fromAccount': fromAccount,
      'fromCurrency': currencyCode,
      'fromAmount': _amountController.text,
      'toCurrency': prefs.getString('currencyCode'),
      'toAmount': _amountController.text,
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
      'senderName': prefs.getString('agentName'),
      'receiverName': _fullNameController.text,
      'service_provider': paymentNetwork,
      'transactionId': reference,
      'walletId': prefs.getString('accountNumber'),
      'narration': 'HCash Float Transfer payment Transaction',
    };
    processUserPayment(_formWalletKey.currentContext!, data).then((value) {
      if (value.status!) {
        progress.dismiss();
        setState(() {
          ignoreTaps = false;
        });
        switch (value.response) {
          case 'SUCCESS':
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
        '00003',
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
        accountNumber: accountNumber,
        accountUrl: accountUrl,
        isLottie: true,
        imgUrl: AppImages.success,
      ),
    );
  }
}
