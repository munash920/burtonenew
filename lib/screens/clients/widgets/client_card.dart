import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/client.dart';

class ClientCard extends StatelessWidget {
  final Client client;
  final VoidCallback onTap;
  final Function(ClientActivityStatus)? onStatusChanged;

  const ClientCard({
    Key? key,
    required this.client,
    required this.onTap,
    this.onStatusChanged,
  }) : super(key: key);

  Color _getStatusColor(ClientActivityStatus status) {
    switch (status) {
      case ClientActivityStatus.active:
        return Colors.green;
      case ClientActivityStatus.semiActive:
        return Colors.orange;
      case ClientActivityStatus.inactive:
        return Colors.red;
    }
  }

  String _getStatusText(ClientActivityStatus status) {
    switch (status) {
      case ClientActivityStatus.active:
        return 'Active';
      case ClientActivityStatus.semiActive:
        return 'Semi-Active';
      case ClientActivityStatus.inactive:
        return 'Inactive';
    }
  }

  void _showStatusChangeDialog(BuildContext context) {
    final List<ClientActivityStatus> statuses = [
      ClientActivityStatus.active,
      ClientActivityStatus.semiActive,
      ClientActivityStatus.inactive,
    ];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Update Client Status'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: statuses.map((status) {
              return ListTile(
                leading: Icon(
                  Icons.circle,
                  color: _getStatusColor(status),
                  size: 16,
                ),
                title: Text(_getStatusText(status)),
                selected: client.activityStatus == status,
                onTap: () => _updateStatus(context, status),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Future<void> _updateStatus(BuildContext context, ClientActivityStatus status) async {
    try {
      await FirebaseFirestore.instance
          .collection('clients')
          .doc(client.id)
          .update({'activityStatus': status.toString().split('.').last});
      
      if (onStatusChanged != null) {
        onStatusChanged!(status);
      }
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Client status updated to ${_getStatusText(status)}'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating status: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: constraints.maxWidth),
              child: ListTile(
                onTap: onTap,
                title: Text(
                  client.companyName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(client.name),
                trailing: GestureDetector(
                  onTap: () => _showStatusChangeDialog(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getStatusColor(client.activityStatus).withOpacity(0.1),
                      border: Border.all(
                        color: _getStatusColor(client.activityStatus),
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.circle,
                          size: 8,
                          color: _getStatusColor(client.activityStatus),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _getStatusText(client.activityStatus),
                          style: TextStyle(
                            color: _getStatusColor(client.activityStatus),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
} 