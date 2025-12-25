import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import 'models/staff.dart';

final hrRepositoryProvider = Provider((ref) => HRRepository(ref));

class HRRepository {
  final Ref _ref;

  HRRepository(this._ref);

  Future<List<Staff>> getStaffList() async {
    final dio = _ref.read(apiClientProvider).client;
    final response = await dio.get('hr/staffs/'); 
    
    final data = response.data;
    final List<dynamic> results = (data is Map && data.containsKey('results')) 
        ? data['results'] 
        : (data is List ? data : []);

    return results.map((json) => Staff.fromJson(json)).toList();
  }
}
