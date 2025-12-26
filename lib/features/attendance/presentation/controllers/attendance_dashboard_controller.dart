import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/attendance.dart';
import '../../data/models/attendance_stats.dart';
import '../../data/attendance_repository.dart';

// Comprehensive Dashboard Provider
final attendanceDashboardProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final repository = ref.watch(attendanceRepositoryProvider);
  return await repository.getDashboardData();
});

// Individual Stats Providers (derived from dashboard)
final studentStatsProvider = Provider<AttendanceStats>((ref) {
  final dashboard = ref.watch(attendanceDashboardProvider);
  return dashboard.when(
    data: (data) {
      final stats = data['stats']?['student'];
      if (stats != null) {
        return AttendanceStats.fromJson(stats);
      }
      return AttendanceStats.empty();
    },
    loading: () => AttendanceStats.empty(),
    error: (_, __) => AttendanceStats.empty(),
  );
});

final staffStatsProvider = Provider<AttendanceStats>((ref) {
  final dashboard = ref.watch(attendanceDashboardProvider);
  return dashboard.when(
    data: (data) {
      final stats = data['stats']?['staff'];
      if (stats != null) {
        return AttendanceStats.fromJson(stats);
      }
      return AttendanceStats.empty();
    },
    loading: () => AttendanceStats.empty(),
    error: (_, __) => AttendanceStats.empty(),
  );
});

final hostelStatsProvider = Provider<AttendanceStats>((ref) {
  final dashboard = ref.watch(attendanceDashboardProvider);
  return dashboard.when(
    data: (data) {
      final stats = data['stats']?['hostel'];
      if (stats != null) {
        return AttendanceStats.fromJson(stats);
      }
      return AttendanceStats.empty();
    },
    loading: () => AttendanceStats.empty(),
    error: (_, __) => AttendanceStats.empty(),
  );
});

final transportStatsProvider = Provider<AttendanceStats>((ref) {
  final dashboard = ref.watch(attendanceDashboardProvider);
  return dashboard.when(
    data: (data) {
      final stats = data['stats']?['transport'];
      if (stats != null) {
        return AttendanceStats.fromJson(stats);
      }
      return AttendanceStats.empty();
    },
    loading: () => AttendanceStats.empty(),
    error: (_, __) => AttendanceStats.empty(),
  );
});

// Recent Attendance Provider (derived from dashboard)
final recentAttendanceProvider = Provider<List<Attendance>>((ref) {
  final dashboard = ref.watch(attendanceDashboardProvider);
  return dashboard.when(
    data: (data) {
      final recent = data['recent_attendance'] as List?;
      if (recent != null) {
        return recent.map((json) => Attendance.fromJson(json)).toList();
      }
      return [];
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

// Legacy providers for backward compatibility
final attendanceStatsProvider = studentStatsProvider;
