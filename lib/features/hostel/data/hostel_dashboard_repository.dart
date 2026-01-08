import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';

final hostelDashboardRepositoryProvider = Provider((ref) => HostelDashboardRepository(ref));

class HostelDashboardRepository {
  final Ref _ref;

  HostelDashboardRepository(this._ref);

  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final client = _ref.read(apiClientProvider).client;
      final response = await client.get('hostel/dashboard/');
      return response.data;
    } catch (e) {
      rethrow;
    }
  }
}

final hostelDashboardStatsProvider = FutureProvider.autoDispose((ref) async {
  return ref.watch(hostelDashboardRepositoryProvider).getDashboardStats();
});
