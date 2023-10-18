// ignore_for_file: parameter_assignments, avoid_dynamic_calls

//import 'package:alt_sms_autofill/alt_sms_autofill.dart';
import 'package:flutter/material.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:pivotpay/components/others/image.dart';
import 'package:pivotpay/components/others/spacers.dart';
import 'package:pivotpay/components/others/text.dart';
import 'package:pivotpay/functions/shared_modules.dart';
import 'package:pivotpay/models/transactions.dart';
import 'package:pivotpay/network/api_service.dart';
import 'package:pivotpay/transactions/transaction.dart';
import 'package:pivotpay/utils/base_page.dart';
import 'package:pivotpay/utils/resources.dart';
import 'package:pivotpay/utils/style.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class TransactionsPage extends BasePage {
  const TransactionsPage({super.key});

  @override
  _TransactionsPageState createState() => _TransactionsPageState();
}

class _TransactionsPageState extends BaseState<TransactionsPage>
    with BasicPage {
  bool shimmer = false;
  bool ignoreTaps = false;
  SharedPreferences? prefs;
  List<Transaction> transactions = [];
  final String selectedDate = '';
  final transactionsKey = GlobalKey();
  String currentMonth = DateFormat('MMMM').format(DateTime.now());
  String? startDate, endDate, startMonth, endMonth, accountNumber;
  @override
  void initState() {
    super.initState();
    endDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final DateTime now = DateTime.now();
    startDate = DateFormat('yyyy-MM-dd').format(DateTime(now.year, now.month));
    getTransactions();
  }

  getTransactions() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      ignoreTaps = true;
      shimmer = true;
      ProgressHUD.of(transactionsKey.currentContext!)!
          .showWithText('Loading ...');
    });
    accountNumber = prefs.getString('accountNumber');
    final Map data = {
      'accountNumber': accountNumber,
      'startDate': startDate,
      'endDate': endDate
    };
    if (!mounted) return;
    getAgentStatement(transactionsKey.currentContext!, data).then((value) {
      if (value.status!) {
        ProgressHUD.of(transactionsKey.currentContext!)!.dismiss();
        setState(() {
          ignoreTaps = false;
          shimmer = false;
          transactions = value.transactionList!;
        });
      } else {
        ProgressHUD.of(transactionsKey.currentContext!)!.dismiss();
        setState(() {
          shimmer = false;
          ignoreTaps = false;
          transactions.clear();
        });
        responseDialog(
          'Sorry',
          'Okay',
          value.responseMessage!,
          transactionsKey.currentContext!,
        );
      }
    });
  }

  @override
  void dispose() {
    //AltSmsAutofill().unregisterListener();
    super.dispose();
  }

  datePickerDialog(BuildContext mContext) {
    showDialog(
      context: mContext,
      builder: (context) => AlertDialog(
        title: Container(
          width: 500,
          height: 400,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Date Picker',
                style: TextStyle(
                  color: Color.fromRGBO(3, 76, 129, 1),
                ),
              ),
              const Divider(
                color: Color.fromRGBO(133, 186, 51, 1),
              ),
              Column(
                children: [
                  SfDateRangePicker(
                    onSelectionChanged: onSelectionChanged,
                    selectionMode: DateRangePickerSelectionMode.range,
                    initialSelectedRange: PickerDateRange(
                      DateTime(DateTime.now().year, DateTime.now().month),
                      DateTime.now(),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 20,
                          color: Colors.black,
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                            setState(() {
                              transactions.clear();
                              getTransactions();
                            });
                          },
                          child: const Text(
                            'Confirm',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color.fromRGBO(
                                133,
                                186,
                                51,
                                1,
                              ),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  onSelectionChanged(DateRangePickerSelectionChangedArgs args) {
    setState(() {
      if (args.value is PickerDateRange) {
        startDate = args.value.startDate.toString().split(' ')[0];
        endDate = args.value.endDate.toString().split(' ')[0];
        startMonth = DateFormat('MMMM').format(
          DateTime.parse(args.value.startDate.toString().split(' ')[0]),
        );
        endMonth = DateFormat('MMMM').format(
          DateTime.parse(args.value.endDate.toString().split(' ')[0]),
        );
        if (startMonth == endMonth) {
          currentMonth = startMonth!;
        } else {
          currentMonth = '$startMonth - $endMonth';
        }
      }
    });
  }

  @override
  Widget rootWidget(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: const MediumText(
          'Transactions',
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
          child: SingleChildScrollView(
            key: transactionsKey,
            child: Column(
              children: [
                const VSpace(25),
                Text.rich(
                  TextSpan(
                    text: 'Transactions &',
                    style: TextStyle(
                      color: AppColors.primaryColor,
                      fontFamily: 'Lato',
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
                    children: <InlineSpan>[
                      TextSpan(
                        text: ' Analytics',
                        style: TextStyle(
                            color: AppColors.pivotPayColorGreen,
                            fontFamily: 'Lato'),
                      )
                    ],
                  ),
                ),
                VSpace.sm,
                Container(
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  margin: const EdgeInsets.only(
                      left: 10, right: 10, top: 20, bottom: 10),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.black, width: 0.2),
                    borderRadius: const BorderRadius.all(
                      Radius.circular(10.0),
                    ),
                  ),
                  child: Column(
                    children: [
                      VSpace.md,
                      ElevatedButton(
                        onPressed: () {
                          datePickerDialog(context);
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size.zero,
                          padding: const EdgeInsets.fromLTRB(
                              20, 10, 20, 10), // Set padding
                        ),
                        child: MediumText(
                          currentMonth,
                          color: Colors.white,
                        ),
                      ),
                      VSpace.md,
                      shimmer
                          ? Shimmer.fromColors(
                              enabled: shimmer,
                              baseColor:
                                  AppColors.pivotPayColorGreen.withOpacity(0.3),
                              highlightColor:
                                  AppColors.pivotPayColorGreen.withOpacity(0.1),
                              child: ListView.builder(
                                itemCount: 10,
                                shrinkWrap: true,
                                itemBuilder: (context, index) {
                                  return Container(
                                    height: 100,
                                    margin: EdgeInsets.only(bottom: Insets.md),
                                    padding: EdgeInsets.all(Insets.md),
                                    decoration: const BoxDecoration(
                                      borderRadius: Corners.lgBorder,
                                      color: Color(0xFFFAFAFA),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              height: 24,
                                              width: 24,
                                              padding: const EdgeInsets.all(3),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF21BC22)
                                                    .withOpacity(0.08),
                                                borderRadius: Corners.lgBorder,
                                              ),
                                              child: const Icon(
                                                PhosphorIcons.arrowDownLeft,
                                                size: 18,
                                                color: Color(0xFF21BC22),
                                              ),
                                            ),
                                            HSpace.sm,
                                            Expanded(
                                              child: Text(
                                                '',
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyles.h3.copyWith(
                                                    color:
                                                        AppColors.primaryColor),
                                              ),
                                            ),
                                            const MediumText(
                                              '',
                                              color: Color(0xFF21BC22),
                                            )
                                          ],
                                        ),
                                        VSpace.xs,
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 32),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  '',
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                      color: AppColors
                                                          .primaryColor),
                                                ),
                                              ),
                                              HSpace.sm,
                                              const SmallText('')
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  );
                                },
                              ),
                            )
                          : transactions.isEmpty
                              ? Center(
                                  child: Column(
                                    children: [
                                      MediumText(
                                          'There are no Transactions for the period of $startDate to $endDate'),
                                      VSpace.lg
                                    ],
                                  ),
                                )
                              : ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: transactions.length,
                                  itemBuilder: (context, index) {
                                    return TransactionWidget(
                                      from:
                                          '${transactions.elementAt(index).fromAccount} ${transactions.elementAt(index).senderName}',
                                      transRef: transactions
                                          .elementAt(index)
                                          .appReference,
                                      transType: transactions
                                          .elementAt(index)
                                          .serviceName,
                                      payee: transactions
                                          .elementAt(index)
                                          .toAccount,
                                      desc: transactions
                                          .elementAt(index)
                                          .narration,
                                      date: transactions
                                          .elementAt(index)
                                          .processedDate,
                                      amount: transactions
                                          .elementAt(index)
                                          .fromAmount,
                                      accountNumber: accountNumber!,
                                      accountName: transactions
                                          .elementAt(index)
                                          .recipientName,
                                      currency: transactions
                                          .elementAt(index)
                                          .fromCurrency,
                                      umemeToken: transactions
                                          .elementAt(index)
                                          .addendum1,
                                      units:
                                          transactions.elementAt(index).units,
                                      transactionCharge: transactions
                                          .elementAt(index)
                                          .billerCharge,
                                      bankRef: transactions
                                          .elementAt(index)
                                          .addendum2,
                                      utilityRcptNo: transactions
                                          .elementAt(index)
                                          .recipietNo,
                                      status: transactions
                                          .elementAt(index)
                                          .tranStatus,
                                      alertType: transactions
                                          .elementAt(index)
                                          .serviceAction,
                                    );
                                  },
                                )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
