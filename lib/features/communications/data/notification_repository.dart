import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepository(ref.read(apiClientProvider));
});

class NotificationRepository {
  final ApiClient _apiClient;

  NotificationRepository(this._apiClient);

  Future<List<Map<String, dynamic>>> getNotifications() async {
    try {
      final response = await _apiClient.get('/communications/notifications/');
      final data = response.data;
      if (data is List) {
        return List<Map<String, dynamic>>.from(data);
      } else if (data is Map && data.containsKey('results')) {
         return List<Map<String, dynamic>>.from(data['results']);
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch notifications: $e');
    }
  }

  Future<void> markAsRead(String id) async {
    await _apiClient.patch('/communications/notifications/$id/', data: {'is_read': true});
  }

  Future<void> markAllAsRead() async {
    await _apiClient.post('/communications/notifications/mark-all-read/', data: {});
  }
}
