import 'package:cloud_firestore/cloud_firestore.dart';

class Target {
  final String id;
  final double revenueTarget;
  final int registrationTarget;
  final int reregistrationTarget;
  final DateTime startDate;
  final DateTime endDate;

  Target({
    required this.id,
    required this.revenueTarget,
    required this.registrationTarget,
    required this.reregistrationTarget,
    required this.startDate,
    required this.endDate,
  });

  factory Target.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Target(
      id: doc.id,
      revenueTarget: (data['revenueTarget'] ?? 0.0).toDouble(),
      registrationTarget: data['registrationTarget'] ?? 0,
      reregistrationTarget: data['reregistrationTarget'] ?? 0,
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: (data['endDate'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'revenueTarget': revenueTarget,
      'registrationTarget': registrationTarget,
      'reregistrationTarget': reregistrationTarget,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
    };
  }
} 