import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:enms/providers/data_provider.dart';
import 'package:enms/models/app_model.dart';
import 'package:enms/models/data_usage.dart';
import 'package:enms/widgets/app_card.dart';
import 'package:enms/widgets/search_bar_widget.dart';
import 'package:enms/widgets/time_range_selector.dart';
import 'package:enms/screens/app_details_screen.dart';

class AppsTab extends StatefulWidget {
  const AppsTab({super.key});

  @override
  State<AppsTab> createState() => _AppsTabState();
}

class _AppsTabState extends State<AppsTab> {
  String _searchQuery = '';
  String _sortBy = 'usage'; // usage, name, alphabetical

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Consumer<DataProvider>(
      builder: (context, dataProvider, child) {
        List<AppModel> apps = dataProvider.getFilteredApps(_searchQuery);
        
        // Sort apps based on selected criteria
        apps.sort((a, b) {
          switch (_sortBy) {
            case 'usage':
              final aUsage = _getTotalUsage(a, dataProvider.selectedTimeRange);
              final bUsage = _getTotalUsage(b, dataProvider.selectedTimeRange);
              return bUsage.compareTo(aUsage);
            case 'name':
              return a.name.compareTo(b.name);
            default:
              return a.name.compareTo(b.name);
          }
        });
        
        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              color: theme.colorScheme.surface,
              child: Column(
                children: [
                  SearchBarWidget(
                    hintText: 'البحث في التطبيقات...',
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TimeRangeSelector(
                          selectedRange: dataProvider.selectedTimeRange,
                          onRangeChanged: (range) {
                            dataProvider.setTimeRange(range);
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      PopupMenuButton<String>(
                        icon: Icon(
                          Icons.sort,
                          color: theme.colorScheme.primary,
                        ),
                        onSelected: (value) {
                          setState(() {
                            _sortBy = value;
                          });
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'usage',
                            child: Row(
                              children: [
                                Icon(Icons.trending_down),
                                SizedBox(width: 12),
                                Text('حسب الاستهلاك'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'name',
                            child: Row(
                              children: [
                                Icon(Icons.sort_by_alpha),
                                SizedBox(width: 12),
                                Text('حسب الاسم'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'إجمالي ${apps.length} تطبيق • ${_formatDataSize(dataProvider.getTotalDataUsage())}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: apps.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.apps,
                            size: 64,
                            color: theme.colorScheme.outline,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'لا توجد تطبيقات',
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: theme.colorScheme.outline,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: apps.length,
                      itemBuilder: (context, index) {
                        final app = apps[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: AppCard(
                            app: app,
                            timeRange: dataProvider.selectedTimeRange,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AppDetailsScreen(
                                    app: app,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  double _getTotalUsage(AppModel app, String timeRange) {
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

  String _formatDataSize(double sizeInMB) {
    if (sizeInMB < 1024) {
      return '${sizeInMB.toStringAsFixed(1)} MB';
    } else {
      return '${(sizeInMB / 1024).toStringAsFixed(1)} GB';
    }
  }
}