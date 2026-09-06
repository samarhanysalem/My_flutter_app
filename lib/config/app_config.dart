import 'package:flutter/material.dart';

/// Everything that varies from one Upwork customer's build to the next.
///
/// To rebrand this app for a new customer, this is the *first* file to
/// edit — see `assets/branding/README.md` for the full white-label
/// checklist (this file, the branding assets, `firebase_options.dart`, and
/// the native package name / bundle ID).
///
/// Nothing outside this file (and `AppTheme`, which reads from it) should
/// contain a customer-specific color, name, or asset path — widgets should
/// always go through [AppTheme] or [AppConfig] instead of hardcoding one.
class AppConfig {
  const AppConfig._();

  /// The OS-level app name: task switcher, browser tab, `MaterialApp.title`.
  static const String appName = 'Doctor Appointment App';

  /// The in-app display name (app bars, about screens). Usually the same as
  /// [appName], kept separate in case a customer wants a shorter in-app
  /// label than their full store-listing name.
  static const String displayName = 'Doctor Appointment App';

  /// The clinic/company this build represents — used in headers, about
  /// screens, and copy like "Sign in to book with the [companyName] team."
  static const String companyName = 'Lakeside Clinic';

  /// Primary brand color: CTAs, links, active/selected states.
  static const Color primaryColor = Color(0xFF4C6FD4);

  /// Secondary/tint brand color: light backgrounds behind primary-colored
  /// icons, badges, and highlights. Not yet consumed by any built screen —
  /// reserved for Home/Booking/etc. (e.g. the specialty shortcuts on Home)
  /// per the design handoff, so those screens have a token to build against
  /// from day one instead of introducing their own.
  static const Color accentColor = Color(0xFFEAF1FD);

  /// Optional extra brand colors from a customer's existing style guide.
  /// Null unless a customer's intake form specifies one; nothing currently
  /// reads these, but they exist so there's somewhere to put a value the
  /// intake form collects instead of it being dropped on the floor.
  static const Color? secondaryColor = null;
  static const Color? tertiaryColor = null;

  /// Google Fonts family name used throughout the app via AppTheme (e.g.
  /// 'DM Sans', 'Inter', 'Poppins'). Only change this if a customer's brand
  /// guidelines call for a specific Google Font; otherwise the template's
  /// default applies.
  static const String fontFamily = 'DM Sans';

  /// Relative to the bundled asset root. See `assets/branding/README.md`
  /// for the exact file this customer's build needs to provide.
  static const String logoAssetPath = 'assets/branding/logo.png';

  /// Support contact shown on about/help screens, if/when one exists.
  static const String supportEmail = 'support@lakesideclinic.example';
  static const String supportPhone = '+1 (555) 010-0100';

  // --- Feature toggles ---------------------------------------------------
  // Customer-specific behavior differences belong here as flags that
  // screens branch on — never as a customer name check in a widget or
  // service file. Add new toggles as new customer engagements need them.

  /// Whether this build supports multiple clinic locations, vs. the
  /// standard single-location booking flow.
  static const bool multipleClinicLocationsEnabled = false;
}
