import 'dart:developer';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:infinite_carousel/infinite_carousel.dart';
import 'package:pivotpay/components/inputs/textfield.dart';
import 'package:pivotpay/components/others/image.dart';
import 'package:pivotpay/components/others/spacers.dart';
import 'package:pivotpay/components/others/text.dart';
import 'package:pivotpay/models/instructions.dart';
import 'package:pivotpay/models/packages.dart';
import 'package:pivotpay/models/providers.dart';
import 'package:pivotpay/savings/payment_plan.dart';
import 'package:pivotpay/savings/provider_packages.dart';
import 'package:pivotpay/utils/resources.dart';
import 'package:pivotpay/utils/routing.dart';
import 'package:pivotpay/utils/style.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';

class TravelProviderPage extends StatefulWidget {
  String? serviceDescription;
  TravelProviderPage({
    super.key,
    this.serviceDescription,
  });

  @override
  _TravelProviderPageState createState() => _TravelProviderPageState();
}

class _TravelProviderPageState extends State<TravelProviderPage> {
  late InfiniteScrollController controller;
  List<Providers> travelProviders = [];
  List<Packages> packages = [];
  int _selectedIndex = 1;
  final numberRegEx = RegExp(r'\d+');
  double itemExtent = 250;
  double get screenWidth => MediaQuery.of(context).size.width;
  int _current = 0;
  final CarouselController _controller = CarouselController();
  bool isSearch = false;
  List<Providers> filteredTravelProviders = [];
  List<Instruction> instructions = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    travelProviders =
        ProvidersList.fromJson(GlobalConfiguration().get('travelProviders'))
            .providersList!;
    packages = PackagesList.fromJson(GlobalConfiguration().get('packages'))
        .packagesList!;
    instructions =
        InstructionList.fromJson(GlobalConfiguration().get('instructions'))
            .instructionList!;
    controller = InfiniteScrollController(initialItem: 1);
    _searchController.addListener(() {
      if (_searchController.text.isNotEmpty) {
        setState(() {
          isSearch = true;
          filteredTravelProviders = travelProviders
              .where((element) => element.providerName!
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

  final List<Widget> imageSliders = imgList
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
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: const MediumText(
          'Service Providers',
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
            VSpace.sm,
            Container(
              padding: const EdgeInsets.only(left: 5, right: 5),
              margin:
                  const EdgeInsets.only(left: 5, right: 5, top: 5, bottom: 10),
              child: Column(
                children: [
                  Column(
                    children: [
                      // VSpace.md,
                      // Center(
                      //   child: InAppImage(
                      //     AppImages.verifyAccount,
                      //     height: 100,
                      //   ),
                      // ),
                      CarouselSlider(
                        items: instructions
                            .map(
                              (e) => Container(
                                decoration: BoxDecoration(
                                  color: Color(int.parse(e.instructionColor!)),
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(10.0),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                    color: AppColors.white)),
                                            child: Padding(
                                              padding: const EdgeInsets.all(10),
                                              child: MediumText(
                                                e.instructionId!,
                                                size: 14,
                                                color: AppColors.white,
                                              ),
                                            ),
                                          ),
                                          HSpace.sm,
                                          ConstrainedBox(
                                            constraints: BoxConstraints(
                                                maxWidth: MediaQuery.of(context)
                                                        .size
                                                        .width -
                                                    230),
                                            child: MediumText(
                                              e.instructionDescription!,
                                              size: 16,
                                              fontWeight: FontWeight.w300,
                                              color: AppColors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(5.0),
                                      child: Align(
                                        alignment: Alignment.centerRight,
                                        child: InAppImage(
                                          'assets/images/${e.instructionImage}',
                                          height: 150,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                            .toList(),
                        carouselController: _controller,
                        options: CarouselOptions(
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
                      VSpace.xs,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: instructions.asMap().entries.map((entry) {
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
                      VSpace.sm,
                      VSpace.md,
                      Column(
                        children: [
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
                                Container(
                                  margin: const EdgeInsets.only(
                                      left: 10, right: 10),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: AppColors.black, width: 0.1),
                                    color: AppColors.white,
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(10.0),
                                    ),
                                  ),
                                  child: TextInputField(
                                    hintText: 'Search here',
                                    prefixIcon: IconButton(
                                      onPressed: () {},
                                      icon: Icon(Icons.search,
                                          color: AppColors.pivotPayColorGreen),
                                    ),
                                    onSaved: (value) {},
                                    controller: _searchController,
                                    validator: (value) {
                                      return null;
                                    },
                                  ),
                                ),
                                VSpace.md,
                                //Expanded(
                                //child:
                                ResponsiveGridList(
                                  horizontalGridMargin: 10,
                                  horizontalGridSpacing: 15,
                                  verticalGridSpacing: 0,
                                  listViewBuilderOptions:
                                      ListViewBuilderOptions(),
                                  shrinkWrap: true,
                                  minItemWidth: 100,
                                  minItemsPerRow: 3,
                                  maxItemsPerRow: 3,
                                  children: List.generate(
                                    isSearch
                                        ? filteredTravelProviders.length
                                        : travelProviders.length,
                                    (index) => GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          PageRouter.fadeScale(
                                            () => isSearch
                                                ? TravelDetailsPage(
                                                    providerId:
                                                        filteredTravelProviders
                                                            .elementAt(index)
                                                            .providerId,
                                                    providerName:
                                                        filteredTravelProviders
                                                            .elementAt(index)
                                                            .providerName,
                                                    providerLogo:
                                                        filteredTravelProviders
                                                            .elementAt(index)
                                                            .providerLogo,
                                                    serviceDescription: widget
                                                        .serviceDescription,
                                                    providerColor:
                                                        filteredTravelProviders
                                                            .elementAt(index)
                                                            .selectedColor,
                                                  )
                                                : TravelDetailsPage(
                                                    providerId: travelProviders
                                                        .elementAt(index)
                                                        .providerId,
                                                    providerName:
                                                        travelProviders
                                                            .elementAt(index)
                                                            .providerName,
                                                    providerLogo:
                                                        travelProviders
                                                            .elementAt(index)
                                                            .providerLogo,
                                                    serviceDescription: widget
                                                        .serviceDescription,
                                                    providerColor:
                                                        travelProviders
                                                            .elementAt(index)
                                                            .selectedColor,
                                                  ),
                                          ),
                                        );
                                      },
                                      child: Card(
                                        elevation: 10,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(4.0),
                                        ),
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
                                                        offset:
                                                            const Offset(0, 4),
                                                        blurRadius: 1,
                                                        spreadRadius: 1)
                                                  ],
                                                  // borderRadius: Corners.lgBorder,
                                                  image: DecorationImage(
                                                    image: Image.asset(
                                                      isSearch
                                                          ? 'assets/images/${filteredTravelProviders.elementAt(index).providerLogo!}.png'
                                                          : 'assets/images/${travelProviders.elementAt(index).providerLogo!}.png',
                                                    ).image,
                                                  ),
                                                ),
                                                padding:
                                                    const EdgeInsets.all(10),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 5,
                                                  right: 5,
                                                  top: 8,
                                                  bottom: 10),
                                              child: Text(
                                                isSearch
                                                    ? filteredTravelProviders
                                                        .elementAt(index)
                                                        .providerName!
                                                    : travelProviders
                                                        .elementAt(index)
                                                        .providerName!,
                                                textAlign: TextAlign.center,
                                                maxLines: 2,
                                                style: const TextStyle(
                                                    fontSize: 9,
                                                    fontFamily: 'WorkSans',
                                                    overflow:
                                                        TextOverflow.ellipsis),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                //),
                                VSpace.lg,
                              ],
                            ),
                          ),
                        ],
                      ),
                      VSpace.lg
                    ],
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
