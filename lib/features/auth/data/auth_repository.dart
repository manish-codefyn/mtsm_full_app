import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/network/api_client.dart';
import '../../../core/config/constants.dart';

final authRepositoryProvider = Provider((ref) => AuthRepository(ref));

class AuthRepository {
  final Ref _ref;
  final _storage = const FlutterSecureStorage();

  AuthRepository(this._ref);

  Future<Map<String, dynamic>> login(String email, String password) async {
    final dio = _ref.read(apiClientProvider).client;
    try {
      final tenantSchema = await _storage.read(key: AppConstants.tenantSchemaKey);
      print('Attempting login with schema: $tenantSchema');
      final response = await dio.post('auth/login/', data: {
        'email': email,
        'password': password,
        'tenant_schema': tenantSchema, 
      });

      final data = response.data;
      final tokens = data['tokens'];
      await _storage.write(key: AppConstants.tokenKey, value: tokens['access']);
      await _storage.write(key: AppConstants.refreshTokenKey, value: tokens['refresh']);
      
      return data['user'];
    } on DioException catch (e) {
      if (e.response != null) {
        print('Login Error Data: ${e.response?.data}');
      }
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> checkTenant(String schema) async {
    // Use a fresh Dio instance to avoid stale base URL from ApiClient
    final dio = Dio(BaseOptions(
      baseUrl: AppConstants.defaultBaseUrl,
      connectTimeout: const Duration(seconds: 10),
    ));
    try {
      final response = await dio.get('public/lookup/', queryParameters: {'schema': schema});
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    final dio = _ref.read(apiClientProvider).client;
    try {
      await dio.post('auth/logout/');
    } catch (_) {}
    await _storage.delete(key: AppConstants.tokenKey);
    await _storage.delete(key: AppConstants.refreshTokenKey);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token');
  }
}
