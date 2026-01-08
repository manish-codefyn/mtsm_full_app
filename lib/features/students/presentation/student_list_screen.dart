import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/student_repository.dart';
import '../domain/student.dart';
import 'student_wrapper_form_screen.dart';
import '../../../shared/models/paginated_response.dart';
// Note: Printing/PDF imports retained for existing functionality
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class StudentListScreen extends ConsumerStatefulWidget {
  const StudentListScreen({super.key});

  @override
  ConsumerState<StudentListScreen> createState() => _StudentListScreenState();
}

class _StudentListScreenState extends ConsumerState<StudentListScreen> {
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
        _page = 1; // Reset to first page on search
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final params = StudentPaginationParams(
      page: _page,
      pageSize: _pageSize,
      search: _searchQuery,
    );
    final studentsAsync = ref.watch(studentPaginationProvider(params));

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: studentsAsync.when(
        data: (response) => _buildContent(context, response),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text('Error loading students: $err'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(studentPaginationProvider(params)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, PaginatedResponse<Student> response) {
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
                        'Students Directory',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.indigo[900],
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Manage your student records',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: () => context.push('/students/add'),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Student'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
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
                  hintText: 'Search by name, admission no, email...',
                  prefixIcon: const Icon(Icons.search, color: Colors.indigo),
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
                          if (states.contains(MaterialState.selected)) return Colors.indigo.withOpacity(0.1);
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
                        DataColumn(label: Text('Student Info')),
                        DataColumn(label: Text('Admission #')),
                        DataColumn(label: Text('Class')),
                        DataColumn(label: Text('Contact')),
                        DataColumn(label: Text('Status')),
                        DataColumn(label: Text('Actions')),
                      ],
                      rows: response.results.map((student) {
                        return DataRow(
                          cells: [
                            DataCell(
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundColor: Colors.indigo[50],
                                    child: Text(
                                      student.firstName.isNotEmpty ? student.firstName[0] : '?',
                                      style: TextStyle(color: Colors.indigo[800], fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        '${student.firstName} ${student.lastName}',
                                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                                      ),
                                      Text(
                                        student.email ?? '-',
                                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            DataCell(Text(student.admissionNumber ?? 'N/A', style: const TextStyle(fontWeight: FontWeight.w500))),
                            DataCell(
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: Colors.grey.shade300),
                                ),
                                child: Text(
                                  student.currentClassName ?? 'N/A',
                                  style: TextStyle(color: Colors.grey[800], fontSize: 13, fontWeight: FontWeight.w500),
                                ),
                              ),
                            ),
                            DataCell(Text(student.mobilePrimary ?? '-', style: const TextStyle(fontSize: 13))),
                            DataCell(
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: (student.status == 'ACTIVE' ? Colors.green : Colors.grey).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  student.status ?? 'UNKNOWN',
                                  style: TextStyle(
                                    color: (student.status == 'ACTIVE' ? Colors.green : Colors.grey)[700],
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
                                    tooltip: 'Edit',
                                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => StudentWrapperFormScreen(student: student))),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.badge_outlined, size: 20, color: Colors.purple),
                                    tooltip: 'ID Card',
                                    onPressed: () => _generateIdCard(context, ref, student),
                                  ),
                                  PopupMenuButton(
                                    icon: Icon(Icons.more_vert, size: 20, color: Colors.grey[600]),
                                    itemBuilder: (context) => [
                                      PopupMenuItem(
                                        child: const Row(children: [Icon(Icons.visibility, size: 18), SizedBox(width: 8), Text('View Details')]),
                                        onTap: () => context.push('/students/detail', extra: student),
                                      ),
                                      const PopupMenuItem(
                                        child: Row(children: [Icon(Icons.delete, size: 18, color: Colors.red), SizedBox(width: 8), Text('Delete')]),
                                        value: 'delete',
                                      ),
                                    ],
                                    onSelected: (value) async {
                                      if (value == 'delete') {
                                        _deleteStudent(context, ref, student);
                                      }
                                    },
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
                                color: Colors.indigo.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '$_page',
                                style: const TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold),
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

  Future<void> _generateIdCard(BuildContext context, WidgetRef ref, Student student) async {
         if (student.id == null) return;
     try {
       // Show loading
       if (context.mounted) {
         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Generating ID Card...')));
       }
       
       final repo = ref.read(studentRepositoryProvider);
       final bytes = await repo.generateIdCard(student.id!);
       
       if (context.mounted) {
          // Show preview dialog first
          await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              contentPadding: EdgeInsets.zero,
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.memory(
                    Uint8List.fromList(bytes),
                    fit: BoxFit.contain,
                    width: 300, // Reasonable preview size
                    errorBuilder: (context, error, stackTrace) => 
                       Padding(padding: const EdgeInsets.all(20), child: Text('Error loading image: $error')),
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
                ElevatedButton.icon(
                  icon: const Icon(Icons.print),
                  label: const Text('Print / Save PDF'),
                  onPressed: () async {
                    // Wrap PNG in PDF
                    final pdf = pw.Document();
                    final image = pw.MemoryImage(Uint8List.fromList(bytes));
                    
                    pdf.addPage(pw.Page(
                      build: (pw.Context context) {
                        return pw.Center(
                          child: pw.Image(image),
                        );
                      },
                    ));

                    await Printing.layoutPdf(
                      onLayout: (format) async => pdf.save(),
                      name: '${student.admissionNumber ?? "card"}_id_card.pdf',
                    );
                  },
                ),
              ],
            ),
          );
       }
     } catch (e) {
       if (context.mounted) {
         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error generating ID: $e')));
       }
     }
  }

  Future<void> _deleteStudent(BuildContext context, WidgetRef ref, Student student) async {
     if (student.id == null) return;
     final confirm = await showDialog<bool>(
       context: context,
       builder: (context) => AlertDialog(
         title: const Text('Delete Student'),
         content: Text('Are you sure you want to delete ${student.firstName}?'),
         actions: [
           TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
           TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
         ],
       ),
     );
     
     if (confirm == true) {
       try {
         await ref.read(studentRepositoryProvider).deleteStudent(student.id!);
         // Refresh list
         ref.invalidate(studentPaginationProvider);
       } catch (e) {
         if (context.mounted) {
           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
         }
       }
     }
  }
}
