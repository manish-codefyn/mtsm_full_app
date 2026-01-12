import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/profile_repository.dart';

final userProfileProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final repository = ref.read(profileRepositoryProvider);
  return repository.getProfile();
});

final profileControllerProvider = Provider((ref) {
  return ProfileController(ref);
});

class ProfileController {
  final Ref _ref;

  ProfileController(this._ref);

  Future<void> updateProfile(Map<String, dynamic> data, {String? filePath}) async {
    final repository = _ref.read(profileRepositoryProvider);
    await repository.updateProfile(data, filePath: filePath);
    _ref.invalidate(userProfileProvider);
  }

  Future<void> changePassword(String oldPassword, String newPassword) async {
    final repository = _ref.read(profileRepositoryProvider);
    await repository.changePassword(oldPassword, newPassword);
  }
}
