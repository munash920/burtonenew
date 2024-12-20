import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/client_provider.dart';
import 'widgets/transaction_summary_card.dart';
import 'widgets/recent_activities_card.dart';
import 'widgets/date_range_selector.dart';
import 'widgets/client_summary_card.dart';
import 'package:shimmer/shimmer.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Use Future.microtask to avoid calling setState during build
    Future.microtask(() {
      if (mounted) {
        context.read<ClientProvider>().loadClients();
        context.read<TransactionProvider>().loadTransactions();
      }
    });
  }

  Future<void> _refreshData() async {
    await Future.wait([
      context.read<ClientProvider>().loadClients(),
      context.read<TransactionProvider>().loadTransactions(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
          ),
        ],
      ),
      body: Consumer2<TransactionProvider, ClientProvider>(
        builder: (context, transactionProvider, clientProvider, child) {
          if (transactionProvider.isLoading || clientProvider.isLoading) {
            return Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  Container(height: 100, color: Colors.white),
                  const SizedBox(height: 16),
                  Container(height: 100, color: Colors.white),
                  const SizedBox(height: 16),
                  Container(height: 100, color: Colors.white),
                ],
              ),
            );
          }

          if (transactionProvider.error != null) {
            return Center(
              child: Text(
                'Error: ${transactionProvider.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refreshData,
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                DateRangeSelector(
                  startDate: transactionProvider.startDate,
                  endDate: transactionProvider.endDate,
                  onDateRangeSelected: (start, end) {
                    transactionProvider.setDateRange(start, end);
                  },
                ),
                const SizedBox(height: 16),
                TransactionSummaryCard(metrics: transactionProvider.metrics),
                const SizedBox(height: 16),
                ClientSummaryCard(clients: clientProvider.clients),
                const SizedBox(height: 16),
                RecentActivitiesCard(transactions: transactionProvider.transactions),
              ],
            ),
          );
        },
      ),
    );
  }
} 