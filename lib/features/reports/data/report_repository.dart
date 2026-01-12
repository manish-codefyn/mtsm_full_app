import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';

final reportRepositoryProvider = Provider<ReportRepository>((ref) {
  return ReportRepository(ref.read(apiClientProvider));
});

class ReportRepository {
  final ApiClient _apiClient;

  ReportRepository(this._apiClient);

  Future<Uint8List> downloadReport(String type) async {
    try {
      final response = await _apiClient.get(
        '/reports/download/$type/', 
        options: Options(responseType: ResponseType.bytes),
      );
      
      // When responseType is bytes, response.data is List<int>
      return Uint8List.fromList(response.data);
    } catch (e) {
      throw Exception('Failed to download report: $e');
    }
  }
}
