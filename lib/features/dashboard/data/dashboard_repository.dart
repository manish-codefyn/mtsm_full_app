import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';

final dashboardRepositoryProvider = Provider((ref) => DashboardRepository(ref));

class DashboardRepository {
  final Ref _ref;

  DashboardRepository(this._ref);

  Future<Map<String, dynamic>> getDashboardStats() async {
    final dio = _ref.read(apiClientProvider).client;
    
    // Execute requests in parallel for performance
    final results = await Future.wait([
      _fetchCount(dio, 'students/students/'),
      _fetchCount(dio, 'hr/staffs/'),
      _fetchTotalFees(dio),
      _fetchTenantInfo(dio),
    ]);

    return {
      'studentCount': results[0],
      'staffCount': results[1],
      'feeCollection': results[2],
      'tenantName': results[3],
    };
  }

  Future<String> _fetchTenantInfo(Dio dio) async {
    try {
      // Use the newly created backend endpoint
      final response = await dio.get('tenants/tenants/current/'); 
      if (response.statusCode == 200) {
        return response.data['name'] ?? 'School ERP'; 
      }
      return 'School ERP';
    } catch (e) {
      print('Error fetching tenant: $e');
      return 'School ERP';
    }
  }

  Future<int> _fetchCount(Dio dio, String endpoint) async {
    try {
      final response = await dio.get(endpoint);
      final data = response.data;
      if (data is Map && data.containsKey('count')) {
        return int.tryParse(data['count'].toString()) ?? 0;
      } else if (data is List) {
        return data.length;
      }
      return 0;
    } catch (e) {
      print('Error fetching count for $endpoint: $e');
      return 0;
    }
  }

  Future<String> _fetchTotalFees(Dio dio) async {
    // For now, mocking fee calculation or fetching from a dedicated endpoint if available
    // Ideally: await dio.get('finance/stats/collection/');
    // Returning a dummy value format as API might not have this aggregation yet
    return "\$45K"; 
  }
}
