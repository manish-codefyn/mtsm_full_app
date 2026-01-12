import 'dart:typed_data'; // Add this import
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../shared/models/paginated_response.dart';
import '../domain/models.dart';
import 'package:printing/printing.dart';

final academicsRepositoryProvider = Provider((ref) => AcademicsRepository(ref));

// Providers for each entity type
final classesPaginationProvider = FutureProvider.family.autoDispose<PaginatedResponse<SchoolClass>, AcademicsPaginationParams>((ref, params) async {
  return ref.watch(academicsRepositoryProvider).getClassesPaginated(params);
});

final sectionsPaginationProvider = FutureProvider.family.autoDispose<PaginatedResponse<Section>, AcademicsPaginationParams>((ref, params) async {
  return ref.watch(academicsRepositoryProvider).getSectionsPaginated(params);
});

final subjectsPaginationProvider = FutureProvider.family.autoDispose<PaginatedResponse<Subject>, AcademicsPaginationParams>((ref, params) async {
  return ref.watch(academicsRepositoryProvider).getSubjectsPaginated(params);
});

final academicYearsPaginationProvider = FutureProvider.family.autoDispose<PaginatedResponse<AcademicYear>, AcademicsPaginationParams>((ref, params) async {
  return ref.watch(academicsRepositoryProvider).getAcademicYears(params);
});

final termsPaginationProvider = FutureProvider.family.autoDispose<PaginatedResponse<Term>, AcademicsPaginationParams>((ref, params) async {
  return ref.watch(academicsRepositoryProvider).getTerms(params);
});

final streamsPaginationProvider = FutureProvider.family.autoDispose<PaginatedResponse<Stream>, AcademicsPaginationParams>((ref, params) async {
  return ref.watch(academicsRepositoryProvider).getStreams(params);
});

final classSubjectsPaginationProvider = FutureProvider.family.autoDispose<PaginatedResponse<ClassSubject>, AcademicsPaginationParams>((ref, params) async {
  return ref.watch(academicsRepositoryProvider).getClassSubjects(params);
});

final timetableProvider = FutureProvider.family.autoDispose<PaginatedResponse<TimeTable>, AcademicsPaginationParams>((ref, params) async {
  return ref.watch(academicsRepositoryProvider).getTimetable(params);
});

// Dashboard Stats Provider
final dashboardStatsProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  return ref.watch(academicsRepositoryProvider).getDashboardStats();
});

// Current Academic Year Provider
final currentAcademicYearProvider = FutureProvider.autoDispose<AcademicYear>((ref) async {
  return ref.watch(academicsRepositoryProvider).getCurrentAcademicYear();
});

class AcademicsPaginationParams {
  final int page;
  final int pageSize;
  final String? search;
  final String? classId;
  final String? sectionId;
  final String? academicYearId;

  const AcademicsPaginationParams({
    this.page = 1,
    this.pageSize = 10,
    this.search,
    this.classId,
    this.sectionId,
    this.academicYearId,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AcademicsPaginationParams &&
          runtimeType == other.runtimeType &&
          page == other.page &&
          pageSize == other.pageSize &&
          search == other.search &&
          classId == other.classId &&
          sectionId == other.sectionId &&
          academicYearId == other.academicYearId;

  @override
  int get hashCode => Object.hash(page, pageSize, search, classId, sectionId, academicYearId);
}

// ...



class AcademicsRepository {
  final Ref _ref;

  AcademicsRepository(this._ref);

  Future<PaginatedResponse<SchoolClass>> getClassesPaginated(AcademicsPaginationParams params) async {
    final dio = _ref.read(apiClientProvider).client;
    try {
      final Map<String, dynamic> queryParams = {
        'page': params.page,
        'page_size': params.pageSize,
      };
      if (params.search != null && params.search!.isNotEmpty) queryParams['search'] = params.search;
      if (params.academicYearId != null) queryParams['academic_year'] = params.academicYearId;

      final response = await dio.get('/academics/classes/', queryParameters: queryParams);
      return PaginatedResponse.fromJson(
        response.data,
        (json) => SchoolClass.fromJson(json as Map<String, dynamic>),
      );
    } catch (e) {
      throw Exception('Failed to fetch classes: $e');
    }
  }

  // DASHBOARD
  Future<Map<String, dynamic>> getDashboardStats() async {
    final dio = _ref.read(apiClientProvider).client;
    try {
      final response = await dio.get('/academics/dashboard/');
      return response.data;
    } catch (e) {
      throw Exception('Failed to fetch dashboard stats: $e');
    }
  }

  // ACADEMIC YEAR
  Future<PaginatedResponse<AcademicYear>> getAcademicYears(AcademicsPaginationParams params) async {
    final dio = _ref.read(apiClientProvider).client;
    try {
      final Map<String, dynamic> queryParams = {
        'page': params.page,
        'page_size': params.pageSize,
      };
      if (params.search != null && params.search!.isNotEmpty) queryParams['search'] = params.search;

      final response = await dio.get('/academics/academic-years/', queryParameters: queryParams);
      return PaginatedResponse.fromJson(
        response.data,
        (json) => AcademicYear.fromJson(json as Map<String, dynamic>),
      );
    } catch (e) {
      throw Exception('Failed to fetch academic years: $e');
    }
  }

  Future<AcademicYear> getAcademicYear(String id) async {
    final dio = _ref.read(apiClientProvider).client;
    try {
      final response = await dio.get('/academics/academic-years/$id/');
      return AcademicYear.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to fetch academic year: $e');
    }
  }

  Future<void> createAcademicYear(Map<String, dynamic> data) async {
    final dio = _ref.read(apiClientProvider).client;
    try {
      await dio.post('/academics/academic-years/', data: data);
    } catch (e) {
      throw Exception('Failed to create academic year: $e');
    }
  }

  Future<void> updateAcademicYear(String id, Map<String, dynamic> data) async {
    final dio = _ref.read(apiClientProvider).client;
    try {
      await dio.patch('/academics/academic-years/$id/', data: data);
    } catch (e) {
      throw Exception('Failed to update academic year: $e');
    }
  }

  Future<void> deleteAcademicYear(String id) async {
    final dio = _ref.read(apiClientProvider).client;
    try {
      await dio.delete('/academics/academic-years/$id/');
    } catch (e) {
      throw Exception('Failed to delete academic year: $e');
    }
  }

  Future<List<AcademicYear>> getAllAcademicYears() async {
     final dio = _ref.read(apiClientProvider).client;
     try {
       final response = await dio.get('/academics/academic-years/', queryParameters: {'page_size': 100});
       final data = PaginatedResponse.fromJson(response.data, (json) => AcademicYear.fromJson(json));
       return data.results;
     } catch (e) {
       return [];
     }
  }

  // TERMS
  Future<PaginatedResponse<Term>> getTerms(AcademicsPaginationParams params) async {
    final dio = _ref.read(apiClientProvider).client;
    try {
      final Map<String, dynamic> queryParams = {
        'page': params.page,
        'page_size': params.pageSize,
      };
      if (params.search != null && params.search!.isNotEmpty) queryParams['search'] = params.search;

      final response = await dio.get('/academics/terms/', queryParameters: queryParams);
      return PaginatedResponse.fromJson(
        response.data,
        (json) => Term.fromJson(json as Map<String, dynamic>),
      );
    } catch (e) {
      throw Exception('Failed to fetch terms: $e');
    }
  }

  Future<Term> getTerm(String id) async {
    final dio = _ref.read(apiClientProvider).client;
    try {
      final response = await dio.get('/academics/terms/$id/');
      return Term.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to fetch term: $e');
    }
  }

  Future<void> createTerm(Map<String, dynamic> data) async {
    final dio = _ref.read(apiClientProvider).client;
    try {
      await dio.post('/academics/terms/', data: data);
    } catch (e) {
      throw Exception('Failed to create term: $e');
    }
  }

  Future<void> updateTerm(String id, Map<String, dynamic> data) async {
    final dio = _ref.read(apiClientProvider).client;
    try {
      await dio.patch('/academics/terms/$id/', data: data);
    } catch (e) {
      throw Exception('Failed to update term: $e');
    }
  }

  Future<void> deleteTerm(String id) async {
    final dio = _ref.read(apiClientProvider).client;
    try {
      await dio.delete('/academics/terms/$id/');
    } catch (e) {
      throw Exception('Failed to delete term: $e');
    }
  }

  // STREAMS
  Future<PaginatedResponse<Stream>> getStreams(AcademicsPaginationParams params) async {
    final dio = _ref.read(apiClientProvider).client;
    try {
      final Map<String, dynamic> queryParams = {
        'page': params.page,
        'page_size': params.pageSize,
      };
      if (params.search != null && params.search!.isNotEmpty) queryParams['search'] = params.search;

      final response = await dio.get('/academics/streams/', queryParameters: queryParams);
      return PaginatedResponse.fromJson(
        response.data,
        (json) => Stream.fromJson(json as Map<String, dynamic>),
      );
    } catch (e) {
      throw Exception('Failed to fetch streams: $e');
    }
  }

  Future<Stream> getStream(String id) async {
    final dio = _ref.read(apiClientProvider).client;
    try {
      final response = await dio.get('/academics/streams/$id/');
      return Stream.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to fetch stream: $e');
    }
  }

  Future<void> createStream(Map<String, dynamic> data) async {
    final dio = _ref.read(apiClientProvider).client;
    try {
      await dio.post('/academics/streams/', data: data);
    } catch (e) {
      throw Exception('Failed to create stream: $e');
    }
  }

  Future<void> updateStream(String id, Map<String, dynamic> data) async {
    final dio = _ref.read(apiClientProvider).client;
    try {
      await dio.patch('/academics/streams/$id/', data: data);
    } catch (e) {
      throw Exception('Failed to update stream: $e');
    }
  }

  Future<void> deleteStream(String id) async {
    final dio = _ref.read(apiClientProvider).client;
    try {
      await dio.delete('/academics/streams/$id/');
    } catch (e) {
      throw Exception('Failed to delete stream: $e');
    }
  }

  Future<List<Stream>> getAllStreams() async {
     final dio = _ref.read(apiClientProvider).client;
     try {
       final response = await dio.get('/academics/streams/', queryParameters: {'page_size': 100});
       final data = PaginatedResponse.fromJson(response.data, (json) => Stream.fromJson(json));
       return data.results;
     } catch (e) {
       return [];
     }
  }

  // CLASS SUBJECTS
  Future<PaginatedResponse<ClassSubject>> getClassSubjects(AcademicsPaginationParams params) async {
    final dio = _ref.read(apiClientProvider).client;
    try {
      final Map<String, dynamic> queryParams = {
        'page': params.page,
        'page_size': params.pageSize,
      };
      if (params.search != null && params.search!.isNotEmpty) queryParams['search'] = params.search;

      final response = await dio.get('/academics/class-subjects/', queryParameters: queryParams);
      return PaginatedResponse.fromJson(
        response.data,
        (json) => ClassSubject.fromJson(json as Map<String, dynamic>),
      );
    } catch (e) {
      throw Exception('Failed to fetch class subjects: $e');
    }
  }

  Future<ClassSubject> getClassSubject(String id) async {
    final dio = _ref.read(apiClientProvider).client;
    try {
      final response = await dio.get('/academics/class-subjects/$id/');
      return ClassSubject.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to fetch class subject: $e');
    }
  }

  Future<void> createClassSubject(Map<String, dynamic> data) async {
    final dio = _ref.read(apiClientProvider).client;
    try {
      await dio.post('/academics/class-subjects/', data: data);
    } catch (e) {
      throw Exception('Failed to create class subject: $e');
    }
  }

  Future<void> updateClassSubject(String id, Map<String, dynamic> data) async {
    final dio = _ref.read(apiClientProvider).client;
    try {
      await dio.patch('/academics/class-subjects/$id/', data: data);
    } catch (e) {
      throw Exception('Failed to update class subject: $e');
    }
  }

  Future<void> deleteClassSubject(String id) async {
    final dio = _ref.read(apiClientProvider).client;
    try {
      await dio.delete('/academics/class-subjects/$id/');
    } catch (e) {
      throw Exception('Failed to delete class subject: $e');
    }
  }

  Future<AcademicYear> getCurrentAcademicYear() async {
    final dio = _ref.read(apiClientProvider).client;
    try {
      // Fetch active academic year. Assuming backend supports filtering or returns sorted list.
      // If we can't filter by is_active via API params easily without checking, we'll fetch list.
      final response = await dio.get('/academics/academic-years/');
      final data = PaginatedResponse.fromJson(
        response.data, 
        (json) => AcademicYear.fromJson(json as Map<String, dynamic>)
      );
      
      // Find active one
      return data.results.firstWhere(
        (ay) => ay.isActive == true, 
        orElse: () => data.results.isNotEmpty ? data.results.first : throw Exception('No academic years found')
      );
    } catch (e) {
      throw Exception('Failed to fetch current academic year: $e');
    }
  }

  // CLASSES


  Future<SchoolClass> getClass(String id) async {
    final dio = _ref.read(apiClientProvider).client;
    try {
      final response = await dio.get('/academics/classes/$id/');
      return SchoolClass.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to fetch class: $e');
    }
  }

  Future<void> createClass(Map<String, dynamic> data) async {
    final dio = _ref.read(apiClientProvider).client;
    try {
      await dio.post('/academics/classes/', data: data);
    } catch (e) {
      throw Exception('Failed to create class: $e');
    }
  }

  Future<void> updateClass(String id, Map<String, dynamic> data) async {
    final dio = _ref.read(apiClientProvider).client;
    try {
      await dio.patch('/academics/classes/$id/', data: data);
    } catch (e) {
      throw Exception('Failed to update class: $e');
    }
  }

  Future<void> deleteClass(String id) async {
    final dio = _ref.read(apiClientProvider).client;
    try {
      await dio.delete('/academics/classes/$id/');
    } catch (e) {
      throw Exception('Failed to delete class: $e');
    }
  }

  // SECTIONS
  Future<PaginatedResponse<Section>> getSectionsPaginated(AcademicsPaginationParams params) async {
    final dio = _ref.read(apiClientProvider).client;
    try {
      final Map<String, dynamic> queryParams = {
        'page': params.page,
        'page_size': params.pageSize,
      };
      if (params.search != null && params.search!.isNotEmpty) queryParams['search'] = params.search;
      if (params.classId != null && params.classId!.isNotEmpty) queryParams['class_name'] = params.classId;

      final response = await dio.get('/academics/sections/', queryParameters: queryParams);
      return PaginatedResponse.fromJson(
        response.data,
        (json) => Section.fromJson(json as Map<String, dynamic>),
      );
    } catch (e) {
      throw Exception('Failed to fetch sections: $e');
    }
  }

  Future<Section> getSection(String id) async {
    final dio = _ref.read(apiClientProvider).client;
    try {
      final response = await dio.get('/academics/sections/$id/');
      return Section.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to fetch section: $e');
    }
  }

  Future<void> createSection(Map<String, dynamic> data) async {
    final dio = _ref.read(apiClientProvider).client;
    try {
      await dio.post('/academics/sections/', data: data);
    } catch (e) {
      throw Exception('Failed to create section: $e');
    }
  }

  Future<void> updateSection(String id, Map<String, dynamic> data) async {
    final dio = _ref.read(apiClientProvider).client;
    try {
      await dio.patch('/academics/sections/$id/', data: data);
    } catch (e) {
      throw Exception('Failed to update section: $e');
    }
  }

  Future<void> deleteSection(String id) async {
    final dio = _ref.read(apiClientProvider).client;
    try {
      await dio.delete('/academics/sections/$id/');
    } catch (e) {
      throw Exception('Failed to delete section: $e');
    }
  }

  // SUBJECTS
  Future<PaginatedResponse<Subject>> getSubjectsPaginated(AcademicsPaginationParams params) async {
    final dio = _ref.read(apiClientProvider).client;
    try {
      final Map<String, dynamic> queryParams = {'page': params.page, 'page_size': params.pageSize};
       if (params.search != null && params.search!.isNotEmpty) queryParams['search'] = params.search;
      
      final response = await dio.get('/academics/subjects/', queryParameters: queryParams);
      return PaginatedResponse.fromJson(
        response.data,
        (json) => Subject.fromJson(json as Map<String, dynamic>),
      );
    } catch (e) {
      throw Exception('Failed to fetch subjects: $e');
    }
  }
  Future<PaginatedResponse<Subject>> getSubjects({int page=1, int pageSize=10}) async {
    return getSubjectsPaginated(AcademicsPaginationParams(page: page, pageSize: pageSize));
  }


  Future<Subject> getSubject(String id) async {
    final dio = _ref.read(apiClientProvider).client;
    try {
      final response = await dio.get('/academics/subjects/$id/');
      return Subject.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to fetch subject: $e');
    }
  }

  Future<void> createSubject(Map<String, dynamic> data) async {
    final dio = _ref.read(apiClientProvider).client;
    try {
      await dio.post('/academics/subjects/', data: data);
    } catch (e) {
      throw Exception('Failed to create subject: $e');
    }
  }

  Future<void> updateSubject(String id, Map<String, dynamic> data) async {
    final dio = _ref.read(apiClientProvider).client;
    try {
      await dio.patch('/academics/subjects/$id/', data: data);
    } catch (e) {
      throw Exception('Failed to update subject: $e');
    }
  }

  Future<void> deleteSubject(String id) async {
    final dio = _ref.read(apiClientProvider).client;
    try {
      await dio.delete('/academics/subjects/$id/');
    } catch (e) {
      throw Exception('Failed to delete subject: $e');
    }
  }

  // FUTURE: Helper to get all classes for dropdowns (non-paginated if supported or large page size)
  Future<List<SchoolClass>> getAllClasses() async {
     final dio = _ref.read(apiClientProvider).client;
     try {
       // Assuming backend supports page_size=100 or similar for now.
       final response = await dio.get('/academics/classes/', queryParameters: {'page_size': 100});
       final data = PaginatedResponse.fromJson(response.data, (json) => SchoolClass.fromJson(json));
       return data.results;
     } catch (e) {
       return [];
     }
  }

  Future<List<Subject>> getAllSubjects() async {
     final dio = _ref.read(apiClientProvider).client;
     try {
       final response = await dio.get('/academics/subjects/', queryParameters: {'page_size': 100});
       final data = PaginatedResponse.fromJson(response.data, (json) => Subject.fromJson(json));
       return data.results;
     } catch (e) {
       return [];
     }
  }


  // USERS
  Future<List<Map<String, dynamic>>> getTeachers() async {
     final dio = _ref.read(apiClientProvider).client;
     try {
       // Fetching staff/teachers. Using /hr/staffs/ as a proxy for now, or /users/?role=teacher if available.
       // Based on HR repo, /hr/staffs/ exists.
       final response = await dio.get('/hr/staffs/', queryParameters: {'page_size': 100});
       final data = response.data;
       final List<dynamic> results = (data is Map && data.containsKey('results')) 
          ? data['results'] 
          : (data is List ? data : []);
       
       return results.cast<Map<String, dynamic>>();
     } catch (e) {
       return [];
     }
  }

  // AUTO GENERATION
  Future<void> autoGenerateTimetable({
    required String classId,
    required String sectionId,
    required String academicYearId,
  }) async {
    final dio = _ref.read(apiClientProvider).client;
    // Don't wrap in try-catch to allow UI to handle specific DioErrors (like 400 validation)
    await dio.post(
      '/academics/timetable/auto-generate/',
      data: {
        'class_id': classId,
        'section_id': sectionId,
        'academic_year': academicYearId,
      },
    );
  }

  Future<void> initializeSubjects() async {
    final dio = _ref.read(apiClientProvider).client;
    try {
      await dio.post('/academics/subjects/initialize/');
    } catch (e) {
      throw Exception('Failed to initialize subjects: $e');
    }
  }

  Future<void> initializeClassSubjects() async {
    final dio = _ref.read(apiClientProvider).client;
    try {
      await dio.post('/academics/class-subjects/initialize/');
    } catch (e) {
      throw Exception('Failed to initialize class subjects: $e');
    }
  }
  
  Future<void> autoGenerateHolidays() async {
    final dio = _ref.read(apiClientProvider).client;
    try {
      await dio.post('/academics/holidays/auto-generate/');
    } catch (e) {
      throw Exception('Failed to auto-generate holidays: $e');
    }
  }

  Future<void> autoGenerateHouses() async {
    final dio = _ref.read(apiClientProvider).client;
    try {
      await dio.post('/academics/houses/auto-generate/');
    } catch (e) {
      throw Exception('Failed to auto-generate houses: $e');
    }
  }

  Future<void> autoGenerateGradingSystem() async {
    final dio = _ref.read(apiClientProvider).client;
    try {
      await dio.post('/academics/grading-systems/auto-generate/');
    } catch (e) {
      throw Exception('Failed to auto-generate grading system: $e');
    }
  }

  // HOLIDAYS
  Future<PaginatedResponse<Holiday>> getHolidays(AcademicsPaginationParams params) async {
    final dio = _ref.read(apiClientProvider).client;
    try {
      final Map<String, dynamic> queryParams = {'page': params.page, 'page_size': params.pageSize};
      if (params.search != null) queryParams['search'] = params.search;
      final response = await dio.get('/academics/holidays/', queryParameters: queryParams);
      return PaginatedResponse.fromJson(response.data, (json) => Holiday.fromJson(json));
    } catch (e) {
      throw Exception('Failed to fetch holidays: $e');
    }
  }

  Future<Holiday> getHoliday(String id) async {
    final dio = _ref.read(apiClientProvider).client;
    try {
      final response = await dio.get('/academics/holidays/$id/');
      return Holiday.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to fetch holiday: $e');
    }
  }

  Future<void> createHoliday(Map<String, dynamic> data) async {
    final dio = _ref.read(apiClientProvider).client;
    try {
      await dio.post('/academics/holidays/', data: data);
    } catch (e) {
      throw Exception('Failed to create holiday: $e');
    }
  }

  Future<void> updateHoliday(String id, Map<String, dynamic> data) async {
    final dio = _ref.read(apiClientProvider).client;
    try {
      await dio.patch('/academics/holidays/$id/', data: data);
    } catch (e) {
      throw Exception('Failed to update holiday: $e');
    }
  }
  
  Future<void> deleteHoliday(String id) async {
    final dio = _ref.read(apiClientProvider).client;
    try {
      await dio.delete('/academics/holidays/$id/');
    } catch (e) {
      throw Exception('Failed to delete holiday: $e');
    }
  }

  Future<void> downloadHolidaysPdf() async {
    final dio = _ref.read(apiClientProvider).client;
    try {
      final response = await dio.get(
        'academics/holidays/download/',
        options: Options(responseType: ResponseType.bytes),
      );
      
      // Use printing package to share/save the PDF
      await Printing.sharePdf(
        bytes: Uint8List.fromList(response.data),
        filename: 'holidays.pdf',
      );
    } catch (e) {
      throw Exception('Failed to download holidays PDF: $e');
    }
  }

  Future<void> downloadStudentAttendanceReport({required String startDate, required String endDate}) async {
    final dio = _ref.read(apiClientProvider).client;
    try {
      final response = await dio.get(
        '/academics/attendance/download/',
        queryParameters: {'start_date': startDate, 'end_date': endDate},
        options: Options(responseType: ResponseType.bytes),
      );
      
      await Printing.sharePdf(
        bytes: Uint8List.fromList(response.data),
        filename: 'attendance_report_${startDate}_$endDate.pdf',
      );
    } catch (e) {
       // Allow UI to handle specific errors if needed, or rethrow
      throw Exception('Failed to download student attendance report: $e');
    }
  }

  // HOUSES
  Future<PaginatedResponse<House>> getHouses(AcademicsPaginationParams params) async {
    final dio = _ref.read(apiClientProvider).client;
    try {
      final Map<String, dynamic> queryParams = {'page': params.page, 'page_size': params.pageSize};
      if (params.search != null) queryParams['search'] = params.search;
      final response = await dio.get('/academics/houses/', queryParameters: queryParams);
      return PaginatedResponse.fromJson(response.data, (json) => House.fromJson(json));
    } catch (e) {
      throw Exception('Failed to fetch houses: $e');
    }
  }
  
  Future<void> createHouse(Map<String, dynamic> data) async {
     final dio = _ref.read(apiClientProvider).client;
     await dio.post('/academics/houses/', data: data);
  }
  
  Future<void> deleteHouse(String id) async {
     final dio = _ref.read(apiClientProvider).client;
     await dio.delete('/academics/houses/$id/');
  }

  // GRADING SYSTEM
  Future<PaginatedResponse<GradingSystem>> getGradingSystems(AcademicsPaginationParams params) async {
    final dio = _ref.read(apiClientProvider).client;
    try {
      final response = await dio.get('/academics/grading-systems/', queryParameters: {'page': params.page, 'page_size': params.pageSize});
      return PaginatedResponse.fromJson(response.data, (json) => GradingSystem.fromJson(json));
    } catch (e) {
      throw Exception('Failed to fetch grading systems: $e');
    }
  }
  
  Future<void> createGradingSystem(Map<String, dynamic> data) async {
     final dio = _ref.read(apiClientProvider).client;
     try {
        await dio.post('/academics/grading-systems/', data: data);
     } catch (e) {
        throw Exception('Failed to create grading system: $e');
     }
  }

  Future<void> deleteGradingSystem(String id) async {
     final dio = _ref.read(apiClientProvider).client;
     try {
        await dio.delete('/academics/grading-systems/$id/');
     } catch (e) {
        throw Exception('Failed to delete grading system: $e');
     }
  }
  Future<PaginatedResponse<Grade>> getGrades(String systemId) async {
    final dio = _ref.read(apiClientProvider).client;
    try {
       // Assuming we can filter grades by system, or just fetch all for now
       final response = await dio.get('/academics/grades/', queryParameters: {'grading_system': systemId, 'page_size': 100});
       return PaginatedResponse.fromJson(response.data, (json) => Grade.fromJson(json));
    } catch (e) {
       throw Exception('Failed to fetch grades: $e');
    }
  }

  Future<void> createGrade(Map<String, dynamic> data) async {
     final dio = _ref.read(apiClientProvider).client;
     try {
        await dio.post('/academics/grades/', data: data);
     } catch (e) {
        throw Exception('Failed to create grade: $e');
     }
  }

  Future<void> deleteGrade(String id) async {
     final dio = _ref.read(apiClientProvider).client;
     try {
        await dio.delete('/academics/grades/$id/');
     } catch (e) {
        throw Exception('Failed to delete grade: $e');
    }
  }

  // AUTO GENERATE METHODS
  Future<void> autoGenerateTerms() async {
    final dio = _ref.read(apiClientProvider).client;
    try {
      await dio.post('/academics/terms/auto-generate/');
    } catch (e) {
      throw Exception('Failed to auto-generate terms: $e');
    }
  }

  Future<void> autoGenerateStreams() async {
    final dio = _ref.read(apiClientProvider).client;
    try {
      await dio.post('/academics/streams/auto-generate/');
    } catch (e) {
      throw Exception('Failed to auto-generate streams: $e');
    }
  }

  // TIMETABLE
  Future<PaginatedResponse<TimeTable>> getTimetable(AcademicsPaginationParams params) async {
    final dio = _ref.read(apiClientProvider).client;
    try {
      final Map<String, dynamic> queryParams = {
        'page': params.page,
        'page_size': params.pageSize,
        'ordering': 'day,period_number', // Ensure logical order
      };
      if (params.search != null && params.search!.isNotEmpty) queryParams['search'] = params.search;
      if (params.classId != null && params.classId!.isNotEmpty) queryParams['class_name'] = params.classId;
      if (params.sectionId != null && params.sectionId!.isNotEmpty) queryParams['section'] = params.sectionId;

      final response = await dio.get('/academics/timetables/', queryParameters: queryParams);
      return PaginatedResponse.fromJson(
        response.data,
        (json) => TimeTable.fromJson(json as Map<String, dynamic>),
      );
    } catch (e) {
      throw Exception('Failed to fetch timetable: $e');
    }
  }

  Future<Uint8List> downloadTimetablePdf(String classId, String sectionId) async {
    final dio = _ref.read(apiClientProvider).client;
    try {
      final response = await dio.get(
        '/academics/timetables/download/',
        queryParameters: {'class_id': classId, 'section_id': sectionId},
        options: Options(responseType: ResponseType.bytes),
      );
      return Uint8List.fromList(response.data);
    } catch (e) {
      throw e; // Rethrow to let UI handle DioException
    }
  }

  Future<void> createTimetableEntry(Map<String, dynamic> data) async {
      final dio = _ref.read(apiClientProvider).client;
      try {
        await dio.post('/academics/timetables/', data: data);
      } catch (e) {
        rethrow;
      }
  }

  Future<void> deleteTimetableEntry(String id) async {
      final dio = _ref.read(apiClientProvider).client;
      try {
        await dio.delete('/academics/timetables/$id/');
      } catch (e) {
        rethrow;
      }
  }
  Future<void> updateTimetableEntry(String id, Map<String, dynamic> data) async {
      final dio = _ref.read(apiClientProvider).client;
      try {
        await dio.patch('/academics/timetables/$id/', data: data);
      } catch (e) {
        rethrow;
      }
  }

  // Helper for dropdowns
  Future<List<ClassSubject>> getAllClassSubjects(String classId) async {
     final dio = _ref.read(apiClientProvider).client;
     try {
       final response = await dio.get('/academics/class-subjects/', queryParameters: {
         'class_name': classId,
         'page_size': 100
       });
       final data = PaginatedResponse.fromJson(
         response.data, 
         (json) => ClassSubject.fromJson(json as Map<String, dynamic>)
       );
       return data.results;
     } catch (e) {
       return [];
     }
  }

  // SYLLABUS
  Future<PaginatedResponse<Syllabus>> getSyllabus(AcademicsPaginationParams params) async {
    final dio = _ref.read(apiClientProvider).client;
    try {
      final Map<String, dynamic> queryParams = {'page': params.page, 'page_size': params.pageSize};
      if (params.search != null) queryParams['search'] = params.search;
      final response = await dio.get('/academics/syllabus/', queryParameters: queryParams);
      return PaginatedResponse.fromJson(response.data, (json) => Syllabus.fromJson(json));
    } catch (e) {
      throw Exception('Failed to fetch syllabus: $e');
    }
  }

  Future<void> createSyllabus(Map<String, dynamic> data) async {
    final dio = _ref.read(apiClientProvider).client;
    try {
      await dio.post('/academics/syllabus/', data: data);
    } catch (e) {
      throw Exception('Failed to create syllabus: $e');
    }
  }

  Future<void> autoGenerateSyllabus() async {
    final dio = _ref.read(apiClientProvider).client;
    try {
      await dio.post('/academics/syllabus/auto-generate/');
    } catch (e) {
      throw Exception('Failed to auto-generate syllabus: $e');
    }
  }

  Future<Uint8List> downloadSyllabusPdf(String id) async {
    final dio = _ref.read(apiClientProvider).client;
    try {
      final response = await dio.get(
        '/academics/syllabus/$id/download/',
        options: Options(responseType: ResponseType.bytes),
      );
      return Uint8List.fromList(response.data);
    } catch (e) {
      throw Exception('Failed to download syllabus: $e');
    }
  }

  // STUDY MATERIALS
  Future<PaginatedResponse<StudyMaterial>> getStudyMaterials(AcademicsPaginationParams params) async {
    final dio = _ref.read(apiClientProvider).client;
    try {
      final Map<String, dynamic> queryParams = {
        'page': params.page,
        'page_size': params.pageSize,
      };
      if (params.search != null && params.search!.isNotEmpty) queryParams['search'] = params.search;
      if (params.classId != null) queryParams['class_name'] = params.classId;

      final response = await dio.get('/academics/study-materials/', queryParameters: queryParams);
      return PaginatedResponse.fromJson(
        response.data,
        (json) => StudyMaterial.fromJson(json as Map<String, dynamic>),
      );
    } catch (e) {
      throw Exception('Failed to fetch study materials: $e');
    }
  }

  Future<void> createStudyMaterial(Map<String, dynamic> data) async {
    final dio = _ref.read(apiClientProvider).client;
    try {
      // If data has file path, we need MultipartRequest.
      FormData formData = FormData.fromMap(data);
      if (data.containsKey('file_path') && data['file_path'] != null) {
          formData.files.add(MapEntry(
            'file',
            await MultipartFile.fromFile(data['file_path']),
          ));
          data.remove('file_path'); 
      }
      
      await dio.post('/academics/study-materials/', data: formData);
    } catch (e) {
      throw Exception('Failed to create study material: $e');
    }
  }
  
  Future<void> autoGenerateStudyMaterial() async {
    final dio = _ref.read(apiClientProvider).client;
    try {
       await dio.post('/academics/study-materials/auto-generate/');
    } catch (e) {
       throw Exception('Failed to auto-generate study materials: $e');
    }
  }

  Future<Uint8List> downloadStudyMaterial(String id, String fileName) async {
    final dio = _ref.read(apiClientProvider).client;
    try {
      final response = await dio.get(
        '/academics/study-materials/$id/download/',
        options: Options(responseType: ResponseType.bytes),
      );
      return Uint8List.fromList(response.data);
    } catch (e) {
      throw Exception('Failed to download study material: $e');
    }
  }

  Future<void> deleteStudyMaterial(String id) async {
    final dio = _ref.read(apiClientProvider).client;
    try {
      await dio.delete('/academics/study-materials/$id/');
    } catch (e) {
       throw Exception('Failed to delete study material: $e');
    }
  }
}
