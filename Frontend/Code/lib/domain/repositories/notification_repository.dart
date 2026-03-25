import '../../data/models/notification.dart';

abstract class NotificationRepository {
  Future<List<AppNotification>> listNotifications();
  Future<void> markAsRead(String notificationId);
  Future<void> markAllAsRead();
}
