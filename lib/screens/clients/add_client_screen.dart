import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/client.dart';
import '../../providers/client_provider.dart';
import 'widgets/platform_credential_form.dart';
import 'widgets/director_dialog.dart';
import 'widgets/service_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/draft_service.dart';

class AddClientScreen extends StatefulWidget {
  const AddClientScreen({Key? key}) : super(key: key);

  @override
  _AddClientScreenState createState() => _AddClientScreenState();
}

class _AddClientScreenState extends State<AddClientScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _registrationNumberController = TextEditingController();
  bool _isLoading = false;
  bool _isDraft = false;
  Map<String, dynamic> _platforms = {
    'TARMS': {'email': '', 'password': ''},
    'CIPZ': {'email': '', 'password': ''},
  };
  List<Director> _directors = [];
  List<Service> _services = [];

  @override
  void initState() {
    super.initState();
    _loadDraft();
  }

  Future<void> _loadDraft() async {
    final draft = await DraftService.getClientDraft();
    if (draft != null) {
      setState(() {
        _nameController.text = draft['name'] ?? '';
        _emailController.text = draft['email'] ?? '';
        _phoneController.text = draft['phone'] ?? '';
        _companyNameController.text = draft['companyName'] ?? '';
        _registrationNumberController.text = draft['registrationNumber'] ?? '';
        _platforms = Map<String, dynamic>.from(draft['platforms']);
        _directors = (draft['directors'] as List)
            .map((d) => Director.fromMap(Map<String, dynamic>.from(d)))
            .toList();
        _services = (draft['services'] as List)
            .map((s) => Service.fromMap(Map<String, dynamic>.from(s)))
            .toList();
        _isDraft = true;
      });

      // Show draft found dialog
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Draft Found'),
            content: const Text('Would you like to continue with your saved draft?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  DraftService.clearClientDraft();
                  _resetForm();
                },
                child: const Text('No, Start Fresh'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Yes, Continue'),
              ),
            ],
          ),
        );
      }
    }
  }

  void _resetForm() {
    setState(() {
      _nameController.clear();
      _emailController.clear();
      _phoneController.clear();
      _companyNameController.clear();
      _registrationNumberController.clear();
      _platforms = {
        'TARMS': {'email': '', 'password': ''},
        'CIPZ': {'email': '', 'password': ''},
      };
      _directors = [];
      _services = [];
      _isDraft = false;
    });
  }

  Future<void> _saveDraft() async {
    await DraftService.saveClientDraft(
      name: _nameController.text,
      email: _emailController.text,
      phone: _phoneController.text,
      companyName: _companyNameController.text,
      registrationNumber: _registrationNumberController.text,
      directors: _directors.map((d) => d.toMap()).toList(),
      services: _services.map((s) => s.toMap()).toList(),
      platforms: _platforms,
    );
  }

  void _updatePlatformCredentials(Map<String, dynamic> platforms) {
    setState(() {
      _platforms = platforms;
    });
  }

  void _addDirector() {
    showDialog(
      context: context,
      builder: (context) => DirectorDialog(
        onSave: (director) {
          setState(() {
            _directors.add(director);
          });
        },
      ),
    );
  }

  void _addService() {
    showDialog(
      context: context,
      builder: (context) => ServiceDialog(
        onSave: (service) {
          setState(() {
            _services.add(service);
          });
        },
      ),
    );
  }

  Future<void> _saveClient() async {
    if (!_formKey.currentState!.validate()) return;

    if (_directors.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one director')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final client = Client(
        id: '', // Will be set by Firebase
        userId: userId,
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        companyName: _companyNameController.text.trim(),
        registrationNumber: _registrationNumberController.text.trim(),
        directors: _directors,
        services: _services,
        platforms: _platforms,
        createdAt: DateTime.now(),
      );

      await context.read<ClientProvider>().createClient(client);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Client added successfully')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding client: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    if (_formKey.currentState?.validate() == false) {
      _saveDraft();
    }
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _companyNameController.dispose();
    _registrationNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_formKey.currentState?.validate() == false) {
          await _saveDraft();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Draft saved')),
          );
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Add Client'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Client Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter client name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Phone',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter phone number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _companyNameController,
                  decoration: const InputDecoration(
                    labelText: 'Company Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter company name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _registrationNumberController,
                  decoration: const InputDecoration(
                    labelText: 'Registration Number',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter registration number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Directors',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _addDirector,
                      icon: const Icon(Icons.add),
                      label: const Text('Add Director'),
                    ),
                  ],
                ),
                if (_directors.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _directors.length,
                    itemBuilder: (context, index) {
                      final director = _directors[index];
                      return Card(
                        child: ListTile(
                          title: Text(director.name),
                          subtitle: Text(director.email),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              setState(() {
                                _directors.removeAt(index);
                              });
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ],
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Services',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _addService,
                      icon: const Icon(Icons.add),
                      label: const Text('Add Service'),
                    ),
                  ],
                ),
                if (_services.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _services.length,
                    itemBuilder: (context, index) {
                      final service = _services[index];
                      return Card(
                        child: ListTile(
                          title: Text(service.name),
                          subtitle: Text(service.description),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              setState(() {
                                _services.removeAt(index);
                              });
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ],
                const SizedBox(height: 24),
                const Text(
                  'Platform Credentials',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                PlatformCredentialForm(
                  platforms: _platforms,
                  onPlatformsChanged: _updatePlatformCredentials,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading ? null : _saveClient,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Save Client'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 