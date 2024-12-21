import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../widgets/notion_card.dart';

class TransactionSummaryCard extends StatelessWidget {
  final Map<String, dynamic> metrics;
  
  const TransactionSummaryCard({
    super.key,
    required this.metrics,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '\$');
    final netProfit = (metrics['netProfit'] as num?) ?? 0;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final subtextColor = isDark ? Colors.white70 : Colors.black54;
    
    return NotionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Transaction Summary',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: textColor,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 16),
          Divider(color: isDark ? Colors.white24 : Colors.black12),
          const SizedBox(height: 16),
          _buildMetricRow(
            'Total Revenue',
            currencyFormat.format(metrics['revenue'] ?? 0),
            Colors.green.withOpacity(0.8),
            subtextColor,
          ),
          const SizedBox(height: 16),
          _buildMetricRow(
            'Total Expenses',
            currencyFormat.format(metrics['expenses'] ?? 0),
            Colors.red.withOpacity(0.8),
            subtextColor,
          ),
          const SizedBox(height: 16),
          _buildMetricRow(
            'Net Profit',
            currencyFormat.format(netProfit),
            netProfit >= 0 ? Colors.green.withOpacity(0.8) : Colors.red.withOpacity(0.8),
            subtextColor,
          ),
          const SizedBox(height: 24),
          Text(
            'Service Counts',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: textColor,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 16),
          _buildMetricRow(
            'Registrations',
            '${metrics['registrations'] ?? 0}',
            Colors.blue.withOpacity(0.8),
            subtextColor,
          ),
          _buildMetricRow(
            'Re-registrations',
            '${metrics['reregistrations'] ?? 0}',
            Colors.purple.withOpacity(0.8),
            subtextColor,
          ),
          _buildMetricRow(
            'Tax Clearance',
            '${metrics['tax_clearance'] ?? 0}',
            Colors.orange.withOpacity(0.8),
            subtextColor,
          ),
          _buildMetricRow(
            'Tax Returns',
            '${metrics['tax_returns'] ?? 0}',
            Colors.teal.withOpacity(0.8),
            subtextColor,
          ),
          _buildMetricRow(
            'Annual Returns',
            '${metrics['annual_returns'] ?? 0}',
            Colors.indigo.withOpacity(0.8),
            subtextColor,
          ),
          _buildMetricRow(
            'Bookkeeping',
            '${metrics['bookkeeping'] ?? 0}',
            Colors.brown.withOpacity(0.8),
            subtextColor,
          ),
        ],
      ),
    );
  }

  Widget _buildMetricRow(String label, String value, Color valueColor, Color textColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}