import 'package:flutter/material.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:intl/intl.dart';
import 'package:pivotpay/components/inputs/textfield.dart';
import 'package:pivotpay/components/others/image.dart';
import 'package:pivotpay/components/others/spacers.dart';
import 'package:pivotpay/components/others/text.dart';
import 'package:pivotpay/loan/bbb_payment.dart';
import 'package:pivotpay/loan/pivot_school_loan.dart';
import 'package:pivotpay/models/providers.dart';
import 'package:pivotpay/utils/resources.dart';
import 'package:pivotpay/utils/routing.dart';
import 'package:pivotpay/utils/style.dart';

class LoanStagingPage extends StatefulWidget {
  const LoanStagingPage({super.key});

  @override
  _LoanStagingPageState createState() => _LoanStagingPageState();
}

class _LoanStagingPageState extends State<LoanStagingPage> {
  int selectedAId = 0, selectedPId = 0;
  int? selectedOId;
  bool isVisible = false, isOthers = false, optionsVisible = true;
  String selected = '';
  String selectedLogo = '';
  final _formLoanStagingKey = GlobalKey<FormState>();
  final TextEditingController _narrationController = TextEditingController();
  List<Providers> loanProviders = [];

  @override
  void initState() {
    super.initState();
    loanProviders =
        ProvidersList.fromJson(GlobalConfiguration().get('loanProviders'))
            .providersList!;
    selectedLogo = loanProviders.first.providerLogo!;
    selected = loanProviders.first.providerName!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: const MediumText(
          'Pay Loan',
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            const VSpace(25),
            Text.rich(
              TextSpan(
                text: 'We are Almost',
                style: TextStyle(
                  color: AppColors.primaryColor,
                  fontFamily: 'Lato',
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
                children: <InlineSpan>[
                  TextSpan(
                    text: ' There!',
                    style: TextStyle(
                        color: AppColors.pivotPayColorGreen,
                        fontFamily: 'Lato'),
                  )
                ],
              ),
            ),
            VSpace.sm,
            SmallText(
              'Select the Payment Options',
              size: FontSizes.s14,
              align: TextAlign.center,
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
                children: [
                  Form(
                    key: _formLoanStagingKey,
                    child: Column(
                      children: [
                        VSpace.md,
                        Center(
                          child: InAppImage(
                            AppImages.verifyAccount,
                            height: 100,
                          ),
                        ),
                        VSpace.md,
                        DropDownTextInputField(
                          labelText: 'Select Loan Provider',
                          isOnboardingField: true,
                          validator: (value) {
                            if (value!.title == null || value.title!.isEmpty) {
                              return 'Please select the Loan Provider';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            selected = value!.title!;
                            selectedLogo = value.imgUrl!;
                          },
                          onChanged: (value) {
                            selected = value.title!;
                            selectedLogo = value.imgUrl!;
                            switch (value.value) {
                              case '2':
                                setState(() {
                                  optionsVisible = false;
                                });
                                break;
                              default:
                                setState(() {
                                  optionsVisible = true;
                                });
                            }
                          },
                          items: [
                            ...loanProviders.map(
                              (e) => DropDownItem(
                                imgUrl: 'assets/images/${e.providerLogo}',
                                title: e.providerName,
                                value: e.providerId,
                              ),
                            )
                          ],
                        ),
                        VSpace.md,
                        Visibility(
                          visible: optionsVisible,
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: SmallText(
                                'Choose payment type',
                                size: 14,
                              ),
                            ),
                          ),
                        ),
                        ...paymentTypes
                            .map(
                              (e) => Visibility(
                                visible: optionsVisible,
                                child: RadioItem(
                                  item: e,
                                  selected: e.id == selectedPId,
                                  onSelect: (id) => setState(() {
                                    selectedPId = id;
                                    if (id == 2) {
                                      isVisible = true;
                                    } else {
                                      isVisible = false;
                                    }
                                  }),
                                ),
                              ),
                            )
                            .toList(),
                        Visibility(
                          visible: isVisible,
                          child: Column(
                            children: [
                              VSpace.md,
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 10),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: SmallText(
                                    'Choose Others payment type',
                                  ),
                                ),
                              ),
                              ...otherPaymentTypes
                                  .map(
                                    (e) => RadioItem(
                                      item: e,
                                      selected: e.id == selectedOId,
                                      onSelect: (id) => setState(() {
                                        selectedOId = id;
                                        if (id == 3) {
                                          isOthers = true;
                                        } else {
                                          isOthers = false;
                                        }
                                      }),
                                    ),
                                  )
                                  .toList(),
                            ],
                          ),
                        ),
                        Visibility(
                          visible: isOthers,
                          child: Column(
                            children: [
                              VSpace.md,
                              TextInputField(
                                labelText: 'Others Narration',
                                controller: _narrationController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter the Others Narration';
                                  }
                                  return null;
                                },
                                onSaved: (value) {},
                              ),
                            ],
                          ),
                        ),
                        VSpace.lg,
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  minimumSize: Size.zero,
                                  backgroundColor:
                                      AppColors.black.withOpacity(0.1),
                                  padding: const EdgeInsets.fromLTRB(
                                    10,
                                    12,
                                    10,
                                    12,
                                  ),
                                ),
                                child: const MediumText('Cancel'),
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
                                  if (_formLoanStagingKey.currentState!
                                      .validate()) {
                                    setState(() {
                                      _formLoanStagingKey.currentState!.save();
                                    });
                                    switch (selected) {
                                      case 'Boda Boda Banja':
                                        Navigator.push(
                                          context,
                                          PageRouter.fadeThrough(
                                            () => BBBPaymentPage(
                                              providerName: selected,
                                              providerOtherPaymentType:
                                                  paymentTypes
                                                              .elementAt(
                                                                  selectedPId)
                                                              .type ==
                                                          'Other Payments'
                                                      ? otherPaymentTypes
                                                          .elementAt(
                                                              selectedOId!)
                                                          .type
                                                      : '',
                                              providerType: paymentTypes
                                                  .elementAt(selectedPId)
                                                  .type,
                                              providerNarration:
                                                  _narrationController
                                                          .text.isNotEmpty
                                                      ? _narrationController
                                                          .text
                                                      : '',
                                              providerLogo: selectedLogo,
                                            ),
                                          ),
                                        );
                                        break;
                                      default:
                                        Navigator.push(
                                          context,
                                          PageRouter.fadeScale(
                                            () => PivotSchoolLoanPage(
                                              providerLogo: selectedLogo,
                                              providerName: selected,
                                            ),
                                          ),
                                        );
                                    }
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                        VSpace.lg
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

class RadioItem extends StatelessWidget {
  final Item? item;
  final bool selected;
  final Function(int)? onSelect;
  RadioItem({this.item, this.selected = false, this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: (() => onSelect!(item!.id!)),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(3.5),
              height: 20,
              width: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected
                      ? AppColors.pivotPayColorGreen
                      : Color(0xFFC8C4C5),
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: selected ? AppColors.pivotPayColorGreen : Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            HSpace.md,
            SmallText(
              item!.type!,
              size: FontSizes.s14,
            )
          ],
        ),
      ),
    );
  }
}

final paymentTypes = [
  Item(id: 0, type: 'Weekly Payments'),
  Item(id: 1, type: 'Tax'),
  Item(id: 2, type: 'Other Payments'),
  Item(id: 3, type: 'Down Payment'),
];

final otherPaymentTypes = [
  Item(id: 0, type: 'Repossession Charges'),
  Item(id: 1, type: 'Penalty'),
  Item(id: 2, type: 'Tin'),
  Item(id: 3, type: 'Others'),
];

final accountTypes = [
  Item(id: 0, type: 'Personal'),
];

class Item {
  final String? type;
  final int? id;
  Item({this.id, this.type});
}
