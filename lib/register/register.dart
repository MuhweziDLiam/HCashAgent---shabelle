import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:country_picker/country_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pivotpay/common/pin.dart';
import 'package:pivotpay/login/login_screen.dart';
import 'package:pivotpay/models/onboarding_countries.dart';
import 'package:http/http.dart' as http;
import 'package:pivotpay/policy/policy.dart';
import 'package:pivotpay/register/otp.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pivotpay/components/inputs/pinfield.dart';
import 'package:pivotpay/components/inputs/textfield.dart';
import 'package:pivotpay/components/others/buttons.dart';
import 'package:pivotpay/components/others/image.dart';
import 'package:pivotpay/components/others/spacers.dart';
import 'package:pivotpay/components/others/text.dart';
import 'package:pivotpay/functions/shared_modules.dart';
import 'package:pivotpay/home/home_screen.dart';
import 'package:pivotpay/models/user.dart';
import 'package:pivotpay/network/api_service.dart';
import 'package:pivotpay/utils/resources.dart';
import 'package:pivotpay/utils/routing.dart';
import 'package:pivotpay/utils/style.dart';
import 'package:pivotpay/validators/validators.dart';

const List<String> scopes = <String>[
  'email',
  'https://www.googleapis.com/auth/user.birthday.read',
  'https://www.googleapis.com/auth/user.gender.read',
  'https://www.googleapis.com/auth/userinfo.profile',
  'https://www.googleapis.com/auth/user.phonenumbers.read'
];

GoogleSignIn _googleSignIn = GoogleSignIn(
  // Optional clientId
  // clientId: 'your-client_id.apps.googleusercontent.com',
  scopes: scopes,
);

class RegisterScreen extends StatefulWidget {
  bool deviceIdExists;
  String deviceId, osType;
  RegisterScreen(
      {Key? key,
      this.deviceIdExists = false,
      this.deviceId = '',
      this.osType = ''})
      : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formRegisterKey = GlobalKey<FormState>();
  bool ignoreTaps = false;
  String? _countryFlag, _prefixCode, version;
  List<OnboardingCountry> onboardingCountries = [];
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _idNumberController = TextEditingController();
  GoogleSignInAccount? _currentUser;
  bool _isAuthorized = false;
  bool termsAccepted = false;
  bool _isSignedIn = false;
  String dob = '',
      email = '',
      gender = '',
      photoUrl = '',
      countryCode = '',
      countryName = '',
      currencyCode = '';

  @override
  void initState() {
    super.initState();
    getInfo();
    _googleSignIn.onCurrentUserChanged
        .listen((GoogleSignInAccount? account) async {
      bool isAuthorized = account != null;
      if (kIsWeb && account != null) {
        isAuthorized = await _googleSignIn.canAccessScopes(scopes);
      }
      if (isAuthorized) {
        getGoogleData(account!);
      }
    });
  }

  getGoogleData(GoogleSignInAccount user) {
    if (!mounted) return;
    getGoogleUserDetails(context, user).then((value) {
      if (value.status!) {
        setState(() {
          _firstNameController.value = TextEditingValue(text: value.firstName!);
          _lastNameController.value = TextEditingValue(text: value.lastName!);
          _phoneNumberController.value =
              TextEditingValue(text: value.phoneNumber!);
          email = value.email!;
          dob = value.dob!;
          gender = value.gender!;
          photoUrl = value.profilePicture!;
        });
      } else {
        responseDialog(
          'Sorry',
          'Okay',
          value.responseMessage!,
          _formRegisterKey.currentContext!,
        );
      }
    });
  }

  getInfo() async {
    WidgetsBinding.instance
        .addPostFrameCallback((_) => getSupportedCountries());
    final versionInfo = await PackageInfo.fromPlatform();
    version = '${versionInfo.version}+${versionInfo.buildNumber}';
  }

  getSupportedCountries() async {
    final progress = ProgressHUD.of(_formRegisterKey.currentContext!);
    progress!.showWithText('Fetching Data...');
    setState(() {
      ignoreTaps = true;
    });
    getOnboardingCountries(
      _formRegisterKey.currentContext!,
    ).then((value) async {
      if (value.status!) {
        progress.dismiss();
        setState(() {
          ignoreTaps = false;
          onboardingCountries = value.countryList!
              .where((element) => element.countryStatus == 'ACTIVE')
              .toList();
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
          _formRegisterKey.currentContext!,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: IgnorePointer(
        ignoring: ignoreTaps,
        child: ProgressHUD(
          child: Builder(
            builder: (context) => SingleChildScrollView(
              child: Form(
                key: _formRegisterKey,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    border: Border.all(color: AppColors.black, width: 0.2),
                    borderRadius: const BorderRadius.all(
                      Radius.circular(10.0),
                    ),
                  ),
                  margin: const EdgeInsets.fromLTRB(15, 40, 15, 20),
                  padding: const EdgeInsets.only(top: 10, bottom: 20),
                  child: Column(
                    children: [
                      InAppImage(
                        AppImages.ppLogoColored,
                        height: 80,
                      ),
                      VSpace.sm,
                      Text.rich(
                        TextSpan(
                          text: 'Create your',
                          style: TextStyle(
                            color: AppColors.primaryColor,
                            fontFamily: 'Lato',
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                          ),
                          children: <InlineSpan>[
                            TextSpan(
                              text: ' account!',
                              style: TextStyle(
                                  color: AppColors.pivotPayColorGreen,
                                  fontFamily: 'Lato'),
                            )
                          ],
                        ),
                      ),
                      VSpace.md,
                      VSpace.sm,
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: Insets.md),
                        child: TextInputField(
                          readOnly: true,
                          prefixIcon: Icon(
                            Icons.location_on,
                            color: AppColors.pivotPayColorGreen,
                          ),
                          controller: _countryController,
                          hintText: 'Country/Region',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please Tap to select your Country/Region';
                            }
                            return null;
                          },
                          onTap: () {
                            showCountryPicker(
                              context: context,
                              countryFilter: onboardingCountries
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
                                getCurrencyDetails(country.countryCode);
                                setState(() {
                                  _countryFlag = country.flagEmoji;
                                  _countryController.value = TextEditingValue(
                                      text:
                                          '${_countryFlag!}    ${country.name}');
                                  _prefixCode = country.phoneCode;
                                  countryCode = country.countryCode;
                                  countryName = country.name;
                                  _phoneNumberController.value =
                                      TextEditingValue(text: '+$_prefixCode');
                                });
                              },
                            );
                          },
                          onSaved: (value) {},
                        ),
                      ),
                      VSpace.md,
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: Insets.md),
                        child: TextInputField(
                          hintText: 'First name',
                          prefixIcon: Icon(
                            Icons.account_circle_rounded,
                            color: AppColors.pivotPayColorGreen,
                          ),
                          validator: (value) {
                            value = value!.replaceAll(' ', '');
                            if (value.isEmpty) {
                              return 'Please enter your first name';
                            }
                            if (!validateSpecialCharacters(value)) {
                              return 'Invalid username supplied';
                            }
                            return null;
                          },
                          controller: _firstNameController,
                          keyboardType: TextInputType.text,
                          onTap: () {},
                          onSaved: (value) {},
                        ),
                      ),
                      VSpace.md,
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: Insets.md),
                        child: TextInputField(
                          hintText: 'Last name',
                          prefixIcon: Icon(
                            Icons.account_circle_rounded,
                            color: AppColors.pivotPayColorGreen,
                          ),
                          validator: (value) {
                            value = value!.replaceAll(' ', '');
                            if (value.isEmpty) {
                              return 'Please enter your last name';
                            }
                            if (!validateSpecialCharacters(value)) {
                              return 'Invalid username supplied';
                            }
                            return null;
                          },
                          controller: _lastNameController,
                          keyboardType: TextInputType.text,
                          onTap: () {},
                          onSaved: (value) {},
                        ),
                      ),
                      VSpace.md,
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: Insets.md),
                        child: TextInputField(
                          decoration: InputDecoration(
                            isDense: true,
                            prefixText: _prefixCode,
                            prefixStyle: TextStyle(
                                backgroundColor: AppColors.primaryColor),
                          ),
                          hintText: 'Enter your phone number',
                          controller: _phoneNumberController,
                          prefixIcon: Icon(
                            Icons.phone,
                            color: AppColors.pivotPayColorGreen,
                          ),
                          onSaved: (value) {},
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
                      ),
                      VSpace.md,
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: Insets.md),
                        child: TextInputField(
                          hintText: 'Username',
                          prefixIcon: Icon(
                            Icons.account_circle_rounded,
                            color: AppColors.pivotPayColorGreen,
                          ),
                          validator: (value) {
                            value = value!.replaceAll(' ', '');
                            if (value.isEmpty) {
                              return 'Please enter your Username';
                            }
                            if (!validateSpecialCharacters(value)) {
                              return 'Invalid username supplied';
                            }
                            return null;
                          },
                          controller: _usernameController,
                          keyboardType: TextInputType.text,
                          onTap: () {},
                          onSaved: (value) {},
                        ),
                      ),
                      VSpace.md,
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: Insets.md),
                        child: TextInputField(
                          hintText: 'Id Number',
                          prefixIcon: Icon(
                            Icons.account_circle_rounded,
                            color: AppColors.pivotPayColorGreen,
                          ),
                          validator: (value) {
                            value = value!.replaceAll(' ', '');
                            if (value.isEmpty) {
                              return 'Please enter Id Number';
                            }
                            if (!validateSpecialCharacters(value)) {
                              return 'Invalid Id Number supplied';
                            }
                            return null;
                          },
                          controller: _idNumberController,
                          keyboardType: TextInputType.text,
                          onTap: () {},
                          onSaved: (value) {},
                        ),
                      ),
                      VSpace.md,
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: Insets.md,
                        ),
                        child: TextInputField(
                          hintText: 'Pin',
                          obsecureText: true,
                          prefixIcon: Icon(
                            Icons.lock,
                            color: AppColors.pivotPayColorGreen,
                          ),
                          validator: (value) {
                            value = value!.replaceAll(' ', '');
                            if (value.isEmpty) {
                              return 'Please enter your Pin';
                            }
                            if (!validateNumbers(value)) {
                              return 'Invalid pin supplied';
                            }
                            if (value.length > 4) {
                              return 'Please enter only 4 numbers';
                            }
                            return null;
                          },
                          controller: _pinController,
                          keyboardType: TextInputType.number,
                          onTap: () {},
                          onSaved: (value) {},
                        ),
                      ),
                      VSpace.md,
                      VSpace.sm,
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pushAndRemoveUntil(
                              context,
                              PageRouter.fadeScale(
                                () => LoginScreen(
                                  deviceId: widget.deviceId,
                                  osType: widget.osType,
                                  deviceIdExists: widget.deviceIdExists,
                                ),
                              ),
                              (route) => false,
                            );
                          },
                          child: Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Already have an account?',
                                  style: TextStyles.caption.copyWith(
                                    color: AppColors.primaryColor,
                                    fontFamily: 'WorkSans',
                                    fontSize: 15,
                                  ),
                                ),
                                TextSpan(
                                  text: ' Login',
                                  style: TextStyles.caption.copyWith(
                                    color: AppColors.pivotPayColorGreen,
                                    fontSize: 16,
                                    fontFamily: 'WorkSans',
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            style: TextStyles.caption
                                .copyWith(color: Colors.black, fontSize: 15),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: Insets.md),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size.zero,
                            padding: const EdgeInsets.fromLTRB(
                              10,
                              14,
                              10,
                              14,
                            ),
                          ),
                          onPressed: () {
                            if (_formRegisterKey.currentState!.validate()) {
                              setState(() {
                                _formRegisterKey.currentState!.save();
                              });
                              checkAccountDetails();
                            }
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              MediumText(
                                'Register',
                                color: AppColors.white,
                              )
                            ],
                          ),
                        ),
                      ),
                      const VSpace(10),
                      Padding(
                        padding: const EdgeInsets.only(left: 10, right: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Container(
                              width: 100,
                              height: 1.5,
                              color: Colors.grey[300],
                            ),
                            const SmallText(
                              ' or ',
                            ),
                            Container(
                              width: 100,
                              height: 1.5,
                              color: Colors.grey[300],
                            ),
                          ],
                        ),
                      ),
                      const VSpace(10),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: Insets.md),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              minimumSize: Size.zero,
                              padding: const EdgeInsets.fromLTRB(
                                10,
                                12,
                                10,
                                12,
                              ),
                              backgroundColor:
                                  AppColors.black.withOpacity(0.1)),
                          onPressed: () async {
                            if (_countryController.text.isEmpty) {
                              responseDialog(
                                  'Sorry',
                                  'Okay',
                                  'Please select country/Region to proceed',
                                  context);
                            } else {
                              final progress = ProgressHUD.of(context);
                              progress!.show();
                              setState(() {
                                ignoreTaps = true;
                              });
                              try {
                                _isSignedIn = await _googleSignIn.isSignedIn();
                                if (_isSignedIn) {
                                  await _googleSignIn.disconnect();
                                }
                                await _googleSignIn.signIn();
                                progress.dismiss();
                                setState(() {
                                  ignoreTaps = false;
                                });
                              } catch (error) {
                                progress.dismiss();
                                setState(() {
                                  ignoreTaps = false;
                                });
                                responseDialog(
                                    'Sorry', 'Okay', error.toString(), context);
                              }
                            }
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              InAppImage(
                                AppIcons.google,
                                height: 20,
                              ),
                              HSpace.md,
                              const MediumText('Sign Up with Google')
                            ],
                          ),
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
    );
  }

  checkAccountDetails() {
    final progress = ProgressHUD.of(_formRegisterKey.currentContext!);
    progress!.showWithText('Checking Phone Number...');
    setState(() {
      ignoreTaps = true;
    });
    final Map data = {
      'phone': _phoneNumberController.text,
    };
    checkPhoneNumber(context, data).then((value) {
      if (value.status!) {
        final Map data = {
          'user': _usernameController.text,
        };
        progress.dismiss();
        progress.showWithText('Checking Username...');
        checkUserNameExists(context, data).then((value) {
          if (value.status!) {
            progress.dismiss();
            setState(() {
              ignoreTaps = false;
            });
            showTerms();
          } else {
            progress.dismiss();
            setState(() {
              ignoreTaps = false;
            });
            responseDialog(
              'Sorry',
              'Okay',
              value.responseMessage!,
              _formRegisterKey.currentContext!,
            );
          }
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
          _formRegisterKey.currentContext!,
        );
      }
    });
  }

  showTerms() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => StatefulBuilder(builder: (context, setState) {
        return Dialog(
          insetPadding: const EdgeInsets.all(50),
          shape: ContinuousRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.all(5),
            child: Scrollbar(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Column(
                      children: [
                        const SizedBox(
                          height: 10,
                        ),
                        const MediumText(
                          'Terms and Conditions',
                          size: 16,
                          color: AppColors.black,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 10, right: 10),
                          child: Divider(
                            color: AppColors.primaryColor,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 8,
                          ),
                          child: Row(
                            children: [
                              Checkbox(
                                value: termsAccepted,
                                onChanged: (value) {
                                  setState(() {
                                    if (value == true) {
                                      termsAccepted = true;
                                    } else {
                                      termsAccepted = false;
                                    }
                                  });
                                },
                                activeColor: AppColors.primaryColor,
                              ),
                              Expanded(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Flexible(
                                      child: Row(
                                        children: [
                                          Flexible(
                                            child: HtmlWidget(
                                              '<p>I agree to the <strong><a href="#">Terms & Conditions</a></strong> of Pivot Pay.</p>',
                                              textStyle: const TextStyle(
                                                fontFamily: 'Lato',
                                                color: AppColors.black,
                                              ),
                                              onTapUrl: (p0) {
                                                fromAsset(
                                                        'assets/docs/privacy_policy.pdf',
                                                        'privacy_policy.pdf')
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
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                minimumSize: Size.zero,
                                padding: const EdgeInsets.fromLTRB(
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
                                          () => OTPPage(
                                            source: widget.osType,
                                            appVersion: version,
                                            email: email,
                                            imgUrl: photoUrl,
                                            deviceIdExists:
                                                widget.deviceIdExists,
                                            idNumber: _idNumberController.text,
                                            firstName:
                                                _firstNameController.text,
                                            lastName: _lastNameController.text,
                                            country: countryName,
                                            countryCode: countryCode,
                                            deviceId: widget.deviceId,
                                            currencyCode: currencyCode,
                                            gender: gender,
                                            dob: dob,
                                            userName: _usernameController.text,
                                            pin: _pinController.text,
                                            phoneNumber:
                                                _phoneNumberController.text,
                                          ),
                                        ),
                                      );
                                    }
                                  : null,
                              child: const MediumText(
                                'Proceed',
                                color: AppColors.white,
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

  getCurrencyDetails(String countryCode) {
    final progress = ProgressHUD.of(_formRegisterKey.currentContext!);
    setState(() {
      ignoreTaps = true;
    });
    progress!.showWithText('Country Details ...');
    final Map data = {
      'countryCode': countryCode,
    };
    getCountryDetails(_formRegisterKey.currentContext!, data)
        .then((value) async {
      if (value.status!) {
        progress.dismiss();
        setState(() {
          ignoreTaps = false;
        });
        currencyCode = value.currency!;
      } else {
        progress.dismiss();
        setState(() {
          ignoreTaps = false;
        });
        responseDialog(
          'Sorry',
          'Okay',
          value.responseMessage!,
          _formRegisterKey.currentContext!,
        );
      }
    });
  }
}
