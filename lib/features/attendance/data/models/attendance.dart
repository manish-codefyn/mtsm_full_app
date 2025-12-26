class Attendance {
  final String id;
  final String type; // student, staff, hostel, transport
  final String? studentId;
  final String? staffId;
  final String studentName;
  final String date;
  final String status;
  final String className;
  final String? tripType; // for transport: PICKUP/DROP
  final String? checkInTime;
  final String? checkOutTime;
  final String? remarks;
  final String? photoUrl;
  final String? markedBy;

  Attendance({
    required this.id,
    required this.type,
    this.studentId,
    this.staffId,
    required this.studentName,
    required this.date,
    required this.status,
    required this.className,
    this.tripType,
    this.checkInTime,
    this.checkOutTime,
    this.remarks,
    this.photoUrl,
    this.markedBy,
  });

  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      id: json['id']?.toString() ?? '',
      type: json['type'] ?? 'student',
      studentId: json['student_id']?.toString(),
      staffId: json['staff_id']?.toString(),
      studentName: json['student_name'] ?? 
                   json['student']?['full_name'] ?? 
                   json['staff_name'] ?? 
                   json['staff']?['full_name'] ?? 
                   'Unknown',
      date: json['date'] ?? '',
      status: json['status'] ?? 'ABSENT',
      className: json['class_name']?.toString() ?? '',
      tripType: json['trip_type'],
      checkInTime: json['check_in_time'] ?? json['check_in'],
      checkOutTime: json['check_out_time'] ?? json['check_out'],
      remarks: json['remarks'],
      photoUrl: json['photo_url'],
      markedBy: json['marked_by'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'student_id': studentId,
      'staff_id': staffId,
      'student_name': studentName,
      'date': date,
      'status': status,
      'class_name': className,
      'trip_type': tripType,
      'check_in_time': checkInTime,
      'check_out_time': checkOutTime,
      'remarks': remarks,
      'photo_url': photoUrl,
      'marked_by': markedBy,
    };
  }
}

// Legacy alias for backward compatibility
typedef StudentAttendance = Attendance;
