import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../config/locale_provider.dart';
import '../../../theme/app_theme.dart';

/// Language names are shown in their own language (an autonym) regardless of
/// the current locale, per standard language-picker convention — this is
/// deliberately not routed through AppLocalizations, since "English" and
/// "العربية" aren't translated copy, they're how each language names itself.
const _languages = [
  (locale: Locale('en'), autonym: 'English'),
  (locale: Locale('ar'), autonym: 'العربية'),
];

/// The login screen's language picker — shows the current language and
/// opens a menu to switch between English and Arabic.
class LanguageToggleButton extends StatelessWidget {
  const LanguageToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    final localeProvider = context.watch<LocaleProvider>();
    final currentCode = localeProvider.locale?.languageCode ??
        Localizations.localeOf(context).languageCode;
    final current = _languages.firstWhere(
      (language) => language.locale.languageCode == currentCode,
      orElse: () => _languages.first,
    );

    return PopupMenuButton<Locale>(
      onSelected: (locale) => context.read<LocaleProvider>().setLocale(locale),
      itemBuilder: (context) => [
        for (final language in _languages)
          PopupMenuItem<Locale>(
            value: language.locale,
            child: Text(language.autonym, style: AppTheme.body),
          ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacing12,
          vertical: AppTheme.spacing8,
        ),
        decoration: BoxDecoration(
          color: AppTheme.accentTint,
          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.language, size: 16, color: AppTheme.primary),
            const SizedBox(width: AppTheme.spacing6),
            Text(
              current.autonym,
              style: AppTheme.captionSecondary.copyWith(
                color: AppTheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
