import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:pivotpay/components/inputs/textfield.dart';
import 'package:pivotpay/components/others/image.dart';
import 'package:pivotpay/components/others/spacers.dart';
import 'package:pivotpay/components/others/text.dart';
import 'package:pivotpay/database/helper.dart';
import 'package:pivotpay/models/bills.dart';
import 'package:pivotpay/send/bank/bank_details.dart';
import 'package:pivotpay/utils/apis.dart';
import 'package:pivotpay/utils/base_page.dart';
import 'package:pivotpay/utils/resources.dart';
import 'package:pivotpay/utils/routing.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';
import 'package:shimmer/shimmer.dart';

class BanksPage extends BasePage {
  String? serviceDescription;
  BanksPage({this.serviceDescription});

  @override
  State<BanksPage> createState() => _BanksPageState();
}

class _BanksPageState extends BaseState<BanksPage> with BasicPage {
  bool isSearch = false;
  List<Bills> banks = [];
  List<Bills> filteredBanks = [];
  final TextEditingController _searchController = TextEditingController();
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () async {
      DatabaseHandler()
          .activeBill(GlobalConfiguration().getValue('bankBillerCode'))
          .then(
        (value) {
          setState(
            () {
              banks = value;
            },
          );
        },
      );
    });

    _searchController.addListener(() {
      if (_searchController.text.isNotEmpty) {
        setState(() {
          isSearch = true;
          filteredBanks = banks
              .where((element) => element.billerName!
                  .toLowerCase()
                  .contains(_searchController.text.toLowerCase()))
              .toList();
        });
      } else {
        setState(() {
          isSearch = false;
        });
      }
    });
  }

  @override
  Widget rootWidget(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: const MediumText(
          'Select a Bank',
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
          const VSpace(10),
          Container(
            margin: const EdgeInsets.only(left: 20, right: 20),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.black, width: 0.1),
              color: AppColors.white,
              borderRadius: const BorderRadius.all(
                Radius.circular(10.0),
              ),
            ),
            child: TextInputField(
              hintText: 'Search here',
              prefixIcon: IconButton(
                onPressed: () {},
                icon: Icon(Icons.search, color: AppColors.pivotPayColorGreen),
              ),
              onSaved: (value) {},
              controller: _searchController,
              validator: (value) {
                return null;
              },
            ),
          ),
          VSpace.xs,
          banks.isEmpty
              ? Expanded(
                  child: Shimmer.fromColors(
                    baseColor: AppColors.pivotPayColorGreen.withOpacity(0.3),
                    highlightColor:
                        AppColors.pivotPayColorGreen.withOpacity(0.1),
                    child: Container(
                      margin: const EdgeInsets.all(15),
                      child: ResponsiveGridList(
                        horizontalGridMargin: 10,
                        horizontalGridSpacing: 0,
                        verticalGridSpacing: 0,
                        listViewBuilderOptions: ListViewBuilderOptions(),
                        shrinkWrap: true,
                        minItemWidth: 100,
                        minItemsPerRow: 3,
                        maxItemsPerRow: 5,
                        children: List.generate(
                            18,
                            (index) => Card(
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
                                            height: 80,
                                            width: 80,
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
                                            padding: const EdgeInsets.all(10),
                                          )),
                                      const Padding(
                                        padding: EdgeInsets.only(
                                            left: 5,
                                            right: 5,
                                            top: 8,
                                            bottom: 10),
                                        child: Text(
                                          'Bank Name',
                                          textAlign: TextAlign.center,
                                          maxLines: 2,
                                          style: TextStyle(
                                              fontSize: 9,
                                              fontFamily: 'WorkSans',
                                              overflow: TextOverflow.ellipsis),
                                        ),
                                      ),
                                    ],
                                  ),
                                )),
                      ),
                    ),
                  ),
                )
              : Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(left: 5, right: 5),
                    child: ResponsiveGridList(
                      horizontalGridMargin: 10,
                      horizontalGridSpacing: 0,
                      verticalGridSpacing: 0,
                      listViewBuilderOptions: ListViewBuilderOptions(),
                      shrinkWrap: true,
                      minItemWidth: 100,
                      minItemsPerRow: 3,
                      maxItemsPerRow: 5,
                      children: List.generate(
                        isSearch ? filteredBanks.length : banks.length,
                        (index) => GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              PageRouter.fadeScale(
                                () => isSearch
                                    ? BankRecipientPage(
                                        filteredBanks
                                            .elementAt(index)
                                            .billerId
                                            .toString(),
                                        filteredBanks
                                            .elementAt(index)
                                            .billerCategory,
                                        filteredBanks
                                            .elementAt(index)
                                            .billerName,
                                        filteredBanks
                                            .elementAt(index)
                                            .billerLogo,
                                        widget.serviceDescription)
                                    : BankRecipientPage(
                                        banks
                                            .elementAt(index)
                                            .billerId
                                            .toString(),
                                        banks.elementAt(index).billerCategory,
                                        banks.elementAt(index).billerName,
                                        banks.elementAt(index).billerLogo,
                                        widget.serviceDescription),
                              ),
                            );
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
                                      height: 80,
                                      width: 80,
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
                                        // borderRadius: Corners.lgBorder,
                                        image: DecorationImage(
                                          image: Image.network(
                                            isSearch
                                                ? billsImgUrl +
                                                    filteredBanks
                                                        .elementAt(index)
                                                        .billerLogo
                                                : billsImgUrl +
                                                    banks
                                                        .elementAt(index)
                                                        .billerLogo,
                                          ).image,
                                        ),
                                      ),
                                      padding: const EdgeInsets.all(10),
                                    )),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 5, right: 5, top: 8, bottom: 10),
                                  child: Text(
                                    isSearch
                                        ? filteredBanks
                                            .elementAt(index)
                                            .billerName!
                                        : banks.elementAt(index).billerName!,
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    style: const TextStyle(
                                        fontSize: 9,
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
                  ),
                ),
        ],
      ),
      backgroundColor: AppColors.black.withOpacity(0.04),
    );
  }
}
