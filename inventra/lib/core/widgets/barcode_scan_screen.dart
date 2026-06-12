import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/theme/app_theme.dart';

class BarcodeScanScreen extends StatefulWidget {
  const BarcodeScanScreen({super.key});

  @override
  State<BarcodeScanScreen> createState() => _BarcodeScanScreenState();
}

class _BarcodeScanScreenState extends State<BarcodeScanScreen>
    with SingleTickerProviderStateMixin {
  final _controller = MobileScannerController();
  late AnimationController _animController;
  bool _processing = false;
  String? _lastScanned;
  bool _torchOn = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_processing) return;
    final barcode = capture.barcodes.firstOrNull?.rawValue;
    if (barcode == null || barcode == _lastScanned) return;
    setState(() {
      _processing = true;
      _lastScanned = barcode;
    });
    Navigator.pop(context, barcode);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scanArea = const Size(280, 180);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
          ),
          // Dark overlay with transparent cutout
          CustomPaint(
            size: MediaQuery.of(context).size,
            painter: _ScanOverlayPainter(scanArea: scanArea),
          ),
          // Corner brackets
          Center(
            child: SizedBox(
              width: scanArea.width,
              height: scanArea.height,
              child: Stack(
                children: [
                  Positioned(top: 0, left: 0, child: _buildCorner(true, true)),
                  Positioned(top: 0, right: 0, child: _buildCorner(true, false)),
                  Positioned(bottom: 0, left: 0, child: _buildCorner(false, true)),
                  Positioned(bottom: 0, right: 0, child: _buildCorner(false, false)),
                ],
              ),
            ),
          ),
          // Animated scan line
          Center(
            child: SizedBox(
              width: scanArea.width - 20,
              height: scanArea.height,
              child: AnimatedBuilder(
                animation: _animController,
                builder: (context, child) {
                  return Align(
                    alignment: Alignment(
                      0,
                      -1 + 2 * _animController.value,
                    ),
                    child: Container(
                      width: double.infinity,
                      height: 2,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            AppTheme.primary.withValues(alpha: 0.8),
                            AppTheme.accent,
                            AppTheme.primary.withValues(alpha: 0.8),
                            Colors.transparent,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primary.withValues(alpha: 0.5),
                            blurRadius: 12,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          // Top bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    const Spacer(),
                    Text(
                      l10n.scanBarcode,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () {
                        _controller.toggleTorch();
                        setState(() => _torchOn = !_torchOn);
                      },
                      icon: Icon(
                        _torchOn ? Icons.flash_on : Icons.flash_off,
                        color: _torchOn ? AppTheme.warning : Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Bottom instruction
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Text(
                    l10n.pointCamera,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCorner(bool top, bool left) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        border: Border(
          top: top
              ? const BorderSide(color: AppTheme.primary, width: 4)
              : BorderSide.none,
          bottom: !top
              ? const BorderSide(color: AppTheme.primary, width: 4)
              : BorderSide.none,
          left: left
              ? const BorderSide(color: AppTheme.primary, width: 4)
              : BorderSide.none,
          right: !left
              ? const BorderSide(color: AppTheme.primary, width: 4)
              : BorderSide.none,
        ),
      ),
    );
  }
}

class _ScanOverlayPainter extends CustomPainter {
  final Size scanArea;

  _ScanOverlayPainter({required this.scanArea});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black.withValues(alpha: 0.6);
    final cutout = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: scanArea.width,
      height: scanArea.height,
    );
    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
        Path()
          ..addRRect(
            RRect.fromRectAndRadius(cutout, const Radius.circular(16)),
          ),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
