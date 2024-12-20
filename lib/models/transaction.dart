import 'package:cloud_firestore/cloud_firestore.dart' show DocumentSnapshot, Timestamp;

enum TransactionType {
  sale,
  payment,
  expense,
  refund
}

enum PaymentMethod {
  cash,
  bankTransfer,
  check,
  creditCard,
  other
}

enum ServiceType {
  registration,
  reregistration,
  tax_clearance,
  tax_returns,
  annual_returns,
  bookkeeping
}

class BusinessTransaction {
  final String id;
  final String userId;
  final String clientId;
  final String clientName;
  final String description;
  final double amount;
  final DateTime date;
  final TransactionType type;
  final ServiceType serviceType;
  final PaymentMethod? paymentMethod;
  final bool isReconciled;
  final String category;
  final String expenseType;

  BusinessTransaction({
    required this.id,
    required this.userId,
    required this.clientId,
    required this.clientName,
    required this.description,
    required this.amount,
    required this.date,
    required this.type,
    required this.serviceType,
    this.paymentMethod,
    this.isReconciled = false,
    required this.category,
    required this.expenseType,
  });

  factory BusinessTransaction.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    return BusinessTransaction(
      id: doc.id,
      userId: data['userId'] ?? '',
      clientId: data['clientId'] ?? '',
      clientName: data['clientName'] ?? '',
      description: data['description'] ?? '',
      amount: (data['amount'] ?? 0.0).toDouble(),
      date: (data['date'] as Timestamp).toDate(),
      type: TransactionType.values.firstWhere(
        (e) => e.toString() == 'TransactionType.${data['type']}',
        orElse: () => TransactionType.sale,
      ),
      serviceType: ServiceType.values.firstWhere(
        (e) => e.toString() == 'ServiceType.${data['serviceType']}',
        orElse: () => ServiceType.registration,
      ),
      paymentMethod: data['paymentMethod'] != null
          ? PaymentMethod.values.firstWhere(
              (e) => e.toString() == 'PaymentMethod.${data['paymentMethod']}',
              orElse: () => PaymentMethod.other,
            )
          : null,
      isReconciled: data['isReconciled'] ?? false,
      category: data['category'] ?? '',
      expenseType: data['expenseType'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'clientId': clientId,
      'clientName': clientName,
      'description': description,
      'amount': amount,
      'date': Timestamp.fromDate(date),
      'type': type.toString().split('.').last,
      'serviceType': serviceType.toString().split('.').last,
      'paymentMethod': paymentMethod?.toString().split('.').last,
      'isReconciled': isReconciled,
      'category': category,
      'expenseType': expenseType,
    };
  }
} 