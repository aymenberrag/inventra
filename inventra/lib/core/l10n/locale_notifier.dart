import 'package:flutter/material.dart';
import '../storage/app_prefs.dart';

class LocaleNotifier extends ChangeNotifier {
  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  bool get isRtl => _locale.languageCode == 'ar';

  Future<void> loadSavedLocale() async {
    final saved = await AppPrefs.getLocale();
    if (saved != null && ['en', 'fr', 'ar'].contains(saved)) {
      _locale = Locale(saved);
      notifyListeners();
    }
  }

  Future<void> setLocale(String languageCode) async {
    if (!['en', 'fr', 'ar'].contains(languageCode)) return;
    _locale = Locale(languageCode);
    await AppPrefs.setLocale(languageCode);
    notifyListeners();
  }
}
