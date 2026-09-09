import '../../l10n/app_localizations.dart';

/// Maps a specialty as stored in Firestore (English, e.g. "Cardiologist")
/// to its localized full display form. Falls back to the raw value for
/// anything outside the known seeded set, so a specialty added directly in
/// Firestore without a translation still renders instead of throwing.
String localizeSpecialty(AppLocalizations loc, String specialty) {
  switch (specialty.trim().toLowerCase()) {
    case 'cardiologist':
      return loc.specialtyFullCardiologist;
    case 'orthopedic surgeon':
      return loc.specialtyFullOrthopedicSurgeon;
    case 'neurologist':
      return loc.specialtyFullNeurologist;
    case 'dermatologist':
      return loc.specialtyFullDermatologist;
    case 'pediatrician':
      return loc.specialtyFullPediatrician;
    case 'endocrinologist':
      return loc.specialtyFullEndocrinologist;
    case 'psychiatrist':
      return loc.specialtyFullPsychiatrist;
    case 'gastroenterologist':
      return loc.specialtyFullGastroenterologist;
    case 'ophthalmologist':
      return loc.specialtyFullOphthalmologist;
    case 'family medicine':
      return loc.specialtyFullFamilyMedicine;
  }
  return specialty;
}
