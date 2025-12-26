import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import 'models/attendance.dart';
import 'models/attendance_stats.dart';

final attendanceRepositoryProvider = Provider((ref) => AttendanceRepository(ref));

class AttendanceRepository {
  final Ref _ref;

  AttendanceRepository(this._ref);

  /// Get comprehensive dashboard data (stats + recent + quick actions)
  Future<Map<String, dynamic>> getDashboardData() async {
    final dio = _ref.read(apiClientProvider).client;
    try {
      final response = await dio.get('attendance/dashboard/');
      return response.data;
    } catch (e) {
      print('Error fetching dashboard data: $e');
      // Return empty dashboard on error
      return {
        'stats': {
          'student': {'total': 0, 'present': 0, 'absent': 0, 'late': 0, 'percentage': 0.0},
          'staff': {'total': 0, 'present': 0, 'absent': 0, 'late': 0, 'percentage': 0.0},
          'hostel': {'total': 0, 'present': 0, 'absent': 0, 'late': 0, 'percentage': 0.0},
          'transport': {'total': 0, 'present': 0, 'absent': 0, 'late': 0, 'percentage': 0.0},
        },
        'quick_actions': {},
        'recent_attendance': [],
      };
    }
  }

  /// Get attendance statistics for today (legacy - use dashboard instead)
  Future<AttendanceStats> getAttendanceStats({String? date, String type = 'student'}) async {
    final dio = _ref.read(apiClientProvider).client;
    try {
      final response = await dio.get(
        'attendance/stats/',
        queryParameters: {
          if (date != null) 'date': date,
          'type': type,
        },
      );
      return AttendanceStats.fromJson(response.data);
    } catch (e) {
      // Return empty stats on error
      return AttendanceStats.empty();
    }
  }

  /// Mark attendance via QR code
  Future<Map<String, dynamic>> markQRAttendance({
    required String qrText,
    required String type,
    String? tripType,
  }) async {
    final dio = _ref.read(apiClientProvider).client;
    final response = await dio.post(
      'attendance/mark-qr/',
      data: {
        'qr_text': qrText,
        'type': type,
        if (tripType != null) 'trip_type': tripType,
      },
    );
    return response.data;
  }

  /// Mark attendance via face recognition
  Future<Map<String, dynamic>> markFaceAttendance({
    required String imageBase64,
    required String type,
    String? tripType,
  }) async {
    final dio = _ref.read(apiClientProvider).client;
    try {
      print('Marking face attendance: type=$type, tripType=$tripType');
      final response = await dio.post(
        'attendance/mark-face/',
        data: {
          'image': imageBase64,
          'type': type,
          if (tripType != null) 'trip_type': tripType,
        },
      );
      print('Face attendance response: ${response.data}');
      return response.data;
    } catch (e) {
      print('Face attendance error: $e');
      rethrow;
    }
  }

  /// Get students by class for manual marking
  Future<List<Map<String, dynamic>>> getStudentsByClass({
    required String classId,
    String? sectionId,
  }) async {
    final dio = _ref.read(apiClientProvider).client;
    final response = await dio.get(
      'attendance/students-by-class/',
      queryParameters: {
        'class_id': classId,
        if (sectionId != null) 'section_id': sectionId,
      },
    );
    
    final data = response.data;
    return List<Map<String, dynamic>>.from(data['students'] ?? []);
  }

  /// Bulk update attendance
  Future<Map<String, dynamic>> bulkUpdateAttendance({
    required List<Map<String, dynamic>> attendanceData,
  }) async {
    final dio = _ref.read(apiClientProvider).client;
    final response = await dio.post(
      'attendance/bulk-update/',
      data: {'attendance': attendanceData},
    );
    return response.data;
  }

  /// Get attendance history with filters
  Future<List<Attendance>> getAttendanceHistory({
    String? startDate,
    String? endDate,
    String? type,
    String? studentId,
  }) async {
    final dio = _ref.read(apiClientProvider).client;
    final response = await dio.get(
      'attendance/history/',
      queryParameters: {
        if (startDate != null) 'start_date': startDate,
        if (endDate != null) 'end_date': endDate,
        if (type != null) 'type': type,
        if (studentId != null) 'student_id': studentId,
      },
    );
    
    final data = response.data;
    final List<dynamic> results = (data is Map && data.containsKey('results')) 
        ? data['results'] 
        : (data is List ? data : []);

    return results.map((json) => Attendance.fromJson(json)).toList();
  }
}
