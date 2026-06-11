import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/api/api_client.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/auth_gate.dart';

void main() {
  ApiClient.init();
  runApp(
    const ProviderScope(
      child: InventraApp(),
    ),
  );
}

class InventraApp extends StatelessWidget {
  const InventraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Inventra',
      theme: AppTheme.lightTheme,
      home: const AuthGate(),
    );
  }
}
