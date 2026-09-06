// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String notAvailableYet(String feature) {
    return '$feature isn\'t available yet.';
  }

  @override
  String get welcomeBack => 'Welcome back';

  @override
  String signInSubtitle(String companyName) {
    return 'Sign in to book with the $companyName team.';
  }

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get signIn => 'Sign in';

  @override
  String get orDivider => 'or';

  @override
  String get continueWithPhone => 'Continue with phone number';

  @override
  String get newHereQuestion => 'New here? ';

  @override
  String get createAnAccount => 'Create an account';

  @override
  String get passwordResetFeature => 'Password reset';

  @override
  String get phoneSignInFeature => 'Phone sign-in';

  @override
  String get createYourAccount => 'Create your account';

  @override
  String get registerSubtitle =>
      'Takes a minute. You will pay at the clinic, so no card needed.';

  @override
  String get fullNameLabel => 'Full name';

  @override
  String get phoneLabel => 'Phone';

  @override
  String get alreadyRegisteredQuestion => 'Already registered? ';

  @override
  String get createAccount => 'Create account';

  @override
  String get enterYourEmail => 'Enter your email';

  @override
  String get enterAValidEmail => 'Enter a valid email';

  @override
  String get enterYourPassword => 'Enter your password';

  @override
  String get enterYourFullName => 'Enter your full name';

  @override
  String get enterYourPhoneNumber => 'Enter your phone number';

  @override
  String get enterAValidPhoneNumber => 'Enter a valid phone number';

  @override
  String get passwordTooShort => 'Password must be at least 8 characters';

  @override
  String get passwordNeedsLetterAndNumber =>
      'Include at least one letter and one number';

  @override
  String agreeToTerms(String companyName) {
    return 'I agree to $companyName\'s terms and privacy policy.';
  }

  @override
  String get showPassword => 'Show password';

  @override
  String get hidePassword => 'Hide password';

  @override
  String get searchHint => 'Search doctors, specialties';

  @override
  String get ourDoctors => 'Our doctors';

  @override
  String get loadDoctorsError =>
      'Something went wrong loading doctors. Please try again.';

  @override
  String get noDoctorsAvailable => 'No doctors available yet.';

  @override
  String get noDoctorsMatchSearch => 'No doctors match your search.';

  @override
  String get signOutQuestion => 'Sign out?';

  @override
  String get cancel => 'Cancel';

  @override
  String get signOut => 'Sign out';

  @override
  String get signOutFailed => 'Sign out failed. Please try again.';

  @override
  String get specialtyAll => 'All';

  @override
  String get specialtyCardio => 'Cardio';

  @override
  String get specialtyOrtho => 'Ortho';

  @override
  String get specialtyNeuro => 'Neuro';

  @override
  String get specialtyDerma => 'Derma';

  @override
  String get specialtyPediatric => 'Pediatric';

  @override
  String get specialtyEndocrine => 'Endocrine';

  @override
  String get specialtyPsych => 'Psych';

  @override
  String get specialtyGastro => 'Gastro';

  @override
  String get specialtyEye => 'Eye';

  @override
  String get specialtyFamily => 'Family';

  @override
  String get specialtyFullCardiologist => 'Cardiologist';

  @override
  String get specialtyFullOrthopedicSurgeon => 'Orthopedic Surgeon';

  @override
  String get specialtyFullNeurologist => 'Neurologist';

  @override
  String get specialtyFullDermatologist => 'Dermatologist';

  @override
  String get specialtyFullPediatrician => 'Pediatrician';

  @override
  String get specialtyFullEndocrinologist => 'Endocrinologist';

  @override
  String get specialtyFullPsychiatrist => 'Psychiatrist';

  @override
  String get specialtyFullGastroenterologist => 'Gastroenterologist';

  @override
  String get specialtyFullOphthalmologist => 'Ophthalmologist';

  @override
  String get specialtyFullFamilyMedicine => 'Family Medicine';

  @override
  String greetingMorningWithName(String name) {
    return 'Good morning, $name';
  }

  @override
  String get greetingMorningNoName => 'Good morning';

  @override
  String greetingAfternoonWithName(String name) {
    return 'Good afternoon, $name';
  }

  @override
  String get greetingAfternoonNoName => 'Good afternoon';

  @override
  String greetingEveningWithName(String name) {
    return 'Good evening, $name';
  }

  @override
  String get greetingEveningNoName => 'Good evening';

  @override
  String get doctorProfileTitle => 'Doctor profile';

  @override
  String get messageAction => 'Message';

  @override
  String get callAction => 'Call';

  @override
  String get locationAction => 'Location';

  @override
  String get bookingFeature => 'Booking';

  @override
  String get bookAppointment => 'Book appointment';

  @override
  String get aboutSectionTitle => 'About';

  @override
  String get noBioAvailable => 'No bio available yet for this doctor.';

  @override
  String get availableToday => 'Available today';
}
