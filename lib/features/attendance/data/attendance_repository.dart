import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';

final attendanceRepositoryProvider = Provider<AttendanceRepository>((ref) {
  return AttendanceRepository(ref.read(apiClientProvider));
});

class AttendanceRepository {
  final ApiClient _apiClient;

  AttendanceRepository(this._apiClient);

  Future<List<Map<String, dynamic>>> getStudentAttendance(String studentId) async {
    try {
      final response = await _apiClient.get('/academics/attendance/', queryParameters: {
        'student': studentId
      });
      
      // Check if response data is list or paginated
      if (response.data is List) {
        return List<Map<String, dynamic>>.from(response.data);
      } else if (response.data is Map && response.data.containsKey('results')) {
        return List<Map<String, dynamic>>.from(response.data['results']);
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch attendance: $e');
    }
  }

  Future<Map<String, dynamic>> getDashboardData() async {
    try {
      final response = await _apiClient.get('/academics/dashboard/');
      return response.data;
    } catch (e) {
      throw Exception('Failed to fetch dashboard data: $e');
    }
  }

  Future<Map<String, dynamic>> markQRAttendance({
    required String qrText,
    required String type,
    String? tripType,
  }) async {
    try {
      final response = await _apiClient.post('/academics/attendance/qr/', data: {
        'qr_text': qrText,
        'type': type,
        if (tripType != null) 'trip_type': tripType,
      });
      return response.data;
    } catch (e) {
      throw Exception('Failed to mark QR attendance: $e');
    }
  }

  Future<Map<String, dynamic>> markFaceAttendance({
    required String imageBase64,
    required String type,
    String? tripType,
  }) async {
    try {
      final response = await _apiClient.post('/academics/attendance/face/', data: {
        'image': imageBase64,
        'type': type,
        if (tripType != null) 'trip_type': tripType,
      });
      return response.data;
    } catch (e) {
      throw Exception('Failed to mark face attendance: $e');
    }
  }
}
