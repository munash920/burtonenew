import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/transaction.dart';
import '../../models/client.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/client_provider.dart';
import '../../services/draft_service.dart';

class AddTransactionScreen extends StatefulWidget {
  final Client? client;
  final BusinessTransaction? transaction;

  const AddTransactionScreen({
    Key? key,
    this.client,
    this.transaction,
  }) : super(key: key);

  @override
  _AddTransactionScreenState createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  late TransactionType _type = TransactionType.sale;
  late ServiceType _serviceType = ServiceType.registration;
  late DateTime _date = DateTime.now();
  PaymentMethod? _paymentMethod;
  bool _isLoading = false;
  String? _selectedClientId;
  String? _selectedClientName;
  bool _isDraft = false;
  String? _expenseType;

  @override
  void initState() {
    super.initState();
    if (widget.transaction != null) {
      _initializeWithTransaction(widget.transaction!);
    } else if (widget.client != null) {
      _selectedClientId = widget.client!.id;
      _selectedClientName = widget.client!.companyName;
    }
    _loadDraft();
  }

  void _initializeWithTransaction(BusinessTransaction transaction) {
    _selectedClientId = transaction.clientId;
    _descriptionController.text = transaction.description;
    _amountController.text = transaction.amount.toString();
    _type = transaction.type;
    _serviceType = transaction.serviceType;
    _date = transaction.date;
    _paymentMethod = transaction.paymentMethod;
  }

  Future<void> _loadDraft() async {
    final draft = await DraftService.getTransactionDraft();
    if (draft != null) {
      setState(() {
        _selectedClientId = draft['selectedClientId'];
        _selectedClientName = draft['selectedClientName'];
        _descriptionController.text = draft['description'] ?? '';
        _amountController.text = draft['amount'] ?? '';
        _type = TransactionType.values.firstWhere(
          (e) => e.toString() == 'TransactionType.${draft['type']}',
          orElse: () => TransactionType.sale,
        );
        _serviceType = ServiceType.values.firstWhere(
          (e) => e.toString() == 'ServiceType.${draft['serviceType']}',
          orElse: () => ServiceType.registration,
        );
        if (draft['paymentMethod'] != null) {
          _paymentMethod = PaymentMethod.values.firstWhere(
            (e) => e.toString() == 'PaymentMethod.${draft['paymentMethod']}',
            orElse: () => PaymentMethod.cash,
          );
        } else {
          _paymentMethod = null;
        }
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
                  DraftService.clearTransactionDraft();
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
      _selectedClientId = null;
      _selectedClientName = null;
      _descriptionController.clear();
      _amountController.clear();
      _type = TransactionType.sale;
      _serviceType = ServiceType.registration;
      _paymentMethod = null;
      _isDraft = false;
    });
  }

  Future<void> _saveDraft() async {
    await DraftService.saveTransactionDraft(
      selectedClientId: _selectedClientId,
      selectedClientName: _selectedClientName,
      description: _descriptionController.text,
      amount: _amountController.text,
      type: _type.toString(),
      serviceType: _serviceType.toString(),
      paymentMethod: _paymentMethod?.toString(),
    );
  }

  @override
  void dispose() {
    if (_formKey.currentState?.validate() == false) {
      _saveDraft();
    }
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  // Brand Colors
  static const Color brandTeal = Color(0xFF008B8B); // Adjust this to match your exact teal

  Widget _buildServiceTypeCard(ServiceType type) {
    final isSelected = _serviceType == type;
    return GestureDetector(
      onTap: () => setState(() => _serviceType = type),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        width: double.infinity,
        decoration: BoxDecoration(
          color: isSelected ? Colors.teal.withOpacity(0.1) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(6.0),
          border: Border.all(
            color: isSelected ? Colors.teal : Colors.grey.shade300,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                type.toString().split('.').last,
                style: TextStyle(
                  color: isSelected ? Colors.teal : Colors.black,
                  fontWeight: FontWeight.w600,
                  fontSize: 16.0,
                ),
              ),
              const SizedBox(width: 8.0),
              if (isSelected)
                const Icon(
                  Icons.check_circle,
                  color: Colors.teal,
                  size: 20.0,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpenseTypeDropdown() {
    final expenseTypes = {
      'Bank & Merchant Fees': 'Finance',
      'Business Meals': 'Meals',
      'Client Entertainment': 'Entertainment',
      'Computers or Equipment': 'Equipment',
      'Independent Contractor': 'Contractor',
      'Insurance Payments': 'Insurance',
      'Interest Paid': 'Finance',
      'Lawyers & Accountants Cons': 'Professional Services',
      'Licenses or Fees': 'Legal',
      'Marketing or Advertising': 'Marketing',
      'Miscellaneous Expenses': 'Miscellaneous',
      'Phone, Internet & Utilities': 'Utilities',
      'Staff Allowances & Benefits': 'Benefits',
      'Rent or Lease': 'Rent',
      'Vehicle Fuel/Oil': 'Transport',
      'Supplies': 'Supplies',
      'Taxes Paid': 'Taxes',
      'Travel & Transportation': 'Transport',
      'Service Fee': 'Registration',
    };

    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(labelText: 'Expense Type'),
      items: expenseTypes.keys.map((String key) {
        return DropdownMenuItem<String>(
          value: key,
          child: Text(key),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _expenseType = value;
          // You can handle categorization logic here if needed
        });
      },
    );
  }

  Future<void> _saveTransaction() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedClientId == null && _type == TransactionType.sale) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a client')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final transaction = BusinessTransaction(
        id: '', // This will be set by Firestore
        userId: userId,
        clientId: _selectedClientId ?? '',
        clientName: _selectedClientName ?? '',
        description: _descriptionController.text,
        amount: double.parse(_amountController.text),
        date: _date,
        type: _type,
        serviceType: _serviceType,
        paymentMethod: _paymentMethod,
        expenseType: _expenseType ?? '',
        category: _expenseType ?? '',
      );

      await context.read<TransactionProvider>().addTransaction(transaction);

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
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
          title: const Text('New Transaction'),
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
          elevation: 0,
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Transaction Type Toggle
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _type = TransactionType.sale),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: _type == TransactionType.sale
                                  ? brandTeal
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.arrow_upward,
                                  color: _type == TransactionType.sale
                                      ? Colors.white
                                      : Colors.grey,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Revenue',
                                  style: TextStyle(
                                    color: _type == TransactionType.sale
                                        ? Colors.white
                                        : Colors.grey,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _type = TransactionType.expense),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: _type == TransactionType.expense
                                  ? Colors.red
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.arrow_downward,
                                  color: _type == TransactionType.expense
                                      ? Colors.white
                                      : Colors.grey,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Expense',
                                  style: TextStyle(
                                    color: _type == TransactionType.expense
                                        ? Colors.white
                                        : Colors.grey,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Client Selection Dropdown
              if (_type == TransactionType.sale)
                DropdownButtonFormField<String>(
                  value: _selectedClientId,
                  decoration: InputDecoration(
                    labelText: 'Select Client',
                    hintText: 'Choose a client',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: _type == TransactionType.sale ? brandTeal : Colors.red,
                        width: 2,
                      ),
                    ),
                    floatingLabelStyle: TextStyle(
                      color: _type == TransactionType.sale ? brandTeal : Colors.red,
                    ),
                  ),
                  items: context.watch<ClientProvider>().clients.map((client) {
                    return DropdownMenuItem(
                      value: client.id,
                      child: Text(client.name),
                      onTap: () {
                        setState(() {
                          _selectedClientName = client.name;
                        });
                      },
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedClientId = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a client';
                    }
                    return null;
                  },
                ),
              if (_type == TransactionType.expense)
                _buildExpenseTypeDropdown(),
              const SizedBox(height: 24),

              // Description Field
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  hintText: 'Enter transaction description',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: _type == TransactionType.sale ? brandTeal : Colors.red,
                      width: 2,
                    ),
                  ),
                  floatingLabelStyle: TextStyle(
                    color: _type == TransactionType.sale ? brandTeal : Colors.red,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Amount Field
              TextFormField(
                controller: _amountController,
                decoration: InputDecoration(
                  labelText: 'Amount',
                  hintText: 'Enter amount',
                  prefixText: '\$',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: _type == TransactionType.sale ? brandTeal : Colors.red,
                      width: 2,
                    ),
                  ),
                  floatingLabelStyle: TextStyle(
                    color: _type == TransactionType.sale ? brandTeal : Colors.red,
                  ),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  if (double.parse(value) <= 0) {
                    return 'Amount must be greater than 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Payment Method Dropdown
              DropdownButtonFormField<PaymentMethod>(
                value: _paymentMethod,
                decoration: InputDecoration(
                  labelText: 'Payment Method',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: _type == TransactionType.sale ? brandTeal : Colors.red,
                      width: 2,
                    ),
                  ),
                  floatingLabelStyle: TextStyle(
                    color: _type == TransactionType.sale ? brandTeal : Colors.red,
                  ),
                ),
                items: PaymentMethod.values.map((method) {
                  return DropdownMenuItem(
                    value: method,
                    child: Text(
                      method.toString().split('.').last.toUpperCase(),
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                  );
                }).toList(),
                onChanged: (PaymentMethod? value) {
                  setState(() => _paymentMethod = value);
                },
              ),
              const SizedBox(height: 24),

              // Service Type Grid
              if (_type == TransactionType.sale)
                GridView.count(
                  shrinkWrap: true,
                  crossAxisCount: 2,
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                  childAspectRatio: 2.5,
                  physics: const NeverScrollableScrollPhysics(),
                  children: ServiceType.values.map((type) => _buildServiceTypeCard(type)).toList(),
                ),
            ],
          ),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            height: 56,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _saveTransaction,
              style: ElevatedButton.styleFrom(
                backgroundColor: _type == TransactionType.sale ? brandTeal : Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
                      _type == TransactionType.sale ? 'Save Revenue' : 'Save Expense',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}