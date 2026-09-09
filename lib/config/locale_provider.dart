import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Holds the user's chosen app language (English/Arabic), persisted across
/// launches. `null` means "follow the system locale" (falling back to the
/// first supported locale — English — if the system locale isn't supported).
class LocaleProvider extends ChangeNotifier {
  LocaleProvider() {
    _loadSavedLocale();
  }

  static const _prefsKey = 'locale_code';

  Locale? _locale;
  Locale? get locale => _locale;

  Future<void> _loadSavedLocale() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      final code = preferences.getString(_prefsKey);
      if (code != null) {
        _locale = Locale(code);
        notifyListeners();
      }
    } catch (_) {
      // No saved preference to restore — fall back to the system locale.
    }
  }

  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    notifyListeners();
    try {
      final preferences = await SharedPreferences.getInstance();
      await preferences.setString(_prefsKey, locale.languageCode);
    } catch (_) {
      // Best-effort persistence — the chosen language still applies for the
      // rest of this session even if saving it for next time fails.
    }
  }
}
