import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:enms/models/app_model.dart';
import 'package:enms/models/network_model.dart';
import 'package:enms/models/data_usage.dart';
import 'package:enms/providers/data_provider.dart';
import 'package:enms/widgets/usage_chart.dart';
import 'package:enms/widgets/time_range_selector.dart';

class AppDetailsScreen extends StatefulWidget {
  final AppModel app;

  const AppDetailsScreen({
    super.key,
    required this.app,
  });

  @override
  State<AppDetailsScreen> createState() => _AppDetailsScreenState();
}

class _AppDetailsScreenState extends State<AppDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Consumer<DataProvider>(
          builder: (context, dataProvider, child) {
            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 200,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(
                      widget.app.name,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: theme.colorScheme.onPrimary,
                      ),
                    ),
                    background: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            theme.colorScheme.primary,
                            theme.colorScheme.primary.withValues(alpha: 0.8),
                          ],
                        ),
                      ),
                      child: SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Text(
                                      widget.app.icon,
                                      style: const TextStyle(fontSize: 32),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          widget.app.packageName,
                                          style: theme.textTheme.bodyMedium?.copyWith(
                                            color: theme.colorScheme.onPrimary.withValues(alpha: 0.8),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        if (widget.app.isSystemApp)
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: theme.colorScheme.secondary,
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              'تطبيق نظام',
                                              style: theme.textTheme.labelSmall?.copyWith(
                                                color: theme.colorScheme.onSecondary,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TimeRangeSelector(
                          selectedRange: dataProvider.selectedTimeRange,
                          onRangeChanged: (range) {
                            dataProvider.setTimeRange(range);
                          },
                        ),
                        const SizedBox(height: 24),
                        _buildUsageStats(context, theme, dataProvider),
                        const SizedBox(height: 24),
                        _buildUsageChart(context, theme, dataProvider),
                        const SizedBox(height: 24),
                        _buildNetworkUsage(context, theme, dataProvider),
                        const SizedBox(height: 24),
                        _buildAppInfo(context, theme),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildUsageStats(BuildContext context, ThemeData theme, DataProvider dataProvider) {
    final usage = _getUsageForTimeRange(dataProvider.selectedTimeRange);
    final totalUsage = usage.values.fold(0.0, (sum, data) => sum + data.totalMB);
    final downloadUsage = usage.values.fold(0.0, (sum, data) => sum + data.downloadMB);
    final uploadUsage = usage.values.fold(0.0, (sum, data) => sum + data.uploadMB);
    
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            'إجمالي الاستهلاك',
            _formatDataSize(totalUsage),
            Icons.data_usage,
            theme.colorScheme.primary,
            theme,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context,
            'التحميل',
            _formatDataSize(downloadUsage),
            Icons.download,
            theme.colorScheme.secondary,
            theme,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context,
            'الرفع',
            _formatDataSize(uploadUsage),
            Icons.upload,
            theme.colorScheme.tertiary,
            theme,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
    ThemeData theme,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildUsageChart(BuildContext context, ThemeData theme, DataProvider dataProvider) {
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
            'استهلاك البيانات عبر الوقت',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: UsageChart(
              type: 'comparison',
              timeRange: dataProvider.selectedTimeRange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNetworkUsage(BuildContext context, ThemeData theme, DataProvider dataProvider) {
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
            'الاستهلاك حسب الشبكة',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          ...widget.app.networkUsage.entries.map((entry) {
            final networkId = entry.key;
            final networkUsage = entry.value;
            final network = dataProvider.networks.firstWhere(
              (n) => n.id == networkId,
              orElse: () => NetworkModel(
                id: networkId,
                name: 'شبكة غير معروفة',
                ssid: 'Unknown',
                isConnected: false,
                signalStrength: 0,
                securityType: 'Unknown',
                dailyUsage: {},
                weeklyUsage: {},
                monthlyUsage: {},
              ),
            );
            
            final totalUsage = networkUsage.values.fold(0.0, (sum, data) => sum + data.totalMB);
            
            return Padding(
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
                          _formatDataSize(totalUsage),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${((totalUsage / _getTotalAppUsage(dataProvider.selectedTimeRange)) * 100).toStringAsFixed(1)}%',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildAppInfo(BuildContext context, ThemeData theme) {
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
            'معلومات التطبيق',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            context,
            'اسم التطبيق',
            widget.app.name,
            Icons.apps,
            theme,
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            context,
            'اسم الحزمة',
            widget.app.packageName,
            Icons.code,
            theme,
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            context,
            'نوع التطبيق',
            widget.app.isSystemApp ? 'تطبيق نظام' : 'تطبيق مستخدم',
            widget.app.isSystemApp ? Icons.security : Icons.person,
            theme,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    ThemeData theme,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: theme.colorScheme.outline,
        ),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.outline,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }

  Map<String, DataUsage> _getUsageForTimeRange(String timeRange) {
    switch (timeRange) {
      case 'daily':
        return widget.app.dailyUsage;
      case 'weekly':
        return widget.app.weeklyUsage;
      case 'monthly':
        return widget.app.monthlyUsage;
      default:
        return widget.app.dailyUsage;
    }
  }

  double _getTotalAppUsage(String timeRange) {
    final usage = _getUsageForTimeRange(timeRange);
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