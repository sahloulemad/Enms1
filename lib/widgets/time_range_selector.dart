import 'package:flutter/material.dart';

class TimeRangeSelector extends StatelessWidget {
  final String selectedRange;
  final ValueChanged<String> onRangeChanged;

  const TimeRangeSelector({
    super.key,
    required this.selectedRange,
    required this.onRangeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildRangeChip(
            context,
            'daily',
            'يومي',
            Icons.today,
            theme,
          ),
          const SizedBox(width: 8),
          _buildRangeChip(
            context,
            'weekly',
            'أسبوعي',
            Icons.date_range,
            theme,
          ),
          const SizedBox(width: 8),
          _buildRangeChip(
            context,
            'monthly',
            'شهري',
            Icons.calendar_month,
            theme,
          ),
          const SizedBox(width: 8),
          _buildRangeChip(
            context,
            'custom',
            'مخصص',
            Icons.tune,
            theme,
          ),
        ],
      ),
    );
  }

  Widget _buildRangeChip(
    BuildContext context,
    String value,
    String label,
    IconData icon,
    ThemeData theme,
  ) {
    final isSelected = selectedRange == value;
    
    return GestureDetector(
      onTap: () {
        if (value == 'custom') {
          _showCustomDatePicker(context);
        } else {
          onRangeChanged(value);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected 
              ? theme.colorScheme.primary 
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected 
                ? theme.colorScheme.primary 
                : theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
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
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCustomDatePicker(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(
        start: DateTime.now().subtract(const Duration(days: 7)),
        end: DateTime.now(),
      ),
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child!,
        );
      },
    );

    if (picked != null) {
      onRangeChanged('custom');
      // Here you would typically call a callback to update the custom date range
      // For now, we'll just trigger the range change
    }
  }
}