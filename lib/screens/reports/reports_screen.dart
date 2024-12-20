import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../models/transaction.dart';
import '../../services/export_service.dart';
import '../dashboard/widgets/date_range_selector.dart';
import '../transactions/add_transaction_screen.dart';
import 'package:shimmer/shimmer.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({Key? key}) : super(key: key);

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _startDate = DateTime.now().subtract(const Duration(days: 30));
    _endDate = DateTime.now();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    final provider = context.read<TransactionProvider>();
    await provider.loadTransactions(
      startDate: _startDate,
      endDate: _endDate,
    );
  }

  Future<void> _exportTransactions(List<BusinessTransaction> transactions) async {
    try {
      final csv = await ExportService.exportTransactionsToCsv(transactions);
      await Share.share(csv, subject: 'Transaction Report');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error exporting transactions: $e')),
        );
      }
    }
  }

  Future<void> _exportRevenueReport(List<BusinessTransaction> transactions) async {
    try {
      final csv = await ExportService.exportRevenueReportToCsv(transactions);
      await Share.share(csv, subject: 'Revenue Report');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error exporting revenue report: $e')),
        );
      }
    }
  }

  Future<void> _exportCashbook() async {
    final provider = context.read<TransactionProvider>();
    final transactions = provider.transactions.where((t) => t.date.isAfter(_startDate!) && t.date.isBefore(_endDate!)).toList();
    try {
      // Generate Excel
      var excel = Excel.createExcel();
      Sheet sheetObject = excel['Cashbook'];
      sheetObject.appendRow(['Date', 'Description', 'Amount', 'Payment Method', 'Category']);
      for (var transaction in transactions) {
        sheetObject.appendRow([
          DateFormat('yyyy-MM-dd').format(transaction.date),
          transaction.description,
          transaction.amount,
          transaction.paymentMethod?.toString() ?? '',
          transaction.category,
        ]);
      }
      final excelBytes = excel.encode();

      // Generate PDF
      final pdf = pw.Document();
      pdf.addPage(
        pw.Page(
          build: (pw.Context context) => pw.Table.fromTextArray(
            data: <List<String>>[
              <String>['Date', 'Description', 'Amount', 'Payment Method', 'Category'],
              ...transactions.map((transaction) => [
                    DateFormat('yyyy-MM-dd').format(transaction.date),
                    transaction.description,
                    transaction.amount.toString(),
                    transaction.paymentMethod?.toString() ?? '',
                    transaction.category,
                  ]),
            ],
          ),
        ),
      );
      final pdfBytes = await pdf.save();

      // Save files
      final directory = await getApplicationDocumentsDirectory();
      final excelPath = '${directory.path}/cashbook.xlsx';
      final pdfPath = '${directory.path}/cashbook.pdf';
      final excelFile = File(excelPath);
      excelFile.writeAsBytesSync(excelBytes!);
      final pdfFile = File(pdfPath);
      pdfFile.writeAsBytesSync(pdfBytes);

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Cashbook exported to Excel and PDF.')));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error exporting cashbook: $e')),
        );
      }
    }
  }

  Future<void> _exportPnL() async {
    final provider = context.read<TransactionProvider>();
    final transactions = provider.transactions.where((t) => t.date.isAfter(_startDate!) && t.date.isBefore(_endDate!)).toList();
    try {
      // Generate Excel
      var excel = Excel.createExcel();
      Sheet sheetObject = excel['P&L'];
      sheetObject.appendRow(['Category', 'Amount']);

      double totalRevenue = transactions.where((t) => t.type == TransactionType.sale).fold(0.0, (sum, t) => sum + t.amount);
      double operatingCosts = transactions.where((t) => t.category == 'Operating').fold(0.0, (sum, t) => sum + t.amount);
      double marketingCosts = transactions.where((t) => t.category == 'Marketing').fold(0.0, (sum, t) => sum + t.amount);
      double distributionCosts = transactions.where((t) => t.category == 'Distribution').fold(0.0, (sum, t) => sum + t.amount);

      sheetObject.appendRow(['Total Revenue', totalRevenue]);
      sheetObject.appendRow(['Operating Costs', operatingCosts]);
      sheetObject.appendRow(['Marketing Costs', marketingCosts]);
      sheetObject.appendRow(['Distribution Costs', distributionCosts]);

      final excelBytes = excel.encode();

      // Generate PDF
      final pdf = pw.Document();
      pdf.addPage(
        pw.Page(
          build: (pw.Context context) => pw.Table.fromTextArray(
            data: <List<String>>[
              <String>['Category', 'Amount'],
              ['Total Revenue', totalRevenue.toString()],
              ['Operating Costs', operatingCosts.toString()],
              ['Marketing Costs', marketingCosts.toString()],
              ['Distribution Costs', distributionCosts.toString()],
            ],
          ),
        ),
      );
      final pdfBytes = await pdf.save();

      // Save files
      final directory = await getApplicationDocumentsDirectory();
      final excelPath = '${directory.path}/pnl.xlsx';
      final pdfPath = '${directory.path}/pnl.pdf';
      final excelFile = File(excelPath);
      excelFile.writeAsBytesSync(excelBytes!);
      final pdfFile = File(pdfPath);
      pdfFile.writeAsBytesSync(pdfBytes);

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('P&L exported to Excel and PDF.')));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error exporting P&L: $e')),
        );
      }
    }
  }

  void _showDateRangePicker() async {
    DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _startDate!, end: _endDate!),
    );
    if (picked != null && picked != DateTimeRange(start: _startDate!, end: _endDate!)) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      _loadData();
    }
  }

  Map<ServiceType, double> _calculateRevenueByService(List<BusinessTransaction> transactions) {
    final Map<ServiceType, double> revenueByService = {};
    for (var transaction in transactions) {
      if (transaction.type == TransactionType.sale) {
        revenueByService[transaction.serviceType] = (revenueByService[transaction.serviceType] ?? 0) + transaction.amount;
      }
    }
    return revenueByService;
  }

  Map<String, double> _calculateMonthlyRevenue(List<BusinessTransaction> transactions) {
    final Map<String, double> monthlyRevenue = {};
    for (var transaction in transactions) {
      if (transaction.type == TransactionType.sale) {
        final monthKey = DateFormat('MMM yyyy').format(transaction.date);
        monthlyRevenue[monthKey] = (monthlyRevenue[monthKey] ?? 0) + transaction.amount;
      }
    }
    return monthlyRevenue;
  }

  Map<String, double> _calculateClientRevenue(List<BusinessTransaction> transactions) {
    final Map<String, double> clientRevenue = {};
    for (var transaction in transactions) {
      if (transaction.type == TransactionType.sale) {
        clientRevenue[transaction.clientName] = (clientRevenue[transaction.clientName] ?? 0) + transaction.amount;
      }
    }
    return clientRevenue;
  }

  Widget _buildRevenueByServiceCard(Map<ServiceType, double> revenueByService) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.pie_chart, color: Colors.teal),
                const SizedBox(width: 8),
                const Text(
                  'Revenue by Service Type',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 24),
            ...revenueByService.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(entry.key.toString().split('.').last),
                    Text(
                      NumberFormat.currency(symbol: '\$').format(entry.value),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyRevenueCard(Map<String, double> monthlyRevenue) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Monthly Revenue',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...monthlyRevenue.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(entry.key),
                    Text(
                      NumberFormat.currency(symbol: '\$').format(entry.value),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopClientsCard(Map<String, double> clientRevenue) {
    final sortedClients = clientRevenue.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topClients = sortedClients.take(5).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Top 5 Clients by Revenue',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...topClients.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        entry.key,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      NumberFormat.currency(symbol: '\$').format(entry.value),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) async {
              final provider = context.read<TransactionProvider>();
              final transactions = provider.transactions;

              switch (value) {
                case 'transactions':
                  await _exportTransactions(transactions);
                  break;
                case 'revenue':
                  await _exportRevenueReport(transactions);
                  break;
                case 'cashbook':
                  await _exportCashbook();
                  break;
                case 'pnl':
                  await _exportPnL();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'transactions',
                child: Text('Export Transactions'),
              ),
              const PopupMenuItem(
                value: 'revenue',
                child: Text('Export Revenue Report'),
              ),
              const PopupMenuItem(
                value: 'cashbook',
                child: Text('Export Cashbook'),
              ),
              const PopupMenuItem(
                value: 'pnl',
                child: Text('Export P&L'),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: _showDateRangePicker,
          ),
        ],
      ),
      body: Consumer<TransactionProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
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

          final transactions = provider.transactions;
          final revenueByService = _calculateRevenueByService(transactions);
          final monthlyRevenue = _calculateMonthlyRevenue(transactions);
          final clientRevenue = _calculateClientRevenue(transactions);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DateRangeSelector(
                  startDate: _startDate,
                  endDate: _endDate,
                  onDateRangeSelected: (start, end) {
                    setState(() {
                      _startDate = start;
                      _endDate = end;
                    });
                    _loadData();
                  },
                ),
                const SizedBox(height: 16),
                _buildRevenueByServiceCard(revenueByService),
                const SizedBox(height: 16),
                _buildMonthlyRevenueCard(monthlyRevenue),
                const SizedBox(height: 16),
                _buildTopClientsCard(clientRevenue),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddTransactionScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}