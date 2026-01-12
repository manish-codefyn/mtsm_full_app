import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository(ref.read(apiClientProvider));
});

class UserRepository {
  final ApiClient _apiClient;

  UserRepository(this._apiClient);

  Future<Map<String, dynamic>> getUsers({int page = 1, String? search, String? role, bool? isActive}) async {
    final queryParams = {
      'page': page,
      if (search != null && search.isNotEmpty) 'search': search,
      if (role != null && role.isNotEmpty) 'role': role,
      if (isActive != null) 'is_active': isActive,
    };

    final response = await _apiClient.client.get('/users/', queryParameters: queryParams);
    return response.data;
  }

  Future<void> updateUser(String id, Map<String, dynamic> data) async {
    await _apiClient.client.patch('/users/$id/', data: data);
  }
}
