import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';

final staffDashboardRepositoryProvider = Provider((ref) => StaffDashboardRepository(ref));

class StaffDashboardRepository {
  final Ref _ref;

  StaffDashboardRepository(this._ref);

  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final client = _ref.read(apiClientProvider).client;
      final response = await client.get('hr/dashboard/');
      return response.data;
    } catch (e) {
      rethrow;
    }
  }
}

final staffDashboardStatsProvider = FutureProvider.autoDispose((ref) async {
  return ref.watch(staffDashboardRepositoryProvider).getDashboardStats();
});
