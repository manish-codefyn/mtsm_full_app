import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';

final eventsDashboardRepositoryProvider = Provider((ref) => EventsDashboardRepository(ref));

class EventsDashboardRepository {
  final Ref _ref;

  EventsDashboardRepository(this._ref);

  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final client = _ref.read(apiClientProvider).client;
      final response = await client.get('events/dashboard/');
      return response.data;
    } catch (e) {
      rethrow;
    }
  }
}

final eventsDashboardStatsProvider = FutureProvider.autoDispose((ref) async {
  return ref.watch(eventsDashboardRepositoryProvider).getDashboardStats();
});
