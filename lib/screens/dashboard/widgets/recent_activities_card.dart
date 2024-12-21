import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/transaction.dart';
import '../../../widgets/notion_card.dart';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final subtextColor = isDark ? Colors.white70 : Colors.black54;
    
    return NotionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Activities',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: textColor,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 16),
          Divider(color: isDark ? Colors.white24 : Colors.black12),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: transactions.take(5).length,
            itemBuilder: (context, index) {
              final transaction = transactions[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: (transaction.type == TransactionType.sale
                            ? Colors.green
                            : Colors.red).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        transaction.type == TransactionType.sale
                            ? Icons.arrow_upward
                            : Icons.arrow_downward,
                        color: transaction.type == TransactionType.sale
                            ? Colors.green.withOpacity(0.8)
                            : Colors.red.withOpacity(0.8),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            transaction.description,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            dateFormat.format(transaction.date),
                            style: TextStyle(
                              fontSize: 14,
                              color: subtextColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      currencyFormat.format(transaction.amount),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: transaction.type == TransactionType.sale
                            ? Colors.green.withOpacity(0.8)
                            : Colors.red.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}