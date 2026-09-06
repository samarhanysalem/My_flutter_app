import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// Snackbar shown when tapping a feature that isn't built yet.
  ///
  /// In en, this message translates to:
  /// **'{feature} isn\'t available yet.'**
  String notAvailableYet(String feature);

  /// Login screen heading.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get welcomeBack;

  /// Login screen subtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to book with the {companyName} team.'**
  String signInSubtitle(String companyName);

  /// Email text field label.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// Password text field label.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// Login screen forgot-password link.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// Sign-in button label.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// Divider text between sign-in methods.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get orDivider;

  /// Phone sign-in button label.
  ///
  /// In en, this message translates to:
  /// **'Continue with phone number'**
  String get continueWithPhone;

  /// Prompt before the create-account link on the login screen.
  ///
  /// In en, this message translates to:
  /// **'New here? '**
  String get newHereQuestion;

  /// Link to the register screen from the login screen.
  ///
  /// In en, this message translates to:
  /// **'Create an account'**
  String get createAnAccount;

  /// Feature name used in the not-available-yet notice for forgot password.
  ///
  /// In en, this message translates to:
  /// **'Password reset'**
  String get passwordResetFeature;

  /// Feature name used in the not-available-yet notice for phone sign-in.
  ///
  /// In en, this message translates to:
  /// **'Phone sign-in'**
  String get phoneSignInFeature;

  /// Register screen heading.
  ///
  /// In en, this message translates to:
  /// **'Create your account'**
  String get createYourAccount;

  /// Register screen subtitle.
  ///
  /// In en, this message translates to:
  /// **'Takes a minute. You will pay at the clinic, so no card needed.'**
  String get registerSubtitle;

  /// Full name text field label.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fullNameLabel;

  /// Phone text field label.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phoneLabel;

  /// Prompt before the sign-in link on the register screen.
  ///
  /// In en, this message translates to:
  /// **'Already registered? '**
  String get alreadyRegisteredQuestion;

  /// Create-account button label.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get createAccount;

  /// Validation error when the email field is empty.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get enterYourEmail;

  /// Validation error when the email field doesn't look like an email.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email'**
  String get enterAValidEmail;

  /// Validation error when the sign-in password field is empty.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get enterYourPassword;

  /// Validation error when the full name field is empty.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name'**
  String get enterYourFullName;

  /// Validation error when the phone field is empty.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number'**
  String get enterYourPhoneNumber;

  /// Validation error when the phone field has too few digits.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid phone number'**
  String get enterAValidPhoneNumber;

  /// Validation error when the sign-up password is too short.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get passwordTooShort;

  /// Validation error when the sign-up password lacks a letter or digit.
  ///
  /// In en, this message translates to:
  /// **'Include at least one letter and one number'**
  String get passwordNeedsLetterAndNumber;

  /// Terms checkbox label on the register screen.
  ///
  /// In en, this message translates to:
  /// **'I agree to {companyName}\'s terms and privacy policy.'**
  String agreeToTerms(String companyName);

  /// Tooltip for the show-password icon button.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get showPassword;

  /// Tooltip for the hide-password icon button.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get hidePassword;

  /// Placeholder text in the home screen search bar.
  ///
  /// In en, this message translates to:
  /// **'Search doctors, specialties'**
  String get searchHint;

  /// Home screen doctor list section title.
  ///
  /// In en, this message translates to:
  /// **'Our doctors'**
  String get ourDoctors;

  /// Shown when the doctor list fails to load.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong loading doctors. Please try again.'**
  String get loadDoctorsError;

  /// Empty state when there are no doctors at all.
  ///
  /// In en, this message translates to:
  /// **'No doctors available yet.'**
  String get noDoctorsAvailable;

  /// Empty state when a search/specialty filter matches nothing.
  ///
  /// In en, this message translates to:
  /// **'No doctors match your search.'**
  String get noDoctorsMatchSearch;

  /// Sign-out confirmation dialog title.
  ///
  /// In en, this message translates to:
  /// **'Sign out?'**
  String get signOutQuestion;

  /// Generic cancel button label.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Sign-out button label.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// Snackbar shown when sign-out throws.
  ///
  /// In en, this message translates to:
  /// **'Sign out failed. Please try again.'**
  String get signOutFailed;

  /// Specialty shortcut that clears the filter.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get specialtyAll;

  /// Short label for the Cardiologist specialty shortcut.
  ///
  /// In en, this message translates to:
  /// **'Cardio'**
  String get specialtyCardio;

  /// Short label for the Orthopedic Surgeon specialty shortcut.
  ///
  /// In en, this message translates to:
  /// **'Ortho'**
  String get specialtyOrtho;

  /// Short label for the Neurologist specialty shortcut.
  ///
  /// In en, this message translates to:
  /// **'Neuro'**
  String get specialtyNeuro;

  /// Short label for the Dermatologist specialty shortcut.
  ///
  /// In en, this message translates to:
  /// **'Derma'**
  String get specialtyDerma;

  /// Short label for the Pediatrician specialty shortcut.
  ///
  /// In en, this message translates to:
  /// **'Pediatric'**
  String get specialtyPediatric;

  /// Short label for the Endocrinologist specialty shortcut.
  ///
  /// In en, this message translates to:
  /// **'Endocrine'**
  String get specialtyEndocrine;

  /// Short label for the Psychiatrist specialty shortcut.
  ///
  /// In en, this message translates to:
  /// **'Psych'**
  String get specialtyPsych;

  /// Short label for the Gastroenterologist specialty shortcut.
  ///
  /// In en, this message translates to:
  /// **'Gastro'**
  String get specialtyGastro;

  /// Short label for the Ophthalmologist specialty shortcut.
  ///
  /// In en, this message translates to:
  /// **'Eye'**
  String get specialtyEye;

  /// Short label for the Family Medicine specialty shortcut.
  ///
  /// In en, this message translates to:
  /// **'Family'**
  String get specialtyFamily;

  /// Full specialty name shown on a doctor's card/profile.
  ///
  /// In en, this message translates to:
  /// **'Cardiologist'**
  String get specialtyFullCardiologist;

  /// Full specialty name shown on a doctor's card/profile.
  ///
  /// In en, this message translates to:
  /// **'Orthopedic Surgeon'**
  String get specialtyFullOrthopedicSurgeon;

  /// Full specialty name shown on a doctor's card/profile.
  ///
  /// In en, this message translates to:
  /// **'Neurologist'**
  String get specialtyFullNeurologist;

  /// Full specialty name shown on a doctor's card/profile.
  ///
  /// In en, this message translates to:
  /// **'Dermatologist'**
  String get specialtyFullDermatologist;

  /// Full specialty name shown on a doctor's card/profile.
  ///
  /// In en, this message translates to:
  /// **'Pediatrician'**
  String get specialtyFullPediatrician;

  /// Full specialty name shown on a doctor's card/profile.
  ///
  /// In en, this message translates to:
  /// **'Endocrinologist'**
  String get specialtyFullEndocrinologist;

  /// Full specialty name shown on a doctor's card/profile.
  ///
  /// In en, this message translates to:
  /// **'Psychiatrist'**
  String get specialtyFullPsychiatrist;

  /// Full specialty name shown on a doctor's card/profile.
  ///
  /// In en, this message translates to:
  /// **'Gastroenterologist'**
  String get specialtyFullGastroenterologist;

  /// Full specialty name shown on a doctor's card/profile.
  ///
  /// In en, this message translates to:
  /// **'Ophthalmologist'**
  String get specialtyFullOphthalmologist;

  /// Full specialty name shown on a doctor's card/profile.
  ///
  /// In en, this message translates to:
  /// **'Family Medicine'**
  String get specialtyFullFamilyMedicine;

  /// Morning greeting with the user's first name.
  ///
  /// In en, this message translates to:
  /// **'Good morning, {name}'**
  String greetingMorningWithName(String name);

  /// Morning greeting when no name is available.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get greetingMorningNoName;

  /// Afternoon greeting with the user's first name.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon, {name}'**
  String greetingAfternoonWithName(String name);

  /// Afternoon greeting when no name is available.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get greetingAfternoonNoName;

  /// Evening greeting with the user's first name.
  ///
  /// In en, this message translates to:
  /// **'Good evening, {name}'**
  String greetingEveningWithName(String name);

  /// Evening greeting when no name is available.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get greetingEveningNoName;

  /// Doctor profile screen title.
  ///
  /// In en, this message translates to:
  /// **'Doctor profile'**
  String get doctorProfileTitle;

  /// Quick action label to message the doctor.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get messageAction;

  /// Quick action label to call the doctor.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get callAction;

  /// Quick action label to view the clinic location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get locationAction;

  /// Feature name used in the not-available-yet notice for booking.
  ///
  /// In en, this message translates to:
  /// **'Booking'**
  String get bookingFeature;

  /// Book appointment button label.
  ///
  /// In en, this message translates to:
  /// **'Book appointment'**
  String get bookAppointment;

  /// Doctor profile About section title.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutSectionTitle;

  /// Fallback copy when a doctor has no bio.
  ///
  /// In en, this message translates to:
  /// **'No bio available yet for this doctor.'**
  String get noBioAvailable;

  /// Doctor profile availability section title.
  ///
  /// In en, this message translates to:
  /// **'Available today'**
  String get availableToday;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
