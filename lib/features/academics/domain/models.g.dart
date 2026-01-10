// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AcademicYear _$AcademicYearFromJson(Map<String, dynamic> json) => AcademicYear(
  id: json['id'] as String,
  name: json['name'] as String,
  startDate: json['start_date'] as String,
  endDate: json['end_date'] as String,
  isActive: json['is_active'] as bool?,
);

Map<String, dynamic> _$AcademicYearToJson(AcademicYear instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'start_date': instance.startDate,
      'end_date': instance.endDate,
      'is_active': instance.isActive,
    };

Term _$TermFromJson(Map<String, dynamic> json) => Term(
  id: json['id'] as String,
  name: json['name'] as String,
  termType: json['term_type'] as String,
  startDate: json['start_date'] as String,
  endDate: json['end_date'] as String,
  isCurrent: json['is_current'] as bool?,
  academicYearId: json['academic_year'] as String?,
);

Map<String, dynamic> _$TermToJson(Term instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'term_type': instance.termType,
  'start_date': instance.startDate,
  'end_date': instance.endDate,
  'is_current': instance.isCurrent,
  'academic_year': instance.academicYearId,
};

Stream _$StreamFromJson(Map<String, dynamic> json) => Stream(
  id: json['id'] as String,
  name: json['name'] as String,
  code: json['code'] as String,
  description: json['description'] as String?,
  availableFromClassId: json['available_from_class'] as String?,
);

Map<String, dynamic> _$StreamToJson(Stream instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'code': instance.code,
  'description': instance.description,
  'available_from_class': instance.availableFromClassId,
};

SchoolClass _$SchoolClassFromJson(Map<String, dynamic> json) => SchoolClass(
  id: json['id'] as String,
  name: json['name'] as String,
  numericLevel: (json['numeric_level'] as num?)?.toInt(),
  classTeacherDetail: json['class_teacher_detail'] as Map<String, dynamic>?,
  currentStrength: (json['current_strength'] as num?)?.toInt(),
  availableSeats: (json['available_seats'] as num?)?.toInt(),
);

Map<String, dynamic> _$SchoolClassToJson(SchoolClass instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'numeric_level': instance.numericLevel,
      'class_teacher_detail': instance.classTeacherDetail,
      'current_strength': instance.currentStrength,
      'available_seats': instance.availableSeats,
    };

Section _$SectionFromJson(Map<String, dynamic> json) => Section(
  id: json['id'] as String,
  name: json['name'] as String,
  classNameId: json['class_name'] as String?,
  classNameDetail: json['class_name_detail'] == null
      ? null
      : SchoolClass.fromJson(json['class_name_detail'] as Map<String, dynamic>),
  sectionInchargeDetail:
      json['section_incharge_detail'] as Map<String, dynamic>?,
  currentStrength: (json['current_strength'] as num?)?.toInt(),
  roomNumber: json['room_number'] as String?,
);

Map<String, dynamic> _$SectionToJson(Section instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'class_name': instance.classNameId,
  'class_name_detail': instance.classNameDetail,
  'section_incharge_detail': instance.sectionInchargeDetail,
  'current_strength': instance.currentStrength,
  'room_number': instance.roomNumber,
};

Subject _$SubjectFromJson(Map<String, dynamic> json) => Subject(
  id: json['id'] as String,
  name: json['name'] as String,
  code: json['code'] as String?,
  type: json['type'] as String?,
);

Map<String, dynamic> _$SubjectToJson(Subject instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'code': instance.code,
  'type': instance.type,
};

ClassSubject _$ClassSubjectFromJson(Map<String, dynamic> json) => ClassSubject(
  id: json['id'] as String,
  classNameDetail: json['class_name_detail'] == null
      ? null
      : SchoolClass.fromJson(json['class_name_detail'] as Map<String, dynamic>),
  subjectDetail: json['subject_detail'] == null
      ? null
      : Subject.fromJson(json['subject_detail'] as Map<String, dynamic>),
  teacherDetail: json['teacher_detail'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$ClassSubjectToJson(ClassSubject instance) =>
    <String, dynamic>{
      'id': instance.id,
      'class_name_detail': instance.classNameDetail,
      'subject_detail': instance.subjectDetail,
      'teacher_detail': instance.teacherDetail,
    };

TimeTable _$TimeTableFromJson(Map<String, dynamic> json) => TimeTable(
  id: json['id'] as String,
  classNameId: json['class_name'] as String,
  classNameDetail: json['class_name_detail'] == null
      ? null
      : SchoolClass.fromJson(json['class_name_detail'] as Map<String, dynamic>),
  sectionId: json['section'] as String,
  sectionDetail: json['section_detail'] == null
      ? null
      : Section.fromJson(json['section_detail'] as Map<String, dynamic>),
  day: json['day'] as String,
  periodNumber: (json['period_number'] as num).toInt(),
  startTime: json['start_time'] as String,
  endTime: json['end_time'] as String,
  classSubjectId: json['subject'] as String,
  subjectDetail: json['subject_detail'] == null
      ? null
      : ClassSubject.fromJson(json['subject_detail'] as Map<String, dynamic>),
  teacherDetail: json['teacher_detail'] as Map<String, dynamic>?,
  room: json['room'] as String?,
  periodType: json['period_type'] as String?,
);

Map<String, dynamic> _$TimeTableToJson(TimeTable instance) => <String, dynamic>{
  'id': instance.id,
  'class_name': instance.classNameId,
  'class_name_detail': instance.classNameDetail,
  'section': instance.sectionId,
  'section_detail': instance.sectionDetail,
  'day': instance.day,
  'period_number': instance.periodNumber,
  'start_time': instance.startTime,
  'end_time': instance.endTime,
  'subject': instance.classSubjectId,
  'subject_detail': instance.subjectDetail,
  'teacher_detail': instance.teacherDetail,
  'room': instance.room,
  'period_type': instance.periodType,
};

Holiday _$HolidayFromJson(Map<String, dynamic> json) => Holiday(
  id: json['id'] as String,
  name: json['name'] as String,
  holidayType: json['holiday_type'] as String,
  startDate: json['start_date'] as String,
  endDate: json['end_date'] as String?,
  description: json['description'] as String?,
);

Map<String, dynamic> _$HolidayToJson(Holiday instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'holiday_type': instance.holidayType,
  'start_date': instance.startDate,
  'end_date': instance.endDate,
  'description': instance.description,
};

House _$HouseFromJson(Map<String, dynamic> json) => House(
  id: json['id'] as String,
  name: json['name'] as String,
  code: json['code'] as String,
  color: json['color'] as String,
  houseMasterDetail: json['house_master_detail'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$HouseToJson(House instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'code': instance.code,
  'color': instance.color,
  'house_master_detail': instance.houseMasterDetail,
};

GradingSystem _$GradingSystemFromJson(Map<String, dynamic> json) =>
    GradingSystem(
      id: json['id'] as String,
      name: json['name'] as String,
      code: json['code'] as String,
      isDefault: json['is_default'] as bool,
    );

Map<String, dynamic> _$GradingSystemToJson(GradingSystem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'code': instance.code,
      'is_default': instance.isDefault,
    };

Grade _$GradeFromJson(Map<String, dynamic> json) => Grade(
  id: json['id'] as String,
  grade: json['grade'] as String,
  minPercentage: (json['min_percentage'] as num).toDouble(),
  maxPercentage: (json['max_percentage'] as num).toDouble(),
  gradePoint: (json['grade_point'] as num).toDouble(),
  description: json['description'] as String?,
);

Map<String, dynamic> _$GradeToJson(Grade instance) => <String, dynamic>{
  'id': instance.id,
  'grade': instance.grade,
  'min_percentage': instance.minPercentage,
  'max_percentage': instance.maxPercentage,
  'grade_point': instance.gradePoint,
  'description': instance.description,
};

Syllabus _$SyllabusFromJson(Map<String, dynamic> json) => Syllabus(
  id: json['id'] as String,
  classNameDetail: json['class_name_detail'] == null
      ? null
      : SchoolClass.fromJson(json['class_name_detail'] as Map<String, dynamic>),
  subjectDetail: json['subject_detail'] == null
      ? null
      : Subject.fromJson(json['subject_detail'] as Map<String, dynamic>),
  topics: json['topics'] as List<dynamic>?,
  recommendedBooks: json['recommended_books'] as String?,
  referenceMaterials: json['reference_materials'] as String?,
  assessmentPattern: json['assessment_pattern'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$SyllabusToJson(Syllabus instance) => <String, dynamic>{
  'id': instance.id,
  'class_name_detail': instance.classNameDetail,
  'subject_detail': instance.subjectDetail,
  'topics': instance.topics,
  'recommended_books': instance.recommendedBooks,
  'reference_materials': instance.referenceMaterials,
  'assessment_pattern': instance.assessmentPattern,
};

StudyMaterial _$StudyMaterialFromJson(Map<String, dynamic> json) =>
    StudyMaterial(
      id: json['id'] as String,
      classSubjectDetail: json['class_subject_detail'] == null
          ? null
          : ClassSubject.fromJson(
              json['class_subject_detail'] as Map<String, dynamic>,
            ),
      title: json['title'] as String,
      description: json['description'] as String?,
      fileUrl: json['file'] as String?,
      uploadedAt: json['uploaded_at'] as String?,
    );

Map<String, dynamic> _$StudyMaterialToJson(StudyMaterial instance) =>
    <String, dynamic>{
      'id': instance.id,
      'class_subject_detail': instance.classSubjectDetail,
      'title': instance.title,
      'description': instance.description,
      'file': instance.fileUrl,
      'uploaded_at': instance.uploadedAt,
    };
