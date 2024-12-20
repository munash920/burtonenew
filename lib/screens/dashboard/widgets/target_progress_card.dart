import 'package:flutter/material.dart';
import '../../../models/target.dart';

class TargetProgressCard extends StatelessWidget {
  final Target target;
  final Map<String, dynamic> metrics;

  const TargetProgressCard({
    Key? key,
    required this.target,
    required this.metrics,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final revenue = metrics['revenue'] ?? 0.0;
    final registrations = metrics['registrations'] ?? 0;
    final reregistrations = metrics['reregistrations'] ?? 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildTargetRow(
              context,
              'Revenue Target',
              Icons.attach_money,
              '\$${target.revenueTarget.toStringAsFixed(2)}',
              '\$${revenue.toStringAsFixed(2)}',
              revenue / target.revenueTarget,
              Colors.green,
            ),
            const SizedBox(height: 16),
            _buildTargetRow(
              context,
              'Registrations',
              Icons.business,
              target.registrationTarget.toString(),
              registrations.toString(),
              registrations / target.registrationTarget,
              Colors.blue,
            ),
            const SizedBox(height: 16),
            _buildTargetRow(
              context,
              'Re-registrations',
              Icons.refresh,
              target.reregistrationTarget.toString(),
              reregistrations.toString(),
              reregistrations / target.reregistrationTarget,
              Colors.orange,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTargetRow(
    BuildContext context,
    String title,
    IconData icon,
    String target,
    String actual,
    double progress,
    Color color,
  ) {
    // Ensure progress is between 0 and 1
    final clampedProgress = progress.clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: LinearProgressIndicator(
                value: clampedProgress,
                backgroundColor: color.withOpacity(0.1),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
            const SizedBox(width: 16),
            Text(
              actual,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              ' / $target',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '${(clampedProgress * 100).toInt()}% achieved',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: color,
              ),
        ),
      ],
    );
  }
} 