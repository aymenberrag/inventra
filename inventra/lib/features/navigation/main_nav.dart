import 'package:flutter/material.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../home/home_screen.dart';
import '../stock/stock_screen.dart';
import '../sale/scanner_screen.dart';
import '../stats/stats_screen.dart';
import '../profile/profile_screen.dart';

class MainNav extends StatefulWidget {
  const MainNav({super.key});

  @override
  State<MainNav> createState() => _MainNavState();
}

class _MainNavState extends State<MainNav> {
  int _index = 0;

  int get _stackIndex {
    if (_index <= 1) return _index;
    if (_index >= 3) return _index - 1;
    return 0;
  }

  void _onTabTapped(int index) {
    if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ScannerScreen()),
      );
      return;
    }
    setState(() => _index = index);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: IndexedStack(
        index: _stackIndex,
        children: const [
          HomeScreen(),
          StockScreen(),
          StatsScreen(),
          ProfileScreen(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            height: 64,
            child: Row(
              children: [
                _NavItem(
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home_rounded,
                  label: l10n.home,
                  selected: _index == 0,
                  onTap: () => _onTabTapped(0),
                ),
                _NavItem(
                  icon: Icons.inventory_2_outlined,
                  activeIcon: Icons.inventory_2_rounded,
                  label: l10n.stock,
                  selected: _index == 1,
                  onTap: () => _onTabTapped(1),
                ),
                Expanded(
                  child: Center(
                    child: GestureDetector(
                      onTap: () => _onTabTapped(2),
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppTheme.primary, AppTheme.primaryDark],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primary.withValues(alpha: 0.35),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.qr_code_scanner_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ),
                  ),
                ),
                _NavItem(
                  icon: Icons.bar_chart_outlined,
                  activeIcon: Icons.bar_chart_rounded,
                  label: l10n.stats,
                  selected: _index == 3,
                  onTap: () => _onTabTapped(3),
                ),
                _NavItem(
                  icon: Icons.person_outline,
                  activeIcon: Icons.person_rounded,
                  label: l10n.profile,
                  selected: _index == 4,
                  onTap: () => _onTabTapped(4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              selected ? activeIcon : icon,
              color: selected ? AppTheme.primary : Colors.grey.shade500,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                color: selected ? AppTheme.primary : Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
