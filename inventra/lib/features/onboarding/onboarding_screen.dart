import 'package:flutter/material.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/storage/app_prefs.dart';
import '../../core/theme/app_theme.dart';
import '../auth/auth_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  List<_SlideData> _slides(AppLocalizations l10n) => [
        _SlideData(
          icon: Icons.storefront_rounded,
          color: AppTheme.primary,
          title: l10n.onboarding1Title,
          description: l10n.onboarding1Desc,
        ),
        _SlideData(
          icon: Icons.qr_code_scanner_rounded,
          color: AppTheme.accent,
          title: l10n.onboarding2Title,
          description: l10n.onboarding2Desc,
        ),
        _SlideData(
          icon: Icons.point_of_sale_rounded,
          color: AppTheme.success,
          title: l10n.onboarding3Title,
          description: l10n.onboarding3Desc,
        ),
        _SlideData(
          icon: Icons.insights_rounded,
          color: AppTheme.warning,
          title: l10n.onboarding4Title,
          description: l10n.onboarding4Desc,
        ),
      ];

  Future<void> _finish() async {
    await AppPrefs.setOnboardingSeen();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const AuthScreen()),
    );
  }

  void _nextPage(int total) {
    if (_currentPage < total - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _finish();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final slides = _slides(l10n);
    final isLast = _currentPage == slides.length - 1;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _finish,
                child: Text(l10n.skip),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: slides.length,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemBuilder: (context, index) {
                  final slide = slides[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            color: slide.color.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(slide.icon, size: 72, color: slide.color),
                        ),
                        const SizedBox(height: 40),
                        Text(
                          slide.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          slide.description,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            height: 1.5,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                slides.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == i ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == i
                        ? AppTheme.primary
                        : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _nextPage(slides.length),
                  child: Text(isLast ? l10n.startManaging : l10n.next),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SlideData {
  final IconData icon;
  final Color color;
  final String title;
  final String description;

  const _SlideData({
    required this.icon,
    required this.color,
    required this.title,
    required this.description,
  });
}
