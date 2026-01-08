import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';

final financeDashboardRepositoryProvider = Provider((ref) => FinanceDashboardRepository(ref));

class FinanceDashboardRepository {
  final Ref _ref;

  FinanceDashboardRepository(this._ref);

  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final client = _ref.read(apiClientProvider).client;
      final response = await client.get('finance/dashboard/');
      return response.data;
    } catch (e) {
      rethrow;
    }
  }
}

final financeDashboardStatsProvider = FutureProvider.autoDispose((ref) async {
  return ref.watch(financeDashboardRepositoryProvider).getDashboardStats();
});
