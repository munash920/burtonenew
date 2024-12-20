import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/transaction.dart';

class RecentActivitiesCard extends StatelessWidget {
  final List<BusinessTransaction> transactions;
  
  const RecentActivitiesCard({
    super.key,
    required this.transactions,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '\$');
    final dateFormat = DateFormat('MMM d, y');
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recent Activities',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: transactions.take(5).length,
              itemBuilder: (context, index) {
                final transaction = transactions[index];
                return ListTile(
                  leading: Icon(
                    transaction.type == TransactionType.sale
                        ? Icons.arrow_upward
                        : Icons.arrow_downward,
                    color: transaction.type == TransactionType.sale
                        ? Colors.green
                        : Colors.red,
                  ),
                  title: Text(transaction.description),
                  subtitle: Text(dateFormat.format(transaction.date)),
                  trailing: Text(
                    currencyFormat.format(transaction.amount),
                    style: TextStyle(
                      color: transaction.type == TransactionType.sale
                          ? Colors.green
                          : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
} 