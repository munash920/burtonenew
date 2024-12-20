import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/client_provider.dart';
import '../../models/transaction.dart';

class ReconciliationScreen extends StatefulWidget {
  const ReconciliationScreen({super.key});

  @override
  State<ReconciliationScreen> createState() => _ReconciliationScreenState();
}

class _ReconciliationScreenState extends State<ReconciliationScreen> {
  final _currencyFormat = NumberFormat.currency(symbol: '\$');
  final _selectedTransactions = <String>{};
  bool _showOnlyUnreconciled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reconciliation'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check_circle_outline),
            onPressed: _selectedTransactions.isEmpty
                ? null
                : () => _reconcileSelected(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Summary Card
          Consumer<TransactionProvider>(
            builder: (context, provider, _) {
              final totalSelected = provider.transactions
                  .where((t) => _selectedTransactions.contains(t.id))
                  .fold(0.0, (sum, t) => sum + t.amount);

              return Card(
                margin: const EdgeInsets.all(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        'Selected Amount',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _currencyFormat.format(totalSelected),
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 16),
                      SwitchListTile(
                        title: const Text('Show Only Unreconciled'),
                        value: _showOnlyUnreconciled,
                        onChanged: (value) {
                          setState(() => _showOnlyUnreconciled = value);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // Transactions List
          Expanded(
            child: Consumer2<TransactionProvider, ClientProvider>(
              builder: (context, transactionProvider, clientProvider, _) {
                var transactions = transactionProvider.transactions;
                if (_showOnlyUnreconciled) {
                  transactions = transactions
                      .where((t) => !t.isReconciled)
                      .toList();
                }

                return ListView.builder(
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    final transaction = transactions[index];
                    final client = clientProvider.clients
                        .firstWhere((c) => c.id == transaction.clientId);

                    return CheckboxListTile(
                      value: _selectedTransactions.contains(transaction.id),
                      onChanged: transaction.isReconciled
                          ? null
                          : (selected) {
                              setState(() {
                                if (selected == true) {
                                  _selectedTransactions.add(transaction.id);
                                } else {
                                  _selectedTransactions.remove(transaction.id);
                                }
                              });
                            },
                      title: Text(client.companyName),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(transaction.description),
                          Text(
                            DateFormat('MMM dd, yyyy').format(transaction.date),
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      secondary: Text(
                        _currencyFormat.format(transaction.amount),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _reconcileSelected(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Reconciliation'),
        content: Text(
          'Are you sure you want to reconcile ${_selectedTransactions.length} transactions?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reconcile'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await context.read<TransactionProvider>().reconcileTransactions(
          _selectedTransactions.toList(),
        );
        setState(() => _selectedTransactions.clear());
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Transactions reconciled successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
  }
} 