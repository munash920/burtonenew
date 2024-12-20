import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/transaction.dart';

class TransactionProvider with ChangeNotifier {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<BusinessTransaction> _transactions = [];
  bool _isLoading = false;
  String? _error;
  DateTime? _startDate;
  DateTime? _endDate;
  Map<String, dynamic> _metrics = {};

  TransactionProvider(this._firestore) {
    _startDate = DateTime.now().subtract(const Duration(days: 30));
    _endDate = DateTime.now();
  }

  List<BusinessTransaction> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String? get error => _error;
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;
  Map<String, dynamic> get metrics => _metrics;

  void setDateRange(DateTime? start, DateTime? end) {
    _startDate = start;
    _endDate = end;
    loadTransactions();
  }

  Future<void> fetchTransactions() => loadTransactions();

  Future<void> loadTransactions({
    DateTime? startDate,
    DateTime? endDate,
    TransactionType? type,
    ServiceType? serviceType,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      Query query = _firestore.collection('transactions')
          .where('userId', isEqualTo: userId);

      if (startDate != null) {
        query = query.where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
      }
      if (endDate != null) {
        query = query.where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate));
      }
      if (type != null) {
        query = query.where('type', isEqualTo: type.toString().split('.').last);
      }
      if (serviceType != null) {
        query = query.where('serviceType', isEqualTo: serviceType.toString().split('.').last);
      }

      final snapshot = await query.get();
      _transactions = snapshot.docs
          .map((doc) => BusinessTransaction.fromFirestore(doc))
          .toList();

      await _calculateMetrics();
    } catch (e) {
      _error = e.toString();
      print('Error loading transactions: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _calculateMetrics() async {
    double revenue = 0;
    double expenses = 0;
    int registrations = 0;
    int reregistrations = 0;

    for (var transaction in _transactions) {
      if (transaction.type == TransactionType.sale) {
        revenue += transaction.amount;
        if (transaction.serviceType == ServiceType.registration) {
          registrations++;
        } else if (transaction.serviceType == ServiceType.reregistration) {
          reregistrations++;
        }
      } else if (transaction.type == TransactionType.expense) {
        expenses += transaction.amount;
      }
    }

    _metrics = {
      'revenue': revenue,
      'expenses': expenses,
      'netProfit': revenue - expenses,
      'registrations': registrations,
      'reregistrations': reregistrations,
    };
  }

  Future<void> addTransaction(BusinessTransaction transaction) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final transactionData = transaction.toMap();
      transactionData['userId'] = userId;

      await _firestore.collection('transactions').add(transactionData);
      await loadTransactions();
    } catch (e) {
      _error = e.toString();
      print('Error adding transaction: $e');
      rethrow;
    }
  }

  Future<void> updateTransaction(String id, BusinessTransaction transaction) async {
    try {
      final userId = _auth.currentUser?.uid;
      final userEmail = _auth.currentUser?.email;
      
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Check if the user has permission to edit (only munashe@butornecooper.co.zw can edit)
      if (userEmail != 'munashe@butornecooper.co.zw') {
        throw Exception('You do not have permission to edit transactions');
      }

      final transactionData = transaction.toMap();
      transactionData['userId'] = userId;

      await _firestore.collection('transactions').doc(id).update(transactionData);
      await loadTransactions();
    } catch (e) {
      _error = e.toString();
      print('Error updating transaction: $e');
      rethrow;
    }
  }

  Future<void> deleteTransaction(String id) async {
    try {
      final userId = _auth.currentUser?.uid;
      final userEmail = _auth.currentUser?.email;
      
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Check if the user has permission to delete (only munashe@butornecooper.co.zw can delete)
      if (userEmail != 'munashe@butornecooper.co.zw') {
        throw Exception('You do not have permission to delete transactions');
      }

      await _firestore.collection('transactions').doc(id).delete();
      await loadTransactions();
    } catch (e) {
      _error = e.toString();
      print('Error deleting transaction: $e');
      rethrow;
    }
  }

  double getTotalRevenue() {
    return _transactions
        .where((t) => t.type == TransactionType.sale)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double getTotalPayments() {
    return _transactions
        .where((t) => t.type == TransactionType.payment)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double getClientBalance(String clientId) {
    return _transactions
        .where((t) => t.clientId == clientId)
        .fold(0.0, (sum, t) {
          if (t.type == TransactionType.sale) {
            return sum + t.amount;
          } else if (t.type == TransactionType.payment) {
            return sum - t.amount;
          }
          return sum;
        });
  }
} 