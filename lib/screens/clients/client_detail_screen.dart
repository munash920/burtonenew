import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/client.dart';
import '../../providers/client_provider.dart';
import '../../providers/transaction_provider.dart';

class ClientDetailScreen extends StatefulWidget {
  final Client client;

  const ClientDetailScreen({
    Key? key,
    required this.client,
  }) : super(key: key);

  @override
  _ClientDetailScreenState createState() => _ClientDetailScreenState();
}

class _ClientDetailScreenState extends State<ClientDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _companyNameController;
  late TextEditingController _registrationNumberController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _notesController;
  late TextEditingController _expectedRevenueController;
  late TextEditingController _actualRevenueController;
  late List<Director> _directors;
  DateTime? _taxDueDate;
  bool _isEditing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _companyNameController = TextEditingController(text: widget.client.companyName);
    _registrationNumberController = TextEditingController(text: widget.client.registrationNumber);
    _emailController = TextEditingController(text: widget.client.email);
    _phoneController = TextEditingController(text: widget.client.phone);
    _notesController = TextEditingController(text: widget.client.notes);
    _expectedRevenueController = TextEditingController(text: widget.client.expectedRevenue.toString());
    _actualRevenueController = TextEditingController(text: widget.client.actualRevenue.toString());
    _directors = List.from(widget.client.directors);
    _taxDueDate = widget.client.taxDueDate;
  }

  @override
  void dispose() {
    _companyNameController.dispose();
    _registrationNumberController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    _expectedRevenueController.dispose();
    _actualRevenueController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final updatedClient = Client(
        id: widget.client.id,
        userId: userId,
        name: widget.client.name,
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        companyName: _companyNameController.text.trim(),
        registrationNumber: _registrationNumberController.text.trim(),
        directors: _directors,
        services: widget.client.services,
        platforms: widget.client.platforms,
        createdAt: widget.client.createdAt,
        lastContact: widget.client.lastContact,
        notes: _notesController.text.trim(),
        expectedRevenue: double.tryParse(_expectedRevenueController.text) ?? 0.0,
        actualRevenue: double.tryParse(_actualRevenueController.text) ?? 0.0,
        taxDueDate: _taxDueDate,
      );

      await context.read<ClientProvider>().updateClient(
        widget.client.id,
        updatedClient.toMap(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Client updated successfully')),
        );
        setState(() {
          _isEditing = false;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating client: $e')),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.client.name),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            onPressed: _isLoading
                ? null
                : () {
                    if (_isEditing) {
                      _handleSubmit();
                    } else {
                      setState(() => _isEditing = true);
                    }
                  },
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoSection(),
            const SizedBox(height: 16),
            _buildDirectorsSection(),
            const SizedBox(height: 16),
            _buildFinancialsSection(),
            const SizedBox(height: 16),
            _buildNotesSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _companyNameController,
              enabled: _isEditing,
              decoration: const InputDecoration(
                labelText: 'Company Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _registrationNumberController,
              enabled: _isEditing,
              decoration: const InputDecoration(
                labelText: 'Registration Number',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _emailController,
                    enabled: _isEditing,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _phoneController,
                    enabled: _isEditing,
                    decoration: const InputDecoration(
                      labelText: 'Phone',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Tax Due Date: ${_taxDueDate != null ? DateFormat('MMM dd, yyyy').format(_taxDueDate!) : 'Not set'}',
                  ),
                ),
                if (_isEditing)
                  TextButton(
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _taxDueDate ?? DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null) {
                        setState(() => _taxDueDate = date);
                      }
                    },
                    child: const Text('Change Date'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDirectorsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Directors',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _directors.length,
              itemBuilder: (context, index) {
                final director = _directors[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            TextFormField(
                              enabled: _isEditing,
                              initialValue: director.name,
                              decoration: const InputDecoration(
                                labelText: 'Name',
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  _directors[index] = Director(
                                    name: value,
                                    email: director.email,
                                    phone: director.phone,
                                  );
                                });
                              },
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              enabled: _isEditing,
                              initialValue: director.email,
                              decoration: const InputDecoration(
                                labelText: 'Email',
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  _directors[index] = Director(
                                    name: director.name,
                                    email: value,
                                    phone: director.phone,
                                  );
                                });
                              },
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              enabled: _isEditing,
                              initialValue: director.phone,
                              decoration: const InputDecoration(
                                labelText: 'Phone',
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  _directors[index] = Director(
                                    name: director.name,
                                    email: director.email,
                                    phone: value,
                                  );
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      if (_isEditing)
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            setState(() {
                              _directors.removeAt(index);
                            });
                          },
                        ),
                    ],
                  ),
                );
              },
            ),
            if (_isEditing)
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _directors.add(Director(
                      name: '',
                      email: '',
                      phone: '',
                    ));
                  });
                },
                icon: const Icon(Icons.add),
                label: const Text('Add Director'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Financial Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _expectedRevenueController,
              enabled: _isEditing,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Expected Revenue',
                border: OutlineInputBorder(),
                prefixText: '\$',
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _actualRevenueController,
              enabled: _isEditing,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Actual Revenue',
                border: OutlineInputBorder(),
                prefixText: '\$',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Notes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              enabled: _isEditing,
              maxLines: 3,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 