import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/network/api_client.dart';

final authRepositoryProvider = Provider((ref) => AuthRepository(ref));

class AuthRepository {
  final Ref _ref;
  final _storage = const FlutterSecureStorage();

  AuthRepository(this._ref);

  Future<Map<String, dynamic>> login(String email, String password) async {
    final dio = _ref.read(apiClientProvider).client;
    try {
      final tenantSchema = await _storage.read(key: 'tenant_schema');
      print('Attempting login with schema: $tenantSchema');
      final response = await dio.post('auth/api-login/', data: {
        'email': email,
        'password': password,
        'tenant_schema': tenantSchema, 
      });

      final data = response.data;
      final tokens = data['tokens'];
      await _storage.write(key: 'access_token', value: tokens['access']);
      await _storage.write(key: 'refresh_token', value: tokens['refresh']);
      
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

  Future<void> logout() async {
    final dio = _ref.read(apiClientProvider).client;
    try {
      await dio.post('auth/api-logout/');
    } catch (_) {}
    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'refresh_token');
  }

  Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token');
  }
}
