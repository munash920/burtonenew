import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Transaction Summary',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildMetricRow(
              'Total Revenue',
              currencyFormat.format(metrics['revenue'] ?? 0),
              Colors.green,
            ),
            const Divider(),
            _buildMetricRow(
              'Total Expenses',
              currencyFormat.format(metrics['expenses'] ?? 0),
              Colors.red,
            ),
            const Divider(),
            _buildMetricRow(
              'Net Profit',
              currencyFormat.format(netProfit),
              netProfit >= 0 ? Colors.green : Colors.red,
            ),
            const Divider(),
            const Text(
              'Service Counts',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            _buildMetricRow(
              'Registrations',
              '${metrics['registrations'] ?? 0}',
              Colors.blue,
            ),
            _buildMetricRow(
              'Re-registrations',
              '${metrics['reregistrations'] ?? 0}',
              Colors.purple,
            ),
            _buildMetricRow(
              'Tax Clearance',
              '${metrics['tax_clearance'] ?? 0}',
              Colors.orange,
            ),
            _buildMetricRow(
              'Tax Returns',
              '${metrics['tax_returns'] ?? 0}',
              Colors.teal,
            ),
            _buildMetricRow(
              'Annual Returns',
              '${metrics['annual_returns'] ?? 0}',
              Colors.indigo,
            ),
            _buildMetricRow(
              'Bookkeeping',
              '${metrics['bookkeeping'] ?? 0}',
              Colors.brown,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricRow(String label, String value, Color valueColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
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