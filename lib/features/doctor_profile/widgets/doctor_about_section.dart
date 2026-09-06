import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';

/// The "About" section. Falls back to generic copy for a doctor whose
/// record doesn't have a bio yet, rather than rendering a blank section.
class DoctorAboutSection extends StatelessWidget {
  const DoctorAboutSection({super.key, required this.bio});

  final String? bio;

  @override
  Widget build(BuildContext context) {
    final trimmedBio = bio?.trim();
    final text = (trimmedBio == null || trimmedBio.isEmpty)
        ? 'No bio available yet for this doctor.'
        : trimmedBio;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('About', style: AppTheme.sectionTitle),
        const SizedBox(height: AppTheme.spacing8),
        Text(text, style: AppTheme.proseSecondary),
      ],
    );
  }
}
