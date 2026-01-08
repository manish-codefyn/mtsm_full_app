import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../domain/academic_year.dart';

final academicsRepositoryProvider = Provider((ref) => AcademicsRepository(ref));

final currentAcademicYearProvider = FutureProvider<AcademicYear?>((ref) async {
  final years = await ref.watch(academicsRepositoryProvider).getAcademicYears();
  try {
    return years.firstWhere((element) => element.isCurrent);
  } catch (_) {
    if (years.isNotEmpty) return years.first;
    return null;
  }
});

final dashboardStatsProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  return ref.watch(academicsRepositoryProvider).getDashboardStats();
});

class AcademicsRepository {
  final Ref _ref;

  AcademicsRepository(this._ref);

  Future<Map<String, dynamic>> getDashboardStats() async {
    final dio = _ref.read(apiClientProvider).client;
    final response = await dio.get('academics/dashboard/');
    return response.data;
  }

  Future<List<AcademicYear>> getAcademicYears() async {
    final dio = _ref.read(apiClientProvider).client;
    final response = await dio.get('academics/academic-years/');
    
    // Handle pagination or list
    final data = response.data;
    if (data is Map && data.containsKey('results')) {
       return (data['results'] as List).map((e) => AcademicYear.fromJson(e)).toList();
    } else if (data is List) {
       return data.map((e) => AcademicYear.fromJson(e)).toList();
    }
    return [];
  }
}
