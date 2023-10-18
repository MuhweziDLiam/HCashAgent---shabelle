import 'dart:async';
import 'dart:developer';
import 'package:currency_picker/currency_picker.dart';
import 'package:clevertap_plugin/clevertap_plugin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pivotpay/card/card_payment.dart';
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
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shimmer/shimmer.dart';

class FundWalletDetailsPage extends BasePage {
  final int paymentMode;

  const FundWalletDetailsPage(this.paymentMode, {super.key});

  @override
  State<FundWalletDetailsPage> createState() => _FundWalletDetailsPageState();
}

class _FundWalletDetailsPageState extends BaseState<FundWalletDetailsPage>
    with BasicPage {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final _formFundKey = GlobalKey<FormState>();
  bool shimmer = false;
  String helperText = '',
      convertedAmount = '0',
      conversionCharge = '0',
      singleUnitAmount = '0';
  String? phone,
      paymentNetwork,
      reference,
      pivotReference,
      serviceName,
      currencyCode,
      toCurrencyCode,
      version,
      location,
      fundMethod;
  SharedPreferences? prefs;
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  bool ignoreTaps = false;
  Timer? _debounce, timer;

  @override
  void initState() {
    super.initState();
    getInfo();
  }

  getInfo() async {
    prefs = await SharedPreferences.getInstance();
    currencyCode = prefs!.getString('currencyCode');
    toCurrencyCode = currencyCode;
    _phoneNumberController.value =
        TextEditingValue(text: prefs!.getString('phoneNumber')!);
    final versionInfo = await PackageInfo.fromPlatform();
    version = '${versionInfo.version}+${versionInfo.buildNumber}';
    final Position position =
        await determinePosition(_formFundKey.currentContext!);
    location = await getCountry(position);
  }

  @override
  Widget rootWidget(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: const MediumText(
          'Fund Pivot Wallet',
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
            builder: (context) => SingleChildScrollView(
              child: Form(
                key: _formFundKey,
                child: Column(
                  children: [
                    const VSpace(25),
                    Text.rich(
                      TextSpan(
                        text: 'Fund Wallet with ',
                        style: TextStyle(
                          color: AppColors.primaryColor,
                          fontFamily: 'Lato',
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                        ),
                        children: <InlineSpan>[
                          TextSpan(
                            text: ' Mobile Money!',
                            style: TextStyle(
                                color: AppColors.pivotPayColorGreen,
                                fontFamily: 'Lato'),
                          )
                        ],
                      ),
                    ),
                    VSpace.sm,
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
                          labelText: 'Enter phone number',
                          controller: _phoneNumberController,
                          prefixIcon: Icon(
                            Icons.phone,
                            color: AppColors.pivotPayColorGreen,
                          ),
                          onSaved: (value) {},
                          readOnly: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your Phone Number';
                            }
                            if (!validatePhoneNumberInput(value)) {
                              return 'Phone number is not valid (no spaces allowed)';
                            }
                            return null;
                          },
                        ),
                        VSpace.md,
                        TextInputField(
                          labelText: 'Enter Amount',
                          controller: _amountController,
                          keyboardType: TextInputType.number,
                          onSaved: (value) {},
                          prefixIcon: Icon(
                            Icons.account_balance_wallet_outlined,
                            size: 24,
                            color: AppColors.pivotPayColorGreen,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter the amount';
                            }
                            if (!validateAmount(value)) {
                              return 'Amount should only contain digits';
                            }
                            return null;
                          },
                        ),
                        VSpace.lg,
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      AppColors.black.withOpacity(0.1),
                                  minimumSize: Size.zero,
                                  padding: const EdgeInsets.fromLTRB(
                                    10,
                                    12,
                                    10,
                                    12,
                                  ),
                                ),
                                child: MediumText(
                                  'Cancel',
                                  color: AppColors.primaryColor,
                                ),
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
                                  if (_formFundKey.currentState!.validate()) {
                                    setState(() {
                                      _formFundKey.currentState!.save();
                                    });
                                    _processTransaction();
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

  _processTransaction() async {
    final progress = ProgressHUD.of(_formFundKey.currentContext!);
    progress!.showWithText('Processing Transaction..');
    setState(() {
      ignoreTaps = true;
    });

    reference = DateTime.now().millisecondsSinceEpoch.toString();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final getXPrefs = GetStorage();
    phone = _phoneNumberController.text;
    if (phone!.startsWith('+')) {
      phone = phone!.replaceAll('+', '');
    }
    paymentNetwork = 'TBD';
    switch (widget.paymentMode) {
      case 1:
        paymentNetwork = 'CARD PAYMENT';
        serviceName = 'CARD_TOPUP';
        fundMethod = 'CARD';
        break;
      default:
        fundMethod = 'MOBILE MONEY';
        serviceName = 'MOMO_TOPUP';
        break;
    }
    reference = reference! + prefs.getString('userName')!.toUpperCase();

    final Map data = {
      'fromAccount': phone,
      'fromCurrency': currencyCode,
      'fromAmount': _amountController.text,
      'toCurrency': toCurrencyCode,
      'toAmount': _amountController.text,
      'toAccount': prefs.getString('accountNumber'),
      'appVersion': version,
      'location': location,
      'osType': getXPrefs.read('source'),
      'transactionAmount': _amountController.text,
      'serviceName': serviceName,
      'payment_method': fundMethod,
      'debitType': fundMethod,
      'phoneNumber': phone,
      'senderName':
          '${prefs.getString('secondName')} ${prefs.getString('firstName')}',
      'receiverName':
          '${prefs.getString('secondName')} ${prefs.getString('firstName')}',
      'service_provider': paymentNetwork,
      'transactionId': reference,
      'walletId': prefs.getString('accountNumber'),
      'narration': 'Fund Pivotpay Wallet',
    };
    processUserPayment(_formFundKey.currentContext!, data).then((value) {
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
        switch (widget.paymentMode) {
          case 0:
            Navigator.push(
              _formFundKey.currentContext!,
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
          case 1:
            Navigator.push(
              _formFundKey.currentContext!,
              PageRouter.fadeScale(
                () => CardPaymentPage(
                  '${prefs.getString('cardUrl')}$reference&customerReference=${_phoneNumberController.text}&itempaidfor=FUNDWALLET&tranamount=${_amountController.text}&usercurrency=$currencyCode&phoneNumber=${_phoneNumberController.text}&email=support@pivotpayts.com&tranId=$reference&password=EVJ7O9V6Q6&vendorKey=KVZQK4ZS7G2B29051EQ9&returnUrl=https%3A%2F%2Fpivotpayts.com%2F&pivotId=$reference&requestSignature=testSignature&redirectUrl=https://dr-web.pivotpayts.com/pivot_pay_api/public/',
                ),
              ),
            );
            break;
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
          _formFundKey.currentContext!,
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
              getWalletBalance(accountNumber, tranReference);
              break;
            case 'PROCESSED':
              t.cancel();
              getWalletBalance(accountNumber, tranReference);
              break;
            case 'FAILED':
              t.cancel();
              Get.off(
                () => TransactionStatusPage(
                  title: 'Transaction Failed',
                  reason: value.responseMessage!,
                  templateId: 3,
                  body: 'Failed to Top up.',
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
              Get.off(
                () => TransactionStatusPage(
                  title: 'Transaction Failed',
                  body: 'Failed to Top up.',
                  templateId: 3,
                  showStatement: false,
                  reason: value.responseMessage,
                  dateTime: DateFormat('E, d MMM yyyy HH:mm:ss')
                      .format(DateTime.now()),
                  transactionRef: tranReference,
                  isLottie: true,
                  imgUrl: AppImages.failed,
                  btnText: 'OK',
                ),
              );
          }
        } else {
          t.cancel();
          Get.off(
            () => TransactionStatusPage(
              title: 'Transaction Failed',
              body: 'Failed to Top up.',
              templateId: 3,
              reason: value.responseMessage,
              dateTime:
                  DateFormat('E, d MMM yyyy HH:mm:ss').format(DateTime.now()),
              showStatement: false,
              transactionRef: tranReference,
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
        '00001',
        'Fund Wallet',
        'Fund wallet transaction',
        'Please note that your transaction is being processed, Incase there is a delay kindly Contact Customer Support',
      );
    }
  }

  _updateBalance(String balance, String tranRef) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString(
      'accountBalance',
      balance,
    );
    final now = DateTime.now();
    final eventData = {
      'Amount': _amountController.text,
      'Date': CleverTapPlugin.getCleverTapDate(now),
      'Fund Mode': fundMethod
    };
    CleverTapPlugin.recordEvent('Fund Account', eventData);

    Get.off(
      () => TransactionStatusPage(
        body: 'Top up completed successfully',
        templateId: 2,
        showStatement: false,
        title: 'Transaction Successful',
        dateTime: DateFormat('E, d MMM yyyy HH:mm:ss').format(DateTime.now()),
        amount:
            '$currencyCode. ${formatNumber(int.parse(_amountController.text))}',
        balance: '$currencyCode. ${formatNumber(int.parse(balance))}',
        transactionRef: tranRef,
        btnText: 'OK',
        isLottie: true,
        imgUrl: AppImages.success,
      ),
    );
  }

  getWalletBalance(String accountNumber, String tranRef) {
    final Map data = {'username': accountNumber};
    getUserBalances(_formFundKey.currentContext!, data).then((value) async {
      if (value.status!) {
        _updateBalance(
            value.accountBalance.toString().replaceAll(',', ''), tranRef);
      } else {
        responseDialog(
          'Sorry',
          'Okay',
          value.response!,
          _formFundKey.currentContext!,
        );
      }
    });
  }
}
