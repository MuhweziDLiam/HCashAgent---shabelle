import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pivotpay/utils/resources.dart';
import 'package:pivotpay/utils/style.dart';

class AppTheme {
  AppTheme._();

  static final textTheme = TextTheme(
    headline1: TextStyles.h1,
    headline2: TextStyles.h2,
    headline3: TextStyles.h3,
    bodyText1: TextStyles.body1,
    bodyText2: TextStyles.body2,
    caption: TextStyles.caption,
    button: TextStyles.body1.copyWith(
      color: Colors.white,
    ),
  );

  static ThemeData get _baseTheme => ThemeData(
        textTheme: textTheme,
        primaryColor: AppColors.primaryColor,
        fontFamily: Fonts.kDefault,
        appBarTheme: AppBarTheme(
            systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: AppColors.primaryColor,
        )),
        scaffoldBackgroundColor: AppColors.scaffoldColor,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: Insets.md),
            textStyle: TextStyles.h3,
            elevation: .0,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            backgroundColor: AppColors.primaryColor,
            foregroundColor: Colors.white,
          ),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          selectedItemColor: AppColors.primaryColor,
          unselectedItemColor: AppColors.greyColor2,
          selectedLabelStyle: TextStyles.body2,
          unselectedLabelStyle: TextStyles.caption,
          type: BottomNavigationBarType.fixed,
          showSelectedLabels: true,
          showUnselectedLabels: true,
        ),
        iconTheme: IconThemeData(
          color: AppColors.greyColor,
        ),
      );

  static ThemeData get defaultTheme =>
      _baseTheme.copyWith(brightness: Brightness.light);
}
