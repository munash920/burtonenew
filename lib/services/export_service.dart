import 'dart:io';
import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../models/client.dart';

class ExportService {
  static Future<String> exportTransactionsToCsv(List<BusinessTransaction> transactions) async {
    final csvData = [
      // Header
      [
        'Date',
        'Type',
        'Service Type',
        'Client',
        'Description',
        'Amount',
        'Payment Method',
        'Reconciled'
      ],
      // Data rows
      ...transactions.map((t) => [
        DateFormat('yyyy-MM-dd').format(t.date),
        t.type.toString().split('.').last,
        t.serviceType.toString().split('.').last,
        t.clientName,
        t.description,
        t.amount.toStringAsFixed(2),
        t.paymentMethod?.toString().split('.').last ?? '',
        t.isReconciled ? 'Yes' : 'No',
      ]),
    ];

    return const ListToCsvConverter().convert(csvData);
  }

  static Future<String> exportRevenueReportToCsv(List<BusinessTransaction> transactions) async {
    // Calculate revenue by service type
    final revenueByService = <String, double>{};
    for (var t in transactions.where((t) => t.type == TransactionType.sale)) {
      final serviceType = t.serviceType.toString().split('.').last;
      revenueByService[serviceType] = (revenueByService[serviceType] ?? 0) + t.amount;
    }

    // Calculate revenue by month
    final revenueByMonth = <String, double>{};
    for (var t in transactions.where((t) => t.type == TransactionType.sale)) {
      final monthKey = DateFormat('yyyy-MM').format(t.date);
      revenueByMonth[monthKey] = (revenueByMonth[monthKey] ?? 0) + t.amount;
    }

    final csvData = [
      ['Revenue Report'],
      ['Generated on', DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())],
      [],
      ['Revenue by Service Type'],
      ['Service Type', 'Amount'],
      ...revenueByService.entries.map((e) => [e.key, e.value.toStringAsFixed(2)]),
      [],
      ['Revenue by Month'],
      ['Month', 'Amount'],
      ...revenueByMonth.entries.map((e) => [e.key, e.value.toStringAsFixed(2)]),
    ];

    return const ListToCsvConverter().convert(csvData);
  }

  static Future<String> exportClientReportToCsv(
    List<Client> clients,
    List<BusinessTransaction> transactions,
  ) async {
    final clientRevenue = <String, double>{};
    final clientTransactionCount = <String, int>{};

    // Calculate revenue and transaction count per client
    for (var t in transactions.where((t) => t.type == TransactionType.sale)) {
      clientRevenue[t.clientId] = (clientRevenue[t.clientId] ?? 0) + t.amount;
      clientTransactionCount[t.clientId] = (clientTransactionCount[t.clientId] ?? 0) + 1;
    }

    final csvData = [
      [
        'Client ID',
        'Name',
        'Company',
        'Email',
        'Phone',
        'Registration Number',
        'Total Revenue',
        'Transaction Count',
        'Last Contact',
      ],
      ...clients.map((c) => [
        c.id,
        c.name,
        c.companyName,
        c.email,
        c.phone,
        c.registrationNumber,
        (clientRevenue[c.id] ?? 0).toStringAsFixed(2),
        clientTransactionCount[c.id] ?? 0,
        c.lastContact != null
            ? DateFormat('yyyy-MM-dd').format(c.lastContact!)
            : 'Never',
      ]),
    ];

    return const ListToCsvConverter().convert(csvData);
  }
} 