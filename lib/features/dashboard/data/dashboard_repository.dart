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
      _fetchCount(dio, 'students/'), // Corrected endpoint
      _fetchCount(dio, 'hr/staff/'),
      _fetchTotalFees(dio),
      _fetchTenantInfo(dio),
      _fetchUserProfile(dio),
    ]);

    return {
      'studentCount': results[0],
      'staffCount': results[1],
      'feeCollection': results[2],
      'tenantName': results[3],
      'userProfile': results[4],
    };
  }

  Future<Map<String, dynamic>> _fetchUserProfile(Dio dio) async {
    try {
      final response = await dio.get('users/me/'); 
      if (response.statusCode == 200) {
        return response.data;
      }
      return {'first_name': 'Admin', 'last_name': 'User', 'avatar': null};
    } catch (e) {
      return {'first_name': 'Admin', 'last_name': 'User', 'avatar': null};
    }
  }

  Future<String> _fetchTenantInfo(Dio dio) async {
    try {
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
      if (response.statusCode == 200 && response.data is Map) {
        return response.data['count'] ?? 0;
      }
      return 0;
    } catch (e) {
      print('Error fetching count for $endpoint: $e');
      return 0;
    }
  }

  Future<String> _fetchTotalFees(Dio dio) async {
    try {
      final response = await dio.get('finance/dashboard/');
      if (response.statusCode == 200 && response.data is Map) {
        final stats = response.data['stats'] as List?;
        if (stats != null) {
          final totalCollected = stats.firstWhere(
            (s) => s['label'] == 'Total Collected',
            orElse: () => {'value': '₹0'},
          );
          return totalCollected['value']?.toString() ?? '₹0';
        }
      }
      return "₹0"; 
    } catch (e) {
      print('Error fetching fees: $e');
      return "₹0";
    }
  }
}
