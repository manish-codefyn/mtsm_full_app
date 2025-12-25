import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import 'models/route.dart';

final transportRepositoryProvider = Provider((ref) => TransportRepository(ref));

class TransportRepository {
  final Ref _ref;

  TransportRepository(this._ref);

  Future<List<TransportRoute>> getRoutes() async {
    final dio = _ref.read(apiClientProvider).client;
    final response = await dio.get('transportation/routes/'); // Adjust endpoint
    
    final data = response.data;
    final List<dynamic> results = (data is Map && data.containsKey('results')) 
        ? data['results'] 
        : (data is List ? data : []);

    return results.map((json) => TransportRoute.fromJson(json)).toList();
  }
}
