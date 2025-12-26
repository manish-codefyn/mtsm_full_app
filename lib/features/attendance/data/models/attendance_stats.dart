class AttendanceStats {
  final int total;
  final int present;
  final int absent;
  final int late;
  final double percentage;

  AttendanceStats({
    required this.total,
    required this.present,
    required this.absent,
    required this.late,
    required this.percentage,
  });

  factory AttendanceStats.fromJson(Map<String, dynamic> json) {
    return AttendanceStats(
      total: json['total'] ?? 0,
      present: json['present'] ?? 0,
      absent: json['absent'] ?? 0,
      late: json['late'] ?? 0,
      percentage: (json['percentage'] ?? 0.0).toDouble(),
    );
  }

  factory AttendanceStats.empty() {
    return AttendanceStats(
      total: 0,
      present: 0,
      absent: 0,
      late: 0,
      percentage: 0.0,
    );
  }
}
