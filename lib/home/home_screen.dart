//import 'package:carousel_slider/carousel_slider.dart';
import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:floating_bottom_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slider_drawer/flutter_slider_drawer.dart';
import 'package:get_storage/get_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:lottie/lottie.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pivotpay/beneficiaries/beneficiaries.dart';
import 'package:pivotpay/bill/bills.dart';
import 'package:pivotpay/common/pin.dart';
import 'package:pivotpay/components/others/image.dart';
import 'package:pivotpay/components/others/spacers.dart';
import 'package:pivotpay/components/others/text.dart';
import 'package:pivotpay/components/slider/slider_view.dart';
import 'package:pivotpay/database/helper.dart';
import 'package:pivotpay/functions/shared_modules.dart';
import 'package:pivotpay/loan/loan_staging.dart';
import 'package:pivotpay/login/login_screen.dart';
import 'package:pivotpay/models/app_info.dart';
import 'package:pivotpay/models/beneficiary.dart';
import 'package:pivotpay/models/bills.dart';
import 'package:pivotpay/network/api_service.dart';
import 'package:pivotpay/policy/policy.dart';
import 'package:pivotpay/profile/profile.dart';
import 'package:pivotpay/qr/qr_code.dart';
import 'package:pivotpay/rates/check_rates.dart';
import 'package:pivotpay/savings/travel_providers.dart';
import 'package:pivotpay/school/school_recipient.dart';
import 'package:pivotpay/security/security.dart';
import 'package:pivotpay/send/service_options.dart';
import 'package:pivotpay/send/wallet/agent_details.dart';
import 'package:pivotpay/send/wallet/wallet_details.dart';
import 'package:pivotpay/support/support.dart';
import 'package:pivotpay/transactions/transactions.dart';
import 'package:pivotpay/utils/apis.dart';
import 'package:pivotpay/utils/base_page.dart';
import 'package:pivotpay/utils/resources.dart' as app_color;
import 'package:pivotpay/utils/resources.dart';
import 'package:pivotpay/utils/routing.dart';
import 'package:pivotpay/utils/style.dart';
import 'package:pivotpay/wallet/fund_options.dart';
import 'package:pivotpay/withdraw/withdraw.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

final List<int> imgList = [0, 1];
final List<String> imgListAds = [
  'assets/images/banner_one.jpg',
  'assets/images/banner_two.jpg',
];

enum _SupportState {
  unknown,
  supported,
  unsupported,
}

class HomePage extends BasePage {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends BaseState<HomePage> with BasicPage {
  final GlobalKey<SliderDrawerState> _sliderDrawerKey =
      GlobalKey<SliderDrawerState>();
  String? agentName = '',
      phoneNumber = '',
      currencyCode = '',
      userName = '',
      accountBalance = '0',
      accountNumber = '',
      greeting = '';
  int _current = 0;
  bool viewBalance = false;
  bool canUseFace = false;
  final LocalAuthentication auth = LocalAuthentication();
  _SupportState _supportState = _SupportState.unknown;
  bool? _canCheckBiometrics;
  List<BiometricType>? _availableBiometrics;
  String _authorized = 'Not Authorized';
  bool _isAuthenticating = false;
  final CarouselController _controller = CarouselController();
  List<Beneficiary> beneficiariesList = [];
  final _dashboardKey = GlobalKey();
  RefreshController _refreshController = RefreshController();

  late List<Widget> cardSliders;
  DatabaseHandler? handler;
  @override
  void initState() {
    handler = DatabaseHandler();
    openApp();
    super.initState();
  }

  @override
  void dispose() {
    if (_isAuthenticating) {
      _cancelAuthentication();
    }
    //AltSmsAutofill().unregisterListener();
    super.dispose();
  }

  Future<bool> _checkBiometrics() async {
    bool canCheckBiometrics;
    try {
      canCheckBiometrics = await auth.canCheckBiometrics;
    } on PlatformException catch (e) {
      canCheckBiometrics = false;
      return false;
    }
    if (!mounted) {
      return false;
    }
    _canCheckBiometrics = canCheckBiometrics;
    return _canCheckBiometrics!;
  }

  Future<void> _getAvailableBiometrics() async {
    List<BiometricType> availableBiometrics;
    try {
      availableBiometrics = await auth.getAvailableBiometrics();
      setState(() {
        canUseFace = availableBiometrics.isEmpty
            ? false
            : availableBiometrics
                    .where((element) => element.name == 'face')
                    .isNotEmpty
                ? true
                : false;
      });
    } on PlatformException catch (e) {
      availableBiometrics = <BiometricType>[];
    }
    if (!mounted) {
      return;
    }
    _availableBiometrics = availableBiometrics;
  }

  Future<bool> _authenticate() async {
    bool authenticated = false;
    try {
      setState(() {
        _isAuthenticating = true;
        _authorized = 'Authenticating';
      });
      authenticated = await auth.authenticate(
        localizedReason: 'Determining the OS Authentication type',
        options: AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: canUseFace,
        ),
      );
      setState(() {
        _isAuthenticating = false;
      });
    } on PlatformException catch (e) {
      setState(() {
        _isAuthenticating = false;
        _authorized = 'Error - ${e.message}';
      });
      return false;
    }
    if (!mounted) {
      return false;
    }
    _authorized = authenticated ? 'Authorized' : 'Not Authorized';
    if (_authorized == 'Authorized') {
      return true;
    } else {
      return false;
    }
  }

  Future<void> _cancelAuthentication() async {
    await auth.stopAuthentication();
    setState(() => _isAuthenticating = false);
  }

  final List<Widget> imageSliders = imgListAds
      .map((item) => ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(5.0)),
          child: Stack(
            children: <Widget>[
              Image.asset(item, fit: BoxFit.cover, width: 1000.0),
              Positioned(
                bottom: 0.0,
                left: 0.0,
                right: 0.0,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color.fromARGB(200, 0, 0, 0),
                        Color.fromARGB(0, 0, 0, 0)
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                      vertical: 10.0, horizontal: 20.0),
                ),
              ),
            ],
          )))
      .toList();

  @override
  Widget rootWidget(BuildContext context) {
    return Scaffold(
      body: SliderDrawer(
        appBar: SliderAppBar(
          appBarHeight: 80,
          appBarPadding: const EdgeInsets.fromLTRB(0, 35, 15, 0),
          isTitleCenter: false,
          trailing: Row(
            children: [
              IconButton(
                onPressed: (() {}),
                icon: InAppImage(
                  AppIcons.notification,
                  height: 20,
                ),
              ),
            ],
          ),
          drawerIconColor: Colors.white,
          appBarColor: app_color.AppColors.primaryColor,
          title: const Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: EdgeInsets.only(top: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MediumText(
                    'Pull down to refresh',
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
        ),
        key: _sliderDrawerKey,
        sliderOpenSize: 200,
        slider: SliderView(
          userName: userName,
          phoneNumber: phoneNumber,
          profilePicture: '',
          onItemClick: (title) {
            _sliderDrawerKey.currentState!.closeSlider();
            switch (title) {
              case 'Beneficiaries':
                // Navigator.push(
                //   context,
                //   PageRouter.fadeScale(() => const BeneficiariesPage()),
                // );
                break;
              case 'Policy':
                fromAsset(
                        'assets/docs/privacy_policy.pdf', 'privacy_policy.pdf')
                    .then((f) {
                  Navigator.push(
                    context,
                    PageRouter.fadeScale(
                      () => PolicyPage(
                        pdfPath: f.path,
                      ),
                    ),
                  );
                });
                break;
              case 'Support':
                // Navigator.push(
                //   context,
                //   PageRouter.fadeScale(() => const SupportPage()),
                // );
                break;
              case 'History':
                Navigator.push(
                  context,
                  PageRouter.fadeScale(() => const TransactionsPage()),
                );
                break;
              case 'Security':
                Navigator.push(
                  context,
                  PageRouter.fadeScale(() => const SecurityPage()),
                );
                break;
              case 'Log out':
                showLogOutDialog();
                break;
              default:
            }
          },
        ),
        child: SmartRefresher(
          controller: _refreshController,
          onLoading: _onLoading,
          onRefresh: _onRefresh,
          key: _dashboardKey,
          header: const WaterDropHeader(),
          child: Container(
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.95)),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          MediumText(
                            '${greeting!}, ${agentName!}',
                            size: 18,
                            fontWeight: FontWeight.w600,
                            color: app_color.AppColors.primaryColor,
                          ),
                          LottieBuilder.asset(
                            AppImages.welcome,
                            width: 40,
                            height: 40,
                          ),
                        ],
                      ),
                      VSpace.xs,
                      Container(
                        padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              app_color.AppColors.pivotPayColorGreen
                                  .withOpacity(0.99),
                              app_color.AppColors.pivotPayColorGreen
                                  .withOpacity(0.98),
                              app_color.AppColors.pivotPayColorGreen
                                  .withOpacity(0.95),
                              app_color.AppColors.pivotPayColorGreen
                                  .withOpacity(0.93),
                              app_color.AppColors.pivotPayColorGreen
                                  .withOpacity(0.90),
                              app_color.AppColors.pivotPayColorGreen
                                  .withOpacity(0.85),
                            ],
                          ),
                        ),
                        child: LargeText(
                          '$currencyCode. ${formatNumber(int.parse(accountBalance!))}',
                          size: 22,
                          color: app_color.AppColors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  VSpace.sm,
                  Container(
                    margin: const EdgeInsets.fromLTRB(10, 0, 10, 20),
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(15, 10, 15, 15),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(1),
                        border: Border.all(
                            color: app_color.AppColors.pivotPayColorGreen),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            offset: const Offset(5, 5),
                          )
                        ],
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        children: [
                          SmallText(
                            'Agent ID.: ${accountNumber!}',
                            fontWeight: FontWeight.w800,
                            size: 14,
                          ),
                          const Divider(
                            color: Colors.black,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 5,
                              right: 20,
                              left: 20,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                GestureDetector(
                                  onTap: () => Navigator.push(
                                    context,
                                    PageRouter.fadeScale(
                                        () => const SendOptionsPage()),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      InAppImage(
                                        AppIcons.sendMoney,
                                        color: app_color.AppColors.primaryColor,
                                        height: 30,
                                      ),
                                      const VSpace(5),
                                      const SmallText('Deposit')
                                    ],
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      PageRouter.fadeScale(
                                          () => WithdrawDetailsPage()),
                                    );
                                  },
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      InAppImage(
                                        AppIcons.withdraw,
                                        color: app_color.AppColors.primaryColor,
                                        height: 30,
                                      ),
                                      const VSpace(5),
                                      const SmallText('Withdraw')
                                    ],
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      PageRouter.fadeThrough(
                                        () => AgentRecipientPage(
                                          serviceName: 'AGENT_TO_AGENT',
                                          paymentNetwork: 'AGENT WALLET',
                                          serviceDescription: 'To Agent Wallet',
                                        ),
                                      ),
                                    );
                                  },
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      InAppImage(
                                        AppIcons.transfer,
                                        color: app_color.AppColors.primaryColor,
                                        height: 30,
                                      ),
                                      const VSpace(5),
                                      const SmallText('Transfer')
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Stack(
                  //   children: [
                  //     Container(
                  //       margin: const EdgeInsets.fromLTRB(10, 30, 10, 20),
                  //       padding: const EdgeInsets.fromLTRB(10, 15, 10, 15),
                  //       decoration: BoxDecoration(
                  //         color: app_color.AppColors.primaryColor,
                  //         borderRadius: BorderRadius.circular(10),
                  //       ),
                  //       child: Column(
                  //         crossAxisAlignment: CrossAxisAlignment.stretch,
                  //         mainAxisSize: MainAxisSize.max,
                  //         children: [
                  //           ConstrainedBox(
                  //             constraints: const BoxConstraints(maxWidth: 300),
                  //             child: const MediumText(
                  //               'Enjoy our offers like discounts',
                  //               color: app_color.AppColors.white,
                  //             ),
                  //           ),
                  //           VSpace.md,
                  //           const MediumText(
                  //             'Commissions, Charge backs',
                  //             color: app_color.AppColors.white,
                  //           ),
                  //         ],
                  //       ),
                  //     ),
                  //     Positioned(
                  //       right: 0,
                  //       top: 0,
                  //       child: InAppImage(
                  //         AppImages.imgAgent,
                  //         height: 155,
                  //       ),
                  //     )
                  //   ],
                  // ),
                  Container(
                    margin: const EdgeInsets.fromLTRB(15, 0, 15, 15),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(1),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: CarouselSlider(
                      items: imageSliders,
                      carouselController: _controller,
                      options: CarouselOptions(
                          height: 180,
                          autoPlay: true,
                          enlargeCenterPage: true,
                          aspectRatio: 2.0,
                          viewportFraction: 1,
                          onPageChanged: (index, reason) {
                            setState(() {
                              _current = index;
                            });
                          }),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                    margin: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(1),
                      border: Border.all(
                          color: app_color.AppColors.pivotPayColorGreen),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          offset: const Offset(5, 5),
                        )
                      ],
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      children: [
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SmallText(
                              'Services',
                              fontWeight: FontW.bold,
                            ),
                          ],
                        ),
                        const Divider(
                          color: Colors.black,
                        ),
                        const VSpace(5),
                        Padding(
                          padding: const EdgeInsets.only(left: 10, right: 10),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  GestureDetector(
                                    onTap: () {},
                                    child: Column(
                                      children: [
                                        CircleAvatar(
                                          radius: 25,
                                          backgroundColor: app_color
                                              .AppColors.pivotPayColorGreen
                                              .withOpacity(0.1),
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: InAppImage(
                                              app_color.AppIcons.airtime,
                                              color: app_color
                                                  .AppColors.pivotPayColorGreen,
                                            ),
                                          ),
                                        ),
                                        const VSpace(5),
                                        ConstrainedBox(
                                            constraints: const BoxConstraints(
                                                maxWidth: 100),
                                            child: const SmallText('Airtime'))
                                      ],
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {},
                                    child: Column(
                                      children: [
                                        CircleAvatar(
                                          radius: 25,
                                          backgroundColor: app_color
                                              .AppColors.pivotPayColorGreen
                                              .withOpacity(0.1),
                                          child: Padding(
                                            padding: const EdgeInsets.all(10.0),
                                            child: InAppImage(
                                              app_color.AppIcons.scanQrCode,
                                              color: app_color
                                                  .AppColors.pivotPayColorGreen,
                                            ),
                                          ),
                                        ),
                                        const VSpace(5),
                                        ConstrainedBox(
                                            constraints: const BoxConstraints(
                                                maxWidth: 100),
                                            child: const SmallText('Scan Pay'))
                                      ],
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => Navigator.push(
                                      context,
                                      PageRouter.fadeScale(() => BillsPage()),
                                    ),
                                    child: Column(
                                      children: [
                                        CircleAvatar(
                                          radius: 25,
                                          backgroundColor: app_color
                                              .AppColors.pivotPayColorGreen
                                              .withOpacity(0.1),
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: InAppImage(
                                              app_color.AppImages.bills,
                                              color: app_color
                                                  .AppColors.pivotPayColorGreen,
                                            ),
                                          ),
                                        ),
                                        const VSpace(5),
                                        ConstrainedBox(
                                            constraints: const BoxConstraints(
                                                maxWidth: 100),
                                            child: const SmallText('Pay Bills'))
                                      ],
                                    ),
                                  )
                                ],
                              ),
                              VSpace.md,
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  GestureDetector(
                                    onTap: () {},
                                    child: Column(
                                      children: [
                                        CircleAvatar(
                                          radius: 25,
                                          backgroundColor: app_color
                                              .AppColors.pivotPayColorGreen
                                              .withOpacity(0.1),
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: InAppImage(
                                              app_color.AppIcons.housing,
                                              color: app_color
                                                  .AppColors.pivotPayColorGreen,
                                            ),
                                          ),
                                        ),
                                        const VSpace(5),
                                        ConstrainedBox(
                                            constraints: const BoxConstraints(
                                                maxWidth: 100),
                                            child: const SmallText('Housing'))
                                      ],
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {},
                                    child: Column(
                                      children: [
                                        CircleAvatar(
                                          radius: 25,
                                          backgroundColor: app_color
                                              .AppColors.pivotPayColorGreen
                                              .withOpacity(0.1),
                                          child: Padding(
                                            padding: const EdgeInsets.all(10.0),
                                            child: InAppImage(
                                              app_color.AppIcons.bundles,
                                              color: app_color
                                                  .AppColors.pivotPayColorGreen,
                                            ),
                                          ),
                                        ),
                                        const VSpace(5),
                                        ConstrainedBox(
                                            constraints: const BoxConstraints(
                                                maxWidth: 100),
                                            child: const SmallText('Internet'))
                                      ],
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {},
                                    child: Column(
                                      children: [
                                        CircleAvatar(
                                          radius: 25,
                                          backgroundColor: app_color
                                              .AppColors.pivotPayColorGreen
                                              .withOpacity(0.1),
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: InAppImage(
                                              app_color.AppIcons.insurance,
                                              color: app_color
                                                  .AppColors.pivotPayColorGreen,
                                            ),
                                          ),
                                        ),
                                        const VSpace(5),
                                        ConstrainedBox(
                                            constraints: const BoxConstraints(
                                                maxWidth: 100),
                                            child: const SmallText('Insurance'))
                                      ],
                                    ),
                                  )
                                ],
                              ),
                              VSpace.md,
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        PageRouter.fadeScale(
                                            () => SchoolRecipientPage()),
                                      );
                                    },
                                    child: Column(
                                      children: [
                                        CircleAvatar(
                                          radius: 25,
                                          backgroundColor: app_color
                                              .AppColors.pivotPayColorGreen
                                              .withOpacity(0.1),
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: InAppImage(
                                              app_color.AppImages.schoolPay,
                                              color: app_color
                                                  .AppColors.pivotPayColorGreen,
                                            ),
                                          ),
                                        ),
                                        const VSpace(5),
                                        ConstrainedBox(
                                            constraints: const BoxConstraints(
                                                maxWidth: 100),
                                            child: const SmallText('Education'))
                                      ],
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {},
                                    child: Column(
                                      children: [
                                        CircleAvatar(
                                          radius: 25,
                                          backgroundColor: app_color
                                              .AppColors.pivotPayColorGreen
                                              .withOpacity(0.1),
                                          child: Padding(
                                            padding: const EdgeInsets.all(5.0),
                                            child: InAppImage(
                                              app_color.AppIcons.save,
                                              width: 20,
                                              color: app_color
                                                  .AppColors.pivotPayColorGreen,
                                            ),
                                          ),
                                        ),
                                        const VSpace(5),
                                        ConstrainedBox(
                                            constraints: const BoxConstraints(
                                                maxWidth: 100),
                                            child: const SmallText('Savings'))
                                      ],
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {},
                                    child: Column(
                                      children: [
                                        CircleAvatar(
                                          radius: 25,
                                          backgroundColor: app_color
                                              .AppColors.pivotPayColorGreen
                                              .withOpacity(0.1),
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: InAppImage(
                                              app_color.AppImages.payLoan,
                                              color: app_color
                                                  .AppColors.pivotPayColorGreen,
                                            ),
                                          ),
                                        ),
                                        const VSpace(5),
                                        ConstrainedBox(
                                            constraints: const BoxConstraints(
                                                maxWidth: 100),
                                            child: const SmallText('Pay Loan'))
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  VSpace.sm,
                ],
              ),
            ),
          ),
        ),
      ),
      extendBody: true,
      backgroundColor: app_color.AppColors.peachColor,
    );
  }

  showLogOutDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Container(
          decoration: const BoxDecoration(
            color: app_color.AppColors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10.0),
              topRight: Radius.circular(10.0),
            ),
          ),
          child: const Padding(
            padding: EdgeInsets.only(left: 20.0, right: 20, top: 20),
            child: Align(
              child: Column(
                children: [
                  MediumText(
                    'Log out',
                    size: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  Divider(
                    color: Colors.black,
                    thickness: 0.1,
                  ),
                ],
              ),
            ),
          ),
        ),
        titlePadding: const EdgeInsets.only(bottom: 10),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: SmallText(
                    'Are you sure you want to log out ?',
                    fontWeight: FontWeight.w500,
                    size: 14,
                  ),
                ),
              ],
            ),
          ],
        ),
        contentPadding: const EdgeInsets.fromLTRB(10, 0, 10, 20),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(10.0),
          ),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              backgroundColor: app_color.AppColors.black.withOpacity(0.1),
              padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
            ),
            child: MediumText(
              'Cancel',
              color: app_color.AppColors.primaryColor,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              backgroundColor: app_color.AppColors.primaryColor,
              padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
            ),
            child: const MediumText(
              'Confirm',
              color: app_color.AppColors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
              logOut();
            },
          ),
        ],
        elevation: 30,
        actionsPadding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
        actionsAlignment: MainAxisAlignment.spaceBetween,
      ),
    );
  }

  logOut() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.clear();
    if (!mounted) return;
    final deviceInfo = GetStorage();
    Navigator.pushAndRemoveUntil(
      context,
      PageRouter.fadeThrough(
        () => LoginScreen(
          deviceIdExists: true,
          deviceId: deviceInfo.read('deviceId'),
          osType: deviceInfo.read('source'),
        ),
      ),
      (route) => false,
    );
  }

  openApp() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    auth.isDeviceSupported().then(
          (bool isSupported) => _supportState =
              isSupported ? _SupportState.supported : _SupportState.unsupported,
        );
    _getAvailableBiometrics();
    setState(
      () {
        agentName = preferences.getString('agentName')!;
        phoneNumber = preferences.getString('phoneNumber')!;
        accountBalance = preferences.getString('accountBalance')!;
        accountNumber = preferences.getString('accountNumber')!;
        currencyCode = preferences.getString('currencyCode')!;
        final hour = TimeOfDay.now().hour;
        if (hour <= 12) {
          greeting = 'Good Morning';
        } else if (hour <= 17) {
          greeting = 'Good Afternoon';
        } else {
          greeting = 'Good Evening';
        }
      },
    );
    getData(accountNumber!);
    getAccountBalance(accountNumber!);
    if (!mounted) return;
    checkInstallationSource(context).then(
      (installSrcResult) {
        if (installSrcResult.canGetDetails) {
          getAppInfo(installSrcResult.source);
        } else {
          storeVersionDialog(
            context,
            'Sorry',
            'Okay',
            'You are running a version of this App that is installed from an unknown source. Please Tap "Okay" to download the App from your corresponding Store',
          );
        }
      },
    );
  }

  getData(String accountNumber) async {
    final Map data = {'accountNumber': accountNumber};
    if (!mounted) return;
    getBeneficiaries(context, data).then((value) {
      setState(() {
        if (value.status!) {
          for (var elementOne in value.beneficiaryList!) {
            if (beneficiariesList
                .where((element) =>
                    element.beneficiaryAccount == elementOne.beneficiaryAccount)
                .isEmpty) {
              beneficiariesList.add(elementOne);
            }
          }
        }
      });
    });
  }

  getAccountBalance(
    String accountNumber,
  ) {
    final Map data = {'username': accountNumber};
    getUserBalances(context, data).then((value) async {
      if (value.status!) {
        final SharedPreferences preferences =
            await SharedPreferences.getInstance();
        preferences.setString(
          'accountBalance',
          value.accountBalance.toString().replaceAll(',', ''),
        );
        setState(() {
          accountBalance = value.accountBalance.toString().replaceAll(',', '');
        });
      } else {
        setState(() {
          accountBalance = value.accountBalance.toString().replaceAll(',', '');
        });
        responseDialog(
          'Sorry',
          'Okay',
          value.response!,
          context,
        );
      }
    });
  }

  getAppInfo(String source) async {
    final Map data = {
      'source': source,
    };
    if (!mounted) return;
    appInfo(context, data).then((value) {
      if (value.status!) {
        saveAppInfo(value);
      }
    });
  }

  saveAppInfo(AppInfo appInfo) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString('appVersion', appInfo.appVersion!);
    preferences.setString('cardUrl', appInfo.cardUrl!);
    preferences.setString('reviewStatus', appInfo.reviewStatus!);
    preferences.setString('email', appInfo.email!);
    preferences.setString('MTNSupportLine', appInfo.mtnSupportLine!);
    preferences.setString('AIRTELSupportLine', appInfo.airtelSupportLine!);
    preferences.setString('whatsapp', appInfo.whatsapp!);
    preferences.setString('facebook', appInfo.facebook!);
    preferences.setString('twitter', appInfo.twitter!);
    preferences.setString('website', appInfo.website!);
    preferences.setString('supportedCurrencies', appInfo.supportedCurrencies!);
    saveBills(appInfo.billList!);
  }

  saveBills(List<Bills> billList) {
    handler!.deleteBills();
    for (int index = 0; index < billList.length; index++) {
      handler?.insertBill(billList.elementAt(index));
    }
  }

  _onLoading() async {
    await Future.delayed(const Duration(milliseconds: 1000));
    openApp();
    _refreshController.refreshCompleted();
  }

  _onRefresh() async {
    await Future.delayed(const Duration(milliseconds: 1000));
    _onLoading();
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
}
