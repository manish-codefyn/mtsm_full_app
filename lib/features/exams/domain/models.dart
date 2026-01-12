
class Exam {
  final String id;
  final String name;
  final String? code;
  final String? examType; // Name or ID
  final String? academicYear; // Name or ID
  final String? className; // Name or ID
  final String startDate;
  final String endDate;
  final String status;
  final bool isPublished;
  final double totalMarks;
  final double passPercentage;

  Exam({
    required this.id,
    required this.name,
    this.code,
    this.examType,
    this.academicYear,
    this.className,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.isPublished,
    this.totalMarks = 100.0,
    this.passPercentage = 35.0,
  });

  factory Exam.fromJson(Map<String, dynamic> json) {
    return Exam(
      id: json['id'],
      name: json['name'],
      code: json['code'],
      examType: json['exam_type_detail'] != null ? json['exam_type_detail']['name'] : json['exam_type'],
      academicYear: json['academic_year_detail'] != null ? json['academic_year_detail']['name'] : json['academic_year'],
      className: json['class_name_detail'] != null ? json['class_name_detail']['name'] : json['class_name'],
      startDate: json['start_date'],
      endDate: json['end_date'],
      status: json['status'],
      isPublished: json['is_published'] ?? false,
      totalMarks: double.tryParse(json['total_marks'].toString()) ?? 100.0,
      passPercentage: double.tryParse(json['pass_percentage'].toString()) ?? 35.0,
    );
  }
}

class Question {
  final String id;
  final String questionText;
  final String questionType;
  final double marks;
  final String complexity;
  final String? topic;
  final String? subjectName;

  Question({
    required this.id,
    required this.questionText,
    required this.questionType,
    required this.marks,
    required this.complexity,
    this.topic,
    this.subjectName,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'],
      questionText: json['question_text'],
      questionType: json['question_type'],
      marks: double.tryParse(json['marks'].toString()) ?? 0.0,
      complexity: json['complexity'],
      topic: json['topic'],
      subjectName: json['subject_detail'] != null ? json['subject_detail']['name'] : null,
    );
  }
}

class ExamPaper {
  final String id;
  final String name;
  final String? subjectName;
  final String? className;
  final double totalMarks;
  final int durationMinutes;
  final String instructions;

  ExamPaper({
    required this.id,
    required this.name,
    this.subjectName,
    this.className,
    required this.totalMarks,
    required this.durationMinutes,
    required this.instructions,
  });

  factory ExamPaper.fromJson(Map<String, dynamic> json) {
    return ExamPaper(
      id: json['id'],
      name: json['name'],
      subjectName: json['subject_detail'] != null ? json['subject_detail']['name'] : null,
      className: json['class_name_detail'] != null ? json['class_name_detail']['name'] : null,
      totalMarks: double.tryParse(json['total_marks'].toString()) ?? 0.0,
      durationMinutes: json['duration_minutes'] ?? 0,
      instructions: json['instructions'] ?? '',
    );
  }
}

class ExamType {
  final String id;
  final String name;
  final String? code;
  final String? description;
  final double weightage;

  ExamType({
    required this.id,
    required this.name,
    this.code,
    this.description,
    this.weightage = 0.0,
  });

  factory ExamType.fromJson(Map<String, dynamic> json) {
    return ExamType(
      id: json['id'],
      name: json['name'],
      code: json['code'],
      description: json['description'],
      weightage: double.tryParse(json['weightage'].toString()) ?? 0.0,
    );
  }
}

class ExamResult {
  final String id;
  final String examId;
  final String studentId;
  final String studentName;
  final String studentAdmissionNumber;
  final bool isPass;
  final String percentageDisplay;
  final String? overallGrade;

  ExamResult({
    required this.id,
    required this.examId,
    required this.studentId,
    required this.studentName,
    required this.studentAdmissionNumber,
    required this.isPass,
    required this.percentageDisplay,
    this.overallGrade,
  });

  factory ExamResult.fromJson(Map<String, dynamic> json) {
    return ExamResult(
      id: json['id'],
      examId: json['exam'],
      studentId: json['student'],
      studentName: json['student_name'] ?? 'Unknown',
      studentAdmissionNumber: json['student_admission_number'] ?? '-',
      isPass: json['is_pass'] ?? false,
      percentageDisplay: json['percentage_display'] ?? '0%',
      overallGrade: json['overall_grade_detail'] != null ? json['overall_grade_detail']['name'] : null,
    );
  }
}

class SubjectResult {
  final String id;
  final String examResultId;
  final String subjectId; // from exam_subject
  final String? subjectName;
  final double marksObtained;
  final double maxMarks;
  final bool isPass;
  final String? grade;

  SubjectResult({
    required this.id,
    required this.examResultId,
    required this.subjectId,
    this.subjectName,
    required this.marksObtained,
    required this.maxMarks,
    required this.isPass,
    this.grade,
  });

  factory SubjectResult.fromJson(Map<String, dynamic> json) {
    return SubjectResult(
      id: json['id'],
      examResultId: json['exam_result'],
      subjectId: json['exam_subject'], // Ideally this should help fetch name
      subjectName: json['exam_subject_detail'] != null && json['exam_subject_detail']['subject_detail'] != null
          ? json['exam_subject_detail']['subject_detail']['name'] 
          : 'Subject',
      marksObtained: double.tryParse(json['marks_obtained'].toString()) ?? 0.0,
      maxMarks: double.tryParse(json['max_marks'].toString()) ?? 100.0,
      isPass: json['is_pass'] ?? false,
      grade: json['grade_detail'] != null ? json['grade_detail']['name'] : null,
    );
  }
}
