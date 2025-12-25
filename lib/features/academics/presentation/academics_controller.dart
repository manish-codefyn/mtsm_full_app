import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/academics_repository.dart';
import '../data/models/academic_year.dart';

final academicYearsProvider = FutureProvider<List<AcademicYear>>((ref) async {
  final repository = ref.watch(academicsRepositoryProvider);
  return repository.getAcademicYears();
});
