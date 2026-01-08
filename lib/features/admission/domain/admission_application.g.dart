// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admission_application.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdmissionApplication _$AdmissionApplicationFromJson(
  Map<String, dynamic> json,
) => AdmissionApplication(
  id: json['id'] as String?,
  applicationNumber: json['application_number'] as String?,
  firstName: json['first_name'] as String,
  lastName: json['last_name'] as String,
  email: json['email'] as String?,
  phone: json['phone'] as String?,
  status: json['status'] as String?,
  submissionDate: json['submission_date'] as String?,
  program: json['program'] as String?,
  programDetail: json['program_detail'] as Map<String, dynamic>?,
  formattedAddress: json['formatted_address'] as String?,
);

Map<String, dynamic> _$AdmissionApplicationToJson(
  AdmissionApplication instance,
) => <String, dynamic>{
  'id': instance.id,
  'application_number': instance.applicationNumber,
  'first_name': instance.firstName,
  'last_name': instance.lastName,
  'email': instance.email,
  'phone': instance.phone,
  'status': instance.status,
  'submission_date': instance.submissionDate,
  'program': instance.program,
  'program_detail': instance.programDetail,
  'formatted_address': instance.formattedAddress,
};
