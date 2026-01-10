import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/academics_repository.dart';
import '../domain/models.dart';
import '../../../shared/models/paginated_response.dart';

class SectionListScreen extends ConsumerStatefulWidget {
  const SectionListScreen({super.key});

  @override
  ConsumerState<SectionListScreen> createState() => _SectionListScreenState();
}

class _SectionListScreenState extends ConsumerState<SectionListScreen> {
  int _page = 1;
  int _pageSize = 10;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _searchQuery = query;
        _page = 1;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final params = AcademicsPaginationParams(
      page: _page,
      pageSize: _pageSize,
      search: _searchQuery,
    );
    final sectionsAsync = ref.watch(sectionsPaginationProvider(params));

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: sectionsAsync.when(
        data: (response) => _buildContent(context, response),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text('Error loading sections: $err'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(sectionsPaginationProvider(params)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, PaginatedResponse<Section> response) {
    return Column(
      children: [
        // Modern Header
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
                          'Sections Management',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.orange[900],
                              ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Manage class sections',
                          style: TextStyle(color: Colors.grey[600]),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                         context.go('/academics/sections/create');
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Add Section'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Search Bar
              TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  hintText: 'Search sections...',
                  prefixIcon: const Icon(Icons.search, color: Colors.orange),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            _onSearchChanged('');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
              ),
            ],
          ),
        ),

        // Data Table
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                   Theme(
                    data: Theme.of(context).copyWith(
                      dividerColor: Colors.transparent,
                      dataTableTheme: DataTableThemeData(
                        headingTextStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                        dataRowColor: MaterialStateProperty.resolveWith((states) {
                          if (states.contains(MaterialState.selected)) return Colors.orange.withOpacity(0.1);
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
                          DataColumn(label: Text('Section Name')),
                          DataColumn(label: Text('Class')),
                          DataColumn(label: Text('Section Incharge')),
                          DataColumn(label: Text('Strength')),
                          DataColumn(label: Text('Actions')),
                        ],
                        rows: response.results.map((sec) {
                          return DataRow(
                            cells: [
                              DataCell(Text(sec.name, style: const TextStyle(fontWeight: FontWeight.w600))),
                              DataCell(Text(sec.classNameDetail?.name ?? '-', style: const TextStyle(fontSize: 13))),
                              DataCell(Text(sec.sectionInchargeDetail?['full_name'] ?? 'Not Assigned', style: const TextStyle(fontSize: 13))),
                              DataCell(Text(sec.currentStrength?.toString() ?? '0', style: const TextStyle(fontSize: 13))),
                              DataCell(
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit_outlined, size: 20, color: Colors.blue),
                                      onPressed: () => context.go('/academics/sections/${sec.id}/edit'),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
                                      onPressed: () => _deleteSection(context, ref, sec),
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
                   // Pagination Footer
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    decoration: BoxDecoration(
                      border: Border(top: BorderSide(color: Colors.grey.shade200)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Showing ${((_page - 1) * _pageSize) + 1} to ${((_page - 1) * _pageSize) + response.results.length} of ${response.count} entries',
                          style: TextStyle(color: Colors.grey[600], fontSize: 13),
                        ),
                        Row(
                          children: [
                            Text("Rows per page: ", style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                            const SizedBox(width: 8),
                            DropdownButton<int>(
                              value: _pageSize,
                              underline: const SizedBox(),
                              items: [10, 25, 50, 100].map((e) => DropdownMenuItem(value: e, child: Text(e.toString()))).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() {
                                    _pageSize = val;
                                    _page = 1;
                                  });
                                }
                              },
                            ),
                            const SizedBox(width: 24),
                            IconButton(
                              icon: const Icon(Icons.chevron_left),
                              onPressed: response.previous == null ? null : () => setState(() => _page--),
                            ),
                             Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '$_page',
                                style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.chevron_right),
                              onPressed: response.next == null ? null : () => setState(() => _page++),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
  Future<void> _deleteSection(BuildContext context, WidgetRef ref, Section sec) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Section'),
        content: Text('Are you sure you want to delete section "${sec.name}"? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ref.read(academicsRepositoryProvider).deleteSection(sec.id);
        ref.refresh(sectionsPaginationProvider(
          AcademicsPaginationParams(page: 1, pageSize: 10, search: ''),
        ));
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Section deleted successfully')));
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
        }
      }
    }
  }
}
