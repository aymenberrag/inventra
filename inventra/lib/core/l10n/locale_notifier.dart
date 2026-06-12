import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../storage/app_prefs.dart';

final localeNotifierProvider = NotifierProvider<LocaleNotifier, Locale>(LocaleNotifier.new);

class LocaleNotifier extends Notifier<Locale> {
  @override
  Locale build() => const Locale('en');

  bool get isRtl => state.languageCode == 'ar';

  Future<void> loadSavedLocale() async {
    final saved = await AppPrefs.getLocale();
    if (saved != null && ['en', 'fr', 'ar'].contains(saved)) {
      state = Locale(saved);
    }
  }

  Future<void> setLocale(String languageCode) async {
    if (!['en', 'fr', 'ar'].contains(languageCode)) return;
    state = Locale(languageCode);
    await AppPrefs.setLocale(languageCode);
  }
}
