import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:enms/models/app_model.dart';
import 'package:enms/models/network_model.dart';
import 'package:enms/models/data_usage.dart';
import 'package:enms/providers/data_provider.dart';
import 'package:enms/widgets/time_range_selector.dart';
import 'package:enms/widgets/usage_chart.dart';
import 'package:enms/widgets/stats_card.dart';

class ReportsTab extends StatefulWidget {
  const ReportsTab({super.key});

  @override
  State<ReportsTab> createState() => _ReportsTabState();
}

class _ReportsTabState extends State<ReportsTab> {
  String _chartType = 'apps'; // apps, networks, comparison

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Consumer<DataProvider>(
      builder: (context, dataProvider, child) {
        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              color: theme.colorScheme.surface,
              child: Column(
                children: [
                  TimeRangeSelector(
                    selectedRange: dataProvider.selectedTimeRange,
                    onRangeChanged: (range) {
                      dataProvider.setTimeRange(range);
                    },
                  ),
                  const SizedBox(height: 16),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildChartTypeButton(
                          'apps',
                          'التطبيقات',
                          Icons.apps,
                          theme,
                        ),
                        const SizedBox(width: 12),
                        _buildChartTypeButton(
                          'networks',
                          'الشبكات',
                          Icons.wifi,
                          theme,
                        ),
                        const SizedBox(width: 12),
                        _buildChartTypeButton(
                          'comparison',
                          'مقارنة',
                          Icons.compare_arrows,
                          theme,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatsRow(context, dataProvider),
                    const SizedBox(height: 24),
                    _buildChartSection(context, dataProvider),
                    const SizedBox(height: 24),
                    _buildTopItemsList(context, dataProvider),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildChartTypeButton(
    String type,
    String label,
    IconData icon,
    ThemeData theme,
  ) {
    final isSelected = _chartType == type;
    return GestureDetector(
      onTap: () {
        setState(() {
          _chartType = type;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected 
              ? theme.colorScheme.primary 
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected 
                  ? theme.colorScheme.onPrimary 
                  : theme.colorScheme.onSurface,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: isSelected 
                    ? theme.colorScheme.onPrimary 
                    : theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context, DataProvider dataProvider) {
    final totalUsage = dataProvider.getTotalDataUsage();
    final activeApps = dataProvider.apps.length;
    final activeNetworks = dataProvider.networks.where((n) => n.isConnected).length;
    
    return Row(
      children: [
        Expanded(
          child: StatsCard(
            title: 'إجمالي الاستهلاك',
            value: _formatDataSize(totalUsage),
            icon: Icons.data_usage,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: StatsCard(
            title: 'التطبيقات النشطة',
            value: activeApps.toString(),
            icon: Icons.apps,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: StatsCard(
            title: 'الشبكات المتصلة',
            value: activeNetworks.toString(),
            icon: Icons.wifi,
            color: Theme.of(context).colorScheme.tertiary,
          ),
        ),
      ],
    );
  }

  Widget _buildChartSection(BuildContext context, DataProvider dataProvider) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _getChartTitle(),
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 300,
            child: UsageChart(
              type: _chartType,
              timeRange: dataProvider.selectedTimeRange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopItemsList(BuildContext context, DataProvider dataProvider) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _chartType == 'apps' ? 'أكثر التطبيقات استهلاكاً' : 'أكثر الشبكات استهلاكاً',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          ..._buildTopItems(context, dataProvider),
        ],
      ),
    );
  }

  List<Widget> _buildTopItems(BuildContext context, DataProvider dataProvider) {
    final theme = Theme.of(context);
    List<Widget> items = [];
    
    if (_chartType == 'apps') {
      final apps = dataProvider.apps.take(5).toList();
      for (int i = 0; i < apps.length; i++) {
        final app = apps[i];
        final usage = _getAppTotalUsage(app, dataProvider.selectedTimeRange);
        
        items.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      app.icon,
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        app.name,
                        style: theme.textTheme.bodyLarge,
                      ),
                      Text(
                        _formatDataSize(usage),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getRankColor(i, theme),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '#${i + 1}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    } else {
      final networks = dataProvider.networks.take(5).toList();
      for (int i = 0; i < networks.length; i++) {
        final network = networks[i];
        final usage = _getNetworkTotalUsage(network, dataProvider.selectedTimeRange);
        
        items.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    network.isConnected ? Icons.wifi : Icons.wifi_off,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        network.name,
                        style: theme.textTheme.bodyLarge,
                      ),
                      Text(
                        _formatDataSize(usage),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getRankColor(i, theme),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '#${i + 1}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }
    
    return items;
  }

  Color _getRankColor(int rank, ThemeData theme) {
    switch (rank) {
      case 0:
        return theme.colorScheme.tertiary; // Gold
      case 1:
        return theme.colorScheme.outline; // Silver
      case 2:
        return theme.colorScheme.secondary; // Bronze
      default:
        return theme.colorScheme.primary;
    }
  }

  String _getChartTitle() {
    switch (_chartType) {
      case 'apps':
        return 'استهلاك البيانات حسب التطبيقات';
      case 'networks':
        return 'استهلاك البيانات حسب الشبكات';
      case 'comparison':
        return 'مقارنة الاستهلاك';
      default:
        return 'استهلاك البيانات';
    }
  }

  double _getAppTotalUsage(AppModel app, String timeRange) {
    Map<String, DataUsage> usage;
    switch (timeRange) {
      case 'daily':
        usage = app.dailyUsage;
        break;
      case 'weekly':
        usage = app.weeklyUsage;
        break;
      case 'monthly':
        usage = app.monthlyUsage;
        break;
      default:
        usage = app.dailyUsage;
    }
    
    return usage.values.fold(0.0, (sum, data) => sum + data.totalMB);
  }

  double _getNetworkTotalUsage(NetworkModel network, String timeRange) {
    Map<String, DataUsage> usage;
    switch (timeRange) {
      case 'daily':
        usage = network.dailyUsage;
        break;
      case 'weekly':
        usage = network.weeklyUsage;
        break;
      case 'monthly':
        usage = network.monthlyUsage;
        break;
      default:
        usage = network.dailyUsage;
    }
    
    return usage.values.fold(0.0, (sum, data) => sum + data.totalMB);
  }

  String _formatDataSize(double sizeInMB) {
    if (sizeInMB < 1024) {
      return '${sizeInMB.toStringAsFixed(1)} MB';
    } else {
      return '${(sizeInMB / 1024).toStringAsFixed(1)} GB';
    }
  }
}