import 'package:flutter/material.dart';
import 'package:enms/models/app_model.dart';
import 'package:enms/models/data_usage.dart';

class AppCard extends StatelessWidget {
  final AppModel app;
  final String timeRange;
  final VoidCallback onTap;

  const AppCard({
    super.key,
    required this.app,
    required this.timeRange,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final usage = _getUsageForTimeRange();
    final totalUsage = usage.values.fold(0.0, (sum, data) => sum + data.totalMB);
    final downloadUsage = usage.values.fold(0.0, (sum, data) => sum + data.downloadMB);
    final uploadUsage = usage.values.fold(0.0, (sum, data) => sum + data.uploadMB);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.shadow.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      app.icon,
                      style: const TextStyle(fontSize: 24),
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
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        app.packageName,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                ),
                if (app.isSystemApp)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.outline.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'نظام',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildUsageMetric(
                      context,
                      'إجمالي',
                      _formatDataSize(totalUsage),
                      Icons.data_usage,
                      theme.colorScheme.primary,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 30,
                    color: theme.colorScheme.outline.withValues(alpha: 0.2),
                  ),
                  Expanded(
                    child: _buildUsageMetric(
                      context,
                      'تحميل',
                      _formatDataSize(downloadUsage),
                      Icons.download,
                      theme.colorScheme.secondary,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 30,
                    color: theme.colorScheme.outline.withValues(alpha: 0.2),
                  ),
                  Expanded(
                    child: _buildUsageMetric(
                      context,
                      'رفع',
                      _formatDataSize(uploadUsage),
                      Icons.upload,
                      theme.colorScheme.tertiary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUsageMetric(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 14,
              color: color,
            ),
            const SizedBox(width: 4),
            Text(
              value,
              style: theme.textTheme.labelLarge?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.outline,
          ),
        ),
      ],
    );
  }

  Map<String, DataUsage> _getUsageForTimeRange() {
    switch (timeRange) {
      case 'daily':
        return app.dailyUsage;
      case 'weekly':
        return app.weeklyUsage;
      case 'monthly':
        return app.monthlyUsage;
      default:
        return app.dailyUsage;
    }
  }

  String _formatDataSize(double sizeInMB) {
    if (sizeInMB < 1024) {
      return '${sizeInMB.toStringAsFixed(1)} MB';
    } else {
      return '${(sizeInMB / 1024).toStringAsFixed(1)} GB';
    }
  }
}