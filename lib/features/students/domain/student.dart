import 'package:json_annotation/json_annotation.dart';

part 'student.g.dart';

@JsonSerializable()
class Student {
  final String? id; // Made nullable for creation where ID doesn't exist yet
  @JsonKey(name: 'first_name')
  final String firstName;
  @JsonKey(name: 'last_name')
  final String lastName;
  @JsonKey(name: 'admission_number')
  final String? admissionNumber; // Can be null if auto-generated
  @JsonKey(name: 'personal_email')
  final String? email;
  @JsonKey(name: 'mobile_primary')
  final String? mobilePrimary;
  final String? gender;
  @JsonKey(name: 'date_of_birth')
  final String? dateOfBirth;
  @JsonKey(name: 'academic_year')
  final String? academicYear;

  Student({
    this.id,
    required this.firstName,
    required this.lastName,
    this.admissionNumber,
    this.email,
    this.mobilePrimary,
    this.gender,
    this.dateOfBirth,
    this.academicYear,
  });

  factory Student.fromJson(Map<String, dynamic> json) => _$StudentFromJson(json);
  Map<String, dynamic> toJson() => _$StudentToJson(this);
}
