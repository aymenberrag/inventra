import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/storage/token_storage.dart';

import '../../core/storage/store_storage.dart';

import '../../core/storage/app_prefs.dart';

import '../../core/api/api_client.dart';

import '../../core/l10n/locale_notifier.dart';

import '../auth/auth_screen.dart';

import '../auth/auth_service.dart';

import '../onboarding/onboarding_screen.dart';

import '../stores/store_selector_screen.dart';

import '../navigation/main_nav.dart';



class AuthGate extends ConsumerStatefulWidget {

  const AuthGate({super.key});



  @override

  ConsumerState<AuthGate> createState() => _AuthGateState();

}



class _AuthGateState extends ConsumerState<AuthGate> {

  bool _loading = true;

  Widget _destination = const AuthScreen();



  @override

  void initState() {

    super.initState();

    ApiClient.init();

    _resolveDestination();

  }



  Future<void> _resolveDestination() async {

    final hasSeenOnboarding = await AppPrefs.hasSeenOnboarding();

    if (!hasSeenOnboarding) {

      setState(() {

        _destination = const OnboardingScreen();

        _loading = false;

      });

      return;

    }



    final hasToken = await TokenStorage.hasTokens();

    if (!hasToken) {

      setState(() {

        _destination = const AuthScreen();

        _loading = false;

      });

      return;

    }



    try {

      final userData = await AuthService().getMe();

      final language = userData['language'] as String? ?? 'en';

      await ref.read(localeNotifierProvider.notifier).setLocale(language);

    } catch (_) {}



    final storeId = await StoreStorage.getStoreId();

    setState(() {

      _destination = storeId != null

          ? const MainNav()

          : const StoreSelectorScreen();

      _loading = false;

    });

  }



  @override

  Widget build(BuildContext context) {

    if (_loading) {

      return const Scaffold(

        body: Center(child: CircularProgressIndicator()),

      );

    }

    return _destination;

  }

}

