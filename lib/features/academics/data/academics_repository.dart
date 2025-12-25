import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import 'models/academic_year.dart';

final academicsRepositoryProvider = Provider((ref) => AcademicsRepository(ref));

class AcademicsRepository {
  final Ref _ref;

  AcademicsRepository(this._ref);

  Future<List<AcademicYear>> getAcademicYears() async {
    final dio = _ref.read(apiClientProvider).client;
    final response = await dio.get('academics/academicyears/'); // Adjust endpoint as needed
    
    // Assuming API returns { "results": [...] } or just [...]
    final data = response.data;
    final List<dynamic> results = (data is Map && data.containsKey('results')) 
        ? data['results'] 
        : (data is List ? data : []);

    return results.map((json) => AcademicYear.fromJson(json)).toList();
  }
}
