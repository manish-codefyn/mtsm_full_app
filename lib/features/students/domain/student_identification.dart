import 'package:json_annotation/json_annotation.dart';

part 'student_identification.g.dart';

@JsonSerializable()
class StudentIdentification {
  final String? id;
  final String? student; // Student ID
  
  @JsonKey(name: 'aadhaar_number')
  final String? aadhaarNumber;
  @JsonKey(name: 'pan_number')
  final String? panNumber;
  @JsonKey(name: 'passport_number')
  final String? passportNumber;
  @JsonKey(name: 'driving_license')
  final String? drivingLicense;
  @JsonKey(name: 'voter_id')
  final String? voterId;
  
  @JsonKey(name: 'abc_id')
  final String? abcId;
  @JsonKey(name: 'shiksha_id')
  final String? shikshaId;
  @JsonKey(name: 'udise_id')
  final String? udiseId;
  
  @JsonKey(name: 'bank_account_number')
  final String? bankAccountNumber;
  @JsonKey(name: 'bank_name')
  final String? bankName;
  @JsonKey(name: 'bank_branch')
  final String? bankBranch;
  @JsonKey(name: 'ifsc_code')
  final String? ifscCode;
  
  @JsonKey(name: 'aadhaar_verified')
  final bool aadhaarVerified;
  @JsonKey(name: 'pan_verified')
  final bool panVerified;
  @JsonKey(name: 'passport_verified')
  final bool passportVerified;
  
  @JsonKey(name: 'social_security_number')
  final String? socialSecurityNumber;
  @JsonKey(name: 'national_insurance_number')
  final String? nationalInsuranceNumber;

  StudentIdentification({
    this.id,
    this.student,
    this.aadhaarNumber,
    this.panNumber,
    this.passportNumber,
    this.drivingLicense,
    this.voterId,
    this.abcId,
    this.shikshaId,
    this.udiseId,
    this.bankAccountNumber,
    this.bankName,
    this.bankBranch,
    this.ifscCode,
    this.aadhaarVerified = false,
    this.panVerified = false,
    this.passportVerified = false,
    this.socialSecurityNumber,
    this.nationalInsuranceNumber,
  });

  factory StudentIdentification.fromJson(Map<String, dynamic> json) => _$StudentIdentificationFromJson(json);
  Map<String, dynamic> toJson() => _$StudentIdentificationToJson(this);
}
