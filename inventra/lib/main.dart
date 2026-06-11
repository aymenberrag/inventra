import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/api/api_client.dart';
import 'core/l10n/app_localizations.dart';
import 'core/l10n/locale_notifier.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/auth_gate.dart';

final localeNotifierProvider = ChangeNotifierProvider<LocaleNotifier>((ref) {
  return LocaleNotifier();
});

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  ApiClient.init();
  final localeNotifier = LocaleNotifier();
  await localeNotifier.loadSavedLocale();
  runApp(
    ProviderScope(
      overrides: [
        localeNotifierProvider.overrideWith((ref) => localeNotifier),
      ],
      child: const InventraApp(),
    ),
  );
}

class InventraApp extends ConsumerWidget {
  const InventraApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localeNotifier = ref.watch(localeNotifierProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Inventra',
      theme: AppTheme.lightTheme,
      locale: localeNotifier.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) {
        return Directionality(
          textDirection:
              localeNotifier.isRtl ? TextDirection.rtl : TextDirection.ltr,
          child: child!,
        );
      },
      home: const AuthGate(),
    );
  }
}
