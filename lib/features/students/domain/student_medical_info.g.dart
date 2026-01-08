// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'student_medical_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StudentMedicalInfo _$StudentMedicalInfoFromJson(Map<String, dynamic> json) =>
    StudentMedicalInfo(
      id: json['id'] as String?,
      student: json['student'] as String?,
      bloodGroup: json['blood_group'] as String?,
      heightCm: (json['height_cm'] as num?)?.toDouble(),
      weightKg: (json['weight_kg'] as num?)?.toDouble(),
      bmi: (json['bmi'] as num?)?.toDouble(),
      knownAllergies: json['known_allergies'] as String?,
      chronicConditions: json['chronic_conditions'] as String?,
      currentMedications: json['current_medications'] as String?,
      dietaryRestrictions: json['dietary_restrictions'] as String?,
      hasDisability: json['has_disability'] as bool? ?? false,
      disabilityType: json['disability_type'] as String?,
      disabilityPercentage: (json['disability_percentage'] as num?)?.toInt(),
      disabilityCertificateNumber:
          json['disability_certificate_number'] as String?,
      vaccinationRecords: json['vaccination_records'] as Map<String, dynamic>?,
      emergencyContactName: json['emergency_contact_name'] as String?,
      emergencyContactRelation: json['emergency_contact_relation'] as String?,
      emergencyContactPhone: json['emergency_contact_phone'] as String?,
      emergencyContactAltPhone: json['emergency_contact_alt_phone'] as String?,
      hasMedicalInsurance: json['has_medical_insurance'] as bool? ?? false,
      insuranceProvider: json['insurance_provider'] as String?,
      insurancePolicyNumber: json['insurance_policy_number'] as String?,
      insuranceValidUntil: json['insurance_valid_until'] as String?,
      specialInstructions: json['special_instructions'] as String?,
      lastMedicalCheckup: json['last_medical_checkup'] as String?,
    );

Map<String, dynamic> _$StudentMedicalInfoToJson(StudentMedicalInfo instance) =>
    <String, dynamic>{
      'id': instance.id,
      'student': instance.student,
      'blood_group': instance.bloodGroup,
      'height_cm': instance.heightCm,
      'weight_kg': instance.weightKg,
      'bmi': instance.bmi,
      'known_allergies': instance.knownAllergies,
      'chronic_conditions': instance.chronicConditions,
      'current_medications': instance.currentMedications,
      'dietary_restrictions': instance.dietaryRestrictions,
      'has_disability': instance.hasDisability,
      'disability_type': instance.disabilityType,
      'disability_percentage': instance.disabilityPercentage,
      'disability_certificate_number': instance.disabilityCertificateNumber,
      'vaccination_records': instance.vaccinationRecords,
      'emergency_contact_name': instance.emergencyContactName,
      'emergency_contact_relation': instance.emergencyContactRelation,
      'emergency_contact_phone': instance.emergencyContactPhone,
      'emergency_contact_alt_phone': instance.emergencyContactAltPhone,
      'has_medical_insurance': instance.hasMedicalInsurance,
      'insurance_provider': instance.insuranceProvider,
      'insurance_policy_number': instance.insurancePolicyNumber,
      'insurance_valid_until': instance.insuranceValidUntil,
      'special_instructions': instance.specialInstructions,
      'last_medical_checkup': instance.lastMedicalCheckup,
    };
