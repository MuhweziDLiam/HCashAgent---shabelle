import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:pivotpay/components/others/spacers.dart';
import 'package:pivotpay/components/others/text.dart';
import 'package:pivotpay/functions/shared_modules.dart';
import 'package:pivotpay/transactions/receipt.dart';
import 'package:pivotpay/utils/resources.dart';
import 'package:pivotpay/utils/routing.dart';
import 'package:pivotpay/utils/style.dart';

enum TransactionType { debit, credit }

class TransactionWidget extends StatelessWidget {
  String from,
      to,
      desc,
      date,
      amount,
      transRef,
      transType,
      payee,
      accountNumber,
      accountName,
      status,
      currency,
      umemeToken,
      units,
      transactionCharge,
      bankRef,
      utilityRcptNo,
      alertType;
  final TransactionType type;

  TransactionWidget({
    this.from = '',
    this.transRef = '',
    this.transType = '',
    this.payee = '',
    this.to = '',
    this.desc = '',
    this.date = '',
    this.amount = '0',
    this.accountNumber = '',
    this.accountName = '',
    this.status = '',
    this.currency = '',
    this.umemeToken = '',
    this.units = '',
    this.transactionCharge = '0',
    this.bankRef = '',
    this.utilityRcptNo = '',
    this.alertType = '',
    this.type = TransactionType.credit,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          PageRouter.fadeThrough(
            () => ReceiptPage(
              from,
              to,
              desc,
              amount,
              transType,
              payee,
              transRef,
              accountNumber,
              accountName,
              date,
              alertType,
              currency,
              umemeToken,
              units,
              transactionCharge,
              bankRef,
              utilityRcptNo,
              status,
            ),
          ),
        );
      },
      child: Container(
        height: 100,
        margin: EdgeInsets.only(bottom: Insets.md),
        padding: EdgeInsets.all(Insets.md),
        decoration: const BoxDecoration(
          borderRadius: Corners.lgBorder,
          color: Color(0xFFFAFAFA),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (alertType == 'CREDIT') ...[
              Row(
                children: [
                  Container(
                    height: 24,
                    width: 24,
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF21BC22).withOpacity(0.08),
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
                      // '$alertType Alert',
                      transType,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style:
                          TextStyles.h3.copyWith(color: AppColors.primaryColor),
                    ),
                  ),
                  MediumText(
                    '+ $currency. ${formatNumber(int.parse(amount))}',
                    color: const Color(0xFF21BC22),
                  )
                ],
              ),
              VSpace.xs,
              Padding(
                padding: const EdgeInsets.only(left: 32),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Text(
                        "from $from\ndescription: $desc",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: AppColors.primaryColor),
                      ),
                    ),
                    HSpace.sm,
                    SmallText(date)
                  ],
                ),
              )
            ] else ...[
              Row(
                children: [
                  Container(
                    height: 24,
                    width: 24,
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: AppColors.redColor.withOpacity(0.08),
                      borderRadius: Corners.lgBorder,
                    ),
                    child: Icon(
                      PhosphorIcons.arrowUpRight,
                      size: 18,
                      color: AppColors.redColor,
                    ),
                  ),
                  HSpace.sm,
                  Expanded(
                    child: Text(
                      // '$alertType Alert',
                      transType,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style:
                          TextStyles.h3.copyWith(color: AppColors.primaryColor),
                    ),
                  ),
                  MediumText(
                    '- $currency. ${formatNumber(int.parse(amount))}',
                    color: AppColors.redColor,
                  ),
                ],
              ),
              VSpace.xs,
              Padding(
                padding: const EdgeInsets.only(left: 32),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Text(
                        "to $payee\ndescription: $desc",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: AppColors.primaryColor),
                      ),
                    ),
                    HSpace.sm,
                    SmallText(date)
                  ],
                ),
              )
            ]
          ],
        ),
      ),
    );
  }
}
