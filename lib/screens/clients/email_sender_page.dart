import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/client_provider.dart';
import '../../providers/email_template_provider.dart';
import '../../models/client.dart';
import '../../models/email_template.dart';
import '../../widgets/template_dialog.dart';
import '../../widgets/email_editor.dart';
import '../../services/email_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/app_theme.dart';

class EmailSenderPage extends StatefulWidget {
  @override
  _EmailSenderPageState createState() => _EmailSenderPageState();
}

class _EmailSenderPageState extends State<EmailSenderPage> {
  List<Client> _selectedClients = [];
  final TextEditingController _emailContentController = TextEditingController();
  final _emailService = EmailService();
  bool _isSending = false;
  bool _selectAll = false;
  String _serviceFilter = '';

  void _toggleClientSelection(Client client) {
    setState(() {
      if (_selectedClients.contains(client)) {
        _selectedClients.remove(client);
      } else {
        _selectedClients.add(client);
      }
    });
  }

  void _toggleSelectAll(bool? value) {
    setState(() {
      _selectAll = value ?? false;
      if (_selectAll) {
        _selectedClients = List.from(context.read<ClientProvider>().clients);
      } else {
        _selectedClients.clear();
      }
    });
  }

  void _applyServiceFilter(String serviceName) {
    setState(() {
      _serviceFilter = serviceName;
    });
  }

  List<Client> _getFilteredClients() {
    final allClients = context.read<ClientProvider>().clients;
    if (_serviceFilter.isEmpty) {
      return allClients;
    }
    return allClients.where((client) =>
      client.services.any((service) => service.name.contains(_serviceFilter))).toList();
  }

  @override
  void initState() {
    super.initState();
    _loadDraft();
  }

  Future<void> _loadDraft() async {
    final prefs = await SharedPreferences.getInstance();
    final draft = prefs.getString('emailDraft') ?? '';
    _emailContentController.text = draft;
  }

  Future<void> _saveDraft() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('emailDraft', _emailContentController.text);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Draft saved!')),
    );
  }

  Widget _buildClientsList() {
    return Consumer<ClientProvider>(
      builder: (context, clientProvider, child) {
        if (clientProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final clients = _getFilteredClients();
        if (clients.isEmpty) {
          return const Center(
            child: Text('No clients available'),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: clients.length,
          itemBuilder: (context, index) {
            final client = clients[index];
            final isSelected = _selectedClients.contains(client);
            
            return Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(
                  color: isSelected ? AppTheme.brandTeal : Colors.grey.shade300,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: InkWell(
                onTap: () => _toggleClientSelection(client),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
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
                      const SizedBox(height: 4),
                      Text(
                        client.directors.isNotEmpty ? client.directors[0].name : 'No Director',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        client.services.isNotEmpty ? client.services[0].name : 'No Service',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTemplatesList() {
    return Consumer<EmailTemplateProvider>(
      builder: (context, templateProvider, child) {
        final templates = templateProvider.templates;
        if (templates.isEmpty) {
          return const Center(
            child: Text('No templates available'),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: templates.length,
          itemBuilder: (context, index) {
            final template = templates[index];
            return Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(
                  color: Colors.grey.shade300,
                  width: 1,
                ),
              ),
              child: ListTile(
                title: Text(
                  template.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  template.content,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _showTemplateDialog(context, template: template),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _deleteTemplate(context, template),
                    ),
                  ],
                ),
                onTap: () => _useTemplate(template),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _sendEmails() async {
    if (_selectedClients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one client')),
      );
      return;
    }

    if (_emailContentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter email content')),
      );
      return;
    }

    setState(() {
      _isSending = true;
    });

    try {
      final recipients = _selectedClients.map((client) => client.email).toList();
      final content = _emailContentController.text + _emailService.getSignature();
      
      await _emailService.sendEmail(
        recipients: recipients,
        subject: 'Important Update from BurtoneCoopër',
        content: content,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Emails sent successfully')),
      );
      
      // Clear the form after successful send
      setState(() {
        _selectedClients.clear();
        _emailContentController.clear();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send emails: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isSending = false;
      });
    }
  }

  Future<void> _showTemplateDialog(BuildContext context, {EmailTemplate? template}) async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => TemplateDialog(template: template),
    );

    if (result != null) {
      final provider = Provider.of<EmailTemplateProvider>(context, listen: false);
      if (template == null) {
        provider.addTemplate(result['title']!, result['content']!);
      } else {
        provider.updateTemplate(template.id, result['title']!, result['content']!);
      }
    }
  }

  void _deleteTemplate(BuildContext context, EmailTemplate template) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Template'),
        content: Text('Are you sure you want to delete "${template.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<EmailTemplateProvider>(context, listen: false)
                  .deleteTemplate(template.id);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red[400],
            ),
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _useTemplate(EmailTemplate template) {
    setState(() {
      _emailContentController.text = template.content;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Send Emails',
          style: TextStyle(color: AppTheme.brandBlack),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppTheme.brandBlack),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.save_outlined, color: AppTheme.brandTeal),
            onPressed: _saveDraft,
            tooltip: 'Save Draft',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Client Selection Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Select Clients',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.brandBlack,
                    ),
                  ),
                  Checkbox(
                    value: _selectAll,
                    onChanged: _toggleSelectAll,
                    activeColor: AppTheme.brandTeal,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'Filter by Service Name',
                  border: OutlineInputBorder(),
                ),
                onChanged: _applyServiceFilter,
              ),
            ),
            Container(
              height: 200, // Fixed height for the client list
              child: _buildClientsList(),
            ),
            Divider(height: 32, thickness: 1, color: Colors.grey[300]),

            // Templates Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Email Templates',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.brandBlack,
                ),
              ),
            ),
            Container(
              height: 200,
              child: _buildTemplatesList(),
            ),
            Divider(height: 32, thickness: 1, color: Colors.grey[300]),

            // Email Writing Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Write Email',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.brandBlack,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                controller: _emailContentController,
                maxLines: 10,
                decoration: InputDecoration(
                  hintText: 'Type your email here...',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: _sendEmails,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.brandTeal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 4,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.send, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Send Email',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}