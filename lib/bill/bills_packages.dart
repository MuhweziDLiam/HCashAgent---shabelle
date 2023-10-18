import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:pivotpay/bill/bills_packages.dart';
import 'package:pivotpay/bill/tv_details.dart';
import 'package:pivotpay/components/inputs/textfield.dart';
import 'package:pivotpay/components/others/image.dart';
import 'package:pivotpay/components/others/spacers.dart';
import 'package:pivotpay/components/others/text.dart';
import 'package:pivotpay/database/helper.dart';
import 'package:pivotpay/functions/shared_modules.dart';
import 'package:pivotpay/models/bills.dart';
import 'package:pivotpay/send/bank/bank_details.dart';
import 'package:pivotpay/utils/apis.dart';
import 'package:pivotpay/utils/base_page.dart';
import 'package:pivotpay/utils/resources.dart';
import 'package:pivotpay/utils/routing.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';
import 'package:shimmer/shimmer.dart';

class BillPackagesPage extends BasePage {
  String? billerLogo, billerName, billerCode;

  BillPackagesPage({this.billerLogo, this.billerCode, this.billerName});

  @override
  State<BillPackagesPage> createState() => _BillPackagesPageState();
}

class _BillPackagesPageState extends BaseState<BillPackagesPage>
    with BasicPage {
  bool isSearch = false;
  List<Bills> configBillsList = [];
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () async {
      DatabaseHandler()
          .activeBillSplit(widget.billerCode!, widget.billerName!)
          .then(
        (value) {
          setState(
            () {
              configBillsList = value;
            },
          );
        },
      );
    });
  }

  @override
  Widget rootWidget(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: MediumText(
          'Select a ${widget.billerName!} Package',
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
      body: Column(
        children: [
          VSpace.md,
          configBillsList.isEmpty
              ? Expanded(
                  child: Shimmer.fromColors(
                      baseColor: AppColors.pivotPayColorGreen.withOpacity(0.3),
                      highlightColor:
                          AppColors.pivotPayColorGreen.withOpacity(0.1),
                      child: Container(
                        margin: const EdgeInsets.only(left: 5, right: 5),
                        child: ListView.builder(
                          itemCount: 10,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            return Container(
                              padding: const EdgeInsets.all(8),
                              margin: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color: AppColors.black, width: 0.05),
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(15.0),
                                  ),
                                  color: AppColors.white),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        height: 40,
                                        width: 40,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                                color: Colors.grey
                                                    .withOpacity(0.5),
                                                offset: const Offset(0, 4),
                                                blurRadius: 1,
                                                spreadRadius: 1)
                                          ],
                                        ),
                                      ),
                                      HSpace.sm,
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: const [
                                          Text(
                                            'Package Name',
                                            maxLines: 2,
                                            style: TextStyle(
                                                fontSize: 12,
                                                fontFamily: 'WorkSans',
                                                overflow:
                                                    TextOverflow.ellipsis),
                                          ),
                                          Text(
                                            'Package Amount',
                                            maxLines: 2,
                                            style: TextStyle(
                                                fontSize: 9,
                                                fontFamily: 'WorkSans',
                                                overflow:
                                                    TextOverflow.ellipsis),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  IconButton(
                                      onPressed: () {},
                                      icon: const Icon(
                                        Icons.arrow_right_outlined,
                                        size: 20,
                                      ))
                                ],
                              ),
                            );
                          },
                        ),
                      )),
                )
              : Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(left: 5, right: 5),
                    child: ListView.builder(
                      itemCount: configBillsList.length,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              PageRouter.fadeScale(
                                () => TvRecipientPage(
                                  billerCode:
                                      configBillsList.elementAt(index).billerId,
                                  billerLogo: widget.billerLogo,
                                  billerName: widget.billerName,
                                  billerAmount: configBillsList
                                      .elementAt(index)
                                      .billerAmount!,
                                  packageName: configBillsList
                                      .elementAt(index)
                                      .billerName,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            margin: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color: AppColors.black, width: 0.05),
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(15.0),
                                ),
                                color: AppColors.white),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      height: 40,
                                      width: 40,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                              color:
                                                  Colors.grey.withOpacity(0.5),
                                              offset: const Offset(0, 4),
                                              blurRadius: 1,
                                              spreadRadius: 1)
                                        ],
                                        image: DecorationImage(
                                          image: Image.asset(
                                            'assets/images/${widget.billerLogo!}',
                                          ).image,
                                        ),
                                      ),
                                    ),
                                    HSpace.sm,
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          configBillsList
                                              .elementAt(index)
                                              .billerName!,
                                          maxLines: 2,
                                          style: const TextStyle(
                                              fontSize: 12,
                                              fontFamily: 'WorkSans',
                                              overflow: TextOverflow.ellipsis),
                                        ),
                                        Text(
                                          formatNumber(int.parse(configBillsList
                                              .elementAt(index)
                                              .billerAmount!)),
                                          maxLines: 2,
                                          style: const TextStyle(
                                              fontSize: 9,
                                              fontFamily: 'WorkSans',
                                              overflow: TextOverflow.ellipsis),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                IconButton(
                                    onPressed: () {},
                                    icon: const Icon(
                                      Icons.arrow_right_outlined,
                                      size: 20,
                                    ))
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
        ],
      ),
      backgroundColor: AppColors.white.withOpacity(0.9),
    );
  }
}
