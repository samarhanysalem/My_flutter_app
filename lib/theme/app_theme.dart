import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../config/app_config.dart';

/// Single source of truth for this app's design tokens: colors, typography,
/// corner radius, and spacing.
///
/// Brand colors are pulled from [AppConfig] so a new customer's palette only
/// means editing that file; the neutrals, type scale, radii, and spacing
/// below are the shared design system and stay the same across customers.
/// Every screen should build its visuals from here rather than hardcoding
/// a color, font, radius, or gap.
class AppTheme {
  const AppTheme._();

  // --- Brand colors (per-customer, from AppConfig) --------------------
  static const Color primary = AppConfig.primaryColor;
  static const Color accentTint = AppConfig.accentColor;

  /// Extra brand colors from a customer's style guide, if they gave one.
  /// Null for most customers — check for null before use.
  static const Color? secondary = AppConfig.secondaryColor;
  static const Color? tertiary = AppConfig.tertiaryColor;

  /// Text/icon color for content rendered on top of a [primary]-colored
  /// surface (buttons, the logo badge, a checked checkbox) — distinct from
  /// [surface] even though both are white today, since a future palette
  /// could change one without the other.
  static const Color onPrimary = Colors.white;

  // --- Neutral colors (shared design system) ---------------------------
  static const Color ink = Color(0xFF131316);
  static const Color textSecondary = Color(0xFF6A6A74);
  static const Color textPlaceholder = Color(0xFFA5A5AE);
  static const Color textDisabled = Color(0xFF8A8A93);
  static const Color surface = Colors.white;
  static const Color screenGround = Color(0xFFF6F6F7);
  static const Color border = Color(0xFFE6E6EA);
  static const Color divider = Color(0xFFE2E2E7);
  static const Color disabledFill = Color(0xFFDCDCE0);
  static const Color checkboxBorder = Color(0xFFD3D3DA);

  /// Rating-star color. A conventional amber/gold across virtually every
  /// app's rating UI, not a brand color — but still centralized here rather
  /// than hardcoded in a widget, per the white-label rules.
  static const Color ratingStar = Color(0xFFF5A623);

  /// Placeholder avatar background tints, cycled by list index for doctor
  /// cards that don't have a real photo.
  static const List<Color> avatarPalette = [
    Color(0xFFFDE8E8),
    Color(0xFFE6EFFE),
    Color(0xFFEAF6EC),
    Color(0xFFF3E8FD),
  ];

  // --- Corner radius -----------------------------------------------------
  static const double radiusXs = 5; // custom checkboxes
  static const double radiusSmall = 8; // fields, buttons
  static const double radiusMedium = 12; // cards (Home/Booking/etc.)
  static const double radiusLarge = 13; // the app mark badge
  static const double radiusTile = 14; // specialty shortcut tiles

  // --- Spacing scale, from the design spec's gap rhythm -------------------
  static const double spacing2 = 2;
  static const double spacing3 = 3;
  static const double spacing4 = 4;
  static const double spacing6 = 6;
  static const double spacing8 = 8;
  static const double spacing10 = 10;
  static const double spacing12 = 12;
  static const double spacing14 = 14;
  static const double spacing18 = 18;
  static const double spacing20 = 20;
  static const double spacing22 = 22;
  static const double spacing24 = 24;
  static const double spacing28 = 28;

  // --- Typography ----------------------------------------------------
  // Every style routes through this one call, so AppConfig.fontFamily is
  // the only place a customer's font preference needs to change.
  static TextStyle _font({
    required double fontSize,
    FontWeight? fontWeight,
    double? letterSpacing,
    double? height,
    Color? color,
  }) => GoogleFonts.getFont(
    AppConfig.fontFamily,
    fontSize: fontSize,
    fontWeight: fontWeight,
    letterSpacing: letterSpacing,
    height: height,
    color: color,
  );

  static TextStyle get heading => _font(
    fontSize: 24,
    fontWeight: FontWeight.w500,
    letterSpacing: -0.02 * 24,
    color: ink,
  );

  static TextStyle get subtitle => _font(fontSize: 13, color: textSecondary);

  static TextStyle get fieldLabel =>
      _font(fontSize: 12, color: textSecondary);

  static TextStyle get body => _font(fontSize: 14, color: ink);

  static TextStyle get buttonLabel =>
      _font(fontSize: 15, fontWeight: FontWeight.w500);

  static TextStyle get linkAccent =>
      _font(fontSize: 13, fontWeight: FontWeight.w500, color: primary);

  static TextStyle get linkAccentSmall => _font(fontSize: 12, color: primary);

  static TextStyle get caption =>
      _font(fontSize: 11, color: textPlaceholder);

  static TextStyle get captionSecondary =>
      _font(fontSize: 11, color: textSecondary);

  static TextStyle get greeting =>
      _font(fontSize: 18, fontWeight: FontWeight.w500, color: ink);

  static TextStyle get sectionTitle =>
      _font(fontSize: 14, fontWeight: FontWeight.w500, color: ink);

  static TextStyle get cardTitle =>
      _font(fontSize: 14, fontWeight: FontWeight.w500, color: ink);

  static TextStyle get termsText =>
      _font(fontSize: 12, height: 1.45, color: textSecondary);

  /// Color left unset — callers combine this with `Theme.of(context)`'s
  /// error color, since that's a `BuildContext`-scoped value AppTheme
  /// doesn't have access to.
  static TextStyle get errorText => _font(fontSize: 12);

  /// The MaterialApp-level ThemeData, seeded from the brand primary color.
  static ThemeData get materialTheme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: primary),
    scaffoldBackgroundColor: screenGround,
  );
}
