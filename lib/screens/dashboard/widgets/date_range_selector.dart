import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateRangeSelector extends StatelessWidget {
  final DateTime? startDate;
  final DateTime? endDate;
  final Function(DateTime?, DateTime?) onDateRangeSelected;

  const DateRangeSelector({
    Key? key,
    this.startDate,
    this.endDate,
    required this.onDateRangeSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Date Range',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildPresetButton(
                    context,
                    'Today',
                    () => _selectPreset(context, 0),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildPresetButton(
                    context,
                    'Week',
                    () => _selectPreset(context, 7),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildPresetButton(
                    context,
                    'Month',
                    () => _selectPreset(context, 30),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildPresetButton(
                    context,
                    'Custom',
                    () => _showCustomDatePicker(context),
                  ),
                ),
              ],
            ),
            if (startDate != null && endDate != null) ...[
              const SizedBox(height: 8),
              Text(
                '${DateFormat('MMM d, y').format(startDate!)} - ${DateFormat('MMM d, y').format(endDate!)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPresetButton(
    BuildContext context,
    String label,
    VoidCallback onPressed,
  ) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 8),
      ),
      child: Text(label),
    );
  }

  void _selectPreset(BuildContext context, int days) {
    final end = DateTime.now();
    final start = end.subtract(Duration(days: days));
    onDateRangeSelected(start, end);
  }

  Future<void> _showCustomDatePicker(BuildContext context) async {
    final initialDateRange = DateTimeRange(
      start: startDate ?? DateTime.now().subtract(const Duration(days: 7)),
      end: endDate ?? DateTime.now(),
    );

    final pickedRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: initialDateRange,
    );

    if (pickedRange != null) {
      onDateRangeSelected(pickedRange.start, pickedRange.end);
    }
  }
} 