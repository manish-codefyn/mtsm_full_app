import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/attendance_repository.dart';
import '../data/models/attendance.dart';

final attendanceListProvider = FutureProvider<List<StudentAttendance>>((ref) async {
  final repository = ref.watch(attendanceRepositoryProvider);
  return repository.getRecentAttendance();
});
