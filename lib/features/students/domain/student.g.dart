// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'student.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Student _$StudentFromJson(Map<String, dynamic> json) => Student(
  id: json['id'] as String?,
  firstName: json['first_name'] as String,
  middleName: json['middle_name'] as String?,
  lastName: json['last_name'] as String,
  photo: json['photo'] as String?,
  admissionNumber: json['admission_number'] as String?,
  rollNumber: json['roll_number'] as String?,
  regNo: json['reg_no'] as String?,
  email: json['personal_email'] as String?,
  institutionalEmail: json['institutional_email'] as String?,
  mobilePrimary: json['mobile_primary'] as String?,
  mobileSecondary: json['mobile_secondary'] as String?,
  gender: json['gender'] as String?,
  dateOfBirth: json['date_of_birth'] as String?,
  nationality: json['nationality'] as String?,
  placeOfBirth: json['place_of_birth'] as String?,
  maritalStatus: json['marital_status'] as String?,
  bloodGroup: json['blood_group'] as String?,
  religion: json['religion'] as String?,
  category: json['category'] as String?,
  isMinority: json['is_minority'] as bool?,
  isPhysicallyChallenged: json['is_physically_challenged'] as bool?,
  annualFamilyIncome: (json['annual_family_income'] as num?)?.toDouble(),
  academicYear: json['academic_year'] as String?,
  currentClass: json['current_class'] as String?,
  currentClassName: json['current_class_name'] as String?,
  stream: json['stream'] as String?,
  section: json['section'] as String?,
  admissionType: json['admission_type'] as String?,
  enrollmentDate: json['enrollment_date'] as String?,
  status: json['status'] as String?,
  statusChangedDate: json['status_changed_date'] as String?,
  passingYear: json['passing_year'] as String?,
  tcIssueDate: json['tc_issue_date'] as String?,
  currentSemester: (json['current_semester'] as num?)?.toInt(),
  totalCreditsEarned: (json['total_credits_earned'] as num?)?.toDouble(),
  cumulativeGradePoint: (json['cumulative_grade_point'] as num?)?.toDouble(),
  feeCategory: json['fee_category'] as String?,
  scholarshipType: json['scholarship_type'] as String?,
  guardians: (json['guardians'] as List<dynamic>?)
      ?.map((e) => Guardian.fromJson(e as Map<String, dynamic>))
      .toList(),
  addresses: (json['addresses'] as List<dynamic>?)
      ?.map((e) => StudentAddress.fromJson(e as Map<String, dynamic>))
      .toList(),
  medicalInfo: json['medical_info'] == null
      ? null
      : StudentMedicalInfo.fromJson(
          json['medical_info'] as Map<String, dynamic>,
        ),
  identification: json['identification'] == null
      ? null
      : StudentIdentification.fromJson(
          json['identification'] as Map<String, dynamic>,
        ),
  academicHistory: (json['academic_history'] as List<dynamic>?)
      ?.map((e) => StudentAcademicHistory.fromJson(e as Map<String, dynamic>))
      .toList(),
  documents: (json['documents'] as List<dynamic>?)
      ?.map((e) => StudentDocument.fromJson(e as Map<String, dynamic>))
      .toList(),
  onboardingSummary: json['onboarding_summary'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$StudentToJson(Student instance) => <String, dynamic>{
  'id': instance.id,
  'first_name': instance.firstName,
  'middle_name': instance.middleName,
  'last_name': instance.lastName,
  'admission_number': instance.admissionNumber,
  'roll_number': instance.rollNumber,
  'reg_no': instance.regNo,
  'personal_email': instance.email,
  'institutional_email': instance.institutionalEmail,
  'mobile_primary': instance.mobilePrimary,
  'mobile_secondary': instance.mobileSecondary,
  'gender': instance.gender,
  'date_of_birth': instance.dateOfBirth,
  'nationality': instance.nationality,
  'place_of_birth': instance.placeOfBirth,
  'marital_status': instance.maritalStatus,
  'blood_group': instance.bloodGroup,
  'religion': instance.religion,
  'category': instance.category,
  'is_minority': instance.isMinority,
  'is_physically_challenged': instance.isPhysicallyChallenged,
  'annual_family_income': instance.annualFamilyIncome,
  'academic_year': instance.academicYear,
  'current_class': instance.currentClass,
  'current_class_name': instance.currentClassName,
  'stream': instance.stream,
  'section': instance.section,
  'admission_type': instance.admissionType,
  'enrollment_date': instance.enrollmentDate,
  'status': instance.status,
  'status_changed_date': instance.statusChangedDate,
  'passing_year': instance.passingYear,
  'tc_issue_date': instance.tcIssueDate,
  'current_semester': instance.currentSemester,
  'total_credits_earned': instance.totalCreditsEarned,
  'cumulative_grade_point': instance.cumulativeGradePoint,
  'fee_category': instance.feeCategory,
  'scholarship_type': instance.scholarshipType,
  'guardians': instance.guardians?.map((e) => e.toJson()).toList(),
  'addresses': instance.addresses?.map((e) => e.toJson()).toList(),
  'medical_info': instance.medicalInfo?.toJson(),
  'identification': instance.identification?.toJson(),
  'academic_history': instance.academicHistory?.map((e) => e.toJson()).toList(),
  'documents': instance.documents?.map((e) => e.toJson()).toList(),
  'photo': instance.photo,
  'onboarding_summary': instance.onboardingSummary,
};
