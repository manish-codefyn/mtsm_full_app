import 'package:json_annotation/json_annotation.dart';

part 'student_academic_history.g.dart';

@JsonSerializable()
class StudentAcademicHistory {
  final String? id;
  final String student; 
  @JsonKey(name: 'academic_year')
  final String academicYear; // ID or Name depending on serializer
  @JsonKey(name: 'class_name')
  final String className; // ID or Name
  final String section; // ID or Name
  @JsonKey(name: 'roll_number')
  final String rollNumber;
  @JsonKey(name: 'overall_grade')
  final String? overallGrade;
  final double? percentage;
  final String result; // PASS, FAIL, etc.
  final String? remarks;

  StudentAcademicHistory({
    this.id,
    required this.student,
    required this.academicYear,
    required this.className,
    required this.section,
    required this.rollNumber,
    this.overallGrade,
    this.percentage,
    this.result = 'APPEARING',
    this.remarks,
  });

  factory StudentAcademicHistory.fromJson(Map<String, dynamic> json) => _$StudentAcademicHistoryFromJson(json);
  Map<String, dynamic> toJson() => _$StudentAcademicHistoryToJson(this);
}
