import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/app_localizations.dart';

import '../../core/storage/store_storage.dart';

import '../../core/theme/app_theme.dart';

import '../../main.dart';

import '../auth/auth_gate.dart';

import '../auth/auth_service.dart';

import '../stores/store_selector_screen.dart';

import '../stores/store_service.dart';



class ProfileScreen extends ConsumerStatefulWidget {

  const ProfileScreen({super.key});



  @override

  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();

}



class _ProfileScreenState extends ConsumerState<ProfileScreen> {

  final _authService = AuthService();

  final _storeService = StoreService();



  UserModel? _user;

  String _storeName = '';

  String _currency = 'USD';

  String _language = 'en';

  int? _storeId;

  bool _loading = true;



  @override

  void initState() {

    super.initState();

    _loadProfile();

  }



  Future<void> _loadProfile() async {

    setState(() => _loading = true);

    try {

      final userData = await _authService.getMe();

      final storeId = await StoreStorage.getStoreId();

      final storeName = await StoreStorage.getStoreName();

      final currency = await StoreStorage.getCurrency();



      setState(() {

        _user = UserModel.fromJson(userData);

        _storeId = storeId;

        _storeName = storeName ?? '';

        _currency = currency;

        _language = _user!.language;

        _loading = false;

      });

    } catch (_) {

      setState(() => _loading = false);

    }

  }



  Future<void> _saveProfile() async {

    try {

      await _authService.updateProfile(

        fullName: _user?.fullName,

        language: _language,

      );

      await ref.read(localeNotifierProvider).setLocale(_language);



      if (_storeId != null) {

        final store = await _storeService.updateStore(

          storeId: _storeId!,

          name: _storeName,

          currency: _currency,

        );

        await StoreStorage.updateStoreInfo(

          name: store.name,

          currency: store.currency,

        );

      }

      if (mounted) {

        ScaffoldMessenger.of(context).showSnackBar(

          SnackBar(

            content: Text(AppLocalizations.of(context).profileUpdated),

            backgroundColor: AppTheme.success,

          ),

        );

      }

    } catch (e) {

      if (mounted) {

        ScaffoldMessenger.of(context).showSnackBar(

          SnackBar(content: Text('Update failed: $e')),

        );

      }

    }

  }



  Future<void> _logout() async {

    await _authService.logout();

    await StoreStorage.clear();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(

      context,

      MaterialPageRoute(builder: (_) => const AuthGate()),

      (_) => false,

    );

  }



  Future<void> _switchStore() async {

    if (!mounted) return;

    Navigator.push(

      context,

      MaterialPageRoute(builder: (_) => const StoreSelectorScreen()),

    );

  }



  @override

  Widget build(BuildContext context) {

    final l10n = AppLocalizations.of(context);



    if (_loading) {

      return const Center(child: CircularProgressIndicator());

    }



    return Scaffold(

      body: SafeArea(

        child: SingleChildScrollView(

          padding: const EdgeInsets.all(16),

          child: Column(

            crossAxisAlignment: CrossAxisAlignment.start,

            children: [

              Text(

                l10n.profile,

                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),

              ),

              const SizedBox(height: 20),

              Center(

                child: CircleAvatar(

                  radius: 44,

                  backgroundColor: AppTheme.primary.withValues(alpha: 0.1),

                  child: Text(

                    (_user?.fullName.isNotEmpty == true)

                        ? _user!.fullName[0].toUpperCase()

                        : '?',

                    style: const TextStyle(

                      fontSize: 32,

                      fontWeight: FontWeight.bold,

                      color: AppTheme.primary,

                    ),

                  ),

                ),

              ),

              const SizedBox(height: 8),

              Center(

                child: Text(

                  _user?.email ?? '',

                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),

                ),

              ),

              const SizedBox(height: 24),

              Text(

                l10n.personalInfo,

                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),

              ),

              const SizedBox(height: 10),

              Card(

                child: Padding(

                  padding: const EdgeInsets.all(16),

                  child: Column(

                    children: [

                      TextFormField(

                        initialValue: _user?.fullName,

                        decoration: InputDecoration(

                          labelText: l10n.fullName,

                          prefixIcon: const Icon(Icons.person_outline),

                        ),

                        onChanged: (v) {

                          setState(() {

                            _user = UserModel(

                              id: _user!.id,

                              fullName: v,

                              email: _user!.email,

                              language: _language,

                            );

                          });

                        },

                      ),

                      const SizedBox(height: 12),

                      DropdownButtonFormField<String>(

                        value: _language,

                        decoration: InputDecoration(

                          labelText: l10n.language,

                          prefixIcon: const Icon(Icons.language),

                        ),

                        items: [

                          DropdownMenuItem(value: 'en', child: Text(l10n.english)),

                          DropdownMenuItem(value: 'fr', child: Text(l10n.french)),

                          DropdownMenuItem(value: 'ar', child: Text(l10n.arabic)),

                        ],

                        onChanged: (v) => setState(() => _language = v ?? 'en'),

                      ),

                    ],

                  ),

                ),

              ),

              const SizedBox(height: 20),

              Text(

                l10n.storeInfo,

                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),

              ),

              const SizedBox(height: 10),

              Card(

                child: Padding(

                  padding: const EdgeInsets.all(16),

                  child: Column(

                    children: [

                      TextFormField(

                        initialValue: _storeName,

                        decoration: InputDecoration(

                          labelText: l10n.storeName,

                          prefixIcon: const Icon(Icons.store_outlined),

                        ),

                        onChanged: (v) => setState(() => _storeName = v),

                      ),

                      const SizedBox(height: 12),

                      DropdownButtonFormField<String>(

                        value: _currency,

                        decoration: InputDecoration(

                          labelText: l10n.currency,

                          prefixIcon: const Icon(Icons.payments_outlined),

                        ),

                        items: const [

                          DropdownMenuItem(value: 'USD', child: Text('USD (\$)')),

                          DropdownMenuItem(value: 'EUR', child: Text('EUR (€)')),

                          DropdownMenuItem(value: 'GBP', child: Text('GBP (£)')),

                          DropdownMenuItem(value: 'MAD', child: Text('MAD')),

                          DropdownMenuItem(value: 'DZD', child: Text('DZD')),

                          DropdownMenuItem(value: 'TND', child: Text('TND')),

                        ],

                        onChanged: (v) => setState(() => _currency = v ?? 'USD'),

                      ),

                    ],

                  ),

                ),

              ),

              const SizedBox(height: 24),

              ElevatedButton(

                onPressed: _saveProfile,

                child: Text(l10n.saveChanges),

              ),

              const SizedBox(height: 10),

              OutlinedButton.icon(

                onPressed: _switchStore,

                icon: const Icon(Icons.swap_horiz),

                label: Text(l10n.switchStore),

                style: OutlinedButton.styleFrom(

                  minimumSize: const Size(double.infinity, 52),

                ),

              ),

              const SizedBox(height: 10),

              OutlinedButton.icon(

                onPressed: _logout,

                icon: const Icon(Icons.logout, color: AppTheme.danger),

                label: Text(

                  l10n.logout,

                  style: const TextStyle(color: AppTheme.danger),

                ),

                style: OutlinedButton.styleFrom(

                  minimumSize: const Size(double.infinity, 52),

                  side: const BorderSide(color: AppTheme.danger),

                ),

              ),

              const SizedBox(height: 16),

            ],

          ),

        ),

      ),

    );

  }

}

