import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import 'models/fee_structure.dart';

final financeRepositoryProvider = Provider((ref) => FinanceRepository(ref));

class FinanceRepository {
  final Ref _ref;

  FinanceRepository(this._ref);

  Future<List<FeeStructure>> getFeeStructures() async {
    final dio = _ref.read(apiClientProvider).client;
    final response = await dio.get('finance/feestructures/');
    
    final data = response.data;
    final List<dynamic> results = (data is Map && data.containsKey('results')) 
        ? data['results'] 
        : (data is List ? data : []);

    return results.map((json) => FeeStructure.fromJson(json)).toList();
  }
}
