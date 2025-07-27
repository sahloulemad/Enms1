import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:enms/models/network_model.dart';
import 'package:enms/models/speed_limit_model.dart';
import 'package:enms/providers/data_provider.dart';
import 'package:enms/widgets/usage_chart.dart';
import 'package:enms/widgets/time_range_selector.dart';

class NetworkDetailsScreen extends StatefulWidget {
  final NetworkModel network;

  const NetworkDetailsScreen({
    super.key,
    required this.network,
  });

  @override
  State<NetworkDetailsScreen> createState() => _NetworkDetailsScreenState();
}

class _NetworkDetailsScreenState extends State<NetworkDetailsScreen> {
@override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Consumer<DataProvider>(
          builder: (context, dataProvider, child) {
            final speedLimit = dataProvider.getSpeedLimitForNetwork(widget.network.id);
            
            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 200,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(
                      widget.network.name,
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
                                    child: Icon(
                                      widget.network.isConnected ? Icons.wifi : Icons.wifi_off,
                                      color: theme.colorScheme.onPrimary,
                                      size: 32,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          widget.network.ssid,
                                          style: theme.textTheme.bodyLarge?.copyWith(
                                            color: theme.colorScheme.onPrimary.withValues(alpha: 0.9),
                                          ),
                                        ),
                                        Text(
                                          '${widget.network.securityType} • ${widget.network.signalStrength}%',
                                          style: theme.textTheme.bodyMedium?.copyWith(
                                            color: theme.colorScheme.onPrimary.withValues(alpha: 0.7),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (widget.network.isConnected)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.secondary,
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Text(
                                        'متصل',
                                        style: theme.textTheme.labelMedium?.copyWith(
                                          color: theme.colorScheme.onSecondary,
                                          fontWeight: FontWeight.bold,
                                        ),
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
                        _buildUsageStats(context, theme),
                        const SizedBox(height: 24),
                        _buildSpeedControlCard(context, theme, speedLimit, dataProvider),
                        const SizedBox(height: 24),
                        _buildUsageChart(context, theme, dataProvider),
                        const SizedBox(height: 24),
                        _buildConnectedApps(context, theme, dataProvider),
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

  Widget _buildUsageStats(BuildContext context, ThemeData theme) {
    final totalUsage = _calculateTotalUsage();
    final downloadUsage = _calculateDownloadUsage();
    final uploadUsage = _calculateUploadUsage();
    
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

  Widget _buildSpeedControlCard(
    BuildContext context,
    ThemeData theme,
    SpeedLimitModel? speedLimit,
    DataProvider dataProvider,
  ) {
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
          Row(
            children: [
              Icon(
                Icons.speed,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 12),
              Text(
                'التحكم في السرعة',
                style: theme.textTheme.titleMedium,
              ),
              const Spacer(),
              Switch(
                value: speedLimit?.isEnabled ?? false,
                onChanged: (value) {
                  if (speedLimit != null) {
                    dataProvider.updateSpeedLimit(
                      speedLimit.copyWith(isEnabled: value),
                    );
                  } else {
                    _showSpeedLimitSetupDialog(context, dataProvider);
                  }
                },
              ),
            ],
          ),
          if (speedLimit != null) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'سرعة التحميل',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                      Text(
                        '${(speedLimit.downloadLimitKbps / 1024).toStringAsFixed(1)} MB/s',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: theme.colorScheme.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'سرعة الرفع',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                      Text(
                        '${(speedLimit.uploadLimitKbps / 1024).toStringAsFixed(1)} MB/s',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: theme.colorScheme.tertiary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      _showSpeedLimitSetupDialog(context, dataProvider, speedLimit);
                    },
                    child: const Text('تعديل'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      dataProvider.removeSpeedLimit(speedLimit.id);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: theme.colorScheme.error,
                      side: BorderSide(color: theme.colorScheme.error),
                    ),
                    child: const Text('إزالة'),
                  ),
                ),
              ],
            ),
          ] else ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  _showSpeedLimitSetupDialog(context, dataProvider);
                },
                icon: const Icon(Icons.add),
                label: const Text('إعداد حد السرعة'),
              ),
            ),
          ],
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
              type: 'networks',
              timeRange: dataProvider.selectedTimeRange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectedApps(BuildContext context, ThemeData theme, DataProvider dataProvider) {
    final connectedApps = dataProvider.apps.where((app) {
      return app.networkUsage.containsKey(widget.network.id);
    }).take(5).toList();

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
            'التطبيقات المتصلة',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          ...connectedApps.map((app) {
            final usage = app.networkUsage[widget.network.id]?.values
                    .fold(0.0, (sum, data) => sum + data.totalMB) ?? 0.0;
            
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
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  void _showSpeedLimitSetupDialog(
    BuildContext context,
    DataProvider dataProvider,
    [SpeedLimitModel? existingLimit]
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => SpeedLimitSetupDialog(
        networkId: widget.network.id,
        existingLimit: existingLimit,
        onSave: (speedLimit) {
          if (existingLimit != null) {
            dataProvider.updateSpeedLimit(speedLimit);
          } else {
            dataProvider.addSpeedLimit(speedLimit);
          }
        },
      ),
    );
  }

  double _calculateTotalUsage() {
    return widget.network.dailyUsage.values.fold(0.0, (sum, data) => sum + data.totalMB);
  }

  double _calculateDownloadUsage() {
    return widget.network.dailyUsage.values.fold(0.0, (sum, data) => sum + data.downloadMB);
  }

  double _calculateUploadUsage() {
    return widget.network.dailyUsage.values.fold(0.0, (sum, data) => sum + data.uploadMB);
  }

  String _formatDataSize(double sizeInMB) {
    if (sizeInMB < 1024) {
      return '${sizeInMB.toStringAsFixed(1)} MB';
    } else {
      return '${(sizeInMB / 1024).toStringAsFixed(1)} GB';
    }
  }
}

class SpeedLimitSetupDialog extends StatefulWidget {
  final String networkId;
  final SpeedLimitModel? existingLimit;
  final Function(SpeedLimitModel) onSave;

  const SpeedLimitSetupDialog({
    super.key,
    required this.networkId,
    this.existingLimit,
    required this.onSave,
  });

  @override
  State<SpeedLimitSetupDialog> createState() => _SpeedLimitSetupDialogState();
}

class _SpeedLimitSetupDialogState extends State<SpeedLimitSetupDialog> {
  late TextEditingController _downloadController;
  late TextEditingController _uploadController;

  @override
  void initState() {
    super.initState();
    _downloadController = TextEditingController(
      text: widget.existingLimit != null 
          ? (widget.existingLimit!.downloadLimitKbps / 1024).toStringAsFixed(1)
          : '',
    );
    _uploadController = TextEditingController(
      text: widget.existingLimit != null 
          ? (widget.existingLimit!.uploadLimitKbps / 1024).toStringAsFixed(1)
          : '',
    );
  }

  @override
  void dispose() {
    _downloadController.dispose();
    _uploadController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.existingLimit != null ? 'تعديل حد السرعة' : 'إعداد حد السرعة',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _downloadController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'سرعة التحميل (MB/s)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.download),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _uploadController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'سرعة الرفع (MB/s)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.upload),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('إلغاء'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saveSpeedLimit,
                    child: const Text('حفظ'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _saveSpeedLimit() {
    final downloadMBps = double.tryParse(_downloadController.text) ?? 0.0;
    final uploadMBps = double.tryParse(_uploadController.text) ?? 0.0;

    if (downloadMBps <= 0 || uploadMBps <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى إدخال قيم صحيحة للسرعة'),
        ),
      );
      return;
    }

    final speedLimit = SpeedLimitModel(
      id: widget.existingLimit?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      networkId: widget.networkId,
      isEnabled: true,
      downloadLimitKbps: downloadMBps * 1024,
      uploadLimitKbps: uploadMBps * 1024,
      createdAt: widget.existingLimit?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    widget.onSave(speedLimit);
    Navigator.pop(context);
  }
}