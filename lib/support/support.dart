import 'package:flutter/material.dart';
import 'package:pivotpay/components/others/image.dart';
import 'package:pivotpay/components/others/spacers.dart';
import 'package:pivotpay/components/others/text.dart';
import 'package:pivotpay/support/web.dart';
import 'package:pivotpay/utils/base_page.dart';
import 'package:pivotpay/utils/resources.dart';
import 'package:pivotpay/utils/routing.dart';
import 'package:pivotpay/utils/style.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class SupportPage extends BasePage {
  const SupportPage({super.key});

  @override
  State<SupportPage> createState() => _SupportPageState();
}

class _SupportPageState extends BaseState<SupportPage> with BasicPage {
  String phoneLine1 = '',
      phoneLine2 = '',
      email = '',
      twitter = '',
      facebook = '',
      whatsApp = '',
      website = '';
  @override
  void initState() {
    super.initState();
    getInfo();
  }

  getInfo() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      email = prefs.getString('email')!;
      phoneLine1 = prefs.getString('MTNSupportLine')!;
      phoneLine2 = prefs.getString('AIRTELSupportLine')!;
      whatsApp = prefs.getString('whatsapp')!;
      facebook = prefs.getString('facebook')!;
      twitter = prefs.getString('twitter')!;
      website = prefs.getString('website')!;
    });
  }

  @override
  Widget rootWidget(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: const MediumText(
          'Contact Support',
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            VSpace.lg,
            Center(
              child: Text.rich(
                TextSpan(
                  text: '24X7 Help &',
                  style: TextStyle(
                    color: AppColors.primaryColor,
                    fontFamily: 'Lato',
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                  children: <InlineSpan>[
                    TextSpan(
                      text: ' Support',
                      style: TextStyle(
                          color: AppColors.pivotPayColorGreen,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'Lato'),
                    )
                  ],
                ),
              ),
            ),
            const Center(
                child: SmallText('Get a quick solution to your questions')),
            VSpace.sm,
            Container(
              margin: const EdgeInsets.only(
                  left: 20, right: 20, top: 20, bottom: 10),
              decoration: BoxDecoration(
                  border: Border.all(color: AppColors.black, width: 0.2),
                  borderRadius: const BorderRadius.all(Radius.circular(10.0))),
              child: Column(
                children: [
                  VSpace.sm,
                  InAppImage(
                    AppImages.support,
                    height: 150,
                  ),
                  VSpace.xs,
                  const Divider(
                    color: Colors.black,
                    thickness: 0.2,
                  ),
                  VSpace.xs,
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 30,
                    ),
                    child: Row(
                      children: [
                        InAppImage(
                          AppImages.callSupport,
                          color: AppColors.primaryColor,
                          height: 30,
                        ),
                        HSpace.lg,
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const MediumText(
                              'Call us 24X7',
                              size: 20,
                            ),
                            VSpace.sm,
                            MediumText(phoneLine1),
                            VSpace.xs,
                            MediumText(phoneLine2),
                          ],
                        ),
                      ],
                    ),
                  ),
                  VSpace.xs,
                  const Divider(
                    color: Colors.black,
                    thickness: 0.2,
                  ),
                  VSpace.xs,
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 30,
                    ),
                    child: Row(
                      children: [
                        InAppImage(
                          AppImages.emailSupport,
                          color: AppColors.primaryColor,
                          height: 30,
                        ),
                        HSpace.lg,
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const MediumText(
                              'Email',
                              size: 20,
                            ),
                            VSpace.sm,
                            MediumText(email),
                          ],
                        ),
                      ],
                    ),
                  ),
                  VSpace.xs,
                  const Divider(
                    color: Colors.black,
                    thickness: 0.2,
                  ),
                  VSpace.xs,
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 30,
                    ),
                    child: Row(
                      children: [
                        InAppImage(
                          AppImages.textSupport,
                          color: AppColors.primaryColor,
                          height: 30,
                        ),
                        HSpace.lg,
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const MediumText(
                              'Text us On',
                              size: 20,
                            ),
                            VSpace.sm,
                            MediumText(phoneLine1),
                            VSpace.xs,
                            MediumText(phoneLine2),
                          ],
                        ),
                      ],
                    ),
                  ),
                  VSpace.xs,
                  const Divider(
                    color: Colors.black,
                    thickness: 0.2,
                  ),
                  VSpace.xs,
                  const MediumText(
                    'Or Reach Us on',
                  ),
                  VSpace.xs,
                  Wrap(
                    spacing: 20,
                    children: [
                      IconButton(
                        icon: Image.asset(
                          'assets/images/whatsapp.png',
                          color: AppColors.primaryColor,
                          width: 20,
                        ),
                        onPressed: () async {
                          await launchUrl(Uri.parse(whatsApp),
                              mode: LaunchMode.externalApplication);
                        },
                      ),
                      IconButton(
                        icon: Image.asset(
                          'assets/icons/world.png',
                          color: AppColors.primaryColor,
                          width: 20,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            PageRouter.fadeScale(
                              () => WebViewPage(website),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: Image.asset(
                          'assets/icons/twitter.png',
                          color: AppColors.primaryColor,
                          width: 25,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            PageRouter.fadeScale(
                              () => WebViewPage(
                                website,
                              ),
                            ),
                          );
                        },
                      )
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
