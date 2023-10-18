import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:pivotpay/components/others/image.dart';
import 'package:pivotpay/components/others/spacers.dart';
import 'package:pivotpay/components/others/text.dart';
import 'package:pivotpay/models/services.dart';
import 'package:pivotpay/send/bank/banks.dart';
import 'package:pivotpay/send/mobile/mobile_networks.dart';
import 'package:pivotpay/send/wallet/wallet_card.dart';
import 'package:pivotpay/send/wallet/wallet_details.dart';
import 'package:pivotpay/utils/base_page.dart';
import 'package:pivotpay/utils/resources.dart';
import 'package:pivotpay/utils/routing.dart';
import 'package:pivotpay/utils/style.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';

class SendOptionsPage extends BasePage {
  const SendOptionsPage({super.key});

  @override
  State<SendOptionsPage> createState() => _SendOptionsPageState();
}

class _SendOptionsPageState extends BaseState<SendOptionsPage> with BasicPage {
  List<Service> sendMoneyServices = [];
  @override
  void initState() {
    super.initState();
    sendMoneyServices =
        ServiceList.fromJson(GlobalConfiguration().get('services'))
            .serviceList!;
  }

  @override
  Widget rootWidget(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: const MediumText(
          'Deposit Options',
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
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 20, bottom: 10),
            child: Text.rich(
              TextSpan(
                text: 'Select the option',
                style: TextStyle(
                  color: AppColors.primaryColor,
                  fontFamily: 'Lato',
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
                children: <InlineSpan>[
                  TextSpan(
                    text: ' you want to perform!',
                    style: TextStyle(
                      color: AppColors.pivotPayColorGreen,
                    ),
                  )
                ],
              ),
            ),
          ),
          VSpace.xs,
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(5),
              child: ResponsiveGridList(
                horizontalGridMargin: 10,
                horizontalGridSpacing: 0,
                verticalGridSpacing: 0,
                shrinkWrap: true,
                minItemWidth: 200,
                minItemsPerRow: 2,
                maxItemsPerRow: 3,
                children: List.generate(
                  sendMoneyServices.length,
                  (index) => Card(
                    elevation: 10,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                    margin: const EdgeInsets.all(10),
                    child: Column(
                      children: [
                        Column(
                          //crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: 5, right: 5, left: 5),
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                child: InAppImage(
                                  'assets/images/${sendMoneyServices.elementAt(index).serviceImg!}',
                                  height: 100,
                                ),
                              ),
                            ),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 10, right: 10, top: 8),
                                child: SmallText(
                                  sendMoneyServices
                                      .elementAt(index)
                                      .serviceName!,
                                  size: FontSizes.s12,
                                  font: 'Lato',
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 10,
                                right: 10,
                                bottom: 5,
                                top: 8,
                              ),
                              child: SmallText(
                                sendMoneyServices
                                    .elementAt(index)
                                    .serviceDescription!,
                                size: FontSizes.s10,
                              ),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                backgroundColor: AppColors.pivotPayColorGreen,
                                minimumSize: Size.zero,
                                padding:
                                    const EdgeInsets.fromLTRB(30, 5, 30, 5),
                              ),
                              child: const SmallText(
                                'Proceed',
                                color: AppColors.white,
                              ),
                              onPressed: () {
                                switch (sendMoneyServices
                                    .elementAt(index)
                                    .serviceCode) {
                                  case 'CASH_IN':
                                    Navigator.push(
                                      context,
                                      PageRouter.fadeThrough(
                                        () => WalletRecipientPage(
                                          serviceName: sendMoneyServices
                                              .elementAt(index)
                                              .serviceCode,
                                          paymentNetwork: 'AGENT WALLET',
                                          serviceDescription: sendMoneyServices
                                              .elementAt(index)
                                              .serviceName,
                                        ),
                                      ),
                                    );
                                    break;
                                  case 'WALLET_TO_MOBILEMONEY':
                                    Navigator.push(
                                      context,
                                      PageRouter.fadeThrough(() =>
                                          MobileNetworkPage(
                                              serviceDescription:
                                                  sendMoneyServices
                                                      .elementAt(index)
                                                      .serviceName)),
                                    );
                                    break;
                                  case 'CARD_TO_WALLET':
                                    Navigator.push(
                                      context,
                                      PageRouter.fadeThrough(
                                          () => WalletCardPage(
                                                serviceDescription:
                                                    sendMoneyServices
                                                        .elementAt(index)
                                                        .serviceName,
                                              )),
                                    );
                                    break;
                                  case 'MOMO_TO_WALLET':
                                    Navigator.push(
                                      context,
                                      PageRouter.fadeThrough(
                                        () => WalletRecipientPage(
                                          serviceName: sendMoneyServices
                                              .elementAt(index)
                                              .serviceCode,
                                          paymentNetwork: 'MOBILE MONEY',
                                          serviceDescription: sendMoneyServices
                                              .elementAt(index)
                                              .serviceName,
                                        ),
                                      ),
                                    );
                                    break;
                                  case 'BANK_TRANSFERS':
                                    Navigator.push(
                                      context,
                                      PageRouter.fadeThrough(() => BanksPage(
                                            serviceDescription:
                                                sendMoneyServices
                                                    .elementAt(index)
                                                    .serviceName,
                                          )),
                                    );
                                    break;
                                  default:
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
