import 'package:json_annotation/json_annotation.dart';

part 'models.g.dart';

@JsonSerializable()
class AcademicYear {
  final String id;
  final String name;
  @JsonKey(name: 'start_date')
  final String startDate;
  @JsonKey(name: 'end_date')
  final String endDate;
  @JsonKey(name: 'is_active')
  final bool? isActive;

  AcademicYear({
    required this.id,
    required this.name,
    required this.startDate,
    required this.endDate,
    this.isActive,
  });

  factory AcademicYear.fromJson(Map<String, dynamic> json) => _$AcademicYearFromJson(json);
  Map<String, dynamic> toJson() => _$AcademicYearToJson(this);
}

@JsonSerializable()
class Term {
  final String id;
  final String name;
  @JsonKey(name: 'term_type')
  final String termType;
  @JsonKey(name: 'start_date')
  final String startDate;
  @JsonKey(name: 'end_date')
  final String endDate;
  @JsonKey(name: 'is_current')
  final bool? isCurrent;
  @JsonKey(name: 'academic_year')
  final String? academicYearId;

  Term({
    required this.id,
    required this.name,
    required this.termType,
    required this.startDate,
    required this.endDate,
    this.isCurrent,
    this.academicYearId,
  });

  bool get isActive => isCurrent ?? false;

  factory Term.fromJson(Map<String, dynamic> json) => _$TermFromJson(json);
  Map<String, dynamic> toJson() => _$TermToJson(this);
}

@JsonSerializable()
class Stream {
  final String id;
  final String name;
  final String code;
  final String? description;
  @JsonKey(name: 'available_from_class')
  final String? availableFromClassId;

  Stream({
    required this.id,
    required this.name,
    required this.code,
    this.description,
    this.availableFromClassId,
  });

  factory Stream.fromJson(Map<String, dynamic> json) => _$StreamFromJson(json);
  Map<String, dynamic> toJson() => _$StreamToJson(this);
}

@JsonSerializable()
class SchoolClass {
  final String id;
  final String name;
  @JsonKey(name: 'numeric_level')
  final int? numericLevel;
  @JsonKey(name: 'class_teacher_detail')
  final Map<String, dynamic>? classTeacherDetail;
  @JsonKey(name: 'current_strength')
  final int? currentStrength;
  @JsonKey(name: 'available_seats')
  final int? availableSeats;

  SchoolClass({
    required this.id,
    required this.name,
    this.numericLevel,
    this.classTeacherDetail,
    this.currentStrength,
    this.availableSeats,
  });

  factory SchoolClass.fromJson(Map<String, dynamic> json) => _$SchoolClassFromJson(json);
  Map<String, dynamic> toJson() => _$SchoolClassToJson(this);
}

@JsonSerializable()
class Section {
  final String id;
  final String name;
  @JsonKey(name: 'class_name')
  final String? classNameId; // The ID
  @JsonKey(name: 'class_name_detail')
  final SchoolClass? classNameDetail;
  @JsonKey(name: 'section_incharge_detail')
  final Map<String, dynamic>? sectionInchargeDetail;
  @JsonKey(name: 'current_strength')
  final int? currentStrength;
  @JsonKey(name: 'room_number')
  final String? roomNumber;

  Section({
    required this.id,
    required this.name,
    this.classNameId,
    this.classNameDetail,
    this.sectionInchargeDetail,
    this.currentStrength,
    this.roomNumber,
  });

  factory Section.fromJson(Map<String, dynamic> json) => _$SectionFromJson(json);
  Map<String, dynamic> toJson() => _$SectionToJson(this);
}

@JsonSerializable()
class Subject {
  final String id;
  final String name;
  final String? code;
  final String? type; // THEORY, PRACTICAL

  Subject({
    required this.id,
    required this.name,
    this.code,
    this.type,
  });

  factory Subject.fromJson(Map<String, dynamic> json) => _$SubjectFromJson(json);
  Map<String, dynamic> toJson() => _$SubjectToJson(this);
}

@JsonSerializable()
class ClassSubject {
  final String id;
  @JsonKey(name: 'class_name_detail')
  final SchoolClass? classNameDetail;
  @JsonKey(name: 'subject_detail')
  final Subject? subjectDetail;
  @JsonKey(name: 'teacher_detail')
  final Map<String, dynamic>? teacherDetail;

  ClassSubject({
    required this.id,
    this.classNameDetail,
    this.subjectDetail,
    this.teacherDetail,
  });

  factory ClassSubject.fromJson(Map<String, dynamic> json) => _$ClassSubjectFromJson(json);
  Map<String, dynamic> toJson() => _$ClassSubjectToJson(this);
}


@JsonSerializable()
class TimeTable {
  final String id;
  @JsonKey(name: 'class_name')
  final String classNameId; // ID
  @JsonKey(name: 'class_name_detail')
  final SchoolClass? classNameDetail;
  @JsonKey(name: 'section')
  final String sectionId; // ID
  @JsonKey(name: 'section_detail')
  final Section? sectionDetail;
  final String day;
  @JsonKey(name: 'period_number')
  final int periodNumber;
  @JsonKey(name: 'start_time')
  final String startTime;
  @JsonKey(name: 'end_time')
  final String endTime;
  @JsonKey(name: 'subject')
  final String classSubjectId; // ID of ClassSubject
  @JsonKey(name: 'subject_detail')
  final ClassSubject? subjectDetail; // Nested ClassSubject
  @JsonKey(name: 'teacher_detail') 
  final Map<String, dynamic>? teacherDetail;
  final String? room;
  @JsonKey(name: 'period_type')
  final String? periodType;

  TimeTable({
    required this.id,
    required this.classNameId,
    this.classNameDetail,
    required this.sectionId,
    this.sectionDetail,
    required this.day,
    required this.periodNumber,
    required this.startTime,
    required this.endTime,
    required this.classSubjectId,
    this.subjectDetail,
    this.teacherDetail,
    this.room,
    this.periodType,
  });

  factory TimeTable.fromJson(Map<String, dynamic> json) => _$TimeTableFromJson(json);
  Map<String, dynamic> toJson() => _$TimeTableToJson(this);
}
@JsonSerializable()
class Holiday {
  final String id;
  final String name;
  @JsonKey(name: 'holiday_type')
  final String holidayType;
  @JsonKey(name: 'start_date')
  final String startDate;
  @JsonKey(name: 'end_date')
  final String? endDate;
  final String? description;

  Holiday({
    required this.id,
    required this.name,
    required this.holidayType,
    required this.startDate,
    this.endDate,
    this.description,
  });

  factory Holiday.fromJson(Map<String, dynamic> json) => _$HolidayFromJson(json);
  Map<String, dynamic> toJson() => _$HolidayToJson(this);
}

@JsonSerializable()
class House {
  final String id;
  final String name;
  final String code;
  final String color; // Hex or Name
  @JsonKey(name: 'house_master_detail')
  final Map<String, dynamic>? houseMasterDetail;

  House({
    required this.id,
    required this.name,
    required this.code,
    required this.color,
    this.houseMasterDetail,
  });

  factory House.fromJson(Map<String, dynamic> json) => _$HouseFromJson(json);
  Map<String, dynamic> toJson() => _$HouseToJson(this);
}

@JsonSerializable()
class GradingSystem {
  final String id;
  final String name;
  final String code;
  @JsonKey(name: 'is_default')
  final bool isDefault;

  GradingSystem({
    required this.id,
    required this.name,
    required this.code,
    required this.isDefault,
  });

  factory GradingSystem.fromJson(Map<String, dynamic> json) => _$GradingSystemFromJson(json);
  Map<String, dynamic> toJson() => _$GradingSystemToJson(this);
}

@JsonSerializable()
class Grade {
  final String id;
  final String grade;
  @JsonKey(name: 'min_percentage')
  final double minPercentage;
  @JsonKey(name: 'max_percentage')
  final double maxPercentage;
  @JsonKey(name: 'grade_point')
  final double gradePoint;
  final String? description;

  Grade({
    required this.id,
    required this.grade,
    required this.minPercentage,
    required this.maxPercentage,
    required this.gradePoint,
    this.description,
  });

  factory Grade.fromJson(Map<String, dynamic> json) => _$GradeFromJson(json);
  Map<String, dynamic> toJson() => _$GradeToJson(this);
}

@JsonSerializable()
class Syllabus {
  final String id;
  @JsonKey(name: 'class_name_detail')
  final SchoolClass? classNameDetail;
  @JsonKey(name: 'subject_detail')
  final Subject? subjectDetail;
  @JsonKey(name: 'topics')
  final List<dynamic>? topics;
  @JsonKey(name: 'recommended_books')
  final String? recommendedBooks;
  @JsonKey(name: 'reference_materials')
  final String? referenceMaterials;
  @JsonKey(name: 'assessment_pattern')
  final Map<String, dynamic>? assessmentPattern;

  Syllabus({
    required this.id,
    this.classNameDetail,
    this.subjectDetail,
    this.topics,
    this.recommendedBooks,
    this.referenceMaterials,
    this.assessmentPattern,
  });

  factory Syllabus.fromJson(Map<String, dynamic> json) => _$SyllabusFromJson(json);
  Map<String, dynamic> toJson() => _$SyllabusToJson(this);
}

@JsonSerializable()
class StudyMaterial {
  final String id;
  @JsonKey(name: 'class_subject_detail')
  final ClassSubject? classSubjectDetail;
  final String title;
  final String? description;
  @JsonKey(name: 'file')
  final String? fileUrl;
  @JsonKey(name: 'uploaded_at')
  final String? uploadedAt;

  StudyMaterial({
    required this.id,
    this.classSubjectDetail,
    required this.title,
    this.description,
    this.fileUrl,
    this.uploadedAt,
  });

  factory StudyMaterial.fromJson(Map<String, dynamic> json) => _$StudyMaterialFromJson(json);
  Map<String, dynamic> toJson() => _$StudyMaterialToJson(this);
}
