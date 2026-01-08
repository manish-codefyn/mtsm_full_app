import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';

final transportDashboardRepositoryProvider = Provider((ref) => TransportDashboardRepository(ref));

class TransportDashboardRepository {
  final Ref _ref;

  TransportDashboardRepository(this._ref);

  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final client = _ref.read(apiClientProvider).client;
      final response = await client.get('transportation/dashboard/');
      return response.data;
    } catch (e) {
      rethrow;
    }
  }
}

final transportDashboardStatsProvider = FutureProvider.autoDispose((ref) async {
  return ref.watch(transportDashboardRepositoryProvider).getDashboardStats();
});
