import 'package:flutter/material.dart';
import '../../../models/client.dart';

class UpcomingReturnsCard extends StatelessWidget {
  final Future<List<Client>> clients;

  const UpcomingReturnsCard({
    Key? key,
    required this.clients,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Upcoming Returns',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            FutureBuilder<List<Client>>(
              future: clients,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error: ${snapshot.error}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }

                final clientList = snapshot.data ?? [];

                if (clientList.isEmpty) {
                  return const Center(
                    child: Text('No upcoming returns'),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: clientList.length,
                  itemBuilder: (context, index) {
                    final client = clientList[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: client.photoUrl.isNotEmpty
                            ? NetworkImage(client.photoUrl)
                            : null,
                        child: client.photoUrl.isEmpty
                            ? Text(client.name[0].toUpperCase())
                            : null,
                      ),
                      title: Text(client.name),
                      subtitle: Text(client.email),
                      trailing: IconButton(
                        icon: const Icon(Icons.arrow_forward),
                        onPressed: () {
                          // Navigate to client details
                          Navigator.pushNamed(
                            context,
                            '/client-details',
                            arguments: client,
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
} 