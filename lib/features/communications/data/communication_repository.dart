import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';

final communicationRepositoryProvider = Provider((ref) => CommunicationRepository(ref));

final notificationsProvider = FutureProvider.autoDispose((ref) async {
  return ref.read(communicationRepositoryProvider).getNotifications();
});

class CommunicationRepository {
  final Ref _ref;

  CommunicationRepository(this._ref);

  Dio get _dio => _ref.read(apiClientProvider).client;

  // Dashboard Stats
  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final response = await _dio.get('communications/dashboard/');
      return response.data;
    } catch (e) {
      print('Error fetching communication stats: $e');
      return {};
    }
  }

  // Notifications
  Future<List<dynamic>> getNotifications({bool unreadOnly = false}) async {
    try {
      final response = await _dio.get('communications/notifications/', 
        queryParameters: unreadOnly ? {'is_read': false} : null
      );
      if (response.data is List) {
        return response.data;
      } else if (response.data is Map && response.data.containsKey('results')) {
        return response.data['results'];
      }
      return [];
    } catch (e) {
      print('Error fetching notifications: $e');
      return [];
    }
  }

  Future<void> markAllNotificationsRead() async {
    try {
      await _dio.post('communications/notifications/mark-all-read/');
    } catch (e) {
      print('Error marking notifications read: $e');
    }
  }

  // Messaging (Threads)
  Future<List<dynamic>> getThreads() async {
    try {
      final response = await _dio.get('communications/threads/');
      if (response.data is List) {
        return response.data;
      } else if (response.data is Map && response.data.containsKey('results')) {
        return response.data['results'];
      }
      return [];
    } catch (e) {
      print('Error fetching threads: $e');
      return [];
    }
  }

  Future<List<dynamic>> getThreadMessages(String threadId) async {
    try {
      final response = await _dio.get('communications/threads/$threadId/messages/');
      if (response.data is List) {
        return response.data;
      } else if (response.data is Map && response.data.containsKey('results')) {
        return response.data['results'];
      }
      return [];
    } catch (e) {
      print('Error fetching messages: $e');
      return [];
    }
  }

  Future<List<dynamic>> getUsers() async {
    try {
      final response = await _dio.get('users/');
      if (response.data is List) {
        return response.data;
      } else if (response.data is Map && response.data.containsKey('results')) {
        return response.data['results'];
      }
      return [];
    } catch (e) {
      print('Error fetching users: $e');
      return [];
    }
  }

  Future<void> createThread(String title, List<String> participantIds, String initialMessage) async {
    try {
      // 1. Create Thread
      final threadResponse = await _dio.post('communications/threads/', data: {
        'title': title,
        'participants': participantIds,
        'is_active': true
      });

      final threadId = threadResponse.data['id'];

      // 2. Send Initial Message
      if (initialMessage.isNotEmpty && threadId != null) {
        await sendMessage(threadId.toString(), initialMessage, subject: title);
      }
    } catch (e) {
      print('Error creating thread: $e');
      rethrow;
    }
  }

  Future<void> sendMessage(String threadId, String content, {String subject = 'New Message'}) async {
     try {
      await _dio.post('communications/threads/$threadId/messages/', data: {
        'body': content, 
        'subject': subject,
        'message_type': 'MESSAGE', // Changed to MESSAGE as per choices
        'priority': 'NORMAL' // Changed from MEDIUM to NORMAL
      });
    } catch (e) {
      print('Error sending message: $e');
      rethrow;
    }
  }
}
