import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:infinite_carousel/infinite_carousel.dart';
import 'package:pivotpay/components/inputs/textfield.dart';
import 'package:pivotpay/components/others/image.dart';
import 'package:pivotpay/components/others/spacers.dart';
import 'package:pivotpay/components/others/text.dart';
import 'package:pivotpay/models/packages.dart';
import 'package:pivotpay/models/providers.dart';
import 'package:pivotpay/savings/payment_plan.dart';
import 'package:pivotpay/utils/resources.dart';
import 'package:pivotpay/utils/routing.dart';
import 'package:pivotpay/utils/style.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timelines/timelines.dart';

final List<String> imgList = [
  'https://wallpaperaccess.com/full/3598438.jpg',
  'https://wallpaperaccess.com/full/941173.jpg',
  'https://www.gulf-times.com/uploads/imported_images/Upload/Slider/720192601131875494427.jpg',
  'https://i0.wp.com/umuyoboro.rw/wp-content/uploads/2020/04/image.jpg?fit=800%2C500&ssl=1',
  'https://www.islamic-relief.org.uk/wp-content/uploads/2022/11/hajj-hero-2.jpg',
];

class TravelDetailsPage extends StatefulWidget {
  String? serviceDescription,
      providerId,
      providerName,
      providerLogo,
      providerColor;
  TravelDetailsPage({
    super.key,
    this.serviceDescription,
    this.providerId,
    this.providerLogo,
    this.providerName,
    this.providerColor,
  });

  @override
  _TravelDetailsPageState createState() => _TravelDetailsPageState();
}

class _TravelDetailsPageState extends State<TravelDetailsPage> {
  late InfiniteScrollController controller;
  List<Providers> travelProviders = [];
  List<Packages> packages = [];
  int _selectedIndex = 1;
  final numberRegEx = RegExp(r'\d+');
  double itemExtent = 250;
  double get screenWidth => MediaQuery.of(context).size.width;
  int _current = 0;
  final CarouselController _controller = CarouselController();
  final TextEditingController _searchController = TextEditingController();
  String username = '';
  @override
  void initState() {
    super.initState();
    packages = PackagesList.fromJson(GlobalConfiguration().get('packages'))
        .packagesList!
        .where((element) => element.providerId == widget.providerId)
        .toList();
    controller = InfiniteScrollController(initialItem: 1);
    getDetails();
  }

  getDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('userName')!;
    });
  }

  final List<Widget> imageSliders = imgList
      .map((item) => ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(5.0)),
          child: Stack(
            children: <Widget>[
              Image.network(item, fit: BoxFit.cover, width: 1000.0),
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
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: [
        Container(
          height: MediaQuery.of(context).size.height * 0.25,
          decoration: BoxDecoration(
            color: Color(
              int.parse(widget.providerColor!),
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                  top: 65,
                  right: 0,
                  left: 0,
                  bottom: 0,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        margin: const EdgeInsets.all(15),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            InAppImage(
                              AppImages.muslimMam,
                              height: 75,
                            ),
                            HSpace.md,
                            Container(
                              margin: const EdgeInsets.only(top: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const MediumText(
                                    'Hi,',
                                    size: 14,
                                    color: AppColors.white,
                                  ),
                                  MediumText(
                                    username,
                                    size: 20,
                                    color: AppColors.white,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      widget.providerId == '1'
                          ? Container(
                              margin: const EdgeInsets.only(top: 10, right: 5),
                              height: 80,
                              width: 80,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.white,
                                  image: DecorationImage(
                                      image: Image.asset(
                                              'assets/images/${widget.providerLogo!}_white.png')
                                          .image)),
                            )
                          : Container(
                              margin: const EdgeInsets.only(top: 10, right: 5),
                              child: InAppImage(
                                'assets/images/${widget.providerLogo!}_white.png',
                                height: 80,
                              ),
                            ),
                    ],
                  ))
            ],
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          bottom: 0,
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0.0,
            title: const MediumText(
              'Service Provider',
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
        ),
        Card(
          elevation: 20.0,
          margin: const EdgeInsets.only(left: 5.0, right: 5.0, top: 160),
          child: SingleChildScrollView(
            child: Column(
              children: [
                VSpace.sm,
                Container(
                  padding: const EdgeInsets.only(
                    left: 5,
                    right: 5,
                  ),
                  margin: const EdgeInsets.only(
                      left: 5, right: 5, top: 5, bottom: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Color(
                            int.parse(widget.providerColor!),
                          ),
                          borderRadius: const BorderRadius.all(
                            Radius.circular(5.0),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                              child: MediumText(
                                '${widget.providerName!} Travel Agency',
                                color: AppColors.white,
                                size: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      VSpace.md,
                      CarouselSlider(
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: imgList.asMap().entries.map((entry) {
                          return GestureDetector(
                            onTap: () => _controller.animateToPage(entry.key),
                            child: Container(
                              width: 8.0,
                              height: 8.0,
                              margin: const EdgeInsets.symmetric(
                                  vertical: 8.0, horizontal: 4.0),
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: (Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.white
                                          : Colors.black)
                                      .withOpacity(
                                          _current == entry.key ? 0.9 : 0.4)),
                            ),
                          );
                        }).toList(),
                      ),
                      Visibility(
                        visible: false,
                        child: StaggeredGrid.count(
                          crossAxisCount: 4,
                          mainAxisSpacing: 4,
                          crossAxisSpacing: 4,
                          children: [
                            StaggeredGridTile.count(
                              crossAxisCellCount: 2,
                              mainAxisCellCount: 2,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppColors.primaryColor,
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(5.0),
                                  ),
                                  image: DecorationImage(
                                      fit: BoxFit.cover,
                                      image: Image.network(
                                        imgList.elementAt(0),
                                        fit: BoxFit.cover,
                                      ).image),
                                ),
                              ),
                            ),
                            StaggeredGridTile.count(
                              crossAxisCellCount: 2,
                              mainAxisCellCount: 1,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppColors.primaryColor,
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(5.0),
                                  ),
                                  image: DecorationImage(
                                      fit: BoxFit.cover,
                                      image: Image.network(
                                        imgList.elementAt(1),
                                        fit: BoxFit.cover,
                                      ).image),
                                ),
                              ),
                            ),
                            StaggeredGridTile.count(
                              crossAxisCellCount: 2,
                              mainAxisCellCount: 3,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppColors.primaryColor,
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(5.0),
                                  ),
                                  image: DecorationImage(
                                      fit: BoxFit.cover,
                                      image: Image.network(
                                        imgList.elementAt(2),
                                        fit: BoxFit.cover,
                                      ).image),
                                ),
                              ),
                            ),
                            StaggeredGridTile.count(
                              crossAxisCellCount: 2,
                              mainAxisCellCount: 2,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppColors.primaryColor,
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(5.0),
                                  ),
                                  image: DecorationImage(
                                      fit: BoxFit.cover,
                                      image: Image.network(
                                        imgList.elementAt(3),
                                        fit: BoxFit.cover,
                                      ).image),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          VSpace.md,
                          Container(
                            padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
                            margin: const EdgeInsets.fromLTRB(2, 0, 2, 2),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(1),
                              border: Border.all(
                                  color: AppColors.black, width: 0.1),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.3),
                                  offset: const Offset(5, 5),
                                )
                              ],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Column(
                              children: [
                                VSpace.sm,
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(children: [
                                        Column(
                                          children: [
                                            Container(
                                              width: 40,
                                              height: 40,
                                              padding: const EdgeInsets.all(10),
                                              decoration: BoxDecoration(
                                                color: Color(
                                                  int.parse(
                                                      widget.providerColor!),
                                                ),
                                                border: Border.all(
                                                    color: AppColors.black,
                                                    width: 0.1),
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              child: Image.asset(
                                                AppImages.flight,
                                                color: AppColors.white,
                                              ),
                                            ),
                                            VSpace.xs,
                                            const SmallText(
                                              'Air Ticket',
                                              size: 9,
                                            )
                                          ],
                                        )
                                      ]),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(children: [
                                        Column(
                                          children: [
                                            Container(
                                              width: 40,
                                              height: 40,
                                              padding: const EdgeInsets.all(10),
                                              decoration: BoxDecoration(
                                                color: Color(
                                                  int.parse(
                                                      widget.providerColor!),
                                                ),
                                                border: Border.all(
                                                    color: AppColors.black,
                                                    width: 0.1),
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              child: Image.asset(
                                                AppImages.travel,
                                                color: AppColors.white,
                                              ),
                                            ),
                                            VSpace.xs,
                                            const SmallText(
                                              'Travel',
                                              size: 9,
                                            )
                                          ],
                                        )
                                      ]),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(children: [
                                        Column(
                                          children: [
                                            Container(
                                              width: 40,
                                              height: 40,
                                              padding: const EdgeInsets.all(10),
                                              decoration: BoxDecoration(
                                                color: Color(
                                                  int.parse(
                                                      widget.providerColor!),
                                                ),
                                                border: Border.all(
                                                    color: AppColors.black,
                                                    width: 0.1),
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              child: Image.asset(
                                                AppImages.car,
                                                color: AppColors.white,
                                              ),
                                            ),
                                            VSpace.xs,
                                            const SmallText(
                                              'Car-hire',
                                              size: 9,
                                            )
                                          ],
                                        )
                                      ]),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(children: [
                                        Column(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(10),
                                              decoration: BoxDecoration(
                                                color: Color(
                                                  int.parse(
                                                      widget.providerColor!),
                                                ),
                                                border: Border.all(
                                                    color: AppColors.black,
                                                    width: 0.1),
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              child: Image.asset(
                                                AppImages.accomodation,
                                                color: AppColors.white,
                                                height: 25,
                                              ),
                                            ),
                                            VSpace.xs,
                                            const SmallText(
                                              'Hotel',
                                              size: 9,
                                            )
                                          ],
                                        )
                                      ]),
                                    ),
                                  ],
                                ),
                                const Divider(
                                  color: Colors.black,
                                  thickness: 0.3,
                                ),
                                Container(
                                  margin: const EdgeInsets.only(left: 10),
                                  child: const Align(
                                      alignment: Alignment.topLeft,
                                      child: MediumText('Select a Package')),
                                ),
                                Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: FixedTimeline.tileBuilder(
                                        theme: TimelineThemeData(
                                          nodePosition: 0,
                                          color: AppColors.primaryColor,
                                          indicatorTheme:
                                              const IndicatorThemeData(
                                                  position: 0.5, size: 10),
                                        ),
                                        builder: TimelineTileBuilder.connected(
                                          connectionDirection:
                                              ConnectionDirection.before,
                                          itemCount: packages.length,
                                          contentsBuilder: (context, index) {
                                            return Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 10),
                                              child: GestureDetector(
                                                onTap: () {
                                                  showDialog(
                                                    context: context,
                                                    builder: (context) {
                                                      return Container(
                                                        margin: const EdgeInsets
                                                                .only(
                                                            left: 5, right: 5),
                                                        child: Dialog(
                                                          shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          12.0)),
                                                          elevation: 0.0,
                                                          backgroundColor:
                                                              Colors.white,
                                                          child: Column(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: [
                                                              Stack(
                                                                children: [
                                                                  Container(
                                                                    decoration:
                                                                        const BoxDecoration(
                                                                      borderRadius:
                                                                          BorderRadius
                                                                              .all(
                                                                        Radius.circular(
                                                                            12.0),
                                                                      ),
                                                                    ),
                                                                    child:
                                                                        Column(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .stretch,
                                                                      children: [
                                                                        Container(
                                                                          padding: const EdgeInsets.only(
                                                                              top: 10,
                                                                              bottom: 10),
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            color:
                                                                                Color(
                                                                              int.parse(widget.providerColor!),
                                                                            ),
                                                                            borderRadius:
                                                                                const BorderRadius.only(
                                                                              topLeft: Radius.circular(
                                                                                10.0,
                                                                              ),
                                                                              topRight: Radius.circular(
                                                                                10.0,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          child:
                                                                              const Center(
                                                                            child:
                                                                                Padding(
                                                                              padding: EdgeInsets.all(5.0),
                                                                              child: MediumText(
                                                                                'Package Details',
                                                                                color: AppColors.white,
                                                                                size: 16,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        VSpace
                                                                            .sm,
                                                                        Container(
                                                                          padding:
                                                                              const EdgeInsets.all(10),
                                                                          margin: const EdgeInsets.fromLTRB(
                                                                              10,
                                                                              10,
                                                                              10,
                                                                              5),
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            color:
                                                                                AppColors.black.withOpacity(0.08),
                                                                            borderRadius:
                                                                                const BorderRadius.all(
                                                                              Radius.circular(5),
                                                                            ),
                                                                          ),
                                                                          child:
                                                                              Column(
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
                                                                                    packages.elementAt(index).packageName!,
                                                                                    color: AppColors.white,
                                                                                    size: 14,
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                              Center(
                                                                                child: MediumText(
                                                                                  packages.elementAt(index).packagePrice!,
                                                                                  fontWeight: FontWeight.w500,
                                                                                  size: 14,
                                                                                ),
                                                                              )
                                                                            ],
                                                                          ),
                                                                        ),
                                                                        VSpace
                                                                            .sm,
                                                                        ListView
                                                                            .builder(
                                                                          shrinkWrap:
                                                                              true,
                                                                          itemCount: packages
                                                                              .elementAt(index)
                                                                              .packageDetails!
                                                                              .length,
                                                                          itemBuilder:
                                                                              (context, listIndex) {
                                                                            return Padding(
                                                                              padding: const EdgeInsets.all(8.0),
                                                                              child: Row(
                                                                                children: [
                                                                                  const SmallText('\u2022'),
                                                                                  HSpace.sm,
                                                                                  Flexible(
                                                                                    child: SmallText(
                                                                                      packages.elementAt(index).packageDetails!.elementAt(listIndex),
                                                                                      size: 14,
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            );
                                                                          },
                                                                        ),
                                                                        VSpace
                                                                            .md,
                                                                        Row(
                                                                          children: [
                                                                            Expanded(
                                                                              child: Container(
                                                                                margin: const EdgeInsets.only(left: 15, bottom: 10, right: 15),
                                                                                child: ElevatedButton(
                                                                                  style: ElevatedButton.styleFrom(
                                                                                    minimumSize: Size.zero,
                                                                                    backgroundColor: Color(
                                                                                      int.parse(widget.providerColor!),
                                                                                    ),
                                                                                    padding: const EdgeInsets.fromLTRB(
                                                                                      10,
                                                                                      8,
                                                                                      10,
                                                                                      8,
                                                                                    ),
                                                                                  ),
                                                                                  onPressed: () {
                                                                                    Navigator.of(context).pop();
                                                                                    Navigator.push(
                                                                                      context,
                                                                                      PageRouter.fadeScale(
                                                                                        () => PaymentPlanPage(
                                                                                          providerCode: packages.elementAt(index).providerId,
                                                                                          providerLogo: widget.providerLogo,
                                                                                          providerName: widget.providerName,
                                                                                          packageName: packages.elementAt(index).packageName!,
                                                                                          providerColor: widget.providerColor,
                                                                                          packageAmount: numberRegEx.allMatches(packages.elementAt(index).packagePrice!.replaceAll(',', '')).map((e) => e.group(0)).last,
                                                                                          currency: packages.elementAt(index).packagePrice!.split('.')[0],
                                                                                        ),
                                                                                      ),
                                                                                    );
                                                                                  },
                                                                                  child: const MediumText(
                                                                                    'Continue',
                                                                                    color: AppColors.white,
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                        VSpace
                                                                            .sm,
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  Positioned(
                                                                    right: 0.0,
                                                                    child:
                                                                        GestureDetector(
                                                                      onTap:
                                                                          () {
                                                                        Navigator.of(context)
                                                                            .pop();
                                                                      },
                                                                      child:
                                                                          const Align(
                                                                        alignment:
                                                                            Alignment.topRight,
                                                                        child:
                                                                            CircleAvatar(
                                                                          radius:
                                                                              14.0,
                                                                          backgroundColor:
                                                                              Colors.white,
                                                                          child: Icon(
                                                                              Icons.close,
                                                                              color: Colors.red),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  );
                                                },
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.all(10),
                                                  margin:
                                                      const EdgeInsets.fromLTRB(
                                                          5, 10, 5, 5),
                                                  decoration: BoxDecoration(
                                                    color: AppColors.black
                                                        .withOpacity(0.08),
                                                    borderRadius:
                                                        const BorderRadius.all(
                                                      Radius.circular(5),
                                                    ),
                                                  ),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .stretch,
                                                    children: [
                                                      Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Color(
                                                            int.parse(widget
                                                                .providerColor!),
                                                          ),
                                                          borderRadius:
                                                              const BorderRadius
                                                                  .all(
                                                            Radius.circular(5),
                                                          ),
                                                        ),
                                                        padding:
                                                            const EdgeInsets
                                                                .all(2),
                                                        margin: const EdgeInsets
                                                            .only(
                                                          top: 5,
                                                          left: 15,
                                                          right: 15,
                                                          bottom: 5,
                                                        ),
                                                        child: Center(
                                                          child: MediumText(
                                                            packages
                                                                .elementAt(
                                                                    index)
                                                                .packageName!,
                                                            color:
                                                                AppColors.white,
                                                            size: 14,
                                                          ),
                                                        ),
                                                      ),
                                                      Center(
                                                        child: MediumText(
                                                          packages
                                                              .elementAt(index)
                                                              .packagePrice!,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          size: 14,
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                          indicatorBuilder: (_, index) {
                                            return DotIndicator(
                                              size: 10,
                                              color: Color(
                                                int.parse(
                                                    widget.providerColor!),
                                              ),
                                              child: const Padding(
                                                padding: EdgeInsets.all(8.0),
                                              ),
                                            );
                                          },
                                          connectorBuilder: (_, index, ___) =>
                                              SolidLineConnector(
                                            thickness: 1,
                                            color: Color(
                                              int.parse(widget.providerColor!),
                                            ),
                                          ),
                                          itemExtentBuilder: (_, index) =>
                                              100.0,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ));
  }
}
