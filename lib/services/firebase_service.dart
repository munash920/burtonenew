import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/client.dart';
import '../models/transaction.dart';
import '../models/app_notification.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Client methods
  Future<List<Client>> getClients() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    final snapshot = await _firestore
        .collection('clients')
        .where('userId', isEqualTo: userId)
        .get();
    return snapshot.docs.map((doc) => Client.fromFirestore(doc)).toList();
  }

  Future<Client?> getClient(String id) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    final doc = await _firestore.collection('clients').doc(id).get();
    if (!doc.exists) return null;

    final client = Client.fromFirestore(doc);
    if (client.userId != userId) throw Exception('Access denied');

    return client;
  }

  Future<void> createClient(Client client) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    final clientData = client.toMap();
    clientData['userId'] = userId;
    clientData['createdAt'] = FieldValue.serverTimestamp();

    await _firestore.collection('clients').add(clientData);
  }

  Future<void> updateClient(String id, Map<String, dynamic> data) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    final doc = await _firestore.collection('clients').doc(id).get();
    if (!doc.exists) throw Exception('Client not found');

    final existingClient = Client.fromFirestore(doc);
    if (existingClient.userId != userId) throw Exception('Access denied');

    data['userId'] = userId; // Ensure userId is preserved
    await _firestore.collection('clients').doc(id).update(data);
  }

  Future<void> deleteClient(String id) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    final doc = await _firestore.collection('clients').doc(id).get();
    if (!doc.exists) throw Exception('Client not found');

    final client = Client.fromFirestore(doc);
    if (client.userId != userId) throw Exception('Access denied');

    await _firestore.collection('clients').doc(id).delete();
  }

  // Transaction methods
  Future<List<BusinessTransaction>> getTransactions({
    DateTime? startDate,
    DateTime? endDate,
    TransactionType? type,
  }) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    Query query = _firestore
        .collection('transactions')
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

    final snapshot = await query.get();
    return snapshot.docs.map((doc) => BusinessTransaction.fromFirestore(doc)).toList();
  }

  Future<Map<String, dynamic>> getTransactionMetrics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final transactions = await getTransactions(
      startDate: startDate,
      endDate: endDate,
    );

    double revenue = 0;
    double expenses = 0;
    int registrations = 0;
    int reregistrations = 0;

    for (var transaction in transactions) {
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

    return {
      'revenue': revenue,
      'expenses': expenses,
      'netProfit': revenue - expenses,
      'registrations': registrations,
      'reregistrations': reregistrations,
    };
  }

  Future<void> createTransaction(BusinessTransaction transaction) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    final transactionData = transaction.toMap();
    transactionData['userId'] = userId;

    await _firestore.collection('transactions').add(transactionData);
  }

  Future<void> updateTransaction(String id, Map<String, dynamic> data) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    final doc = await _firestore.collection('transactions').doc(id).get();
    if (!doc.exists) throw Exception('Transaction not found');

    final transaction = BusinessTransaction.fromFirestore(doc);
    if (transaction.userId != userId) throw Exception('Access denied');

    data['userId'] = userId; // Ensure userId is preserved
    await _firestore.collection('transactions').doc(id).update(data);
  }

  Future<void> deleteTransaction(String id) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    final doc = await _firestore.collection('transactions').doc(id).get();
    if (!doc.exists) throw Exception('Transaction not found');

    final transaction = BusinessTransaction.fromFirestore(doc);
    if (transaction.userId != userId) throw Exception('Access denied');

    await _firestore.collection('transactions').doc(id).delete();
  }

  // Notification methods
  Future<List<AppNotification>> getNotifications() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    final snapshot = await _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .get();
    return snapshot.docs.map((doc) => AppNotification.fromFirestore(doc)).toList();
  }

  Future<void> createNotification(AppNotification notification) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    final notificationData = notification.toMap();
    notificationData['userId'] = userId;

    await _firestore.collection('notifications').add(notificationData);
  }

  Future<void> updateNotification(String id, Map<String, dynamic> data) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    final doc = await _firestore.collection('notifications').doc(id).get();
    if (!doc.exists) throw Exception('Notification not found');

    final existingData = doc.data() as Map<String, dynamic>;
    if (existingData['userId'] != userId) throw Exception('Access denied');

    data['userId'] = userId; // Ensure userId is preserved
    await _firestore.collection('notifications').doc(id).update(data);
  }

  Future<void> deleteNotification(String id) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    final doc = await _firestore.collection('notifications').doc(id).get();
    if (!doc.exists) throw Exception('Notification not found');

    final existingData = doc.data() as Map<String, dynamic>;
    if (existingData['userId'] != userId) throw Exception('Access denied');

    await _firestore.collection('notifications').doc(id).delete();
  }
}
