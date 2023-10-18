import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// styles - Contains the design system for the entire app.
// Includes paddings, text styles etc.
class Insets {
  static double scale = 1;
  static double get xs => 4 * scale;
  static double get sm => 8 * scale;
  static double get md => 16 * scale;
  static double get lg => 32 * scale;
  static double get xlg => 64 * scale;
  // padding from the status bar on ios
  static double get statusBar => 34;
}

class Corners {
  static const double sm = 3;
  static const Radius smRadius = Radius.circular(sm);
  static const BorderRadius smBorder = BorderRadius.all(smRadius);

  static const double md = 5;
  static const Radius mdRadius = Radius.circular(md);
  static const BorderRadius mdBorder = BorderRadius.all(mdRadius);

  static const double lg = 8;
  static const Radius lgRadius = Radius.circular(lg);
  static const BorderRadius lgBorder = BorderRadius.all(lgRadius);

  static const double xl = 12;
  static const Radius xlRadius = Radius.circular(xl);
  static const BorderRadius xlBorder = BorderRadius.all(xlRadius);
}

class Fonts {
  static const kDefault = "Manrope";
}

class FontW {
  static const regular = FontWeight.w400;
  static const bold = FontWeight.w600;
}

/// You can use these directly if you need
/// but usually there should be a predefined style in TextStyles.
class FontSizes {
  /// Provides the ability to nudge the app-wide font scale in either direction
  static double get scale => 1;
  static double get s10 => 10 * scale;
  static double get s11 => 11 * scale;
  static double get s12 => 12 * scale;
  static double get s14 => 14 * scale;
  static double get s15 => 15 * scale;
  static double get s16 => 16 * scale;
  static double get s18 => 18 * scale;
  static double get s20 => 20 * scale;
  static double get s24 => 24 * scale;
  static double get s28 => 28 * scale;
  static double get s32 => 32 * scale;
  static double get s48 => 48 * scale;
}

class IconSizes {
  static double get scale => 1;
  static double get sm => 18 * scale;
  static double get md => 24 * scale;
}

/// TextStyles - All the core text styles for the app should be declared here.
/// Don't try and create every variant in existence here, just the high level ones.
/// More specific variants can be created on the fly using `style.copyWith()`
class TextStyles {
  static const TextStyle kDefault =
      TextStyle(fontFamily: Fonts.kDefault, fontWeight: FontW.regular);

  static TextStyle get h1 => kDefault.copyWith(
        fontWeight: FontW.bold,
        fontSize: FontSizes.s48,
      );

  static TextStyle get h2 => h1.copyWith(
        fontSize: FontSizes.s24,
        letterSpacing: -.5,
      );

  static TextStyle get h3 => h1.copyWith(
        fontSize: FontSizes.s14,
        letterSpacing: -.05,
      );

  static TextStyle get title1 => kDefault.copyWith(
        fontWeight: FontW.bold,
        fontSize: FontSizes.s18,
      );

  static TextStyle get title2 => title1.copyWith(
        fontWeight: FontW.regular,
        fontSize: FontSizes.s16,
      );

  static TextStyle get body1 => kDefault.copyWith(
        fontWeight: FontW.regular,
        fontSize: FontSizes.s14,
      );

  static TextStyle get body2 => body1.copyWith(
        fontSize: FontSizes.s12,
        height: 1.5,
        letterSpacing: .2,
      );

  static TextStyle get body3 => body1.copyWith(
        fontSize: FontSizes.s12,
        height: 1.5,
        fontWeight: FontW.bold,
      );

  static TextStyle get caption => kDefault.copyWith(
        fontWeight: FontW.regular,
        fontSize: FontSizes.s12,
      );
}
