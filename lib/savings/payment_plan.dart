import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:accordion/accordion.dart';
import 'package:flutter/material.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:pivotpay/components/others/image.dart';
import 'package:pivotpay/components/others/spacers.dart';
import 'package:pivotpay/components/others/text.dart';
import 'package:pivotpay/functions/shared_modules.dart';
import 'package:pivotpay/models/packages.dart';
import 'package:pivotpay/savings/payment_details.dart';
import 'package:pivotpay/savings/pdf_screen.dart';
import 'package:pivotpay/utils/base_page.dart';
import 'package:pivotpay/utils/resources.dart';
import 'package:pivotpay/utils/routing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:flutter/services.dart';

class PaymentPlanPage extends BasePage {
  String? providerLogo,
      providerName,
      providerCode,
      packageName,
      packageAmount,
      currency,
      installmentAmount,
      providerColor;

  PaymentPlanPage({
    this.providerLogo,
    this.providerCode,
    this.providerName,
    this.providerColor,
    this.packageName,
    this.currency,
    this.installmentAmount = '0',
    this.packageAmount = '0',
  });

  @override
  State<PaymentPlanPage> createState() => _PaymentPlanPageState();
}

class _PaymentPlanPageState extends BaseState<PaymentPlanPage> with BasicPage {
  bool isSearch = false;
  bool termsAccepted = false;
  final numberRegEx = RegExp(r'\d+');
  double installmentAmount = 0.0;
  int paymentPeriods = 1;
  @override
  void initState() {
    super.initState();
    paymentPeriods = int.parse(numberRegEx
        .allMatches(PackagesList.fromJson(GlobalConfiguration().get('packages'))
            .packagesList!
            .where((element) => element.providerId == widget.providerCode)
            .first
            .paymentPlans!
            .last)
        .map((e) => e.group(0))
        .last!);
    installmentAmount = int.parse(widget.packageAmount!) / paymentPeriods;
  }

  Future<File> fromAsset(String asset, String filename) async {
    Completer<File> completer = Completer();
    try {
      var dir = await getApplicationDocumentsDirectory();
      File file = File("${dir.path}/$filename");
      var data = await rootBundle.load(asset);
      var bytes = data.buffer.asUint8List();
      await file.writeAsBytes(bytes, flush: true);
      completer.complete(file);
    } catch (e) {
      throw Exception('Error parsing asset file!');
    }
    return completer.future;
  }

  @override
  Widget rootWidget(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(int.parse(widget.providerColor!)),
        title: const MediumText(
          'Payment Plans',
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
          VSpace.sm,
          Container(
            padding: const EdgeInsets.only(top: 8, bottom: 8),
            margin: const EdgeInsets.fromLTRB(10, 10, 10, 0),
            decoration: BoxDecoration(
              color: Color(
                int.parse(widget.providerColor!),
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(
                  10.0,
                ),
                topRight: Radius.circular(
                  10.0,
                ),
              ),
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: MediumText(
                  '${widget.providerName!} Travel Agency',
                  color: AppColors.white,
                  size: 16,
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            margin: const EdgeInsets.fromLTRB(10, 0, 10, 5),
            decoration: const BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(
                  10.0,
                ),
                bottomRight: Radius.circular(
                  10.0,
                ),
              ),
            ),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Color(
                      int.parse(widget.providerColor!),
                    ),
                    borderRadius: const BorderRadius.all(
                      Radius.circular(5),
                    ),
                  ),
                  padding: const EdgeInsets.all(2),
                  margin: const EdgeInsets.only(
                    top: 5,
                    left: 15,
                    right: 15,
                    bottom: 5,
                  ),
                  child: Center(
                    child: MediumText(
                      widget.packageName!,
                      color: AppColors.white,
                      size: 14,
                    ),
                  ),
                ),
                Center(
                  child: MediumText(
                    '${widget.currency!}. ${formatNumber(int.parse(widget.packageAmount!))}',
                    fontWeight: FontWeight.w500,
                    size: 14,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(left: 5, right: 5),
              child: Accordion(
                headerBackgroundColor: AppColors.white,
                children: [
                  ...PackagesList.fromJson(
                          GlobalConfiguration().get('packages'))
                      .packagesList!
                      .where((element) =>
                          element.providerId == widget.providerCode)
                      .first
                      .paymentPlans!
                      .map(
                        (e) => AccordionSection(
                          contentBorderColor:
                              Color(int.parse(widget.providerColor!)),
                          contentBorderWidth: 0.5,
                          rightIcon: Icon(
                            Icons.arrow_drop_down_outlined,
                            color: Color(int.parse(widget.providerColor!)),
                          ),
                          headerPadding: const EdgeInsets.all(10),
                          content: ListView.builder(
                            shrinkWrap: true,
                            itemCount: int.parse(numberRegEx
                                .allMatches(e)
                                .map((e) => e.group(0))
                                .last!),
                            itemBuilder: (context, index) {
                              return Column(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    margin: const EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Color(int.parse(
                                                widget.providerColor!)),
                                            width: 0.3),
                                        borderRadius: const BorderRadius.all(
                                          Radius.circular(5.0),
                                        ),
                                        color: AppColors.white),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Month ${index + 1}',
                                          maxLines: 2,
                                          style: const TextStyle(
                                              fontSize: 12,
                                              fontFamily: 'Lato',
                                              overflow: TextOverflow.ellipsis),
                                        ),
                                        MediumText(
                                          '${widget.currency!}. ${formatNumber(int.parse((int.parse(widget.packageAmount!) / int.parse(numberRegEx.allMatches(e).map((e) => e.group(0)).last!)).round().toString()))}',
                                        )
                                      ],
                                    ),
                                  ),
                                  Visibility(
                                      visible: index ==
                                              int.parse(numberRegEx
                                                      .allMatches(e)
                                                      .map((e) => e.group(0))
                                                      .last!) -
                                                  1
                                          ? true
                                          : false,
                                      child: VSpace.xs),
                                  Visibility(
                                    visible: index ==
                                            int.parse(numberRegEx
                                                    .allMatches(e)
                                                    .map((e) => e.group(0))
                                                    .last!) -
                                                1
                                        ? true
                                        : false,
                                    child: Container(
                                      margin: const EdgeInsets.only(
                                          left: 40, right: 40),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                minimumSize: Size.zero,
                                                backgroundColor: Color(
                                                  int.parse(
                                                      widget.providerColor!),
                                                ),
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                  10,
                                                  8,
                                                  10,
                                                  8,
                                                ),
                                              ),
                                              onPressed: () {
                                                showDialog(
                                                  barrierDismissible: false,
                                                  context: context,
                                                  builder: (context) =>
                                                      StatefulBuilder(builder:
                                                          (context, setState) {
                                                    return Dialog(
                                                      insetPadding:
                                                          const EdgeInsets.all(
                                                              50),
                                                      shape:
                                                          ContinuousRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                      ),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(5),
                                                        child: Scrollbar(
                                                          child:
                                                              SingleChildScrollView(
                                                            child: Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              children: [
                                                                Column(
                                                                  children: [
                                                                    const SizedBox(
                                                                      height:
                                                                          10,
                                                                    ),
                                                                    const MediumText(
                                                                      'Terms and Conditions',
                                                                      size: 16,
                                                                      color: AppColors
                                                                          .black,
                                                                    ),
                                                                    Padding(
                                                                      padding: const EdgeInsets
                                                                              .only(
                                                                          left:
                                                                              10,
                                                                          right:
                                                                              10),
                                                                      child:
                                                                          Divider(
                                                                        color: Color(
                                                                            int.parse(widget.providerColor!)),
                                                                      ),
                                                                    ),
                                                                    Padding(
                                                                      padding:
                                                                          const EdgeInsets
                                                                              .symmetric(
                                                                        horizontal:
                                                                            4,
                                                                        vertical:
                                                                            8,
                                                                      ),
                                                                      child:
                                                                          Row(
                                                                        children: [
                                                                          Checkbox(
                                                                            value:
                                                                                termsAccepted,
                                                                            onChanged:
                                                                                (value) {
                                                                              setState(() {
                                                                                if (value == true) {
                                                                                  termsAccepted = true;
                                                                                } else {
                                                                                  termsAccepted = false;
                                                                                }
                                                                              });
                                                                            },
                                                                            activeColor:
                                                                                Color(int.parse(widget.providerColor!)),
                                                                          ),
                                                                          Expanded(
                                                                            child:
                                                                                Column(
                                                                              mainAxisSize: MainAxisSize.min,
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                              children: [
                                                                                Flexible(
                                                                                  child: Row(
                                                                                    children: [
                                                                                      Flexible(
                                                                                        child: HtmlWidget(
                                                                                          '<p>I agree to the <strong><a href="#">Terms & Conditions</a></strong> of Halal Savings.</p>',
                                                                                          textStyle: const TextStyle(
                                                                                            fontFamily: 'Lato',
                                                                                            color: AppColors.black,
                                                                                          ),
                                                                                          onTapUrl: (p0) {
                                                                                            fromAsset('assets/docs/tc.pdf', 'tc.pdf').then((f) {
                                                                                              Navigator.push(
                                                                                                context,
                                                                                                PageRouter.fadeScale(
                                                                                                  () => PDFScreen(
                                                                                                    providerColor: widget.providerColor,
                                                                                                    path: f.path,
                                                                                                  ),
                                                                                                ),
                                                                                              );
                                                                                            });
                                                                                            return true;
                                                                                          },
                                                                                        ),
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                    Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .end,
                                                                      children: [
                                                                        ElevatedButton(
                                                                          style:
                                                                              ElevatedButton.styleFrom(
                                                                            backgroundColor:
                                                                                Color(int.parse(widget.providerColor!)),
                                                                            minimumSize:
                                                                                Size.zero,
                                                                            padding:
                                                                                const EdgeInsets.fromLTRB(
                                                                              20,
                                                                              8,
                                                                              20,
                                                                              8,
                                                                            ),
                                                                          ),
                                                                          onPressed: termsAccepted
                                                                              ? () {
                                                                                  Navigator.pop(context);
                                                                                  Navigator.push(
                                                                                    context,
                                                                                    PageRouter.fadeScale(
                                                                                      () => PaymentDetailsPage(
                                                                                        providerColor: widget.providerColor,
                                                                                        providerCode: widget.providerCode,
                                                                                        providerLogo: widget.providerLogo,
                                                                                        providerName: widget.providerName,
                                                                                        packageName: widget.packageName,
                                                                                        currency: widget.currency,
                                                                                        installmentAmount: (int.parse(widget.packageAmount!) / int.parse(numberRegEx.allMatches(e).map((e) => e.group(0)).last!)).round(),
                                                                                        packageMonths: int.parse(
                                                                                          numberRegEx.allMatches(e).map((e) => e.group(0)).last!,
                                                                                        ).toString(),
                                                                                      ),
                                                                                    ),
                                                                                  );
                                                                                }
                                                                              : null,
                                                                          child:
                                                                              const MediumText(
                                                                            'Proceed',
                                                                            color:
                                                                                AppColors.white,
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  }),
                                                );
                                              },
                                              child: const MediumText(
                                                'Confirm',
                                                color: AppColors.white,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                          header: Row(
                            children: [
                              Container(
                                height: 30,
                                width: 30,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                ),
                                child: Image.asset(
                                  AppImages.hajji,
                                  color:
                                      Color(int.parse(widget.providerColor!)),
                                ),
                              ),
                              HSpace.sm,
                              Text(
                                ('${numberRegEx.allMatches(e).map((e) => e.group(0)).last!} Months'),
                                maxLines: 2,
                                style: const TextStyle(
                                    fontSize: 13,
                                    fontFamily: 'Lato',
                                    overflow: TextOverflow.ellipsis),
                              ),
                            ],
                          ),
                        ),
                      )
                ],
              ),
            ),
          ),
        ],
      ),
      backgroundColor: AppColors.white.withOpacity(0.9),
    );
  }
}
