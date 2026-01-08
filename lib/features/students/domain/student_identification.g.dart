// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'student_identification.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StudentIdentification _$StudentIdentificationFromJson(
  Map<String, dynamic> json,
) => StudentIdentification(
  id: json['id'] as String?,
  student: json['student'] as String?,
  aadhaarNumber: json['aadhaar_number'] as String?,
  panNumber: json['pan_number'] as String?,
  passportNumber: json['passport_number'] as String?,
  drivingLicense: json['driving_license'] as String?,
  voterId: json['voter_id'] as String?,
  abcId: json['abc_id'] as String?,
  shikshaId: json['shiksha_id'] as String?,
  udiseId: json['udise_id'] as String?,
  bankAccountNumber: json['bank_account_number'] as String?,
  bankName: json['bank_name'] as String?,
  bankBranch: json['bank_branch'] as String?,
  ifscCode: json['ifsc_code'] as String?,
  aadhaarVerified: json['aadhaar_verified'] as bool? ?? false,
  panVerified: json['pan_verified'] as bool? ?? false,
  passportVerified: json['passport_verified'] as bool? ?? false,
  socialSecurityNumber: json['social_security_number'] as String?,
  nationalInsuranceNumber: json['national_insurance_number'] as String?,
);

Map<String, dynamic> _$StudentIdentificationToJson(
  StudentIdentification instance,
) => <String, dynamic>{
  'id': instance.id,
  'student': instance.student,
  'aadhaar_number': instance.aadhaarNumber,
  'pan_number': instance.panNumber,
  'passport_number': instance.passportNumber,
  'driving_license': instance.drivingLicense,
  'voter_id': instance.voterId,
  'abc_id': instance.abcId,
  'shiksha_id': instance.shikshaId,
  'udise_id': instance.udiseId,
  'bank_account_number': instance.bankAccountNumber,
  'bank_name': instance.bankName,
  'bank_branch': instance.bankBranch,
  'ifsc_code': instance.ifscCode,
  'aadhaar_verified': instance.aadhaarVerified,
  'pan_verified': instance.panVerified,
  'passport_verified': instance.passportVerified,
  'social_security_number': instance.socialSecurityNumber,
  'national_insurance_number': instance.nationalInsuranceNumber,
};
