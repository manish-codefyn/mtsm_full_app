import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/constants.dart';

final apiClientProvider = Provider((ref) => ApiClient(ref));

class ApiClient {
  final Ref _ref;
  final Dio _dio;
  final _storage = const FlutterSecureStorage();

  ApiClient(this._ref)
      : _dio = Dio(BaseOptions(
          baseUrl: AppConstants.defaultBaseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
          contentType: 'application/json',
        )) {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Add auth token if available
        final token = await _storage.read(key: AppConstants.tokenKey);
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        
        // Add X-Tenant-ID header for tenant selection (Strategy 3)
        final tenantSchema = await _storage.read(key: AppConstants.tenantSchemaKey);
        if (tenantSchema != null) {
          options.headers['X-Tenant-ID'] = tenantSchema;
        }
        
        print('Request URL: ${options.baseUrl}${options.path}');
        return handler.next(options);
      },
    ));

    // Initialize base URL from storage
    _initBaseUrl();
  }

  void _initBaseUrl() async {
    final url = await _storage.read(key: AppConstants.tenantUrlKey);
    if (url != null) {
      // Ensure URL ends with / but doesn't include /api/v1/
      String baseUrl = url.endsWith('/') ? url : '$url/';
      _dio.options.baseUrl = baseUrl;
      print('ApiClient: Restored Base URL to $baseUrl');
    }
  }

  void setBaseUrl(String url) {
    // Ensure URL ends with / but doesn't include /api/v1/
    String baseUrl = url.endsWith('/') ? url : '$url/';
    _dio.options.baseUrl = baseUrl;
    _storage.write(key: AppConstants.tenantUrlKey, value: baseUrl);
    print('ApiClient: Updated Base URL to $baseUrl');
  }

  Dio get client => _dio;
}
