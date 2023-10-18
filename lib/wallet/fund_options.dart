import 'package:flutter/material.dart';
import 'package:pivotpay/components/others/buttons.dart';
import 'package:pivotpay/components/others/image.dart';
import 'package:pivotpay/components/others/spacers.dart';
import 'package:pivotpay/components/others/text.dart';
import 'package:pivotpay/utils/base_page.dart';
import 'package:pivotpay/utils/resources.dart';
import 'package:pivotpay/utils/routing.dart';
import 'package:pivotpay/utils/style.dart';
import 'package:pivotpay/wallet/fund_card.dart';
import 'package:pivotpay/wallet/fund_details.dart';

class FundOptionsPage extends BasePage {
  const FundOptionsPage({super.key});

  @override
  _FundOptionsPageState createState() => _FundOptionsPageState();
}

class _FundOptionsPageState extends BaseState<FundOptionsPage> with BasicPage {
  int selectedId = 0;
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            VSpace.md,
            Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: Insets.lg, vertical: 10),
              child: Align(
                child: Text.rich(
                  TextSpan(
                      text: 'How would you like',
                      style: TextStyle(
                        color: AppColors.primaryColor,
                        fontFamily: 'Lato',
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                      ),
                      children: <InlineSpan>[
                        TextSpan(
                          text: ' to add funds ?',
                          style: TextStyle(
                              color: AppColors.pivotPayColorGreen,
                              fontFamily: 'Lato'),
                        )
                      ]),
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(
                  left: 20, right: 20, top: 20, bottom: 10),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.black, width: 0.2),
                borderRadius: const BorderRadius.all(
                  Radius.circular(10.0),
                ),
              ),
              child: Column(
                children: [
                  VSpace.md,
                  InAppImage(
                    AppImages.addFunds,
                    height: 100,
                  ),
                  VSpace.md,
                  ...fundMethods
                      .map(
                        (e) => FundMethodItem(
                          method: e,
                          selected: e.id == selectedId,
                          onSelect: (id) => setState(() {
                            selectedId = id;
                          }),
                        ),
                      )
                      .toList(),
                  VSpace.md,
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: Insets.lg),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              minimumSize: Size.zero,
                              backgroundColor: AppColors.black.withOpacity(0.1),
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
                              Widget next;
                              switch (selectedId) {
                                case 0:
                                  next = FundWalletDetailsPage(selectedId);
                                  break;
                                default:
                                  next = FundCardDetailsPage(selectedId);
                              }
                              Navigator.push(
                                context,
                                PageRouter.fadeThrough(() => next),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  VSpace.lg
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(1),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(25),
                    margin: const EdgeInsets.fromLTRB(15, 15, 15, 0),
                    decoration: BoxDecoration(
                        color: AppColors.peachColor,
                        borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(15),
                            topLeft: Radius.circular(15))),
                    child: Row(
                      children: [
                        InAppImage(
                          AppIcons.cashbackOffers,
                          height: 20,
                        ),
                        const HSpace(10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            MediumText('Cashback & Offers'),
                            SmallText(
                              'View your scratch card points and offers',
                              size: 10,
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                  Visibility(
                    visible: false,
                    child: Container(
                      padding: const EdgeInsets.all(25),
                      margin: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                      decoration: BoxDecoration(
                        color: AppColors.lightBlue,
                      ),
                      child: Row(
                        children: [
                          InAppImage(
                            AppIcons.referEarn,
                            height: 20,
                          ),
                          const HSpace(10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              MediumText('Refer & Earn'),
                              SmallText(
                                'Refer a friend and earn on their 1st transaction',
                                size: 10,
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(25),
                    margin: const EdgeInsets.fromLTRB(15, 0, 15, 15),
                    decoration: BoxDecoration(
                        color: AppColors.lightViolet,
                        borderRadius: const BorderRadius.only(
                            bottomRight: Radius.circular(15),
                            bottomLeft: Radius.circular(15))),
                    child: Row(
                      children: [
                        InAppImage(
                          AppIcons.helpSupport,
                          height: 20,
                        ),
                        const HSpace(10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            MediumText('24/7 Help & Support'),
                            SmallText(
                              'Get quick support for your issues',
                              size: 10,
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FundMethodItem extends StatelessWidget {
  final FundMethod? method;
  final bool? selected;
  final Function(int)? onSelect;

  const FundMethodItem({
    super.key,
    this.method,
    this.onSelect,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onSelect!(method!.id!),
      child: Container(
        margin: EdgeInsets.symmetric(
            horizontal: Insets.lg, vertical: Insets.sm + 3),
        padding:
            EdgeInsets.symmetric(horizontal: Insets.md, vertical: Insets.md),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected!
                ? AppColors.pivotPayColorGreen
                : const Color(0xFFC8C4C5),
          ),
          color: Colors.white,
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(selected! ? 5 : 1),
              height: 20,
              width: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected!
                    ? AppColors.primaryColor
                    : const Color(0xFFC8C4C5),
              ),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            HSpace.md,
            SmallText(
              method!.name!,
              size: FontSizes.s16,
            )
          ],
        ),
      ),
    );
  }
}

final fundMethods = [
  FundMethod(name: 'Mobile money', id: 0),
  FundMethod(name: 'Debit / Credit card', id: 1),
];

class FundMethod {
  String? name;
  int? id;
  FundMethod({this.name, this.id});
}
