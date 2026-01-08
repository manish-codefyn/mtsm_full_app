import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http_parser/http_parser.dart'; // for MediaType
import 'package:mime/mime.dart';
import '../../../../core/network/api_client.dart';
import '../domain/student.dart';
import '../domain/onboarding_status.dart';
import '../domain/student_document.dart';

final studentRepositoryProvider = Provider((ref) => StudentRepository(ref));

final studentListProvider = FutureProvider.autoDispose<List<Student>>((ref) async {
  return ref.watch(studentRepositoryProvider).getStudents();
});

class StudentRepository {
  final Ref _ref;

  StudentRepository(this._ref);

  Future<List<Student>> getStudents() async {
    final dio = _ref.read(apiClientProvider).client;
    try {
      final response = await dio.get('students/');
      // Assuming standard DRF paginated response or list
      // For now handling direct list or "results" key
      final data = response.data;
      if (data is Map && data.containsKey('results')) {
        final List<Student> students = [];
        for (var item in (data['results'] as List)) {
          try {
            students.add(Student.fromJson(item));
          } catch (e) {
            print('Error parsing student: $e');
          }
        }
        return students;
      } else if (data is List) {
        return data.map((e) => Student.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }
  Future<String> createStudent(Map<String, dynamic> data) async {
    final dio = _ref.read(apiClientProvider).client;
    final response = await dio.post('students/create/', data: data);
    return response.data['id']; // Assumes backend returns {id: "..."} which StudentCreateAPIView does 
  }

  Future<void> updateStudent(String id, Map<String, dynamic> data) async {
    final dio = _ref.read(apiClientProvider).client;
    await dio.patch('students/$id/update/', data: data);
  }

  Future<void> deleteStudent(String id) async {
    final dio = _ref.read(apiClientProvider).client;
    await dio.delete('students/$id/delete/');
  }

  Future<List<int>> generateIdCard(String id) async {
    final dio = _ref.read(apiClientProvider).client;
    final response = await dio.get(
      'students/$id/id-card/',
      options: Options(responseType: ResponseType.bytes),
    );
    return response.data;
  }

  // Related Models - Medical Info
  Future<Map<String, dynamic>> getMedicalInfo(String studentId) async {
     final dio = _ref.read(apiClientProvider).client;
     final response = await dio.get('students/$studentId/medical/');
     return response.data;
  }

  Future<void> updateMedicalInfo(String studentId, Map<String, dynamic> data) async {
    final dio = _ref.read(apiClientProvider).client;
    await dio.put('students/$studentId/medical/', data: data);
  }

  // Related Models - Identification
  Future<Map<String, dynamic>> getIdentification(String studentId) async {
     final dio = _ref.read(apiClientProvider).client;
     final response = await dio.get('students/$studentId/identification/');
     return response.data;
  }

  Future<void> updateIdentification(String studentId, Map<String, dynamic> data) async {
    final dio = _ref.read(apiClientProvider).client;
    await dio.put('students/$studentId/identification/', data: data);
  }

    // Related Models - Academic History
  Future<List<dynamic>> getAcademicHistory(String studentId) async {
     final dio = _ref.read(apiClientProvider).client;
     final response = await dio.get('students/$studentId/history/');
     return response.data['results'] ?? [];
  }

  Future<void> addAcademicHistory(String studentId, Map<String, dynamic> data) async {
    final dio = _ref.read(apiClientProvider).client;
    await dio.post('students/$studentId/history/', data: data);
  }

  // Onboarding
  Future<OnboardingStatus> getOnboardingStatus(String studentId) async {
    final dio = _ref.read(apiClientProvider).client;
    final response = await dio.get('students/$studentId/onboarding/');
    return OnboardingStatus.fromJson(response.data);
  }

  // Documents
  Future<List<StudentDocument>> getDocuments(String studentId) async {
    final dio = _ref.read(apiClientProvider).client;
    final response = await dio.get('students/$studentId/documents/');
    // Assuming pagination
     final data = response.data;
     if (data is Map && data.containsKey('results')) {
        return (data['results'] as List).map((e) => StudentDocument.fromJson(e)).toList();
     } else if (data is List) {
        return data.map((e) => StudentDocument.fromJson(e)).toList();
     }
    return [];
  }

  Future<void> uploadDocument({
    required String studentId, 
    required String docType, 
    required String fileName,
    String? filePath,
    List<int>? fileBytes, 
  }) async {
    final dio = _ref.read(apiClientProvider).client;
    
    // Determine content type (fallback to octet-stream)
    final mimeType = lookupMimeType(fileName) ?? 'application/octet-stream';
    final typeData = mimeType.split('/');
    
    MultipartFile filePart;
    if (fileBytes != null) {
       filePart = MultipartFile.fromBytes(
         fileBytes,
         filename: fileName,
         contentType: MediaType(typeData[0], typeData[1]),
       );
    } else if (filePath != null) {
       filePart = await MultipartFile.fromFile(
         filePath, 
         filename: fileName, 
         contentType: MediaType(typeData[0], typeData[1])
       );
    } else {
       throw const FileSystemException('No file data provided');
    }

    final formData = FormData.fromMap({
      'student': studentId,
      'doc_type': docType,
      'is_current': true,
      'file': filePart,
    });

    await dio.post('students/$studentId/documents/', data: formData);
  }
}
