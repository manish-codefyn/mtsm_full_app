import 'package:json_annotation/json_annotation.dart';
import 'guardian.dart';
import 'student_address.dart';
import 'student_document.dart';
import 'student_medical_info.dart';
import 'student_identification.dart';
import 'student_academic_history.dart';

part 'student.g.dart';

@JsonSerializable(explicitToJson: true)
class Student {
  final String? id;
  @JsonKey(name: 'first_name')
  final String firstName;
  @JsonKey(name: 'middle_name')
  final String? middleName;
  @JsonKey(name: 'last_name')
  final String lastName;
  
  // Identification
  @JsonKey(name: 'admission_number')
  final String? admissionNumber;
  @JsonKey(name: 'roll_number')
  final String? rollNumber;
  @JsonKey(name: 'reg_no')
  final String? regNo;
  
  // Contact
  @JsonKey(name: 'personal_email')
  final String? email;
  @JsonKey(name: 'institutional_email')
  final String? institutionalEmail;
  @JsonKey(name: 'mobile_primary')
  final String? mobilePrimary;
  @JsonKey(name: 'mobile_secondary')
  final String? mobileSecondary;
  
  // Personal
  final String? gender;
  @JsonKey(name: 'date_of_birth')
  final String? dateOfBirth;
  final String? nationality;
  @JsonKey(name: 'place_of_birth')
  final String? placeOfBirth;
  @JsonKey(name: 'marital_status')
  final String? maritalStatus;
  @JsonKey(name: 'blood_group')
  final String? bloodGroup;
  final String? religion;
  final String? category;
  @JsonKey(name: 'is_minority')
  final bool? isMinority;
  @JsonKey(name: 'is_physically_challenged')
  final bool? isPhysicallyChallenged;
  @JsonKey(name: 'annual_family_income')
  final double? annualFamilyIncome;

  // Academic Info
  @JsonKey(name: 'academic_year')
  final String? academicYear;
  @JsonKey(name: 'current_class')
  final String? currentClass;
  @JsonKey(name: 'current_class_name')
  final String? currentClassName;
  final String? stream;
  final String? section;
  @JsonKey(name: 'admission_type')
  final String? admissionType;
  @JsonKey(name: 'enrollment_date')
  final String? enrollmentDate;
  
  // Status
  final String? status;
  @JsonKey(name: 'status_changed_date')
  final String? statusChangedDate;
  @JsonKey(name: 'passing_year')
  final String? passingYear;
  @JsonKey(name: 'tc_issue_date')
  final String? tcIssueDate;

  // Academic Tracking
  @JsonKey(name: 'current_semester')
  final int? currentSemester;
  @JsonKey(name: 'total_credits_earned')
  final double? totalCreditsEarned;
  @JsonKey(name: 'cumulative_grade_point')
  final double? cumulativeGradePoint;

  // Fee
  @JsonKey(name: 'fee_category')
  final String? feeCategory;
  @JsonKey(name: 'scholarship_type')
  final String? scholarshipType;

  // Relations
  final List<Guardian>? guardians;
  final List<StudentAddress>? addresses;
  @JsonKey(name: 'medical_info')
  final StudentMedicalInfo? medicalInfo;
  final StudentIdentification? identification;
  @JsonKey(name: 'academic_history')
  final List<StudentAcademicHistory>? academicHistory;
  final List<StudentDocument>? documents;

  Student({
    this.id,
    required this.firstName,
    this.middleName,
    required this.lastName,
    this.admissionNumber,
    this.rollNumber,
    this.regNo,
    this.email,
    this.institutionalEmail,
    this.mobilePrimary,
    this.mobileSecondary,
    this.gender,
    this.dateOfBirth,
    this.nationality,
    this.placeOfBirth,
    this.maritalStatus,
    this.bloodGroup,
    this.religion,
    this.category,
    this.isMinority,
    this.isPhysicallyChallenged,
    this.annualFamilyIncome,
    this.academicYear,
    this.currentClass,
    this.currentClassName,
    this.stream,
    this.section,
    this.admissionType,
    this.enrollmentDate,
    this.status,
    this.statusChangedDate,
    this.passingYear,
    this.tcIssueDate,
    this.currentSemester,
    this.totalCreditsEarned,
    this.cumulativeGradePoint,
    this.feeCategory,
    this.scholarshipType,
    this.guardians,
    this.addresses,
    this.medicalInfo,
    this.identification,
    this.academicHistory,
    this.documents,
    this.onboardingSummary,
  });

  @JsonKey(name: 'onboarding_summary')
  final Map<String, dynamic>? onboardingSummary;

  factory Student.fromJson(Map<String, dynamic> json) => _$StudentFromJson(json);
  Map<String, dynamic> toJson() => _$StudentToJson(this);
}
