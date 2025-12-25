import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/hr_repository.dart';
import '../../data/models/staff.dart';

final staffListProvider = FutureProvider<List<Staff>>((ref) async {
  final repository = ref.watch(hrRepositoryProvider);
  return repository.getStaffList();
});
