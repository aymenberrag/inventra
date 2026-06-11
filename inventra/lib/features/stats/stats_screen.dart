import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../core/storage/store_storage.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/stat_card.dart';
import '../sale/sale_service.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  final _statsService = StatsService();

  String _period = 'today';
  DateTime? _startDate;
  DateTime? _endDate;
  Map<String, dynamic>? _stats;
  String _currency = 'USD';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _loading = true);
    try {
      final storeId = await StoreStorage.getStoreId();
      final currency = await StoreStorage.getCurrency();
      if (storeId == null) return;

      String? start;
      String? end;
      if (_period == 'custom' && _startDate != null && _endDate != null) {
        start = DateFormat('yyyy-MM-dd').format(_startDate!);
        end = DateFormat('yyyy-MM-dd').format(_endDate!);
      }

      final stats = await _statsService.getDashboard(
        storeId: storeId,
        period: _period == 'custom' ? null : _period,
        start: start,
        end: end,
      );

      setState(() {
        _stats = stats;
        _currency = currency;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _pickDateRange() async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (range != null) {
      setState(() {
        _period = 'custom';
        _startDate = range.start;
        _endDate = range.end;
      });
      _loadStats();
    }
  }

  List<Map<String, dynamic>> get _chartData {
    final chart = _stats?['chart'] as List?;
    if (chart == null) return [];
    return chart.cast<Map<String, dynamic>>();
  }

  @override
  Widget build(BuildContext context) {
    final revenue = (_stats?['total_revenue'] as num?)?.toDouble() ?? 0;
    final profit = (_stats?['total_profit'] as num?)?.toDouble() ?? 0;
    final sales = (_stats?['total_sales'] as num?)?.toInt() ?? 0;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadStats,
          child: CustomScrollView(
            slivers: [
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Text(
                    'Statistics',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      _PeriodChip(
                        label: 'Today',
                        selected: _period == 'today',
                        onTap: () {
                          setState(() => _period = 'today');
                          _loadStats();
                        },
                      ),
                      _PeriodChip(
                        label: 'This Week',
                        selected: _period == 'week',
                        onTap: () {
                          setState(() => _period = 'week');
                          _loadStats();
                        },
                      ),
                      _PeriodChip(
                        label: 'This Month',
                        selected: _period == 'month',
                        onTap: () {
                          setState(() => _period = 'month');
                          _loadStats();
                        },
                      ),
                      _PeriodChip(
                        label: 'Custom',
                        selected: _period == 'custom',
                        onTap: _pickDateRange,
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: _loading
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(40),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      : Column(
                          children: [
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
                                  title: 'Avg. Sale',
                                  value: sales > 0
                                      ? CurrencyFormatter.format(revenue / sales, _currency)
                                      : CurrencyFormatter.format(0, _currency),
                                  icon: Icons.analytics,
                                  color: AppTheme.warning,
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            _buildChart(
                              title: 'Revenue',
                              color: AppTheme.primary,
                              valueKey: 'revenue',
                            ),
                            const SizedBox(height: 24),
                            _buildChart(
                              title: 'Profit',
                              color: AppTheme.success,
                              valueKey: 'profit',
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

  Widget _buildChart({
    required String title,
    required Color color,
    required String valueKey,
  }) {
    if (_chartData.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Text(
              'No $title data for this period',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
        ),
      );
    }

    final maxY = _chartData
        .map((e) => (e[valueKey] as num?)?.toDouble() ?? 0)
        .fold(0.0, (a, b) => a > b ? a : b);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  maxY: maxY > 0 ? maxY * 1.2 : 10,
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: maxY > 0 ? maxY / 4 : 2,
                  ),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index < 0 || index >= _chartData.length) {
                            return const SizedBox.shrink();
                          }
                          final label = _chartData[index]['label']?.toString() ?? '';
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              label.length > 5 ? label.substring(label.length - 5) : label,
                              style: const TextStyle(fontSize: 9),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  barGroups: List.generate(_chartData.length, (index) {
                    final value =
                        (_chartData[index][valueKey] as num?)?.toDouble() ?? 0;
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: value,
                          color: color,
                          width: 16,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(6),
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PeriodChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _PeriodChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        selectedColor: AppTheme.primary.withValues(alpha: 0.15),
        checkmarkColor: AppTheme.primary,
      ),
    );
  }
}
