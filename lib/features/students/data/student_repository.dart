import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../domain/student.dart';

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
  Future<void> createStudent(Map<String, dynamic> data) async {
    final dio = _ref.read(apiClientProvider).client;
    await dio.post('students/students/', data: data);
  }

  Future<void> updateStudent(String id, Map<String, dynamic> data) async {
    final dio = _ref.read(apiClientProvider).client;
    await dio.patch('students/students/$id/', data: data);
  }

  Future<void> deleteStudent(String id) async {
    final dio = _ref.read(apiClientProvider).client;
    await dio.delete('students/students/$id/');
  }

  Future<List<int>> generateIdCard(String id) async {
    final dio = _ref.read(apiClientProvider).client;
    final response = await dio.get(
      'students/students/$id/generate_id_card/',
      options: Options(responseType: ResponseType.bytes),
    );
    return response.data;
  }
}
