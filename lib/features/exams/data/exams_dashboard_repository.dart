import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';

final examsDashboardRepositoryProvider = Provider((ref) => ExamsDashboardRepository(ref));

class ExamsDashboardRepository {
  final Ref _ref;

  ExamsDashboardRepository(this._ref);

  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final client = _ref.read(apiClientProvider).client;
      final response = await client.get('exams/dashboard/');
      return response.data;
    } catch (e) {
      rethrow;
    }
  }
}

final examsDashboardStatsProvider = FutureProvider.autoDispose((ref) async {
  return ref.watch(examsDashboardRepositoryProvider).getDashboardStats();
});
