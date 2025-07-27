import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:enms/providers/data_provider.dart';
import 'package:enms/widgets/network_card.dart';
import 'package:enms/widgets/search_bar_widget.dart';
import 'package:enms/widgets/time_range_selector.dart';
import 'package:enms/screens/network_details_screen.dart';

class NetworksTab extends StatefulWidget {
  const NetworksTab({super.key});

  @override
  State<NetworksTab> createState() => _NetworksTabState();
}

class _NetworksTabState extends State<NetworksTab> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Consumer<DataProvider>(
      builder: (context, dataProvider, child) {
        final networks = dataProvider.getFilteredNetworks(_searchQuery);
        
        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              color: theme.colorScheme.surface,
              child: Column(
                children: [
                  SearchBarWidget(
                    hintText: 'البحث في الشبكات...',
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  TimeRangeSelector(
                    selectedRange: dataProvider.selectedTimeRange,
                    onRangeChanged: (range) {
                      dataProvider.setTimeRange(range);
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: networks.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.wifi_off,
                            size: 64,
                            color: theme.colorScheme.outline,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'لا توجد شبكات',
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: theme.colorScheme.outline,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'تأكد من الاتصال بشبكة Wi-Fi',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.outline,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: networks.length,
                      itemBuilder: (context, index) {
                        final network = networks[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: NetworkCard(
                            network: network,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => NetworkDetailsScreen(
                                    network: network,
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
}