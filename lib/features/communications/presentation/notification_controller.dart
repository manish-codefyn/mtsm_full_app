import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/notification_repository.dart';

// 1. Data Provider (Same pattern as Dashboard)
final notificationsProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final repository = ref.read(notificationRepositoryProvider);
  return repository.getNotifications();
});

// 2. Controller for Actions
final notificationControllerProvider = Provider((ref) {
  return NotificationController(ref);
});

class NotificationController {
  final Ref _ref;
  
  NotificationController(this._ref);

  Future<void> markAsRead(String id) async {
    final repository = _ref.read(notificationRepositoryProvider);
    await repository.markAsRead(id);
    // Refresh the list
    _ref.invalidate(notificationsProvider);
  }

  Future<void> markAllAsRead() async {
    final repository = _ref.read(notificationRepositoryProvider);
    await repository.markAllAsRead();
    // Refresh the list
    _ref.invalidate(notificationsProvider);
  }
}
