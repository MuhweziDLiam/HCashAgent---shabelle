import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:pivotpay/components/others/image.dart';
import 'package:pivotpay/components/others/spacers.dart';
import 'package:pivotpay/components/others/text.dart';
import 'package:pivotpay/functions/shared_modules.dart';
import 'package:pivotpay/utils/resources.dart';
import 'package:pivotpay/utils/style.dart';

class ReceiptPage extends StatelessWidget {
  String from = '',
      to = '',
      narration = '',
      amount = '0',
      transactionType = '',
      payee = '',
      transactionRef = '',
      accountNumber = '',
      accountName = '',
      date = '',
      alertType = '',
      currency = '',
      umemeToken = '',
      units = '',
      transactionCharge = '0',
      bankRef = '',
      utilityRcptNo = '',
      status = '';

  ReceiptPage(
    this.from,
    this.to,
    this.narration,
    this.amount,
    this.transactionType,
    this.payee,
    this.transactionRef,
    this.accountNumber,
    this.accountName,
    this.date,
    this.alertType,
    this.currency,
    this.umemeToken,
    this.units,
    this.transactionCharge,
    this.bankRef,
    this.utilityRcptNo,
    this.status,
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: const MediumText(
          'E-Receipt',
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            Column(
              children: [
                const VSpace(25),
                Text.rich(
                  TextSpan(
                    text: 'Transaction details',
                    style: TextStyle(
                      color: AppColors.primaryColor,
                      fontFamily: 'Lato',
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
                    children: <InlineSpan>[
                      TextSpan(
                        text: ' - E-Summary',
                        style: TextStyle(
                            color: AppColors.pivotPayColorGreen,
                            fontWeight: FontWeight.w800,
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      VSpace.md,
                      Center(
                        child: InAppImage(
                          AppImages.receipt,
                          height: 100,
                        ),
                      ),
                      VSpace.md,
                      SizedBox(
                        height: 54,
                        child: ElevatedButton(
                          onPressed: () {},
                          clipBehavior: Clip.hardEdge,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.pivotPayColorGreen,
                            padding: EdgeInsets.zero,
                            shape: ContinuousRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Padding(
                            padding:
                                const EdgeInsets.only(left: 10.0, right: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                InAppImage(
                                  AppImages.hcaLogoColored,
                                  height: 30,
                                ),
                                HSpace.sm,
                                const MediumText(
                                  'Transaction Summary',
                                  color: AppColors.white,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      VSpace.lg,
                      ReceiptItem('Means', transactionType),
                      ReceiptItem('Date', date),
                      ReceiptItem('Account Number', payee),
                      ReceiptItem('Account Name', accountName),
                      ReceiptItem(
                        'Amount',
                        '$currency. ${formatNumber(double.parse(amount).round())}',
                      ),
                      if (umemeToken != 'null' && umemeToken.isNotEmpty)
                        ReceiptItem('Token', umemeToken),
                      if (units != 'null' && units.isNotEmpty)
                        ReceiptItem('Units', units),
                      ReceiptItem('Charge', transactionCharge),
                      if (bankRef != 'null' &&
                          bankRef.isNotEmpty &&
                          bankRef != 'authCode')
                        ReceiptItem('Bank Ref.', bankRef),
                      if (utilityRcptNo != 'null' && utilityRcptNo.isNotEmpty)
                        ReceiptItem('Utility Ref', utilityRcptNo),
                      if (narration != 'Payment Type')
                        ReceiptItem('Reason', narration),
                      ReceiptItem('Type', alertType),
                      ReceiptItem(
                        'Status',
                        status == 'INSERTED' ? 'PENDING' : status,
                      ),
                      ReceiptItem('Transaction ID/Ref', transactionRef),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ReceiptItem extends StatelessWidget {
  final String k, v;
  ReceiptItem(this.k, this.v);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: Insets.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SmallText(k),
          Flexible(
            child: SmallText(
              v,
              fontWeight: FontW.bold,
            ),
          ),
        ],
      ),
    );
  }
}
