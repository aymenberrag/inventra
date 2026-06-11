import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/validators.dart';
import '../../core/storage/store_storage.dart';
import 'auth_service.dart';
import 'privacy_policy_screen.dart';
import '../stores/store_selector_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _loginFormKey = GlobalKey<FormState>();
  final _registerFormKey = GlobalKey<FormState>();

  final _loginEmail = TextEditingController();
  final _loginPassword = TextEditingController();
  final _registerName = TextEditingController();
  final _registerEmail = TextEditingController();
  final _registerPassword = TextEditingController();
  final _registerConfirm = TextEditingController();

  bool _loading = false;
  bool _obscureLogin = true;
  bool _obscureRegister = true;
  bool _obscureConfirm = true;
  bool _agreedToPrivacy = false;

  final _authService = AuthService();
  final _googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loginEmail.dispose();
    _loginPassword.dispose();
    _registerName.dispose();
    _registerEmail.dispose();
    _registerPassword.dispose();
    _registerConfirm.dispose();
    super.dispose();
  }

  Future<void> _handleAuth(Future<Map<String, dynamic>> Function() action) async {
    try {
      setState(() => _loading = true);
      final response = await action();
      await _authService.saveAuthResponse(response);
      await StoreStorage.clear();

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const StoreSelectorScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_authService.parseError(e)),
          backgroundColor: AppTheme.danger,
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _handleGoogleSignIn() async {
    try {
      setState(() => _loading = true);
      final account = await _googleSignIn.signIn();
      if (account == null) {
        setState(() => _loading = false);
        return;
      }

      final auth = await account.authentication;
      final idToken = auth.idToken;
      if (idToken == null) {
        throw Exception('Google sign-in failed: no ID token');
      }

      final response = await _authService.googleSignIn(
        idToken: idToken,
        fullName: account.displayName,
        email: account.email,
      );
      await _authService.saveAuthResponse(response);
      await StoreStorage.clear();

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const StoreSelectorScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_authService.parseError(e)),
          backgroundColor: AppTheme.danger,
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Widget _buildGoogleButton(AppLocalizations l10n) {
    return OutlinedButton.icon(
      onPressed: _loading ? null : _handleGoogleSignIn,
      icon: Image.network(
        'https://www.google.com/favicon.ico',
        width: 20,
        height: 20,
        errorBuilder: (_, __, ___) =>
            const Icon(Icons.g_mobiledata, color: AppTheme.primary),
      ),
      label: Text(l10n.continueWithGoogle),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 52),
        side: BorderSide(color: Colors.grey.shade300),
      ),
    );
  }

  Widget _buildDivider(AppLocalizations l10n) {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.grey.shade300)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(l10n.orDivider, style: TextStyle(color: Colors.grey.shade600)),
        ),
        Expanded(child: Divider(color: Colors.grey.shade300)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: Container(
        decoration: AppTheme.authGradient,
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 40),
              const Icon(Icons.inventory_2_rounded, size: 56, color: Colors.white),
              const SizedBox(height: 12),
              Text(
                l10n.appName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Manage your store with ease',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      TabBar(
                        controller: _tabController,
                        labelColor: AppTheme.primary,
                        unselectedLabelColor: Colors.grey,
                        indicatorColor: AppTheme.primary,
                        tabs: [
                          Tab(text: l10n.login),
                          Tab(text: l10n.register),
                        ],
                      ),
                      Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            _buildLoginTab(l10n),
                            _buildRegisterTab(l10n),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoginTab(AppLocalizations l10n) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _loginFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildGoogleButton(l10n),
            const SizedBox(height: 20),
            _buildDivider(l10n),
            const SizedBox(height: 20),
            TextFormField(
              controller: _loginEmail,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: l10n.email,
                prefixIcon: const Icon(Icons.email_outlined),
              ),
              validator: Validators.email,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _loginPassword,
              obscureText: _obscureLogin,
              decoration: InputDecoration(
                labelText: l10n.password,
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureLogin ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () => setState(() => _obscureLogin = !_obscureLogin),
                ),
              ),
              validator: (v) => Validators.required(v, field: 'Password'),
            ),
            const SizedBox(height: 28),
            ElevatedButton(
              onPressed: _loading
                  ? null
                  : () {
                      if (_loginFormKey.currentState!.validate()) {
                        _handleAuth(
                          () => _authService.login(
                            email: _loginEmail.text.trim(),
                            password: _loginPassword.text,
                          ),
                        );
                      }
                    },
              child: _loading
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Text(l10n.signIn),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegisterTab(AppLocalizations l10n) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _registerFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildGoogleButton(l10n),
            const SizedBox(height: 20),
            _buildDivider(l10n),
            const SizedBox(height: 20),
            TextFormField(
              controller: _registerName,
              decoration: InputDecoration(
                labelText: l10n.fullName,
                prefixIcon: const Icon(Icons.person_outline),
              ),
              validator: Validators.fullName,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _registerEmail,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: l10n.email,
                prefixIcon: const Icon(Icons.email_outlined),
              ),
              validator: Validators.email,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _registerPassword,
              obscureText: _obscureRegister,
              decoration: InputDecoration(
                labelText: l10n.password,
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureRegister ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () =>
                      setState(() => _obscureRegister = !_obscureRegister),
                ),
              ),
              validator: Validators.password,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _registerConfirm,
              obscureText: _obscureConfirm,
              decoration: InputDecoration(
                labelText: l10n.confirmPassword,
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirm ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () =>
                      setState(() => _obscureConfirm = !_obscureConfirm),
                ),
              ),
              validator: (v) {
                if (v != _registerPassword.text) {
                  return 'Passwords do not match';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            FormField<bool>(
              initialValue: _agreedToPrivacy,
              validator: (v) {
                if (v != true) return l10n.mustAgreePrivacy;
                return null;
              },
              builder: (state) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Checkbox(
                          value: state.value ?? false,
                          onChanged: (v) {
                            setState(() => _agreedToPrivacy = v ?? false);
                            state.didChange(v);
                          },
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const PrivacyPolicyScreen(),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: Text.rich(
                                TextSpan(
                                  style: TextStyle(
                                    color: Colors.grey.shade800,
                                    fontSize: 14,
                                  ),
                                  children: [
                                    TextSpan(text: '${l10n.agreePrivacy.split(l10n.privacyPolicy).first.trim()} '),
                                    TextSpan(
                                      text: l10n.privacyPolicy,
                                      style: const TextStyle(
                                        color: AppTheme.primary,
                                        fontWeight: FontWeight.w600,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (state.hasError)
                      Padding(
                        padding: const EdgeInsets.only(left: 12, top: 4),
                        child: Text(
                          state.errorText!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loading
                  ? null
                  : () {
                      if (_registerFormKey.currentState!.validate()) {
                        _handleAuth(
                          () => _authService.register(
                            fullName: _registerName.text.trim(),
                            email: _registerEmail.text.trim(),
                            password: _registerPassword.text,
                          ),
                        );
                      }
                    },
              child: _loading
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Text(l10n.createAccount),
            ),
          ],
        ),
      ),
    );
  }
}
