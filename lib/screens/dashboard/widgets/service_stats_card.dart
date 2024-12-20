import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class ServiceStatsCard extends StatelessWidget {
  final String service;
  final double price;
  final int targetClients;
  final int currentClients;

  const ServiceStatsCard({
    super.key,
    required this.service,
    required this.price,
    required this.targetClients,
    required this.currentClients,
  });

  double get progressPercentage => currentClients / targetClients;
  double get targetRevenue => price * targetClients;
  double get currentRevenue => price * currentClients;
  double get variance => currentRevenue - targetRevenue;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(right: 16),
      child: Container(
        width: 300,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              service,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CircularPercentIndicator(
                  radius: 30,
                  lineWidth: 8,
                  percent: progressPercentage,
                  center: Text('${(progressPercentage * 100).toInt()}%'),
                  progressColor: Theme.of(context).colorScheme.primary,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Target: \$${targetRevenue.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    Text(
                      'Current: \$${currentRevenue.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    Text(
                      'Variance: \$${variance.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: variance >= 0 ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progressPercentage,
              backgroundColor: Colors.grey[200],
            ),
            const SizedBox(height: 8),
            Text(
              '$currentClients/$targetClients clients',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
} 