import 'package:json_annotation/json_annotation.dart';

part 'admission_application.g.dart';

@JsonSerializable(explicitToJson: true)
class AdmissionApplication {
  final String? id;
  
  @JsonKey(name: 'application_number')
  final String? applicationNumber;
  
  @JsonKey(name: 'first_name')
  final String firstName;
  
  @JsonKey(name: 'last_name')
  final String lastName;
  
  final String? email;
  final String? phone;
  
  @JsonKey(name: 'status')
  final String? status;

  @JsonKey(name: 'submission_date')
  final String? submissionDate;

  @JsonKey(name: 'program')
  final String? program; 
  
  @JsonKey(name: 'program_detail')
  final Map<String, dynamic>? programDetail;
  
  @JsonKey(name: 'formatted_address')
  final String? formattedAddress;

  AdmissionApplication({
    this.id,
    this.applicationNumber,
    required this.firstName,
    required this.lastName,
    this.email,
    this.phone,
    this.status,
    this.submissionDate,
    this.program,
    this.programDetail,
    this.formattedAddress,
  });

  factory AdmissionApplication.fromJson(Map<String, dynamic> json) => _$AdmissionApplicationFromJson(json);
  Map<String, dynamic> toJson() => _$AdmissionApplicationToJson(this);
  
  String get fullName => '$firstName $lastName';
}
