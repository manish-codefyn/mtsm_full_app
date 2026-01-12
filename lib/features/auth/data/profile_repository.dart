import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository(ref.read(apiClientProvider));
});

class ProfileRepository {
  final ApiClient _apiClient;

  ProfileRepository(this._apiClient);

  Future<Map<String, dynamic>> getProfile() async {
    final response = await _apiClient.client.get('/users/me/');
    return response.data;
  }

  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data, {String? filePath}) async {
    FormData formData = FormData.fromMap(data);
    
    if (filePath != null) {
      formData.files.add(MapEntry(
        'avatar',
        await MultipartFile.fromFile(filePath, filename: 'avatar.jpg'),
      ));
    }

    final response = await _apiClient.client.patch('/users/me/', data: formData);
    return response.data;
  }

  Future<void> changePassword(String oldPassword, String newPassword) async {
    await _apiClient.client.post('/users/change_password/', data: {
      'old_password': oldPassword,
      'new_password': newPassword,
    });
  }
}
