import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/transaction.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/client_provider.dart';
import 'add_transaction_screen.dart';

class TransactionHistoryScreen extends StatefulWidget {
  final String? clientId;

  const TransactionHistoryScreen({
    super.key,
    this.clientId,
  });

  @override
  State<TransactionHistoryScreen> createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  final _currencyFormat = NumberFormat.currency(symbol: '\$');
  TransactionType? _filterType;
  PaymentMethod? _filterPaymentMethod;
  bool _showReconciled = false;
  bool _isSearching = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<TransactionProvider>().fetchTransactions();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() {
            _searchQuery = value.toLowerCase();
          });
        },
        decoration: InputDecoration(
          hintText: 'Search transactions...',
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: Theme.of(context).cardColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          FilterChip(
            label: const Text('Show Reconciled'),
            selected: _showReconciled,
            onSelected: (value) {
              setState(() => _showReconciled = value);
            },
          ),
          const SizedBox(width: 8),
          ...TransactionType.values.map((type) => Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(type.name.toUpperCase()),
              selected: _filterType == type,
              onSelected: (value) {
                setState(() {
                  _filterType = value ? type : null;
                });
              },
            ),
          )),
          if (_filterType == TransactionType.payment)
            ...PaymentMethod.values.map((method) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(method.name.toUpperCase()),
                selected: _filterPaymentMethod == method,
                onSelected: (value) {
                  setState(() {
                    _filterPaymentMethod = value ? method : null;
                  });
                },
              ),
            )),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  _searchQuery = '';
                }
              });
            },
          ),
        ],
      ),
      body: Consumer<TransactionProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          var transactions = provider.transactions;

          // Apply filters
          if (widget.clientId != null) {
            transactions = transactions
                .where((t) => t.clientId == widget.clientId)
                .toList();
          }
          if (_filterType != null) {
            transactions = transactions
                .where((t) => t.type == _filterType)
                .toList();
          }
          if (_filterPaymentMethod != null) {
            transactions = transactions
                .where((t) => t.paymentMethod == _filterPaymentMethod)
                .toList();
          }
          if (!_showReconciled) {
            transactions = transactions
                .where((t) => !t.isReconciled)
                .toList();
          }
          if (_searchQuery.isNotEmpty) {
            transactions = transactions.where((t) {
              final client = context.read<ClientProvider>().clients
                  .firstWhere((c) => c.id == t.clientId);
              return client.companyName.toLowerCase().contains(_searchQuery) ||
                     t.type.toString().toLowerCase().contains(_searchQuery) ||
                     t.amount.toString().contains(_searchQuery);
            }).toList();
          }

          if (transactions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No transactions found',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              if (_isSearching) _buildSearchBar(),
              _buildFilterChips(),
              Expanded(
                child: ListView.builder(
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    final transaction = transactions[index];
                    final client = context
                        .read<ClientProvider>()
                        .clients
                        .firstWhere((c) => c.id == transaction.clientId);

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: InkWell(
                        onTap: () {
                          // Show transaction details in a bottom sheet
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) => DraggableScrollableSheet(
                              initialChildSize: 0.7,
                              minChildSize: 0.5,
                              maxChildSize: 0.95,
                              builder: (_, controller) => Container(
                                decoration: BoxDecoration(
                                  color: Theme.of(context).scaffoldBackgroundColor,
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                                ),
                                padding: const EdgeInsets.all(16),
                                child: ListView(
                                  controller: controller,
                                  children: [
                                    Center(
                                      child: Container(
                                        width: 40,
                                        height: 4,
                                        margin: const EdgeInsets.only(bottom: 20),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[300],
                                          borderRadius: BorderRadius.circular(2),
                                        ),
                                      ),
                                    ),
                                    Text(
                                      client.companyName,
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    _DetailRow(
                                      label: 'Amount',
                                      value: _currencyFormat.format(transaction.amount),
                                    ),
                                    _DetailRow(
                                      label: 'Type',
                                      value: transaction.type.name.toUpperCase(),
                                    ),
                                    _DetailRow(
                                      label: 'Date',
                                      value: DateFormat('MMM dd, yyyy').format(transaction.date),
                                    ),
                                    if (transaction.paymentMethod != null)
                                      _DetailRow(
                                        label: 'Payment Method',
                                        value: transaction.paymentMethod!.name.toUpperCase(),
                                      ),
                                    _DetailRow(
                                      label: 'Status',
                                      value: transaction.isReconciled ? 'Reconciled' : 'Pending',
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: transaction.type == TransactionType.sale
                                      ? Colors.green.withOpacity(0.2)
                                      : Colors.blue.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  transaction.type == TransactionType.sale
                                      ? Icons.shopping_cart
                                      : Icons.payment,
                                  color: transaction.type == TransactionType.sale
                                      ? Colors.green
                                      : Colors.blue,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      client.companyName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      DateFormat('MMM dd, yyyy').format(transaction.date),
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    _currencyFormat.format(transaction.amount),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  if (transaction.isReconciled)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.green.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Text(
                                        'Reconciled',
                                        style: TextStyle(
                                          color: Colors.green,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              StreamBuilder(
                                stream: FirebaseAuth.instance.authStateChanges(),
                                builder: (context, snapshot) {
                                  final userEmail = FirebaseAuth.instance.currentUser?.email;
                                  if (userEmail == 'munashe@butornecooper.co.zw') {
                                    return IconButton(
                                      icon: const Icon(Icons.more_vert),
                                      onPressed: () {
                                        showModalBottomSheet(
                                          context: context,
                                          builder: (context) => Container(
                                            padding: const EdgeInsets.symmetric(vertical: 16),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                ListTile(
                                                  leading: const Icon(Icons.edit),
                                                  title: const Text('Edit Transaction'),
                                                  onTap: () {
                                                    Navigator.pop(context);
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (_) => AddTransactionScreen(
                                                          transaction: transaction,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                                ListTile(
                                                  leading: const Icon(Icons.delete, color: Colors.red),
                                                  title: const Text('Delete Transaction', style: TextStyle(color: Colors.red)),
                                                  onTap: () async {
                                                    Navigator.pop(context);
                                                    final confirm = await showDialog<bool>(
                                                      context: context,
                                                      builder: (context) => AlertDialog(
                                                        title: const Text('Delete Transaction'),
                                                        content: const Text('Are you sure you want to delete this transaction?'),
                                                        actions: [
                                                          TextButton(
                                                            onPressed: () => Navigator.pop(context, false),
                                                            child: const Text('CANCEL'),
                                                          ),
                                                          TextButton(
                                                            onPressed: () => Navigator.pop(context, true),
                                                            child: const Text('DELETE', style: TextStyle(color: Colors.red)),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                    
                                                    if (confirm == true) {
                                                      try {
                                                        await provider.deleteTransaction(transaction.id);
                                                        ScaffoldMessenger.of(context).showSnackBar(
                                                          const SnackBar(
                                                            content: Text('Transaction deleted successfully'),
                                                            backgroundColor: Colors.green,
                                                          ),
                                                        );
                                                      } catch (e) {
                                                        ScaffoldMessenger.of(context).showSnackBar(
                                                          SnackBar(
                                                            content: Text(e.toString()),
                                                            backgroundColor: Colors.red,
                                                          ),
                                                        );
                                                      }
                                                    }
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  }
                                  return const SizedBox.shrink();
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}