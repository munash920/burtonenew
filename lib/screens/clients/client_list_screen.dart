import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:burtone/providers/client_provider.dart';
import 'package:burtone/models/client.dart';
import 'package:burtone/theme/app_theme.dart';
import 'package:burtone/screens/clients/add_client_screen.dart';
import 'package:burtone/screens/clients/email_sender_page.dart';
import 'package:burtone/screens/clients/edit_client_screen.dart';
import 'package:burtone/screens/clients/widgets/client_card.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;

class ClientListScreen extends StatelessWidget {
  const ClientListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Clients',
          style: TextStyle(color: Theme.of(context).textTheme.titleLarge?.color),
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.email_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => EmailSenderPage()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.person_add_outlined),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddClientScreen()),
              );
              Provider.of<ClientProvider>(context, listen: false).loadClients();
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'import') {
                _importClients(context);
              } else if (value == 'export') {
                _exportClients(context);
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'import',
                child: Text('Import Clients'),
              ),
              const PopupMenuItem<String>(
                value: 'export',
                child: Text('Export Clients'),
              ),
            ],
          ),
        ],
      ),
      body: Consumer<ClientProvider>(
        builder: (context, clientProvider, child) {
          if (clientProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final clients = clientProvider.clients;

          if (clients.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 64,
                    color: Theme.of(context).iconTheme.color,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No clients yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AddClientScreen()),
                    ),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Client'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.brandTeal,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: clients.length,
            itemBuilder: (context, index) {
              final client = clients[index];
              return _buildExpandableClientCard(context, client, clientProvider);
            },
          );
        },
      ),
    );
  }

  Widget _buildExpandableClientCard(
    BuildContext context,
    Client client,
    ClientProvider clientProvider,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ExpansionTile(
        backgroundColor: Theme.of(context).cardColor,
        collapsedBackgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: Theme.of(context).dividerColor),
        ),
        title: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    client.companyName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    client.name,
                    style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
                  ),
                ],
              ),
            ),
            _buildClientStatus(context, client),
          ],
        ),
        subtitle: Text(
          client.email,
          style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
        ),
        trailing: Icon(Icons.expand_more),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                _buildInfoSection('Company Details', [
                  _buildInfoRow(context, 'Company Name', client.companyName),
                  _buildInfoRow(context, 'Registration Number', client.registrationNumber),
                  _buildInfoRow(context, 'Phone', client.phone),
                ]),
                const Divider(height: 32),
                _buildInfoSection('Directors', 
                  client.directors.map((director) => 
                    _buildInfoRow(context, director.name, director.email)
                  ).toList()
                ),
                const Divider(height: 32),
                _buildInfoSection('Services',
                  client.services.map((service) =>
                    _buildInfoRow(context, service.name, service.description)
                  ).toList()
                ),
                const Divider(height: 32),
                _buildInfoSection('Platform Credentials', [
                  if (client.platforms['TARMS'] != null)
                    _buildInfoRow(context, 'TARMS', client.platforms['TARMS']['email']),
                  if (client.platforms['CIPZ'] != null)
                    _buildInfoRow(context, 'CIPZ', client.platforms['CIPZ']['email']),
                ]),
                const SizedBox(height: 16),
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditClientScreen(client: client),
                        ),
                      );
                      clientProvider.loadClients();
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit Client'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.brandTeal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _changeClientStatus(BuildContext context, Client client, ClientActivityStatus newStatus) {
    // Update the client's status
    Provider.of<ClientProvider>(context, listen: false).updateClientStatus(client, newStatus);

    // Show a snackbar with the change
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Status changed to ${newStatus.name}'),
        backgroundColor: AppTheme.brandTeal,
      ),
    );

    print('Client ${client.name} status changed to ${newStatus.name}');
  }

  Widget _buildClientStatus(BuildContext context, Client client) {
    Color statusColor;
    switch (client.activityStatus) {
      case ClientActivityStatus.active:
        statusColor = Colors.green;
        break;
      case ClientActivityStatus.inactive:
        statusColor = Colors.red;
        break;
      case ClientActivityStatus.semiActive:
        statusColor = Colors.orange;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Row(
      children: [
        Text(
          client.activityStatus.name,
          style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () async {
            final newStatus = await showMenu<ClientActivityStatus>(
              context: context,
              position: RelativeRect.fromLTRB(100, 100, 100, 100), // Adjust position as needed
              items: const [
                PopupMenuItem(value: ClientActivityStatus.active, child: Text('Active')),
                PopupMenuItem(value: ClientActivityStatus.inactive, child: Text('Inactive')),
                PopupMenuItem(value: ClientActivityStatus.semiActive, child: Text('Semi-Active')),
              ],
            );
            if (newStatus != null) {
              _changeClientStatus(context, client, newStatus);
            }
          },
          child: Icon(
            client.lastContact != null && client.lastContact!.isAfter(DateTime.now().subtract(const Duration(days: 30)))
                ? Icons.check_circle
                : Icons.radio_button_unchecked,
            color: client.lastContact != null && client.lastContact!.isAfter(DateTime.now().subtract(const Duration(days: 30)))
                ? Colors.green
                : Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyLarge?.color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteDialog(
    BuildContext context,
    Client client,
    ClientProvider clientProvider,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Client'),
        content: Text('Are you sure you want to delete ${client.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Delete',
              style: TextStyle(color: Colors.red[400]),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        await clientProvider.deleteClient(client.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Client deleted successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting client: $e')),
        );
      }
    }
  }

  Future<void> _importClients(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['csv', 'xlsx']);
    if (result != null) {
      final file = File(result.files.single.path!);
      final extension = result.files.single.extension;

      List<Client> importedClients = [];

      if (extension == 'csv') {
        final input = file.openRead();
        final fields = await input.transform(utf8.decoder).transform(CsvToListConverter()).toList();
        for (var row in fields.skip(1)) { // Skip header row
          importedClients.add(Client(
            id: row[0].toString(),
            userId: row[1].toString(),
            name: row[2].toString(),
            email: row[3].toString(),
            phone: row[4].toString(),
            companyName: row[5].toString(),
            registrationNumber: row[6].toString(),
            directors: [], // Parse as needed
            services: [], // Parse as needed
            platforms: {}, // Parse as needed
            createdAt: DateTime.now(),
            lastContact: null,
            notes: '',
            expectedRevenue: 0.0,
            actualRevenue: 0.0,
            taxDueDate: null,
            activityStatus: ClientActivityStatus.active,
          ));
        }
      } else if (extension == 'xlsx') {
        var bytes = file.readAsBytesSync();
        var excel = Excel.decodeBytes(bytes);
        for (var table in excel.tables.keys) {
          for (var row in excel.tables[table]!.rows.skip(1)) { // Skip header row
            importedClients.add(Client(
              id: row[0]?.value.toString() ?? '',
              userId: row[1]?.value.toString() ?? '',
              name: row[2]?.value.toString() ?? '',
              email: row[3]?.value.toString() ?? '',
              phone: row[4]?.value.toString() ?? '',
              companyName: row[5]?.value.toString() ?? '',
              registrationNumber: row[6]?.value.toString() ?? '',
              directors: [], // Parse as needed
              services: [], // Parse as needed
              platforms: {}, // Parse as needed
              createdAt: DateTime.now(),
              lastContact: null,
              notes: '',
              expectedRevenue: 0.0,
              actualRevenue: 0.0,
              taxDueDate: null,
              activityStatus: ClientActivityStatus.active,
            ));
          }
        }
      }

      // Update provider with imported clients
      Provider.of<ClientProvider>(context, listen: false).addClients(importedClients);
    }
  }

  Future<void> _exportClients(BuildContext context) async {
    final clients = Provider.of<ClientProvider>(context, listen: false).clients;
    List<List<dynamic>> rows = [];
    rows.add(["ID", "UserID", "Name", "Email", "Phone", "CompanyName", "RegistrationNumber"]);

    for (var client in clients) {
      List<dynamic> row = [];
      row.add(client.id);
      row.add(client.userId);
      row.add(client.name);
      row.add(client.email);
      row.add(client.phone);
      row.add(client.companyName);
      row.add(client.registrationNumber);
      rows.add(row);
    }

    String csv = const ListToCsvConverter().convert(rows);
    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Export not supported on web.')));
      return;
    }

    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/clients_export.csv';
    final file = File(path);
    await file.writeAsString(csv);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Clients exported to $path')));
  }
}