import 'dart:async';
import 'dart:developer';

import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:fluttercontactpicker/fluttercontactpicker.dart';
import 'package:get_storage/get_storage.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pivotpay/components/inputs/textfield.dart';
import 'package:pivotpay/components/others/buttons.dart';
import 'package:pivotpay/components/others/image.dart';
import 'package:pivotpay/components/others/spacers.dart';
import 'package:pivotpay/components/others/text.dart';
import 'package:pivotpay/functions/shared_modules.dart';
import 'package:pivotpay/models/disbursment_countries.dart';
import 'package:pivotpay/models/transacting_networks.dart';
import 'package:pivotpay/network/api_service.dart';
import 'package:pivotpay/send/mobile/mobile_details.dart';
import 'package:pivotpay/send/mobile/mobile_imt.dart';
import 'package:pivotpay/utils/base_page.dart';
import 'package:pivotpay/utils/resources.dart';
import 'package:pivotpay/utils/routing.dart';
import 'package:pivotpay/utils/style.dart';
import 'package:pivotpay/validators/validators.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

class MobileNetworkPage extends BasePage {
  String? serviceDescription;
  MobileNetworkPage({super.key, this.serviceDescription});

  @override
  State<MobileNetworkPage> createState() => _MobileNetworkPageState();
}

class _MobileNetworkPageState extends BaseState<MobileNetworkPage>
    with BasicPage {
  int selectedId = 0;
  String? version,
      _prefixCode,
      selectedCountry,
      phone,
      paymentNetwork,
      countryCode;
  String accountName = '';
  bool loaded = false, validated = false;
  List<DisbursmentCountry> disbursmentCountries = [];
  final _formPhoneKey = GlobalKey<FormState>();
  Timer? _debounce;
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  bool ignoreTaps = false;
  bool isVerified = false;

  @override
  void initState() {
    super.initState();
    getInfo();
  }

  getInfo() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    countryCode = prefs.getString('countryCode');
    setState(() {
      loaded = true;
      selectedCountry = countryCode;
    });
    _prefixCode = TransactingNetworks.fromjson(
            GlobalConfiguration().get('transactingNetworks'))
        .transactingNetwork!
        .where((element) => element.countryCode == selectedCountry)
        .first
        .dailCode;
    _phoneNumberController.value = TextEditingValue(text: _prefixCode!);
    _countryController.value = TextEditingValue(
        text:
            '${TransactingNetworks.fromjson(GlobalConfiguration().get('transactingNetworks')).transactingNetwork!.where((element) => element.countryCode == selectedCountry).first.countryName!} (${TransactingNetworks.fromjson(GlobalConfiguration().get('transactingNetworks')).transactingNetwork!.where((element) => element.countryCode == selectedCountry).first.countryCode!})');
    final versionInfo = await PackageInfo.fromPlatform();
    version = '${versionInfo.version}+${versionInfo.buildNumber}';
    WidgetsBinding.instance
        .addPostFrameCallback((_) => getSupportedCountries());
  }

  getSupportedCountries() async {
    final progress = ProgressHUD.of(_formPhoneKey.currentContext!);
    progress!.showWithText('Fetching Data...');
    setState(() {
      ignoreTaps = true;
    });
    getDisbursementCountries(
      _formPhoneKey.currentContext!,
    ).then((value) async {
      if (value.status!) {
        progress.dismiss();
        setState(() {
          ignoreTaps = false;
          disbursmentCountries = value.countryList!;
        });
      } else {
        progress.dismiss();
        setState(() {
          ignoreTaps = false;
        });
        responseDialog(
          'Sorry',
          'Okay',
          value.responseMessage!,
          _formPhoneKey.currentContext!,
        );
      }
    });
  }

  @override
  Widget rootWidget(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: const MediumText(
          'Mobile Networks',
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
      body: IgnorePointer(
        ignoring: ignoreTaps,
        child: ProgressHUD(
          child: Builder(
            builder: (context) => Form(
              key: _formPhoneKey,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const VSpace(20),
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
                    Container(
                      padding: const EdgeInsets.only(left: 25, right: 25),
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
                            AppImages.networkFrame,
                            height: 100,
                          ),
                          VSpace.md,
                          TextInputField(
                            readOnly: true,
                            controller: _countryController,
                            labelText: 'Select Country',
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please Tap to select your Country / Region';
                              }
                              return null;
                            },
                            onTap: () {
                              showCountryPicker(
                                context: context,
                                countryFilter: disbursmentCountries
                                    .map((e) => e.code!)
                                    .toList(),
                                countryListTheme: CountryListThemeData(
                                  flagSize: 25,
                                  backgroundColor: Colors.white,
                                  //Optional. Sets the border radius for the bottomsheet.
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(20.0),
                                    topRight: Radius.circular(20.0),
                                  ),
                                  //Optional. Styles the search field.
                                  inputDecoration: InputDecoration(
                                    labelText: 'Search',
                                    hintText: 'Start typing to search',
                                    prefixIcon: const Icon(Icons.search),
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: const Color(0xFF8C98A8)
                                            .withOpacity(0.2),
                                      ),
                                    ),
                                  ),
                                ), // optional. Shows phone code before the country name.
                                onSelect: (Country country) {
                                  setState(() {
                                    _countryController.value = TextEditingValue(
                                        text: country.displayNameNoCountryCode);
                                    _prefixCode = country.phoneCode;
                                    selectedCountry = country.countryCode;
                                    _phoneNumberController.value =
                                        TextEditingValue(text: '+$_prefixCode');
                                  });
                                },
                              );
                            },
                            onSaved: (value) {},
                          ),
                          VSpace.md,
                          SmallText(
                            'Supported Networks',
                            size: FontSizes.s14,
                          ),
                          VSpace.sm,
                          Wrap(
                              spacing: 20,
                              runSpacing: 10,
                              children: loaded
                                  ? TransactingNetworks.fromjson(
                                          GlobalConfiguration()
                                              .get('transactingNetworks'))
                                      .transactingNetwork!
                                      .where((element) =>
                                          element.countryCode ==
                                          selectedCountry)
                                      .first
                                      .networks!
                                      .map((e) => PaymentMethodItem(
                                            img: e.img!,
                                          ))
                                      .toList()
                                  : [3]
                                      .map((e) => PaymentMethodItem(
                                            shimmer: true,
                                          ))
                                      .toList()),
                          VSpace.md,
                          TextInputField(
                            decoration: InputDecoration(
                              isDense: true,
                              prefixText: _prefixCode,
                              prefixStyle: TextStyle(
                                  backgroundColor: AppColors.primaryColor),
                            ),
                            labelText: 'Enter Recipent phone number',
                            controller: _phoneNumberController,
                            onSaved: (value) {},
                            onChanged: (value) {
                              if (selectedCountry == countryCode) {
                                phone = value;
                                if (phone!.length == 13) {
                                  if (phone!.startsWith('+')) {
                                    phone = phone!.replaceAll('+', '');
                                  }
                                  if (phone!.startsWith('0')) {
                                    phone = phone!.replaceFirst('0', '256');
                                  }
                                  _validatePhoneNumber(
                                    context,
                                  );
                                }
                              }

                              return value!;
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter the recipient phone number';
                              }
                              if (value.length < 10) {
                                return 'Invalid phone number';
                              }
                              if (!validatePhoneNumberInput(value)) {
                                return 'Invalid phone number';
                              }

                              return null;
                            },
                          ),
                          Visibility(
                            visible: validated,
                            child: VSpace.md,
                          ),
                          Visibility(
                            visible: validated,
                            child: TextInputField(
                              readOnly: true,
                              labelText: 'Recipient Name',
                              prefixIcon: Icon(
                                Icons.account_circle,
                                color: AppColors.pivotPayColorGreen,
                              ),
                              onSaved: (value) {},
                              controller: _fullNameController,
                              validator: (value) {
                                return null;
                              },
                            ),
                          ),
                          VSpace.md,
                          const MediumText(
                            ' or ',
                          ),
                          VSpace.md,
                          ThemePrimaryButton(
                            'Select from contact list',
                            textColor: AppColors.white,
                            color: AppColors.pivotPayColorGreen,
                            onTap: () {
                              final contactNumber = openContactBook();
                              contactNumber.then((value) {
                                setState(() {
                                  if (value.startsWith('0')) {
                                    value =
                                        value.replaceFirst('0', _prefixCode!);
                                  }
                                  _phoneNumberController.value =
                                      TextEditingValue(text: value);
                                  if (selectedCountry == 'UG') {
                                    phone = value;
                                    if (phone!.length == 13) {
                                      if (phone!.startsWith('+')) {
                                        phone = phone!.replaceAll('+', '');
                                      }
                                      if (phone!.startsWith('0')) {
                                        phone = phone!.replaceFirst('0', '256');
                                      }
                                      _validatePhoneNumber(
                                        context,
                                      );
                                    }
                                  }
                                });
                              });
                            },
                            child: InAppImage(
                              AppImages.phoneIcon,
                              color: AppColors.primaryColor,
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
                                    if (_formPhoneKey.currentState!
                                        .validate()) {
                                      setState(() {
                                        _formPhoneKey.currentState!.save();
                                      });
                                      if (selectedCountry == 'UG') {
                                        if (isVerified) {
                                          Navigator.push(
                                            context,
                                            PageRouter.fadeScale(
                                              () => MobileRecipientPage(
                                                phoneNumber: phone,
                                                accountName: accountName,
                                                serviceDescription:
                                                    widget.serviceDescription,
                                              ),
                                            ),
                                          );
                                        } else {
                                          responseDialog(
                                            'Sorry',
                                            'Okay',
                                            'Please verify the supplied phone number before you proceed',
                                            context,
                                          );
                                        }
                                      } else {
                                        getTransactionCurrency(
                                            selectedCountry!, context);
                                      }
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                          VSpace.lg,
                        ],
                      ),
                    ),
                    VSpace.md,
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  _validatePhoneNumber(BuildContext context) async {
    FocusManager.instance.primaryFocus?.unfocus();
    final progress = ProgressHUD.of(context);
    setState(() {
      ignoreTaps = true;
    });
    progress!.showWithText('Validating Phone Number...');
    if (phone!.startsWith('25670') ||
        phone!.startsWith('25675') ||
        phone!.startsWith('25674')) {
      paymentNetwork = 'AIRTEL';
    } else {
      paymentNetwork = 'MTN';
    }
    final getXPrefs = GetStorage();
    final Map data = {
      'accountNumber': phone,
      'accountType': 'MOMO',
      'password': 'OIZWVA6QI7',
      'appVersion': version,
      'osType': getXPrefs.read('source'),
      'checkoutMode': 'TUMIAWALLET',
      'vendorCode': 'TUMIA_APP',
      'telecom': paymentNetwork,
    };
    validatePhoneNumber(_formPhoneKey.currentContext!, data)
        .then((value) async {
      if (value.status!) {
        progress.dismiss();
        isVerified = true;
        setState(() {
          ignoreTaps = false;
          validated = true;
          accountName = value.accountName!;
          _fullNameController.value =
              TextEditingValue(text: value.accountName!);
        });
      } else {
        isVerified = false;
        progress.dismiss();
        setState(() {
          ignoreTaps = false;
        });
        responseDialog(
          'Sorry',
          'Okay',
          value.responseMessage!,
          _formPhoneKey.currentContext!,
        );
      }
    });
  }

  getTransactionCurrency(String countryCode, BuildContext context) async {
    final progress = ProgressHUD.of(context);
    setState(() {
      ignoreTaps = true;
    });
    progress!.showWithText('Processing ...');
    final Map data = {
      'countryCode': countryCode,
    };
    getCountryDetails(_formPhoneKey.currentContext!, data).then((value) async {
      if (value.status!) {
        progress.dismiss();
        setState(() {
          ignoreTaps = false;
        });
        Navigator.push(
          context,
          PageRouter.fadeScale(
            () => MobileIMTPage(
              phoneNumber: phone,
              accountName: '',
              serviceDescription: widget.serviceDescription,
              currencyCode: value.currency!,
            ),
          ),
        );
      } else {
        progress.dismiss();
        setState(() {
          ignoreTaps = false;
        });
        responseDialog(
          'Sorry',
          'Okay',
          value.responseMessage!,
          _formPhoneKey.currentContext!,
        );
      }
    });
  }

  Future<String> openContactBook() async {
    final contact = await FlutterContactPicker.pickPhoneContact();
    final phoneNumber =
        contact.phoneNumber!.number.toString().replaceAll(RegExp(r'\s+'), '');
    return phoneNumber;
  }
}

class PaymentMethodItem extends StatelessWidget {
  String img;
  bool shimmer;
  PaymentMethodItem({super.key, this.img = '', this.shimmer = false});

  @override
  Widget build(BuildContext context) {
    return shimmer
        ? Shimmer.fromColors(
            baseColor: AppColors.pivotPayColorGreen.withOpacity(0.3),
            highlightColor: AppColors.pivotPayColorGreen.withOpacity(0.1),
            child: Container(
              height: 48,
              padding: EdgeInsets.all(Insets.xs),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(9),
              ),
            ),
          )
        : Container(
            padding: EdgeInsets.all(Insets.xs),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(9),
            ),
            child: InAppImage(
              'assets/images/$img',
              height: 48,
            ),
          );
    // .onTap(() => onSelect(method.id));
  }
}
