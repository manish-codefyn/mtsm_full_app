import 'package:json_annotation/json_annotation.dart';

part 'student_medical_info.g.dart';

@JsonSerializable()
class StudentMedicalInfo {
  final String? id;
  final String? student; // Student ID, nullable in OneToOne reverse sometimes
  @JsonKey(name: 'blood_group')
  final String? bloodGroup;
  @JsonKey(name: 'height_cm')
  final double? heightCm;
  @JsonKey(name: 'weight_kg')
  final double? weightKg;
  final double? bmi;
  
  @JsonKey(name: 'known_allergies')
  final String? knownAllergies;
  @JsonKey(name: 'chronic_conditions')
  final String? chronicConditions;
  @JsonKey(name: 'current_medications')
  final String? currentMedications;
  @JsonKey(name: 'dietary_restrictions')
  final String? dietaryRestrictions;
  
  @JsonKey(name: 'has_disability')
  final bool hasDisability;
  @JsonKey(name: 'disability_type')
  final String? disabilityType;
  @JsonKey(name: 'disability_percentage')
  final int? disabilityPercentage;
  @JsonKey(name: 'disability_certificate_number')
  final String? disabilityCertificateNumber;
  
  @JsonKey(name: 'vaccination_records')
  final Map<String, dynamic>? vaccinationRecords;
  
  @JsonKey(name: 'emergency_contact_name')
  final String? emergencyContactName;
  @JsonKey(name: 'emergency_contact_relation')
  final String? emergencyContactRelation;
  @JsonKey(name: 'emergency_contact_phone')
  final String? emergencyContactPhone;
  @JsonKey(name: 'emergency_contact_alt_phone')
  final String? emergencyContactAltPhone;
  
  @JsonKey(name: 'has_medical_insurance')
  final bool hasMedicalInsurance;
  @JsonKey(name: 'insurance_provider')
  final String? insuranceProvider;
  @JsonKey(name: 'insurance_policy_number')
  final String? insurancePolicyNumber;
  @JsonKey(name: 'insurance_valid_until')
  final String? insuranceValidUntil;
  
  @JsonKey(name: 'special_instructions')
  final String? specialInstructions;
  @JsonKey(name: 'last_medical_checkup')
  final String? lastMedicalCheckup;

  StudentMedicalInfo({
    this.id,
    this.student,
    this.bloodGroup,
    this.heightCm,
    this.weightKg,
    this.bmi,
    this.knownAllergies,
    this.chronicConditions,
    this.currentMedications,
    this.dietaryRestrictions,
    this.hasDisability = false,
    this.disabilityType,
    this.disabilityPercentage,
    this.disabilityCertificateNumber,
    this.vaccinationRecords,
    this.emergencyContactName,
    this.emergencyContactRelation,
    this.emergencyContactPhone,
    this.emergencyContactAltPhone,
    this.hasMedicalInsurance = false,
    this.insuranceProvider,
    this.insurancePolicyNumber,
    this.insuranceValidUntil,
    this.specialInstructions,
    this.lastMedicalCheckup,
  });

  factory StudentMedicalInfo.fromJson(Map<String, dynamic> json) => _$StudentMedicalInfoFromJson(json);
  Map<String, dynamic> toJson() => _$StudentMedicalInfoToJson(this);
}
