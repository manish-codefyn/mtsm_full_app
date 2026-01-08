import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';

final communicationsDashboardRepositoryProvider = Provider((ref) => CommunicationsDashboardRepository(ref));

class CommunicationsDashboardRepository {
  final Ref _ref;

  CommunicationsDashboardRepository(this._ref);

  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final client = _ref.read(apiClientProvider).client;
      final response = await client.get('communications/dashboard/');
      return response.data;
    } catch (e) {
      rethrow;
    }
  }
}

final communicationsDashboardStatsProvider = FutureProvider.autoDispose((ref) async {
  return ref.watch(communicationsDashboardRepositoryProvider).getDashboardStats();
});
