// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'student.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Student _$StudentFromJson(Map<String, dynamic> json) => Student(
  id: json['id'] as String?,
  firstName: json['first_name'] as String,
  lastName: json['last_name'] as String,
  admissionNumber: json['admission_number'] as String?,
  email: json['personal_email'] as String?,
  mobilePrimary: json['mobile_primary'] as String?,
  gender: json['gender'] as String?,
  dateOfBirth: json['date_of_birth'] as String?,
  academicYear: json['academic_year'] as String?,
);

Map<String, dynamic> _$StudentToJson(Student instance) => <String, dynamic>{
  'id': instance.id,
  'first_name': instance.firstName,
  'last_name': instance.lastName,
  'admission_number': instance.admissionNumber,
  'personal_email': instance.email,
  'mobile_primary': instance.mobilePrimary,
  'gender': instance.gender,
  'date_of_birth': instance.dateOfBirth,
  'academic_year': instance.academicYear,
};
