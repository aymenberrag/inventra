import 'package:flutter/material.dart';
import '../../core/storage/token_storage.dart';
import '../../core/storage/store_storage.dart';
import '../../core/api/api_client.dart';
import '../auth/auth_screen.dart';
import '../stores/store_selector_screen.dart';
import '../navigation/main_nav.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _loading = true;
  Widget _destination = const AuthScreen();

  @override
  void initState() {
    super.initState();
    ApiClient.init();
    _resolveDestination();
  }

  Future<void> _resolveDestination() async {
    final hasToken = await TokenStorage.hasTokens();
    if (!hasToken) {
      setState(() {
        _destination = const AuthScreen();
        _loading = false;
      });
      return;
    }

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
