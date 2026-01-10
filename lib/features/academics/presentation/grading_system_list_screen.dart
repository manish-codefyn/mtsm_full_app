import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/academics_repository.dart';
import '../domain/models.dart';
import '../../../shared/models/paginated_response.dart';

final gradingSystemsPaginationProvider = FutureProvider.family.autoDispose<PaginatedResponse<GradingSystem>, AcademicsPaginationParams>((ref, params) async {
  return ref.watch(academicsRepositoryProvider).getGradingSystems(params);
});

class GradingSystemListScreen extends ConsumerStatefulWidget {
  const GradingSystemListScreen({super.key});

  @override
  ConsumerState<GradingSystemListScreen> createState() => _GradingSystemListScreenState();
}

class _GradingSystemListScreenState extends ConsumerState<GradingSystemListScreen> {
  int _page = 1;
  int _pageSize = 10;
  
  Future<void> _handleAutoGenerate() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Auto-Generate Grading System'),
        content: const Text(
            'This will generate the standard CBSE 10-point scale grading system. Continue?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Generate'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref.read(academicsRepositoryProvider).autoGenerateGradingSystem();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Grading System generated successfully!')));
        ref.refresh(gradingSystemsPaginationProvider(AcademicsPaginationParams(page: _page, pageSize: _pageSize)));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final params = AcademicsPaginationParams(page: _page, pageSize: _pageSize);
    final sysAsync = ref.watch(gradingSystemsPaginationProvider(params));

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: sysAsync.when(
        data: (response) => _buildContent(context, response),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text('Error loading grading systems: $err'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(gradingSystemsPaginationProvider(params)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, PaginatedResponse<GradingSystem> response) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => context.pop(),
                    tooltip: 'Back',
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Grading Systems',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.teal[900],
                              ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Manage grading scales',
                          style: TextStyle(color: Colors.grey[600]),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: _handleAutoGenerate,
                    icon: const Icon(Icons.auto_awesome),
                    label: const Text('Auto Generate'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.teal,
                      side: const BorderSide(color: Colors.teal),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(width: 12),
                   ElevatedButton.icon(
                    onPressed: () => context.go('/academics/grading/add'),
                    icon: const Icon(Icons.add),
                    label: const Text('Add System'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: Theme(
                data: Theme.of(context).copyWith(
                  dividerColor: Colors.transparent,
                  dataTableTheme: DataTableThemeData(
                    headingTextStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                    dataRowColor: MaterialStateProperty.resolveWith((states) {
                      return Colors.white;
                    }),
                  ),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    horizontalMargin: 24,
                    columnSpacing: 24,
                    headingRowHeight: 56,
                    dataRowHeight: 72,
                    columns: const [
                      DataColumn(label: Text('Name')),
                      DataColumn(label: Text('Code')),
                      DataColumn(label: Text('Default')),
                      DataColumn(label: Text('Actions')),
                    ],
                    rows: response.results.map((sys) {
                      return DataRow(
                        cells: [
                          DataCell(Text(sys.name, style: const TextStyle(fontWeight: FontWeight.w600))),
                          DataCell(Text(sys.code)),
                          DataCell(
                              sys.isDefault 
                              ? const Icon(Icons.check_circle, color: Colors.green, size: 20)
                              : const SizedBox(),
                          ),
                          DataCell(
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                  IconButton(
                                  icon: const Icon(Icons.visibility_outlined, size: 20, color: Colors.teal),
                                  onPressed: () {
                                    context.go('/academics/grading/${sys.id}/grades', extra: sys.name);
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined, size: 20, color: Colors.blue),
                                  onPressed: () {},
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
