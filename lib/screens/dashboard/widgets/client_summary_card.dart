import 'package:flutter/material.dart';
import '../../../models/client.dart';

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

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Client Summary',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildMetricRow(
              'Total Clients',
              clients.length.toString(),
              Icons.people,
              Colors.blue,
            ),
            const Divider(),
            _buildMetricRow(
              'Active Clients',
              activeClients.toString(),
              Icons.person_outline,
              Colors.green,
            ),
            const Divider(),
            _buildMetricRow(
              'Semi-Active Clients',
              semiActiveClients.toString(),
              Icons.person_outline,
              Colors.orange,
            ),
            const Divider(),
            _buildMetricRow(
              'Inactive Clients',
              inactiveClients.toString(),
              Icons.person_off_outlined,
              Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricRow(String label, String value, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}