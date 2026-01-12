import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../shared/models/paginated_response.dart';
import '../domain/models.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

final examRepositoryProvider = Provider((ref) => ExamRepository(ref));

final examsPaginationProvider = FutureProvider.family.autoDispose<PaginatedResponse<Exam>, ExamPaginationParams>((ref, params) async {
  return ref.watch(examRepositoryProvider).getExams(params);
});

class ExamPaginationParams {
  final int page;
  final int pageSize;
  final String? search;
  final String? classId;
  final String? academicYearId;

  const ExamPaginationParams({
    this.page = 1,
    this.pageSize = 10,
    this.search,
    this.classId,
    this.academicYearId,
  });
}

class ExamRepository {
  final Ref _ref;

  ExamRepository(this._ref);

  Future<PaginatedResponse<Exam>> getExams(ExamPaginationParams params) async {
    final dio = _ref.read(apiClientProvider).client;
    try {
      final Map<String, dynamic> queryParams = {
        'page': params.page,
        'page_size': params.pageSize,
      };
      if (params.search != null && params.search!.isNotEmpty) queryParams['search'] = params.search;
      if (params.classId != null) queryParams['class_name'] = params.classId;
      if (params.academicYearId != null) queryParams['academic_year'] = params.academicYearId;

      final response = await dio.get('/exams/', queryParameters: queryParams);
      return PaginatedResponse.fromJson(
        response.data,
        (json) => Exam.fromJson(json as Map<String, dynamic>),
      );
    } catch (e) {
      throw Exception('Failed to fetch exams: $e');
    }
  }

  // --- Exam Paper Generation & Questions ---

  Future<void> generateExamPaper({
    required String name,
    required String subjectId,
    required String classId,
    required double totalMarks,
    required int durationMinutes,
    required String instructions,
    required List<String> questionTypes, // Mocking selection logic
  }) async {
    final dio = _ref.read(apiClientProvider).client;
    try {
      // 1. Fetch Questions (Simple selection for now)
      final questionsResponse = await dio.get('/exams/questions/', queryParameters: {
        'subject': subjectId,
        'page_size': 100
      });
      final List<dynamic> questions = questionsResponse.data['results'];
      
      // Select questions to match marks (Simplistic Logic)
      List<String> selectedQuestionIds = [];
      double currentMarks = 0;
      for (var q in questions) {
        if (currentMarks < totalMarks) {
          selectedQuestionIds.add(q['id']);
          currentMarks += double.tryParse(q['marks'].toString()) ?? 0;
        }
      }

      // 2. Create Paper
      final paperData = {
        'name': name,
        'subject': subjectId,
        'class_name': classId,
        'total_marks': totalMarks, // For now set to requested, or calculated
        'duration_minutes': durationMinutes,
        'instructions': instructions,
        // Backend doesn't support direct question creation in same call yet, unless we updated serializer.
        // We really should use a custom action `auto-generate` on backend, but let's do it client-side for now via separate calls.
      };
      
      final paperResponse = await dio.post('/exams/papers/', data: paperData);
      final paperId = paperResponse.data['id'];

      // 3. Link Questions
      // Iterate and link questions (Inefficient but functional for MVP)
      for (var i = 0; i < selectedQuestionIds.length; i++) {
         try {
            await dio.post('/exams/paper-questions/', data: {
              'paper': paperId,
              'question': selectedQuestionIds[i],
              'order': i + 1
            });
         } catch (e) {
           print('Failed to link question ${selectedQuestionIds[i]}: $e');
         }
      }

      // 4. Generate PDF immediately? 
      // User can trigger it separately or we can return the paper object.
      // For now, we just complete.
    } catch (e) {
      throw Exception('Failed to generate paper: $e');
    }
  }

  // --- PDF Export ---

  Future<void> exportExamListPdf(List<Exam> exams) async {
    final pdf = pw.Document();
    final font = await PdfGoogleFonts.nunitoExtraLight();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        theme: pw.ThemeData.withFont(base: font),
        build: (context) => [
          pw.Header(level: 0, child: pw.Text('Exam Schedule', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold))),
          pw.SizedBox(height: 20),
          pw.Table.fromTextArray(
            context: context,
            headers: ['Exam Name', 'Class', 'Start Date', 'End Date', 'Status'],
            data: exams.map((e) => [
              e.name,
              e.className ?? '-',
              e.startDate,
              e.endDate,
              e.status
            ]).toList(),
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
            cellAlignments: {
              0: pw.Alignment.centerLeft,
              1: pw.Alignment.center,
              2: pw.Alignment.center,
              3: pw.Alignment.center,
              4: pw.Alignment.center,
            },
          ),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
      name: 'exam_schedule.pdf',
    );
  }

  Future<void> exportExamPaperPdf(ExamPaper paper, List<Question> questions) async {
    final pdf = pw.Document();
    final font = await PdfGoogleFonts.nunitoRegular();
    final boldFont = await PdfGoogleFonts.nunitoBold();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        theme: pw.ThemeData.withFont(base: font, bold: boldFont),
        build: (context) => [
          // Header
          pw.Center(child: pw.Text(paper.name.toUpperCase(), style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold))),
          pw.SizedBox(height: 10),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Subject: ${paper.subjectName ?? '-'}'),
              pw.Text('Class: ${paper.className ?? '-'}'),
            ],
          ),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Time: ${paper.durationMinutes} Mins'),
              pw.Text('Max Marks: ${paper.totalMarks}'),
            ],
          ),
          pw.Divider(),
          if (paper.instructions.isNotEmpty) ...[
            pw.Text('Instructions:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.Text(paper.instructions),
            pw.SizedBox(height: 10),
            pw.Divider(),
          ],
          
          // Questions
          ...questions.asMap().entries.map((entry) {
            final idx = entry.key + 1;
            final q = entry.value;
            return pw.Container(
              margin: const pw.EdgeInsets.only(bottom: 12),
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.SizedBox(width: 25, child: pw.Text('$idx.', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                  pw.Expanded(
                    child: pw.Text(q.questionText),
                  ),
                  pw.SizedBox(width: 40, child: pw.Text('[${q.marks}]', textAlign: pw.TextAlign.right, style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
      name: '${paper.name.replaceAll(" ", "_")}.pdf',
    );
  }

  // --- CRUD for Exams ---

  Future<void> createExam(Map<String, dynamic> data) async {
    final dio = _ref.read(apiClientProvider).client;
    try {
      await dio.post('/exams/', data: data);
    } catch (e) {
      throw Exception('Failed to create exam: $e');
    }
  }

  Future<void> updateExam(String id, Map<String, dynamic> data) async {
    final dio = _ref.read(apiClientProvider).client;
    try {
      await dio.patch('/exams/$id/', data: data);
    } catch (e) {
      throw Exception('Failed to update exam: $e');
    }
  }

  Future<void> deleteExam(String id) async {
    final dio = _ref.read(apiClientProvider).client;
    try {
      await dio.delete('/exams/$id/');
    } catch (e) {
      throw Exception('Failed to delete exam: $e');
    }
  }
  
  // --- Exam Results & Marks ---
  
  Future<PaginatedResponse<ExamResult>> getExamResults({required String examId, int page=1, int pageSize=100}) async {
    final dio = _ref.read(apiClientProvider).client;
    try {
      final response = await dio.get('/exams/results/', queryParameters: {'exam': examId, 'page': page, 'page_size': pageSize});
      return PaginatedResponse.fromJson(response.data, (json) => ExamResult.fromJson(json));
    } catch (e) {
      throw Exception('Failed to fetch results: $e');
    }
  }
  
  // Create results for all students in the class linked to the exam (Initialization)
  Future<void> initializeExamResults(String examId) async {
     // This logic might be complex. Ideally, backend should have "initialize results" endpoint.
     // For now, we will handle this in UI: "Check if result exists, if not create".
     // Or we assume results are created when marks are entered.
  }
  
  Future<void> createExamResult(Map<String, dynamic> data) async {
     final dio = _ref.read(apiClientProvider).client;
     await dio.post('/exams/results/', data: data);
  }
  
  // Fetch Subject Results (Marks) for a student in an exam
  Future<List<SubjectResult>> getSubjectResults(String examResultId) async {
     final dio = _ref.read(apiClientProvider).client;
     try {
       final response = await dio.get('/exams/subject-results/', queryParameters: {'exam_result': examResultId});
       final List data = response.data['results'];
       return data.map((json) => SubjectResult.fromJson(json)).toList();
     } catch (e) {
       return [];
     }
  }
  
  Future<void> saveSubjectResult(Map<String, dynamic> data) async {
    final dio = _ref.read(apiClientProvider).client;
    try {
      // Check if exists first? Or just POST. 
      // If we need update, we need ID. 
      // Ideally we should upsert. Backend view `SubjectResultViewSet` usually supports standard CRUD.
      // If data has ID, use PATCH, else POST.
      if (data.containsKey('id') && data['id'] != null) {
         await dio.patch('/exams/subject-results/${data['id']}/', data: data);
      } else {
         await dio.post('/exams/subject-results/', data: data);
      }
    } catch (e) {
      throw Exception('Failed to save mark: $e');
    }
  }

  // --- Configuration ---
  Future<List<ExamType>> getExamTypes() async {
    final dio = _ref.read(apiClientProvider).client;
    try {
      final response = await dio.get('/exams/types/', queryParameters: {'page_size': 100});
      final List data = response.data['results'];
      return data.map((json) => ExamType.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> createExamType(Map<String, dynamic> data) async {
    final dio = _ref.read(apiClientProvider).client;
    try {
      await dio.post('/exams/types/', data: data);
    } catch (e) {
      throw Exception('Failed to create exam type: $e');
    }
  }

  Future<void> updateExamType(String id, Map<String, dynamic> data) async {
    final dio = _ref.read(apiClientProvider).client;
    try {
      await dio.patch('/exams/types/$id/', data: data);
    } catch (e) {
      throw Exception('Failed to update exam type: $e');
    }
  }

  Future<void> deleteExamType(String id) async {
    final dio = _ref.read(apiClientProvider).client;
    try {
      await dio.delete('/exams/types/$id/');
    } catch (e) {
      throw Exception('Failed to delete exam type: $e');
    }
  }

  // --- Questions (New) ---

  Future<PaginatedResponse<Question>> getQuestions({
    int page = 1, 
    int pageSize = 20, 
    String? search, 
    String? subjectId, 
    String? type
  }) async {
    final dio = _ref.read(apiClientProvider).client;
    try {
      final Map<String, dynamic> queryParams = {
        'page': page,
        'page_size': pageSize,
      };
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (subjectId != null) queryParams['subject'] = subjectId;
      if (type != null) queryParams['question_type'] = type;

      final response = await dio.get('/exams/questions/', queryParameters: queryParams);
      return PaginatedResponse.fromJson(
        response.data, 
        (json) => Question.fromJson(json)
      );
    } catch (e) {
      throw Exception('Failed to fetch questions: $e');
    }
  }

  Future<void> saveQuestion(Map<String, dynamic> data) async {
    final dio = _ref.read(apiClientProvider).client;
    try {
      if (data.containsKey('id') && data['id'] != null) {
        await dio.patch('/exams/questions/${data['id']}/', data: data);
      } else {
        await dio.post('/exams/questions/', data: data);
      }
    } catch (e) {
      throw Exception('Failed to save question: $e');
    }
  }

  Future<void> deleteQuestion(String id) async {
    final dio = _ref.read(apiClientProvider).client;
    try {
      await dio.delete('/exams/questions/$id/');
    } catch (e) {
      throw Exception('Failed to delete question: $e');
    }
  }

  // --- Paper Management ---
  Future<PaginatedResponse<ExamPaper>> getExamPapers({int page = 1, int pageSize = 20}) async {
    final dio = _ref.read(apiClientProvider).client;
    try {
       final response = await dio.get('/exams/papers/', queryParameters: {'page': page, 'page_size': pageSize});
       return PaginatedResponse.fromJson(response.data, (json) => ExamPaper.fromJson(json));
    } catch (e) {
       throw Exception('Failed to fetch papers: $e');
    }
  }


  Future<void> deleteExamPaper(String id) async {
    final dio = _ref.read(apiClientProvider).client;
    try {
      await dio.delete('/exams/papers/$id/');
    } catch (e) {
      throw Exception('Failed to delete paper: $e');
    }
  }

  // --- Additional PDF Exports ---

  Future<void> exportQuestionListPdf(List<Question> questions) async {
    final pdf = pw.Document();
    final font = await PdfGoogleFonts.nunitoExtraLight();
    
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        theme: pw.ThemeData.withFont(base: font),
        build: (context) => [
          pw.Header(level: 0, child: pw.Text('Question Bank Export', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold))),
          pw.SizedBox(height: 20),
          ...questions.map((q) => pw.Container(
            margin: const pw.EdgeInsets.only(bottom: 10),
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey300)),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                     pw.Text('${q.questionType} • ${q.subjectName ?? "-"} • ${q.complexity}'),
                     pw.Text('${q.marks} Marks', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ]
                ),
                pw.SizedBox(height: 5),
                pw.Text(q.questionText),
              ],
            ),
          )).toList(),
        ],
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save(), name: 'question_bank.pdf');
  }

  Future<void> exportExamTypesPdf(List<ExamType> types) async {
    final pdf = pw.Document();
    final font = await PdfGoogleFonts.nunitoExtraLight();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        theme: pw.ThemeData.withFont(base: font),
        build: (context) => [
          pw.Header(level: 0, child: pw.Text('Exam Configuration Types', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold))),
          pw.SizedBox(height: 20),
          pw.Table.fromTextArray(
            headers: ['Name', 'Code', 'Description'],
            data: types.map((t) => [t.name, t.code ?? '-', t.description ?? '-']).toList(),
          ),
        ],
      ),
    );
     await Printing.layoutPdf(onLayout: (format) async => pdf.save(), name: 'exam_types.pdf');
  }

  Future<void> exportExamResultsPdf(String examName, List<ExamResult> results) async {
    final pdf = pw.Document();
    final font = await PdfGoogleFonts.nunitoExtraLight();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        theme: pw.ThemeData.withFont(base: font),
        build: (context) => [
          pw.Header(level: 0, child: pw.Text('Exam Results: $examName', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold))),
          pw.SizedBox(height: 20),
          pw.Table.fromTextArray(
            headers: ['Student', 'Adm No', 'Result', 'Percentage', 'Grade'],
            data: results.map((r) => [
              r.studentName,
              r.studentAdmissionNumber,
              r.isPass ? 'PASS' : 'FAIL',
              r.percentageDisplay,
              r.overallGrade ?? '-'
            ]).toList(),
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.teal),
            rowDecoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300))),
          ),
        ],
      ),
    );
    await Printing.layoutPdf(onLayout: (format) async => pdf.save(), name: 'exam_results_$examName.pdf');
  }
}
