// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'student_academic_history.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StudentAcademicHistory _$StudentAcademicHistoryFromJson(
  Map<String, dynamic> json,
) => StudentAcademicHistory(
  id: json['id'] as String?,
  student: json['student'] as String,
  academicYear: json['academic_year'] as String,
  className: json['class_name'] as String,
  section: json['section'] as String,
  rollNumber: json['roll_number'] as String,
  overallGrade: json['overall_grade'] as String?,
  percentage: (json['percentage'] as num?)?.toDouble(),
  result: json['result'] as String? ?? 'APPEARING',
  remarks: json['remarks'] as String?,
);

Map<String, dynamic> _$StudentAcademicHistoryToJson(
  StudentAcademicHistory instance,
) => <String, dynamic>{
  'id': instance.id,
  'student': instance.student,
  'academic_year': instance.academicYear,
  'class_name': instance.className,
  'section': instance.section,
  'roll_number': instance.rollNumber,
  'overall_grade': instance.overallGrade,
  'percentage': instance.percentage,
  'result': instance.result,
  'remarks': instance.remarks,
};
