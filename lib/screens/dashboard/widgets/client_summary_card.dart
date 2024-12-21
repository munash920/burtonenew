import 'package:flutter/material.dart';
import '../../../models/client.dart';
import '../../../widgets/notion_card.dart';

class ClientSummaryCard extends StatelessWidget {
  final List<Client> clients;

  const ClientSummaryCard({
    super.key,
    required this.clients,
  });

  @override
  Widget build(BuildContext context) {
    final activeClients = clients.where((c) => c.activityStatus == ClientActivityStatus.active).length;
    final inactiveClients = clients.where((c) => c.activityStatus == ClientActivityStatus.inactive).length;
    final semiActiveClients = clients.where((c) => c.activityStatus == ClientActivityStatus.semiActive).length;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;

    return NotionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Client Summary',
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
            'Total Clients',
            clients.length.toString(),
            Icons.people,
            Colors.blue.withOpacity(0.8),
            context,
          ),
          const SizedBox(height: 16),
          _buildMetricRow(
            'Active Clients',
            activeClients.toString(),
            Icons.person_outline,
            Colors.green.withOpacity(0.8),
            context,
          ),
          const SizedBox(height: 16),
          _buildMetricRow(
            'Semi-Active Clients',
            semiActiveClients.toString(),
            Icons.person_outline,
            Colors.orange.withOpacity(0.8),
            context,
          ),
          const SizedBox(height: 16),
          _buildMetricRow(
            'Inactive Clients',
            inactiveClients.toString(),
            Icons.person_outline,
            Colors.red.withOpacity(0.8),
            context,
          ),
        ],
      ),
    );
  }

  Widget _buildMetricRow(String label, String value, IconData icon, Color color, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white70 : Colors.black54;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: textColor,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}