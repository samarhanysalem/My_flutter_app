// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String notAvailableYet(String feature) {
    return '$feature غير متاح حاليًا.';
  }

  @override
  String get welcomeBack => 'مرحبًا بعودتك';

  @override
  String signInSubtitle(String companyName) {
    return 'سجّل الدخول للحجز مع فريق $companyName.';
  }

  @override
  String get emailLabel => 'البريد الإلكتروني';

  @override
  String get passwordLabel => 'كلمة المرور';

  @override
  String get forgotPassword => 'هل نسيت كلمة المرور؟';

  @override
  String get signIn => 'تسجيل الدخول';

  @override
  String get orDivider => 'أو';

  @override
  String get continueWithPhone => 'المتابعة برقم الهاتف';

  @override
  String get newHereQuestion => 'مستخدم جديد؟ ';

  @override
  String get createAnAccount => 'إنشاء حساب';

  @override
  String get passwordResetFeature => 'إعادة تعيين كلمة المرور';

  @override
  String get phoneSignInFeature => 'تسجيل الدخول بالهاتف';

  @override
  String get createYourAccount => 'أنشئ حسابك';

  @override
  String get registerSubtitle =>
      'يستغرق الأمر دقيقة واحدة فقط. الدفع في العيادة، فلا حاجة لبطاقة.';

  @override
  String get fullNameLabel => 'الاسم الكامل';

  @override
  String get phoneLabel => 'رقم الهاتف';

  @override
  String get alreadyRegisteredQuestion => 'مسجّل بالفعل؟ ';

  @override
  String get createAccount => 'إنشاء الحساب';

  @override
  String get enterYourEmail => 'أدخل بريدك الإلكتروني';

  @override
  String get enterAValidEmail => 'أدخل بريدًا إلكترونيًا صحيحًا';

  @override
  String get enterYourPassword => 'أدخل كلمة المرور';

  @override
  String get enterYourFullName => 'أدخل اسمك الكامل';

  @override
  String get enterYourPhoneNumber => 'أدخل رقم هاتفك';

  @override
  String get enterAValidPhoneNumber => 'أدخل رقم هاتف صحيحًا';

  @override
  String get passwordTooShort => 'يجب ألا تقل كلمة المرور عن 8 أحرف';

  @override
  String get passwordNeedsLetterAndNumber =>
      'أضف حرفًا ورقمًا واحدًا على الأقل';

  @override
  String agreeToTerms(String companyName) {
    return 'أوافق على شروط $companyName وسياسة الخصوصية.';
  }

  @override
  String get showPassword => 'إظهار كلمة المرور';

  @override
  String get hidePassword => 'إخفاء كلمة المرور';

  @override
  String get searchHint => 'ابحث عن أطباء أو تخصصات';

  @override
  String get ourDoctors => 'أطباؤنا';

  @override
  String get loadDoctorsError => 'حدث خطأ أثناء تحميل الأطباء. حاول مرة أخرى.';

  @override
  String get noDoctorsAvailable => 'لا يوجد أطباء متاحون حاليًا.';

  @override
  String get noDoctorsMatchSearch => 'لا يوجد أطباء يطابقون بحثك.';

  @override
  String get signOutQuestion => 'تسجيل الخروج؟';

  @override
  String get cancel => 'إلغاء';

  @override
  String get signOut => 'تسجيل الخروج';

  @override
  String get signOutFailed => 'فشل تسجيل الخروج. حاول مرة أخرى.';

  @override
  String get specialtyAll => 'الكل';

  @override
  String get specialtyCardio => 'قلب';

  @override
  String get specialtyOrtho => 'عظام';

  @override
  String get specialtyNeuro => 'أعصاب';

  @override
  String get specialtyDerma => 'جلدية';

  @override
  String get specialtyPediatric => 'أطفال';

  @override
  String get specialtyEndocrine => 'غدد صماء';

  @override
  String get specialtyPsych => 'نفسي';

  @override
  String get specialtyGastro => 'هضمي';

  @override
  String get specialtyEye => 'عيون';

  @override
  String get specialtyFamily => 'طب الأسرة';

  @override
  String get specialtyFullCardiologist => 'طبيب قلب';

  @override
  String get specialtyFullOrthopedicSurgeon => 'جراح عظام';

  @override
  String get specialtyFullNeurologist => 'طبيب أعصاب';

  @override
  String get specialtyFullDermatologist => 'طبيب جلدية';

  @override
  String get specialtyFullPediatrician => 'طبيب أطفال';

  @override
  String get specialtyFullEndocrinologist => 'طبيب غدد صماء';

  @override
  String get specialtyFullPsychiatrist => 'طبيب نفسي';

  @override
  String get specialtyFullGastroenterologist => 'طبيب جهاز هضمي';

  @override
  String get specialtyFullOphthalmologist => 'طبيب عيون';

  @override
  String get specialtyFullFamilyMedicine => 'طب الأسرة';

  @override
  String greetingMorningWithName(String name) {
    return 'صباح الخير، $name';
  }

  @override
  String get greetingMorningNoName => 'صباح الخير';

  @override
  String greetingAfternoonWithName(String name) {
    return 'طاب نهارك، $name';
  }

  @override
  String get greetingAfternoonNoName => 'طاب نهارك';

  @override
  String greetingEveningWithName(String name) {
    return 'مساء الخير، $name';
  }

  @override
  String get greetingEveningNoName => 'مساء الخير';

  @override
  String get doctorProfileTitle => 'الملف الشخصي للطبيب';

  @override
  String get messageAction => 'رسالة';

  @override
  String get callAction => 'اتصال';

  @override
  String get locationAction => 'الموقع';

  @override
  String get bookingFeature => 'الحجز';

  @override
  String get bookAppointment => 'احجز موعدًا';

  @override
  String get aboutSectionTitle => 'نبذة';

  @override
  String get noBioAvailable => 'لا تتوفر نبذة عن هذا الطبيب حتى الآن.';

  @override
  String get availableToday => 'متاح اليوم';

  @override
  String availableOn(String date) {
    return 'متاح في $date';
  }

  @override
  String get selectDate => 'اختر التاريخ';

  @override
  String get noSlotsAvailable => 'لا توجد مواعيد متاحة في هذا اليوم.';

  @override
  String get loadAvailabilityError =>
      'تعذّر تحميل المواعيد المتاحة. حاول مرة أخرى.';
}
