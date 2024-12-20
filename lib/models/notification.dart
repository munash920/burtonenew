import 'package:cloud_firestore/cloud_firestore.dart';

enum NotificationType {
  taxReturn,
  payment,
  clientUpdate,
  system
}

class AppNotification {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final DateTime createdAt;
  final bool isRead;
  final String? clientId;
  final String? actionRoute;

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.createdAt,
    this.isRead = false,
    this.clientId,
    this.actionRoute,
  });

  factory AppNotification.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AppNotification(
      id: doc.id,
      title: data['title'] ?? '',
      message: data['message'] ?? '',
      type: NotificationType.values[data['type'] ?? 0],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      isRead: data['isRead'] ?? false,
      clientId: data['clientId'],
      actionRoute: data['actionRoute'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'message': message,
      'type': type.index,
      'createdAt': Timestamp.fromDate(createdAt),
      'isRead': isRead,
      'clientId': clientId,
      'actionRoute': actionRoute,
    };
  }
} 