import 'package:flutter/widgets.dart';

import '../../l10n/app_localizations.dart';
import '../utils/specialty_localizations.dart';

/// A doctor sourced from Firestore's `doctors` collection. Shared across the
/// `home` and `doctor_profile` features, so it lives here rather than inside
/// either feature folder.
class Doctor {
  const Doctor({
    required this.id,
    required this.name,
    required this.specialty,
    required this.rating,
    this.bio,
    this.nameAr,
  });

  final String id;
  final String name;
  final String specialty;
  final double rating;

  /// Shown on the doctor's profile screen. Null for a doctor whose record
  /// doesn't have one yet — the profile screen falls back to generic copy.
  final String? bio;

  /// Arabic form of [name]. A transliteration, not a translation — proper
  /// names aren't translated — sourced from Firestore alongside [name].
  /// Null for a doctor whose record doesn't have one yet.
  final String? nameAr;

  factory Doctor.fromFirestore(String id, Map<String, dynamic> data) {
    return Doctor(
      id: id,
      name: data['name'] as String? ?? '',
      specialty: data['specialty'] as String? ?? '',
      rating: (data['rating'] as num?)?.toDouble() ?? 0,
      bio: data['bio'] as String?,
      nameAr: data['nameAr'] as String?,
    );
  }

  /// [name], localized: [nameAr] when [locale] is Arabic and one exists,
  /// otherwise the stored [name].
  String localizedName(Locale locale) {
    final arabic = nameAr?.trim();
    if (locale.languageCode == 'ar' && arabic != null && arabic.isNotEmpty) {
      return arabic;
    }
    return name;
  }

  /// [specialty], localized against the known specialty set seeded into
  /// Firestore — see `localizeSpecialty`.
  String localizedSpecialty(AppLocalizations loc) =>
      localizeSpecialty(loc, specialty);
}
