import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';

final assignmentsDashboardRepositoryProvider = Provider((ref) => AssignmentsDashboardRepository(ref));

class AssignmentsDashboardRepository {
  final Ref _ref;

  AssignmentsDashboardRepository(this._ref);

  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final client = _ref.read(apiClientProvider).client;
      final response = await client.get('assignments/dashboard/');
      return response.data;
    } catch (e) {
      rethrow;
    }
  }
}

final assignmentsDashboardStatsProvider = FutureProvider.autoDispose((ref) async {
  return ref.watch(assignmentsDashboardRepositoryProvider).getDashboardStats();
});
