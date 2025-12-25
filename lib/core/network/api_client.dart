import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final apiClientProvider = Provider((ref) => ApiClient(ref));

class ApiClient {
  final Ref _ref;
  final Dio _dio;
  final _storage = const FlutterSecureStorage();

  ApiClient(this._ref)
      : _dio = Dio(BaseOptions(
          baseUrl: 'http://127.0.0.1:8000/api/v1/',
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
          contentType: 'application/json',
        )) {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Add auth token if available
        final token = await _storage.read(key: 'access_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        
        // Add X-Tenant-ID header for tenant selection (Strategy 3)
        final tenantSchema = await _storage.read(key: 'tenant_schema');
        if (tenantSchema != null) {
          print('Adding X-Tenant-ID header: $tenantSchema');
          options.headers['X-Tenant-ID'] = tenantSchema;
        }
        
        return handler.next(options);
      },
    ));

    // Initialize base URL from storage
    _initBaseUrl();
  }

  void _initBaseUrl() async {
    final url = await _storage.read(key: 'tenant_url');
    if (url != null) {
      _dio.options.baseUrl = url;
      print('ApiClient: Restored Base URL to $url');
    }
  }

  void setBaseUrl(String url) {
    _dio.options.baseUrl = url;
    print('ApiClient: Updated Base URL to $url');
  }

  Dio get client => _dio;
}
