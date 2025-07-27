import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:enms/models/app_model.dart';
import 'package:enms/models/network_model.dart';
import 'package:enms/models/data_usage.dart';
import 'package:enms/providers/data_provider.dart';

class UsageChart extends StatelessWidget {
  final String type;
  final String timeRange;

  const UsageChart({
    super.key,
    required this.type,
    required this.timeRange,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Consumer<DataProvider>(
      builder: (context, dataProvider, child) {
        switch (type) {
          case 'apps':
            return _buildAppsChart(context, dataProvider, theme);
          case 'networks':
            return _buildNetworksChart(context, dataProvider, theme);
          case 'comparison':
            return _buildComparisonChart(context, dataProvider, theme);
          default:
            return _buildAppsChart(context, dataProvider, theme);
        }
      },
    );
  }

  Widget _buildAppsChart(BuildContext context, DataProvider dataProvider, ThemeData theme) {
    final apps = dataProvider.apps.take(5).toList();
    final chartData = apps.map((app) {
      final usage = _getAppUsage(app, timeRange);
      return PieChartSectionData(
        color: _getAppColor(apps.indexOf(app), theme),
        value: usage,
        title: '${(usage / 1024).toStringAsFixed(1)} GB',
        radius: 80,
        titleStyle: theme.textTheme.labelSmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      );
    }).toList();

    return Column(
      children: [
        Expanded(
          child: PieChart(
            PieChartData(
              sections: chartData,
              centerSpaceRadius: 60,
              sectionsSpace: 2,
              pieTouchData: PieTouchData(
                touchCallback: (FlTouchEvent event, pieTouchResponse) {
                  // Handle touch events
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children: apps.asMap().entries.map((entry) {
            final index = entry.key;
            final app = entry.value;
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: _getAppColor(index, theme),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  app.name,
                  style: theme.textTheme.bodySmall,
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildNetworksChart(BuildContext context, DataProvider dataProvider, ThemeData theme) {
    final networks = dataProvider.networks.take(4).toList();
    final chartData = networks.asMap().entries.map((entry) {
      final index = entry.key;
      final network = entry.value;
      final usage = _getNetworkUsage(network, timeRange);
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: usage / 1024, // Convert to GB
            color: _getNetworkColor(index, theme),
            width: 20,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ],
      );
    }).toList();

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceEvenly,
        maxY: chartData.isNotEmpty 
            ? chartData.map((e) => e.barRods.first.toY).reduce((a, b) => a > b ? a : b) * 1.2
            : 10,
        barGroups: chartData,
        gridData: FlGridData(show: true),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toStringAsFixed(1)} GB',
                  style: theme.textTheme.bodySmall,
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() < networks.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      networks[value.toInt()].name,
                      style: theme.textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
      ),
    );
  }

  Widget _buildComparisonChart(BuildContext context, DataProvider dataProvider, ThemeData theme) {
    final apps = dataProvider.apps.take(5).toList();
    List<FlSpot> downloadSpots = [];
    List<FlSpot> uploadSpots = [];

    for (int i = 0; i < apps.length; i++) {
      final app = apps[i];
      final usage = _getAppUsageBreakdown(app, timeRange);
      downloadSpots.add(FlSpot(i.toDouble(), usage['download']! / 1024));
      uploadSpots.add(FlSpot(i.toDouble(), usage['upload']! / 1024));
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toStringAsFixed(1)} GB',
                  style: theme.textTheme.bodySmall,
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() < apps.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      apps[value.toInt()].name.substring(0, 
                          apps[value.toInt()].name.length > 6 ? 6 : apps[value.toInt()].name.length),
                      style: theme.textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: downloadSpots,
            isCurved: true,
            color: theme.colorScheme.secondary,
            barWidth: 3,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: theme.colorScheme.secondary.withValues(alpha: 0.2),
            ),
          ),
          LineChartBarData(
            spots: uploadSpots,
            isCurved: true,
            color: theme.colorScheme.tertiary,
            barWidth: 3,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: theme.colorScheme.tertiary.withValues(alpha: 0.2),
            ),
          ),
        ],
      ),
    );
  }

  Color _getAppColor(int index, ThemeData theme) {
    final colors = [
      theme.colorScheme.primary,
      theme.colorScheme.secondary,
      theme.colorScheme.tertiary,
      theme.colorScheme.error,
      theme.colorScheme.outline,
    ];
    return colors[index % colors.length];
  }

  Color _getNetworkColor(int index, ThemeData theme) {
    final colors = [
      theme.colorScheme.primary,
      theme.colorScheme.secondary,
      theme.colorScheme.tertiary,
      theme.colorScheme.error,
    ];
    return colors[index % colors.length];
  }

  double _getAppUsage(AppModel app, String timeRange) {
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

  double _getNetworkUsage(NetworkModel network, String timeRange) {
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

  Map<String, double> _getAppUsageBreakdown(AppModel app, String timeRange) {
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
    
    return {
      'download': usage.values.fold(0.0, (sum, data) => sum + data.downloadMB),
      'upload': usage.values.fold(0.0, (sum, data) => sum + data.uploadMB),
    };
  }
}