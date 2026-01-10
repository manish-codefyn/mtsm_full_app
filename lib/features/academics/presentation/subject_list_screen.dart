import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/academics_repository.dart';
import '../domain/models.dart';
import '../../../shared/models/paginated_response.dart';

class SubjectListScreen extends ConsumerStatefulWidget {
  const SubjectListScreen({super.key});

  @override
  ConsumerState<SubjectListScreen> createState() => _SubjectListScreenState();
}

class _SubjectListScreenState extends ConsumerState<SubjectListScreen> {
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

  bool _isInitializing = false;

  Future<void> _initializeSubjects() async {
    setState(() => _isInitializing = true);
    try {
      await ref.read(academicsRepositoryProvider).initializeSubjects();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Standard Subjects Initialized Successfully'), backgroundColor: Colors.green),
        );
      }
      ref.refresh(subjectsPaginationProvider(AcademicsPaginationParams(page: _page, pageSize: _pageSize, search: _searchQuery)));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('Initialization Failed: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isInitializing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final params = AcademicsPaginationParams(
      page: _page,
      pageSize: _pageSize,
      search: _searchQuery,
    );
    final subjectsAsync = ref.watch(subjectsPaginationProvider(params));

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: BackButton(color: Colors.black),
        title: Text('Subjects Library', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        actions: [
           IconButton(
            icon: _isInitializing 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) 
                : const Icon(Icons.auto_fix_high, color: Colors.blue),
            tooltip: 'Initialize Standard Subjects',
            onPressed: _isInitializing ? null : _initializeSubjects,
          ),
        ],
      ),
      body: subjectsAsync.when(
        data: (response) => _buildContent(context, response),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text('Error loading subjects: $err'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(subjectsPaginationProvider(params)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, PaginatedResponse<Subject> response) {
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Manage Subjects',
                           style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                           overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Total: ${response.count}',
                          style: TextStyle(color: Colors.grey[600]),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                          // Navigate to form
                         context.push('/academics/subjects/create');
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Add Subject'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
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
                  hintText: 'Search subjects...',
                  prefixIcon: const Icon(Icons.search, color: Colors.blue),
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
                          if (states.contains(MaterialState.selected)) return Colors.blue.withOpacity(0.1);
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
                          DataColumn(label: Text('Subject Name')),
                          DataColumn(label: Text('Code')),
                          DataColumn(label: Text('Type')),
                          DataColumn(label: Text('Actions')),
                        ],
                        rows: response.results.map((sub) {
                          return DataRow(
                            cells: [
                              DataCell(Text(sub.name, style: const TextStyle(fontWeight: FontWeight.w600))),
                              DataCell(Text(sub.code ?? '-', style: const TextStyle(fontFamily: 'Monospace', fontSize: 13))),
                              DataCell(
                                 Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: (sub.type == 'PRACTICAL' ? Colors.purple : Colors.teal).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    sub.type ?? 'THEORY',
                                    style: TextStyle(
                                      color: (sub.type == 'PRACTICAL' ? Colors.purple : Colors.teal)[800],
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              DataCell(
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit_outlined, size: 20, color: Colors.blue),
                                      onPressed: () {
                                         // TODO: Edit
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
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
                   // Pagination Footer
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    decoration: BoxDecoration(
                      border: Border(top: BorderSide(color: Colors.grey.shade200)),
                    ),
                    child: Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      runSpacing: 12,
                      spacing: 12,
                      children: [
                        Text(
                          'Showing ${((_page - 1) * _pageSize) + 1} to ${((_page - 1) * _pageSize) + response.results.length} of ${response.count} entries',
                          style: TextStyle(color: Colors.grey[600], fontSize: 13),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text("Rows: ", style: TextStyle(color: Colors.grey[600], fontSize: 13)), // Compact
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
                            const SizedBox(width: 16), // Compact
                            IconButton(
                              icon: const Icon(Icons.chevron_left),
                              onPressed: response.previous == null ? null : () => setState(() => _page--),
                              constraints: const BoxConstraints(), // Compact
                              padding: const EdgeInsets.all(8),
                            ),
                             Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), // Compact
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '$_page',
                                style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.chevron_right),
                              onPressed: response.next == null ? null : () => setState(() => _page++),
                              constraints: const BoxConstraints(),
                              padding: const EdgeInsets.all(8),
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
}
