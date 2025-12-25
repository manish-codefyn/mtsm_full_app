import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import 'models/attendance.dart';

final attendanceRepositoryProvider = Provider((ref) => AttendanceRepository(ref));

class AttendanceRepository {
  final Ref _ref;

  AttendanceRepository(this._ref);

  Future<List<StudentAttendance>> getRecentAttendance() async {
    final dio = _ref.read(apiClientProvider).client;
    final response = await dio.get('academics/studentattendances/');
    
    final data = response.data;
    final List<dynamic> results = (data is Map && data.containsKey('results')) 
        ? data['results'] 
        : (data is List ? data : []);

    return results.map((json) => StudentAttendance.fromJson(json)).toList();
  }
}
