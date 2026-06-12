import 'dart:math' as math;
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
          illustration: () => const _DashboardIllustration(),
          color: AppTheme.primary,
          title: l10n.onboarding1Title,
          description: l10n.onboarding1Desc,
        ),
        _SlideData(
          illustration: () => const _ScannerIllustration(),
          color: AppTheme.accent,
          title: l10n.onboarding2Title,
          description: l10n.onboarding2Desc,
        ),
        _SlideData(
          illustration: () => const _POSIllustration(),
          color: AppTheme.success,
          title: l10n.onboarding3Title,
          description: l10n.onboarding3Desc,
        ),
        _SlideData(
          illustration: () => const _AnalyticsIllustration(),
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
                        _AnimatedIllustration(
                          key: ValueKey('illustration_$index'),
                          isActive: _currentPage == index,
                          color: slide.color,
                          child: slide.illustration(),
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

// ---------------------------------------------------------------------------
// Data model
// ---------------------------------------------------------------------------

class _SlideData {
  final Widget Function() illustration;
  final Color color;
  final String title;
  final String description;

  const _SlideData({
    required this.illustration,
    required this.color,
    required this.title,
    required this.description,
  });
}

// ---------------------------------------------------------------------------
// Animated wrapper – scales in when the page becomes active
// ---------------------------------------------------------------------------

class _AnimatedIllustration extends StatefulWidget {
  final bool isActive;
  final Color color;
  final Widget child;

  const _AnimatedIllustration({
    super.key,
    required this.isActive,
    required this.color,
    required this.child,
  });

  @override
  State<_AnimatedIllustration> createState() => _AnimatedIllustrationState();
}

class _AnimatedIllustrationState extends State<_AnimatedIllustration>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack);
    _opacity = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    if (widget.isActive) _ctrl.forward();
  }

  @override
  void didUpdateWidget(covariant _AnimatedIllustration old) {
    super.didUpdateWidget(old);
    if (widget.isActive && !old.isActive) {
      _ctrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) => Opacity(
        opacity: _opacity.value,
        child: Transform.scale(
          scale: 0.6 + 0.4 * _scale.value,
          child: child,
        ),
      ),
      child: Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          color: widget.color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(
            color: widget.color.withValues(alpha: 0.18),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: widget.color.withValues(alpha: 0.12),
              blurRadius: 30,
              spreadRadius: 0,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: widget.child,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 1. Dashboard mockup illustration
// ---------------------------------------------------------------------------

class _DashboardIllustration extends StatelessWidget {
  const _DashboardIllustration();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Top stat pills
          Row(
            children: [
              _pill(AppTheme.primary, 42),
              const SizedBox(width: 8),
              _pill(AppTheme.success, 32),
              const Spacer(),
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(Icons.grid_view_rounded,
                    size: 14, color: AppTheme.primary),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Revenue card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Fake label
                Container(
                  width: 50,
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(height: 6),
                // Fake amount
                Container(
                  width: 72,
                  height: 10,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                const SizedBox(height: 10),
                // Bar chart
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _bar(18, AppTheme.primary.withValues(alpha: 0.3)),
                    const SizedBox(width: 4),
                    _bar(28, AppTheme.primary.withValues(alpha: 0.5)),
                    const SizedBox(width: 4),
                    _bar(22, AppTheme.primary.withValues(alpha: 0.4)),
                    const SizedBox(width: 4),
                    _bar(34, AppTheme.primary),
                    const SizedBox(width: 4),
                    _bar(26, AppTheme.primary.withValues(alpha: 0.6)),
                    const SizedBox(width: 4),
                    _bar(30, AppTheme.primary.withValues(alpha: 0.8)),
                    const SizedBox(width: 4),
                    _bar(20, AppTheme.primary.withValues(alpha: 0.35)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          // Bottom stat row
          Row(
            children: [
              Expanded(child: _miniCard('128', AppTheme.accent)),
              const SizedBox(width: 8),
              Expanded(child: _miniCard('94%', AppTheme.success)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _pill(Color color, double width) {
    return Container(
      width: width,
      height: 18,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Center(
        child: Container(
          width: width - 16,
          height: 5,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2.5),
          ),
        ),
      ),
    );
  }

  Widget _bar(double height, Color color) {
    return Container(
      width: 10,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _miniCard(String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 2. Scanner / Inventory mockup illustration
// ---------------------------------------------------------------------------

class _ScannerIllustration extends StatelessWidget {
  const _ScannerIllustration();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Scanner frame
          SizedBox(
            width: 90,
            height: 80,
            child: Stack(
              children: [
                // Corner brackets
                ..._corners(AppTheme.accent),
                // Scan line
                Positioned(
                  top: 36,
                  left: 8,
                  right: 8,
                  child: Container(
                    height: 2,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.accent.withValues(alpha: 0.0),
                          AppTheme.accent,
                          AppTheme.accent.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                ),
                // Barcode lines
                Positioned(
                  top: 18,
                  left: 20,
                  right: 20,
                  bottom: 22,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(
                      12,
                      (i) => Container(
                        width: i.isEven ? 2 : 3,
                        color: const Color(0xFF0F172A).withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Inventory list items
          _inventoryRow(AppTheme.accent),
          const SizedBox(height: 6),
          _inventoryRow(AppTheme.success),
          const SizedBox(height: 6),
          _inventoryRow(AppTheme.primary),
        ],
      ),
    );
  }

  List<Widget> _corners(Color color) {
    const len = 16.0;
    const thickness = 2.5;
    return [
      // Top-left
      Positioned(top: 0, left: 0, child: _cornerPiece(color, len, thickness, true, true)),
      // Top-right
      Positioned(top: 0, right: 0, child: _cornerPiece(color, len, thickness, true, false)),
      // Bottom-left
      Positioned(bottom: 0, left: 0, child: _cornerPiece(color, len, thickness, false, true)),
      // Bottom-right
      Positioned(bottom: 0, right: 0, child: _cornerPiece(color, len, thickness, false, false)),
    ];
  }

  Widget _cornerPiece(Color color, double len, double thickness, bool top, bool left) {
    return SizedBox(
      width: len,
      height: len,
      child: CustomPaint(
        painter: _CornerPainter(color: color, thickness: thickness, top: top, left: left),
      ),
    );
  }

  Widget _inventoryRow(Color dotColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: dotColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(3),
            ),
            child: Center(
              child: Container(
                width: 5,
                height: 5,
                decoration: BoxDecoration(
                  color: dotColor,
                  borderRadius: BorderRadius.circular(1.5),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2.5),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 24,
            height: 12,
            decoration: BoxDecoration(
              color: dotColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Center(
              child: Container(
                width: 14,
                height: 4,
                decoration: BoxDecoration(
                  color: dotColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CornerPainter extends CustomPainter {
  final Color color;
  final double thickness;
  final bool top;
  final bool left;

  _CornerPainter({
    required this.color,
    required this.thickness,
    required this.top,
    required this.left,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = thickness
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    if (top && left) {
      path.moveTo(0, size.height);
      path.lineTo(0, 0);
      path.lineTo(size.width, 0);
    } else if (top && !left) {
      path.moveTo(0, 0);
      path.lineTo(size.width, 0);
      path.lineTo(size.width, size.height);
    } else if (!top && left) {
      path.moveTo(0, 0);
      path.lineTo(0, size.height);
      path.lineTo(size.width, size.height);
    } else {
      path.moveTo(0, size.height);
      path.lineTo(size.width, size.height);
      path.lineTo(size.width, 0);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _CornerPainter old) =>
      color != old.color || thickness != old.thickness;
}

// ---------------------------------------------------------------------------
// 3. POS / Cart mockup illustration
// ---------------------------------------------------------------------------

class _POSIllustration extends StatelessWidget {
  const _POSIllustration();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Header bar
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.success.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.shopping_cart_rounded,
                    size: 12, color: AppTheme.success),
                const SizedBox(width: 6),
                Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppTheme.success,
                    borderRadius: BorderRadius.circular(2.5),
                  ),
                ),
                const Spacer(),
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: AppTheme.success,
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: const Center(
                    child: Text('3',
                        style: TextStyle(
                          fontSize: 8,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        )),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          // Cart items
          _cartItem(54),
          const SizedBox(height: 5),
          _cartItem(38),
          const SizedBox(height: 5),
          _cartItem(46),
          const SizedBox(height: 10),
          // Divider
          Container(
            width: double.infinity,
            height: 1,
            color: Colors.grey.shade200,
          ),
          const SizedBox(height: 8),
          // Total bar
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.success,
                  AppTheme.success.withValues(alpha: 0.85),
                ],
              ),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.success.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 32,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(2.5),
                  ),
                ),
                Container(
                  width: 42,
                  height: 7,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(3.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _cartItem(double nameWidth) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: AppTheme.success.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: nameWidth,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2.5),
            ),
          ),
          const Spacer(),
          Container(
            width: 28,
            height: 5,
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A).withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(2.5),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 4. Analytics mockup illustration
// ---------------------------------------------------------------------------

class _AnalyticsIllustration extends StatelessWidget {
  const _AnalyticsIllustration();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Stat pills row
          Row(
            children: [
              _statPill('+28%', AppTheme.success),
              const SizedBox(width: 6),
              _statPill('+12%', AppTheme.primary),
              const Spacer(),
              _statPill('1.4k', AppTheme.warning),
            ],
          ),
          const SizedBox(height: 14),
          // Chart area
          Container(
            width: double.infinity,
            height: 72,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: CustomPaint(
              painter: _ChartPainter(
                lineColor: AppTheme.warning,
                fillColor: AppTheme.warning.withValues(alpha: 0.12),
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Trend arrow + label
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.warning.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Transform.rotate(
                  angle: -math.pi / 6,
                  child: Icon(Icons.trending_up_rounded,
                      size: 16, color: AppTheme.warning),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 48,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppTheme.warning.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(2.5),
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppTheme.success,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    '↑ 28%',
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Bottom mini bars
          Row(
            children: [
              Expanded(child: _bottomBar(AppTheme.primary, 0.7)),
              const SizedBox(width: 4),
              Expanded(child: _bottomBar(AppTheme.accent, 0.55)),
              const SizedBox(width: 4),
              Expanded(child: _bottomBar(AppTheme.success, 0.85)),
              const SizedBox(width: 4),
              Expanded(child: _bottomBar(AppTheme.warning, 0.6)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statPill(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }

  Widget _bottomBar(Color color, double fraction) {
    return Column(
      children: [
        Container(
          height: 14 * fraction + 4,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: FractionallySizedBox(
              heightFactor: fraction,
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ChartPainter extends CustomPainter {
  final Color lineColor;
  final Color fillColor;

  _ChartPainter({required this.lineColor, required this.fillColor});

  @override
  void paint(Canvas canvas, Size size) {
    final points = <Offset>[
      Offset(0, size.height * 0.7),
      Offset(size.width * 0.15, size.height * 0.55),
      Offset(size.width * 0.30, size.height * 0.65),
      Offset(size.width * 0.45, size.height * 0.35),
      Offset(size.width * 0.60, size.height * 0.40),
      Offset(size.width * 0.75, size.height * 0.20),
      Offset(size.width, size.height * 0.10),
    ];

    // Fill
    final fillPath = Path()..moveTo(0, size.height);
    for (final p in points) {
      fillPath.lineTo(p.dx, p.dy);
    }
    fillPath.lineTo(size.width, size.height);
    fillPath.close();
    canvas.drawPath(fillPath, Paint()..color = fillColor);

    // Line
    final linePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      linePath.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(
      linePath,
      Paint()
        ..color = lineColor
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    // Dot at last point
    canvas.drawCircle(
      points.last,
      3.5,
      Paint()..color = lineColor,
    );
    canvas.drawCircle(
      points.last,
      2,
      Paint()..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(covariant _ChartPainter old) =>
      lineColor != old.lineColor || fillColor != old.fillColor;
}
