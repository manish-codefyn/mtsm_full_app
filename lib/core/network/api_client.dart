import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/constants.dart';
import '../router/app_router.dart'; // Import router provider
import '../../main.dart'; // Import rootScaffoldMessengerKey

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
      onError: (DioException e, handler) async {
        if (e.response?.statusCode == 401) {
           print('ApiClient: 401 Unauthorized Intercepted. Redirecting to login.');
           
           // Show user feedback
           rootScaffoldMessengerKey.currentState?.showSnackBar(
             const SnackBar(
               content: Text('Session Expired. Please login again.'),
               backgroundColor: Colors.red,
             ),
           );

           // Clear token
           await _storage.delete(key: AppConstants.tokenKey);
           // Redirect using router provider
           // Note: We use ref.read because we are inside a callback, mimicking a read.
           // However, accessing providers inside callbacks requires care. 
           // For now, simpler is better: assuming router is alive.
           try {
             _ref.read(routerProvider).go('/login');
           } catch (err) {
             print('ApiClient: Navigation failed: $err');
           }
        }
        return handler.next(e);
      },
    ));

    // Initialize base URL from storage
    _initBaseUrl();
  }

  bool _isManuallyConfigured = false;

  void _initBaseUrl() async {
    final url = await _storage.read(key: AppConstants.tenantUrlKey);
    // If URL was manually set while we were reading, abort restoration
    if (_isManuallyConfigured) return;
    
    if (url != null) {
      // Ensure URL ends with / but doesn't include /api/v1/
      String baseUrl = url.endsWith('/') ? url : '$url/';
      _dio.options.baseUrl = baseUrl;
      print('ApiClient: Restored Base URL to $baseUrl');
    }
  }

  void setBaseUrl(String url) {
    _isManuallyConfigured = true;
    // Ensure URL ends with / but doesn't include /api/v1/
    String baseUrl = url.endsWith('/') ? url : '$url/';
    _dio.options.baseUrl = baseUrl;
    _storage.write(key: AppConstants.tenantUrlKey, value: baseUrl);
    print('ApiClient: Updated Base URL to $baseUrl');
  }

  Dio get client => _dio;

  Future<Response> get(String path, {Object? data, Map<String, dynamic>? queryParameters, Options? options, CancelToken? cancelToken, ProgressCallback? onReceiveProgress}) {
    return _dio.get(path, data: data, queryParameters: queryParameters, options: options, cancelToken: cancelToken, onReceiveProgress: onReceiveProgress);
  }

  Future<Response> post(String path, {Object? data, Map<String, dynamic>? queryParameters, Options? options, CancelToken? cancelToken, ProgressCallback? onSendProgress, ProgressCallback? onReceiveProgress}) {
    return _dio.post(path, data: data, queryParameters: queryParameters, options: options, cancelToken: cancelToken, onSendProgress: onSendProgress, onReceiveProgress: onReceiveProgress);
  }

  Future<Response> put(String path, {Object? data, Map<String, dynamic>? queryParameters, Options? options, CancelToken? cancelToken, ProgressCallback? onSendProgress, ProgressCallback? onReceiveProgress}) {
    return _dio.put(path, data: data, queryParameters: queryParameters, options: options, cancelToken: cancelToken, onSendProgress: onSendProgress, onReceiveProgress: onReceiveProgress);
  }

  Future<Response> patch(String path, {Object? data, Map<String, dynamic>? queryParameters, Options? options, CancelToken? cancelToken, ProgressCallback? onSendProgress, ProgressCallback? onReceiveProgress}) {
    return _dio.patch(path, data: data, queryParameters: queryParameters, options: options, cancelToken: cancelToken, onSendProgress: onSendProgress, onReceiveProgress: onReceiveProgress);
  }

  Future<Response> delete(String path, {Object? data, Map<String, dynamic>? queryParameters, Options? options, CancelToken? cancelToken}) {
    return _dio.delete(path, data: data, queryParameters: queryParameters, options: options, cancelToken: cancelToken);
  }
}
