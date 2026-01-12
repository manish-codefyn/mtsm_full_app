import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/attendance_repository.dart';

final studentAttendanceProvider = FutureProvider.family<List<Map<String, dynamic>>, String>((ref, studentId) async {
  final repository = ref.read(attendanceRepositoryProvider);
  return repository.getStudentAttendance(studentId);
});
