import '../models/notification.dart';
import '../services/notification_service.dart';
import '../../domain/repositories/notification_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationService _notificationService;

  NotificationRepositoryImpl(this._notificationService);

  @override
  Future<List<AppNotification>> listNotifications() =>
      _notificationService.listNotifications();

  @override
  Future<void> markAsRead(String notificationId) =>
      _notificationService.markAsRead(notificationId);

  @override
  Future<void> markAllAsRead() => _notificationService.markAllAsRead();
}
