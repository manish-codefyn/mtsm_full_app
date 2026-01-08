import 'package:json_annotation/json_annotation.dart';

part 'guardian.g.dart';

@JsonSerializable()
class Guardian {
  final String? id;
  final String student; // Student ID
  final String relation;
  @JsonKey(name: 'full_name')
  final String fullName;
  @JsonKey(name: 'date_of_birth')
  final String? dateOfBirth;
  final String? email;
  @JsonKey(name: 'phone_primary')
  final String phonePrimary;
  @JsonKey(name: 'phone_secondary')
  final String? phoneSecondary;
  final String? occupation;
  final String? qualification;
  @JsonKey(name: 'company_name')
  final String? companyName;
  final String? designation;
  @JsonKey(name: 'annual_income')
  final double? annualIncome;
  
  @JsonKey(name: 'is_primary')
  final bool isPrimary;
  @JsonKey(name: 'is_emergency_contact')
  final bool isEmergencyContact;
  @JsonKey(name: 'can_pickup')
  final bool canPickup;
  
  @JsonKey(name: 'aadhaar_number')
  final String? aadhaarNumber;
  @JsonKey(name: 'pan_number')
  final String? panNumber;

  Guardian({
    this.id,
    required this.student,
    required this.relation,
    required this.fullName,
    this.dateOfBirth,
    this.email,
    required this.phonePrimary,
    this.phoneSecondary,
    this.occupation,
    this.qualification,
    this.companyName,
    this.designation,
    this.annualIncome,
    this.isPrimary = false,
    this.isEmergencyContact = false,
    this.canPickup = true,
    this.aadhaarNumber,
    this.panNumber,
  });

  factory Guardian.fromJson(Map<String, dynamic> json) => _$GuardianFromJson(json);
  Map<String, dynamic> toJson() => _$GuardianToJson(this);
}
