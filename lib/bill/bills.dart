import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:pivotpay/bill/bills_packages.dart';
import 'package:pivotpay/bill/electricity_details.dart';
import 'package:pivotpay/bill/water_details.dart';
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

class BillsPage extends BasePage {
  String? serviceDescription;

  BillsPage({this.serviceDescription});

  @override
  State<BillsPage> createState() => _BillsPageState();
}

class _BillsPageState extends BaseState<BillsPage> with BasicPage {
  bool isSearch = false;
  List<ConfigBills> configBillsList = [];
  List<BillCategory> billCategoryList = [];
  @override
  void initState() {
    super.initState();
    configBillsList =
        ConfigBillsList.fromJson(GlobalConfiguration().get('bills'))
            .configBillsList!;
    billCategoryList =
        BillCategoryList.fromJson(GlobalConfiguration().get('billCategories'))
            .billCategoryList!;
  }

  @override
  Widget rootWidget(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: const MediumText(
          'Bill Categories',
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
      body: Column(
        children: [
          VSpace.md,
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: billCategoryList.length,
              itemBuilder: (BuildContext context, int categoryIndex) {
                return Container(
                  margin: const EdgeInsets.only(
                      left: 10, right: 10, top: 10, bottom: 10),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.black, width: 0.1),
                    color: AppColors.black.withOpacity(0.05),
                    borderRadius: const BorderRadius.all(
                      Radius.circular(10.0),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      VSpace.sm,
                      Container(
                        padding: const EdgeInsets.fromLTRB(10, 0, 10, 5),
                        margin: const EdgeInsets.only(left: 20),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor,
                          borderRadius: const BorderRadius.all(
                            Radius.circular(10.0),
                          ),
                        ),
                        child: MediumText(
                          billCategoryList.elementAt(categoryIndex).billName!,
                          font: 'Lato',
                          color: AppColors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      VSpace.xs,
                      ResponsiveGridList(
                        horizontalGridMargin: 10,
                        horizontalGridSpacing: 0,
                        verticalGridSpacing: 0,
                        listViewBuilderOptions: ListViewBuilderOptions(
                          physics: const NeverScrollableScrollPhysics(),
                        ),
                        shrinkWrap: true,
                        minItemWidth: 100,
                        minItemsPerRow: 3,
                        maxItemsPerRow: 5,
                        children: List.generate(
                          configBillsList
                              .where((element) =>
                                  element.billCategory ==
                                  billCategoryList
                                      .elementAt(categoryIndex)
                                      .billId)
                              .length,
                          (index) => GestureDetector(
                            onTap: () {
                              switch (configBillsList
                                  .where((element) =>
                                      element.billCategory ==
                                      billCategoryList
                                          .elementAt(categoryIndex)
                                          .billId)
                                  .elementAt(index)
                                  .billCategory) {
                                case '1':
                                  DatabaseHandler()
                                      .activeBill(configBillsList
                                          .where((element) =>
                                              element.billCategory ==
                                              billCategoryList
                                                  .elementAt(categoryIndex)
                                                  .billId)
                                          .elementAt(index)
                                          .billerCode!)
                                      .then(
                                    (value) {
                                      Navigator.push(
                                        context,
                                        PageRouter.fadeScale(
                                          () => WaterRecipientPage(
                                            billerLogo: configBillsList
                                                .where((element) =>
                                                    element.billCategory ==
                                                    billCategoryList
                                                        .elementAt(
                                                            categoryIndex)
                                                        .billId)
                                                .elementAt(index)
                                                .billerLogo,
                                            billerName: configBillsList
                                                .where((element) =>
                                                    element.billCategory ==
                                                    billCategoryList
                                                        .elementAt(
                                                            categoryIndex)
                                                        .billId)
                                                .elementAt(index)
                                                .billerName,
                                            billerCode: configBillsList
                                                .where((element) =>
                                                    element.billCategory ==
                                                    billCategoryList
                                                        .elementAt(
                                                            categoryIndex)
                                                        .billId)
                                                .elementAt(index)
                                                .billerCode,
                                            waterLocations: value,
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                  break;
                                case '2':
                                  if (configBillsList
                                          .where((element) =>
                                              element.billCategory ==
                                              billCategoryList
                                                  .elementAt(categoryIndex)
                                                  .billId)
                                          .elementAt(index)
                                          .billerCode ==
                                      '2') {
                                    showComingSoonDialog(context);
                                  } else {
                                    Navigator.push(
                                      context,
                                      PageRouter.fadeScale(
                                        () => BillPackagesPage(
                                          billerLogo: configBillsList
                                              .where((element) =>
                                                  element.billCategory ==
                                                  billCategoryList
                                                      .elementAt(categoryIndex)
                                                      .billId)
                                              .elementAt(index)
                                              .billerLogo,
                                          billerName: configBillsList
                                              .where((element) =>
                                                  element.billCategory ==
                                                  billCategoryList
                                                      .elementAt(categoryIndex)
                                                      .billId)
                                              .elementAt(index)
                                              .billerName,
                                          billerCode: configBillsList
                                              .where((element) =>
                                                  element.billCategory ==
                                                  billCategoryList
                                                      .elementAt(categoryIndex)
                                                      .billId)
                                              .elementAt(index)
                                              .billerCode,
                                        ),
                                      ),
                                    );
                                  }
                                  break;
                                case '3':
                                  Navigator.push(
                                    context,
                                    PageRouter.fadeScale(
                                      () => ElectricityRecipientPage(
                                        billerLogo: configBillsList
                                            .where((element) =>
                                                element.billCategory ==
                                                billCategoryList
                                                    .elementAt(categoryIndex)
                                                    .billId)
                                            .elementAt(index)
                                            .billerLogo,
                                        billerName: configBillsList
                                            .where((element) =>
                                                element.billCategory ==
                                                billCategoryList
                                                    .elementAt(categoryIndex)
                                                    .billId)
                                            .elementAt(index)
                                            .billerName,
                                        billerCode: configBillsList
                                            .where((element) =>
                                                element.billCategory ==
                                                billCategoryList
                                                    .elementAt(categoryIndex)
                                                    .billId)
                                            .elementAt(index)
                                            .billerCode,
                                      ),
                                    ),
                                  );
                                  break;
                                default:
                              }
                            },
                            child: Card(
                              elevation: 10,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4.0),
                              ),
                              margin: const EdgeInsets.all(10),
                              child: Column(
                                //crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Padding(
                                      padding: const EdgeInsets.only(
                                          top: 8, right: 5, left: 5),
                                      child: Container(
                                        height: 60,
                                        width: 60,
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
                                          // borderRadius: Corners.lgBorder,
                                          image: DecorationImage(
                                            image: Image.asset(
                                              'assets/images/${configBillsList.where((element) => element.billCategory == billCategoryList.elementAt(categoryIndex).billId).elementAt(index).billerLogo!}',
                                            ).image,
                                          ),
                                        ),
                                        padding: const EdgeInsets.all(10),
                                      )),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 5, right: 5, top: 8, bottom: 10),
                                    child: Text(
                                      configBillsList
                                          .where((element) =>
                                              element.billCategory ==
                                              billCategoryList
                                                  .elementAt(categoryIndex)
                                                  .billId)
                                          .elementAt(index)
                                          .billerName!,
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      style: const TextStyle(
                                          fontSize: 12,
                                          fontFamily: 'WorkSans',
                                          overflow: TextOverflow.ellipsis),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
