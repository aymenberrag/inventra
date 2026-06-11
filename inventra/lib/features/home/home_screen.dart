import 'package:flutter/material.dart';

import '../../core/l10n/app_localizations.dart';

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

    final l10n = AppLocalizations.of(context);



    showModalBottomSheet(

      context: context,

      isScrollControlled: true,

      shape: const RoundedRectangleBorder(

        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),

      ),

      builder: (ctx) {

        return DraggableScrollableSheet(

          expand: false,

          initialChildSize: 0.5,

          minChildSize: 0.3,

          maxChildSize: 0.85,

          builder: (_, scrollController) {

            return Padding(

              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),

              child: Column(

                crossAxisAlignment: CrossAxisAlignment.start,

                children: [

                  Center(

                    child: Container(

                      width: 40,

                      height: 4,

                      decoration: BoxDecoration(

                        color: Colors.grey.shade300,

                        borderRadius: BorderRadius.circular(2),

                      ),

                    ),

                  ),

                  const SizedBox(height: 16),

                  Row(

                    children: [

                      Text(

                        l10n.notifications,

                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),

                      ),

                      const Spacer(),

                      if (_notificationCount > 0)

                        Container(

                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),

                          decoration: BoxDecoration(

                            color: AppTheme.danger.withValues(alpha: 0.1),

                            borderRadius: BorderRadius.circular(12),

                          ),

                          child: Text(

                            '$_notificationCount',

                            style: const TextStyle(

                              color: AppTheme.danger,

                              fontWeight: FontWeight.bold,

                            ),

                          ),

                        ),

                    ],

                  ),

                  const SizedBox(height: 16),

                  Expanded(

                    child: _notifications.isEmpty

                        ? Center(

                            child: Column(

                              mainAxisSize: MainAxisSize.min,

                              children: [

                                Icon(Icons.notifications_none, size: 48, color: Colors.grey.shade400),

                                const SizedBox(height: 12),

                                Text(l10n.noNotifications, style: TextStyle(color: Colors.grey.shade600)),

                              ],

                            ),

                          )

                        : ListView.separated(

                            controller: scrollController,

                            itemCount: _notifications.length,

                            separatorBuilder: (_, __) => const SizedBox(height: 8),

                            itemBuilder: (_, i) {

                              final n = _notifications[i];

                              return Container(

                                padding: const EdgeInsets.all(14),

                                decoration: BoxDecoration(

                                  color: AppTheme.warning.withValues(alpha: 0.08),

                                  borderRadius: BorderRadius.circular(12),

                                  border: Border.all(

                                    color: AppTheme.warning.withValues(alpha: 0.2),

                                  ),

                                ),

                                child: Row(

                                  children: [

                                    Container(

                                      padding: const EdgeInsets.all(8),

                                      decoration: BoxDecoration(

                                        color: AppTheme.warning.withValues(alpha: 0.15),

                                        borderRadius: BorderRadius.circular(8),

                                      ),

                                      child: const Icon(

                                        Icons.warning_amber_rounded,

                                        color: AppTheme.warning,

                                        size: 20,

                                      ),

                                    ),

                                    const SizedBox(width: 12),

                                    Expanded(

                                      child: Text(

                                        n['message']?.toString() ?? '',

                                        style: const TextStyle(fontSize: 14),

                                      ),

                                    ),

                                  ],

                                ),

                              );

                            },

                          ),

                  ),

                ],

              ),

            );

          },

        );

      },

    );

  }



  @override

  Widget build(BuildContext context) {

    final l10n = AppLocalizations.of(context);

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

              padding: const EdgeInsets.symmetric(horizontal: 16),

              child: Column(

                crossAxisAlignment: CrossAxisAlignment.start,

                children: [

                  Text(

                    l10n.todaysOverview,

                    style: const TextStyle(

                      fontSize: 17,

                      fontWeight: FontWeight.w600,

                    ),

                  ),

                  const SizedBox(height: 12),

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

                      mainAxisSpacing: 10,

                      crossAxisSpacing: 10,

                      childAspectRatio: 1.45,

                      children: [

                        StatCard(

                          title: l10n.totalSales,

                          value: '$sales',

                          icon: Icons.receipt_long,

                          color: AppTheme.primary,

                        ),

                        StatCard(

                          title: l10n.revenue,

                          value: CurrencyFormatter.format(revenue, _currency),

                          icon: Icons.attach_money,

                          color: AppTheme.accent,

                        ),

                        StatCard(

                          title: l10n.profit,

                          value: CurrencyFormatter.format(profit, _currency),

                          icon: Icons.trending_up,

                          color: AppTheme.success,

                        ),

                        StatCard(

                          title: l10n.lowStock,

                          value: '$_notificationCount',

                          icon: Icons.inventory_2,

                          color: AppTheme.warning,

                        ),

                      ],

                    ),

                  const SizedBox(height: 16),

                  Container(

                    padding: const EdgeInsets.all(16),

                    decoration: BoxDecoration(

                      gradient: LinearGradient(

                        colors: [

                          AppTheme.primary.withValues(alpha: 0.08),

                          AppTheme.accent.withValues(alpha: 0.08),

                        ],

                      ),

                      borderRadius: BorderRadius.circular(16),

                      border: Border.all(color: AppTheme.primary.withValues(alpha: 0.15)),

                    ),

                    child: Row(

                      children: [

                        Container(

                          padding: const EdgeInsets.all(12),

                          decoration: BoxDecoration(

                            color: AppTheme.primary.withValues(alpha: 0.15),

                            borderRadius: BorderRadius.circular(12),

                          ),

                          child: const Icon(Icons.qr_code_scanner_rounded, color: AppTheme.primary),

                        ),

                        const SizedBox(width: 14),

                        Expanded(

                          child: Column(

                            crossAxisAlignment: CrossAxisAlignment.start,

                            children: [

                              Text(

                                l10n.quickSale,

                                style: const TextStyle(

                                  fontWeight: FontWeight.w600,

                                  fontSize: 15,

                                ),

                              ),

                              const SizedBox(height: 2),

                              Text(

                                l10n.quickSaleHint,

                                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),

                              ),

                            ],

                          ),

                        ),

                      ],

                    ),

                  ),

                  const SizedBox(height: 20),

                ],

              ),

            ),

          ),

        ],

      ),

    );

  }

}

