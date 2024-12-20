import 'package:flutter/foundation.dart';
import '../models/app_notification.dart';
import '../services/firebase_service.dart';
import '../services/notification_service.dart';

class NotificationProvider with ChangeNotifier {
  final FirebaseService _firebaseService;
  final NotificationService _notificationService = NotificationService();
  List<AppNotification> _notifications = [];
  bool _isLoading = false;

  NotificationProvider(this._firebaseService);

  List<AppNotification> get notifications => _notifications;
  bool get isLoading => _isLoading;

  Future<void> loadNotifications() async {
    _isLoading = true;
    notifyListeners();

    try {
      _notifications = await _firebaseService.getNotifications();
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAsRead(String notificationId) async {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      await _firebaseService.updateNotification(
        _notifications[index].id,
        {'isRead': true},
      );
      await loadNotifications();
    }
  }

  Future<void> createNotification(AppNotification notification) async {
    await _firebaseService.createNotification(notification);
    await loadNotifications();
    
    // Show local notification
    await _notificationService.showNotification(
      title: notification.title,
      body: notification.message,
    );
  }

  Future<void> deleteNotification(String notificationId) async {
    await _firebaseService.deleteNotification(notificationId);
    await loadNotifications();
  }
} 