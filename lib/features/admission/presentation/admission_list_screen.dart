import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/admission_repository.dart';
import '../domain/admission_application.dart';
import '../../../shared/models/paginated_response.dart';

class AdmissionListScreen extends ConsumerStatefulWidget {
  const AdmissionListScreen({super.key});

  @override
  ConsumerState<AdmissionListScreen> createState() => _AdmissionListScreenState();
}

class _AdmissionListScreenState extends ConsumerState<AdmissionListScreen> {
  int _page = 1;
  int _pageSize = 10;
  String _searchQuery = '';
  String _statusFilter = 'All'; // Default
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
    final params = AdmissionPaginationParams(
      page: _page,
      pageSize: _pageSize,
      search: _searchQuery,
      status: _statusFilter == 'All' ? null : _statusFilter,
    );
    final applicationsAsync = ref.watch(admissionPaginationProvider(params));

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: applicationsAsync.when(
        data: (response) => _buildContent(context, response),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text('Error loading applications: $err'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(admissionPaginationProvider(params)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, PaginatedResponse<AdmissionApplication> response) {
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Admission Applications',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple[900],
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Manage online admission queries',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  const Spacer(),
                  // Filter Status Dropdown
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _statusFilter,
                        hint: const Text('Status'),
                        items: ['All', 'DRAFT', 'SUBMITTED', 'UNDER_REVIEW', 'SHORTLISTED', 'ADMITTED', 'REJECTED', 'WAITLISTED']
                            .map((e) => DropdownMenuItem(value: e, child: Text(e.replaceAll('_', ' '))))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _statusFilter = val;
                              _page = 1;
                            });
                          }
                        },
                      ),
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
                  hintText: 'Search by application no, name, email...',
                  prefixIcon: const Icon(Icons.search, color: Colors.deepPurple),
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
                          if (states.contains(MaterialState.selected)) return Colors.deepPurple.withOpacity(0.1);
                          return Colors.white;
                        }),
                      ),
                    ),
                    child: DataTable(
                      horizontalMargin: 24,
                      columnSpacing: 24,
                      headingRowHeight: 56,
                      dataRowHeight: 72,
                      columns: const [
                        DataColumn(label: Text('Applicant')),
                        DataColumn(label: Text('App No.')),
                        DataColumn(label: Text('Program')),
                        DataColumn(label: Text('Submission Date')),
                        DataColumn(label: Text('Status')),
                        DataColumn(label: Text('Actions')),
                      ],
                      rows: response.results.map((app) {
                         String programName = app.programDetail != null 
                             ? '${app.programDetail!['class_grade']} ${app.programDetail!['program_type']}' 
                             : (app.program ?? 'N/A');
                         
                        return DataRow(
                          cells: [
                            DataCell(
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundColor: Colors.deepPurple[50],
                                    child: Text(
                                      app.firstName.isNotEmpty ? app.firstName[0] : '?',
                                      style: TextStyle(color: Colors.deepPurple[800], fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        '${app.firstName} ${app.lastName}',
                                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                                      ),
                                      Text(
                                        app.email ?? app.phone ?? '-',
                                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            DataCell(Text(app.applicationNumber ?? 'DRAFT', style: const TextStyle(fontWeight: FontWeight.w500))),
                            DataCell(Text(programName, style: const TextStyle(fontSize: 13))),
                            DataCell(Text(app.submissionDate?.split('T')[0] ?? '-', style: const TextStyle(fontSize: 13))),
                            DataCell(
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(app.status ?? '').withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  app.status?.replaceAll('_', ' ') ?? 'UNKNOWN',
                                  style: TextStyle(
                                    color: _getStatusColor(app.status ?? ''),
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
                                  PopupMenuButton<String>(
                                    icon: const Icon(Icons.more_vert),
                                    onSelected: (action) => _handleAction(context, ref, app, action),
                                    itemBuilder: (context) => [
                                      // View Details (Placeholder for now)
                                      const PopupMenuItem(value: 'view', child: Row(children: [Icon(Icons.visibility, color: Colors.blue), SizedBox(width: 8), Text('View Details')])),
                                      
                                      // Actions based on status
                                      if (app.status != 'ADMITTED')
                                         const PopupMenuItem(value: 'ADMITTED', child: Row(children: [Icon(Icons.check_circle, color: Colors.green), SizedBox(width: 8), Text('Admit')])),
                                      if (app.status != 'REJECTED')
                                         const PopupMenuItem(value: 'REJECTED', child: Row(children: [Icon(Icons.cancel, color: Colors.red), SizedBox(width: 8), Text('Reject')])),
                                      if (app.status != 'WAITLISTED')
                                         const PopupMenuItem(value: 'WAITLISTED', child: Row(children: [Icon(Icons.access_time, color: Colors.orange), SizedBox(width: 8), Text('Waitlist')])),
                                       if (app.status != 'SHORTLISTED')
                                         const PopupMenuItem(value: 'SHORTLISTED', child: Row(children: [Icon(Icons.list, color: Colors.purple), SizedBox(width: 8), Text('Shortlist')])),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }).toList(),
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
                                color: Colors.deepPurple.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '$_page',
                                style: const TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold),
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

  Color _getStatusColor(String status) {
    switch (status) {
      case 'ADMITTED': return Colors.green;
      case 'REJECTED': return Colors.red;
      case 'WAITLISTED': return Colors.orange;
      case 'SHORTLISTED': return Colors.purple;
      case 'SUBMITTED': return Colors.blue;
      default: return Colors.grey;
    }
  }

  Future<void> _handleAction(BuildContext context, WidgetRef ref, AdmissionApplication app, String action) async {
    if (action == 'view') {
      // Navigate to detail
      // context.push('/admission/detail', extra: app);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Detail view coming soon')));
      return;
    }

    // Status Update
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update Status to $action'),
        content: Text('Are you sure you want to change the status of ${app.applicationNumber} to $action?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Confirm', style: TextStyle(color: Colors.deepPurple))),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ref.read(admissionRepositoryProvider).updateApplicationStatus(app.id!, action);
        ref.invalidate(admissionPaginationProvider);
        if (context.mounted) {
           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Status updated to $action')));
        }
      } catch (e) {
        if (context.mounted) {
           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      }
    }
  }
}
