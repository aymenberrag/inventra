import 'package:flutter/material.dart';
import '../../core/storage/store_storage.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/widgets/app_header.dart';
import '../../core/widgets/stat_card.dart';
import '../../core/theme/app_theme.dart';
import '../stores/store_service.dart';
import '../sale/sale_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _statsService = StatsService();
  final _storeService = StoreService();

  String _storeName = '';
  String _currency = 'USD';
  int _notificationCount = 0;
  Map<String, dynamic>? _stats;
  List<Map<String, dynamic>> _notifications = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final storeId = await StoreStorage.getStoreId();
      final storeName = await StoreStorage.getStoreName();
      final currency = await StoreStorage.getCurrency();

      if (storeId == null) return;

      final results = await Future.wait([
        _statsService.getDashboard(storeId: storeId, period: 'today'),
        _storeService.getNotifications(storeId),
      ]);

      setState(() {
        _storeName = storeName ?? 'My Store';
        _currency = currency;
        _stats = results[0] as Map<String, dynamic>;
        _notifications = (results[1] as List).cast<Map<String, dynamic>>();
        _notificationCount = _notifications.length;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  void _showNotifications() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Notifications',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              if (_notifications.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: Text('No notifications')),
                )
              else
                ..._notifications.map(
                  (n) => ListTile(
                    leading: const Icon(Icons.warning_amber, color: AppTheme.warning),
                    title: Text(n['message']?.toString() ?? ''),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final revenue = (_stats?['total_revenue'] as num?)?.toDouble() ?? 0;
    final profit = (_stats?['total_profit'] as num?)?.toDouble() ?? 0;
    final sales = (_stats?['total_sales'] as num?)?.toInt() ?? 0;

    return RefreshIndicator(
      onRefresh: _loadData,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: AppHeader(
              storeName: _storeName,
              notificationCount: _notificationCount,
              onNotificationTap: _showNotifications,
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Today's Overview",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_loading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.3,
                      children: [
                        StatCard(
                          title: 'Total Sales',
                          value: '$sales',
                          icon: Icons.receipt_long,
                          color: AppTheme.primary,
                        ),
                        StatCard(
                          title: 'Revenue',
                          value: CurrencyFormatter.format(revenue, _currency),
                          icon: Icons.attach_money,
                          color: AppTheme.accent,
                        ),
                        StatCard(
                          title: 'Profit',
                          value: CurrencyFormatter.format(profit, _currency),
                          icon: Icons.trending_up,
                          color: AppTheme.success,
                        ),
                        StatCard(
                          title: 'Low Stock',
                          value: '$_notificationCount',
                          icon: Icons.inventory_2,
                          color: AppTheme.warning,
                        ),
                      ],
                    ),
                  const SizedBox(height: 24),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppTheme.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.qr_code_scanner, color: AppTheme.primary),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Quick Sale',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  'Tap the + button to scan products',
                                  style: TextStyle(color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
