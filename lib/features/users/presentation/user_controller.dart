import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/user_repository.dart';

// Filter Models
class UserFilterState {
  final String? search;
  final String? role;
  final bool? isActive;
  final int page;

  UserFilterState({this.search, this.role, this.isActive, this.page = 1});

  UserFilterState copyWith({String? search, String? role, bool? isActive, int? page}) {
    return UserFilterState(
      search: search ?? this.search,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      page: page ?? this.page,
    );
  }
}

// Filter Notifier
final userFilterProvider = NotifierProvider<UserFilterNotifier, UserFilterState>(UserFilterNotifier.new);

class UserFilterNotifier extends Notifier<UserFilterState> {
  @override
  UserFilterState build() {
    return UserFilterState();
  }

  void update(UserFilterState Function(UserFilterState) cb) {
    state = cb(state);
  }
}

// User List Provider
final userListProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final filters = ref.watch(userFilterProvider);
  final repository = ref.read(userRepositoryProvider);
  return repository.getUsers(
    page: filters.page,
    search: filters.search,
    role: filters.role,
    isActive: filters.isActive,
  );
});

// Controller
final userControllerProvider = Provider((ref) {
  return UserController(ref);
});

class UserController {
  final Ref _ref;

  UserController(this._ref);

  Future<void> toggleUserStatus(String id, bool currentStatus) async {
    final repository = _ref.read(userRepositoryProvider);
    await repository.updateUser(id, {'is_active': !currentStatus});
    _ref.invalidate(userListProvider);
  }

  Future<void> updateUserRole(String id, String newRole) async {
    final repository = _ref.read(userRepositoryProvider);
    await repository.updateUser(id, {'role': newRole});
    _ref.invalidate(userListProvider);
  }
}
