import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../shared/models/paginated_response.dart';
import '../domain/admission_application.dart';

final admissionRepositoryProvider = Provider((ref) => AdmissionRepository(ref));

final admissionPaginationProvider = FutureProvider.family.autoDispose<PaginatedResponse<AdmissionApplication>, AdmissionPaginationParams>((ref, params) async {
  return ref.watch(admissionRepositoryProvider).getApplicationsPaginated(
    page: params.page,
    pageSize: params.pageSize,
    search: params.search,
    status: params.status,
  );
});

class AdmissionPaginationParams {
  final int page;
  final int pageSize;
  final String? search;
  final String? status;

  AdmissionPaginationParams({
    this.page = 1,
    this.pageSize = 10,
    this.search,
    this.status,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdmissionPaginationParams &&
          runtimeType == other.runtimeType &&
          page == other.page &&
          pageSize == other.pageSize &&
          search == other.search &&
          status == other.status;

  @override
  int get hashCode => Object.hash(page, pageSize, search, status);
}

class AdmissionRepository {
  final Ref _ref;

  AdmissionRepository(this._ref);

  Future<PaginatedResponse<AdmissionApplication>> getApplicationsPaginated({
    int page = 1,
    int pageSize = 10,
    String? search,
    String? status,
  }) async {
    final dio = _ref.read(apiClientProvider).client;
    try {
      final Map<String, dynamic> queryParams = {
        'page': page,
        'page_size': pageSize,
      };
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (status != null && status.isNotEmpty && status != 'All') queryParams['status'] = status;

      final response = await dio.get('/admission/applications/', queryParameters: queryParams);
      return PaginatedResponse.fromJson(
        response.data,
        (json) => AdmissionApplication.fromJson(json as Map<String, dynamic>),
      );
    } catch (e) {
      throw Exception('Failed to fetch admission applications: $e');
    }
  }

  Future<void> updateApplicationStatus(String id, String newStatus, {String? notes}) async {
    final dio = _ref.read(apiClientProvider).client;
    try {
      // The backend method is update_status but exposed via detail update (PATCH) usually.
      // However, looking at the model, status is a field. updating it via PATCH /applications/{id}/ should call save(), which triggers update logic if overridden?
      // Wait, model.update_status is a helper. The serializer allows status field update.
      // So simple PATCH should work.
      await dio.patch('/admission/applications/$id/', data: {
        'status': newStatus,
        // 'notes': notes // If backend serializer accepts notes, otherwise logic handles logging.
        // Serializer implies basic update.
      });
    } catch (e) {
      throw Exception('Failed to update status: $e');
    }
  }
}
