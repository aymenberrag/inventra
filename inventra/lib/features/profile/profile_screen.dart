import 'package:flutter/material.dart';
import '../../core/storage/store_storage.dart';
import '../../core/theme/app_theme.dart';
import '../auth/auth_gate.dart';
import '../auth/auth_service.dart';
import '../stores/store_selector_screen.dart';
import '../stores/store_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
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
          const SnackBar(
            content: Text('Profile updated'),
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
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Profile',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              Center(
                child: CircleAvatar(
                  radius: 48,
                  backgroundColor: AppTheme.primary.withValues(alpha: 0.1),
                  child: Text(
                    (_user?.fullName.isNotEmpty == true)
                        ? _user!.fullName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      fontSize: 36,
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
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Personal Info',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TextFormField(
                        initialValue: _user?.fullName,
                        decoration: const InputDecoration(
                          labelText: 'Full Name',
                          prefixIcon: Icon(Icons.person_outline),
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
                        decoration: const InputDecoration(
                          labelText: 'Language',
                          prefixIcon: Icon(Icons.language),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'en', child: Text('English')),
                          DropdownMenuItem(value: 'fr', child: Text('Français')),
                          DropdownMenuItem(value: 'ar', child: Text('العربية')),
                        ],
                        onChanged: (v) => setState(() => _language = v ?? 'en'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Store Info',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TextFormField(
                        initialValue: _storeName,
                        decoration: const InputDecoration(
                          labelText: 'Store Name',
                          prefixIcon: Icon(Icons.store_outlined),
                        ),
                        onChanged: (v) => setState(() => _storeName = v),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: _currency,
                        decoration: const InputDecoration(
                          labelText: 'Currency',
                          prefixIcon: Icon(Icons.payments_outlined),
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
                child: const Text('Save Changes'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _switchStore,
                icon: const Icon(Icons.swap_horiz),
                label: const Text('Switch Store / Create New'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 52),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _logout,
                icon: const Icon(Icons.logout, color: AppTheme.danger),
                label: const Text(
                  'Logout',
                  style: TextStyle(color: AppTheme.danger),
                ),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 52),
                  side: const BorderSide(color: AppTheme.danger),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
