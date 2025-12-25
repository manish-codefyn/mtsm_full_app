import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/finance_repository.dart';
import '../data/models/fee_structure.dart';

final feeStructureProvider = FutureProvider<List<FeeStructure>>((ref) async {
  final repository = ref.watch(financeRepositoryProvider);
  return repository.getFeeStructures();
});
