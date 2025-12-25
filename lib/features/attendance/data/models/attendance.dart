class StudentAttendance {
  final String id;
  final String studentName;
  final String date;
  final String status;
  final String className;

  StudentAttendance({
    required this.id,
    required this.studentName,
    required this.date,
    required this.status,
    required this.className,
  });

  factory StudentAttendance.fromJson(Map<String, dynamic> json) {
    return StudentAttendance(
      id: json['id']?.toString() ?? '',
      studentName: json['student_name'] ?? json['student']?['full_name'] ?? 'Unknown',
      date: json['date'] ?? '',
      status: json['status'] ?? 'ABSENT',
      className: json['class_name']?.toString() ?? '',
    );
  }
}
