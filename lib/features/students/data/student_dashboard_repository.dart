import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';

final studentDashboardRepositoryProvider = Provider((ref) => StudentDashboardRepository(ref));

class StudentDashboardRepository {
  final Ref _ref;

  StudentDashboardRepository(this._ref);

  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final client = _ref.read(apiClientProvider).client;
      final response = await client.get('students/dashboard/');
      return response.data;
    } catch (e) {
      rethrow;
    }
  }
}

final studentDashboardStatsProvider = FutureProvider.autoDispose((ref) async {
  return ref.watch(studentDashboardRepositoryProvider).getDashboardStats();
});
