import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/attendance_repository.dart';
import '../data/models/attendance.dart';

// Use the new dashboard-based providers from attendance_dashboard_controller.dart
// This file is kept for backward compatibility

final attendanceListProvider = FutureProvider<List<Attendance>>((ref) async {
  final repository = ref.watch(attendanceRepositoryProvider);
  // Get data from dashboard API
  final dashboardData = await repository.getDashboardData();
  final recent = dashboardData['recent_attendance'] as List?;
  if (recent != null) {
    return recent.map((json) => Attendance.fromJson(json)).toList();
  }
  return [];
});
