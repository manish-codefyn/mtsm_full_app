// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'guardian.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Guardian _$GuardianFromJson(Map<String, dynamic> json) => Guardian(
  id: json['id'] as String?,
  student: json['student'] as String,
  relation: json['relation'] as String,
  fullName: json['full_name'] as String,
  dateOfBirth: json['date_of_birth'] as String?,
  email: json['email'] as String?,
  phonePrimary: json['phone_primary'] as String,
  phoneSecondary: json['phone_secondary'] as String?,
  occupation: json['occupation'] as String?,
  qualification: json['qualification'] as String?,
  companyName: json['company_name'] as String?,
  designation: json['designation'] as String?,
  annualIncome: (json['annual_income'] as num?)?.toDouble(),
  isPrimary: json['is_primary'] as bool? ?? false,
  isEmergencyContact: json['is_emergency_contact'] as bool? ?? false,
  canPickup: json['can_pickup'] as bool? ?? true,
  aadhaarNumber: json['aadhaar_number'] as String?,
  panNumber: json['pan_number'] as String?,
);

Map<String, dynamic> _$GuardianToJson(Guardian instance) => <String, dynamic>{
  'id': instance.id,
  'student': instance.student,
  'relation': instance.relation,
  'full_name': instance.fullName,
  'date_of_birth': instance.dateOfBirth,
  'email': instance.email,
  'phone_primary': instance.phonePrimary,
  'phone_secondary': instance.phoneSecondary,
  'occupation': instance.occupation,
  'qualification': instance.qualification,
  'company_name': instance.companyName,
  'designation': instance.designation,
  'annual_income': instance.annualIncome,
  'is_primary': instance.isPrimary,
  'is_emergency_contact': instance.isEmergencyContact,
  'can_pickup': instance.canPickup,
  'aadhaar_number': instance.aadhaarNumber,
  'pan_number': instance.panNumber,
};
