import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/student_repository.dart';
import '../domain/student.dart';
import 'student_wrapper_form_screen.dart';
import '../../../shared/models/paginated_response.dart';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
// Import Academics for filters
import '../../academics/data/academics_repository.dart';
import '../../academics/domain/models.dart';

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

  // Filter State
  String? _selectedClassId;
  String? _selectedSectionId;
  String? _selectedAcademicYearId;
  String _feeFilter = 'All'; // All, Paid, Not Paid

  // Filter Data
  List<SchoolClass> _classes = [];
  List<Section> _sections = [];
  List<AcademicYear> _academicYears = [];
  bool _isLoadingFilters = true;

  @override
  void initState() {
    super.initState();
    _loadFilters();
  }

  Future<void> _loadFilters() async {
    try {
      final academicsRepo = ref.read(academicsRepositoryProvider);
      final academicYears = await academicsRepo.getAcademicYears(const AcademicsPaginationParams(pageSize: 100)); // Use paginated params
      
      if (mounted) {
        setState(() {
          _academicYears = academicYears.results;
          // Set default academic year if active exists
          try {
            _selectedAcademicYearId = _academicYears.firstWhere((y) => y.isActive == true).id;
          } catch (_) {
             if (_academicYears.isNotEmpty) _selectedAcademicYearId = _academicYears.first.id;
          }
        });
        // Load classes for the selected year
        await _loadClasses(_selectedAcademicYearId);
        setState(() => _isLoadingFilters = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingFilters = false);
      print("Error loading filters: $e");
    }
  }

  Future<void> _loadClasses(String? academicYearId) async {
    try {
      final academicsRepo = ref.read(academicsRepositoryProvider);
      final classes = await academicsRepo.getClassesPaginated(
        AcademicsPaginationParams(page: 1, pageSize: 100, academicYearId: academicYearId)
      );
      if (mounted) {
        setState(() {
          _classes = classes.results;
        });
      }
    } catch (e) {
       print("Error loading classes: $e");
    }
  }

  Future<void> _loadSections(String classId) async {
    setState(() {
      _sections = [];
      _selectedSectionId = null;
    });
    try {
      final academicsRepo = ref.read(academicsRepositoryProvider);
      // Fetch sections for this class using pagination provider logic or separate call
      // Using hack: getSectionsPaginated with filter and large page size
      final response = await academicsRepo.getSectionsPaginated(
          AcademicsPaginationParams(page: 1, pageSize: 100, classId: classId)
      );
      if (mounted) {
        setState(() {
          _sections = response.results;
        });
      }
    } catch (e) {
      print("Error loading sections: $e");
    }
  }

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
    bool? hasOutstandingFees;
    if (_feeFilter == 'Paid') hasOutstandingFees = false;
    if (_feeFilter == 'Not Paid') hasOutstandingFees = true;

    final params = StudentPaginationParams(
      page: _page,
      pageSize: _pageSize,
      search: _searchQuery,
      classId: _selectedClassId,
      sectionId: _selectedSectionId,
      academicYearId: _selectedAcademicYearId,
      hasOutstandingFees: hasOutstandingFees,
    );
    final studentsAsync = ref.watch(studentPaginationProvider(params));

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: _buildContent(context, studentsAsync, params),
    );
  }

  Widget _buildContent(BuildContext context, AsyncValue<PaginatedResponse<Student>> studentsAsync, StudentPaginationParams params) {
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
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 16,
                runSpacing: 16,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
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
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Export Button
                      OutlinedButton.icon(
                        onPressed: () => _exportPdf(params),
                        icon: const Icon(Icons.picture_as_pdf),
                        label: const Text('Export PDF'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        ),
                      ),
                      const SizedBox(width: 12),
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
                ],
              ),
              const SizedBox(height: 24),
              
              // Filters Row
              if (_isLoadingFilters) const LinearProgressIndicator(),
              if (!_isLoadingFilters)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      // Academic Year
                      SizedBox(
                        width: 180,
                        child: DropdownButtonFormField<String>(
                          value: _selectedAcademicYearId,
                          decoration: const InputDecoration(labelText: 'Academic Year', border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 0)),
                          items: [
                            const DropdownMenuItem(value: null, child: Text('All Years')),
                            ..._academicYears.map((y) => DropdownMenuItem(value: y.id, child: Text(y.name))),
                          ],
                          onChanged: (val) {
                            setState(() {
                              _selectedAcademicYearId = val;
                              _selectedClassId = null; // Reset class
                              _selectedSectionId = null; // Reset section
                              _page = 1;
                            });
                             // Reload classes based on selected year
                             _loadClasses(val);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Class
                      SizedBox(
                        width: 150,
                        child: DropdownButtonFormField<String>(
                          value: _selectedClassId,
                          decoration: const InputDecoration(labelText: 'Class', border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 0)),
                          items: [
                            const DropdownMenuItem(value: null, child: Text('All Classes')),
                            ..._classes.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))),
                          ],
                          onChanged: (val) {
                            setState(() {
                              _selectedClassId = val;
                              _selectedSectionId = null; // Reset section
                              _page = 1;
                            });
                            if (val != null) _loadSections(val);
                            else setState(() => _sections = []);
                          },
                        ),
                      ),

                      const SizedBox(width: 12),
                      // Section
                      SizedBox(
                        width: 150,
                        child: DropdownButtonFormField<String>(
                          value: _selectedSectionId,
                          decoration: const InputDecoration(labelText: 'Section', border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 0)),
                          items: [
                            const DropdownMenuItem(value: null, child: Text('All Sections')),
                            ..._sections.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name))),
                          ],
                          onChanged: _sections.isEmpty ? null : (val) {
                            setState(() {
                              _selectedSectionId = val;
                              _page = 1;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Fee Status
                      SizedBox(
                        width: 150,
                        child: DropdownButtonFormField<String>(
                          value: _feeFilter,
                          decoration: const InputDecoration(labelText: 'Fee Status', border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 0)),
                          items: const [
                            DropdownMenuItem(value: 'All', child: Text('All Status')),
                            DropdownMenuItem(value: 'Paid', child: Text('Paid')),
                            DropdownMenuItem(value: 'Not Paid', child: Text('Unpaid/Due')),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _feeFilter = val;
                                _page = 1;
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 16),

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
          child: studentsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Error: $err')),
            data: (response) => SingleChildScrollView(
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
                           // ... (Existing DataRow Builder)
                           return DataRow(
                            cells: [
                              DataCell(
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 20,
                                      backgroundColor: Colors.indigo[50],
                                      backgroundImage: student.photo != null ? NetworkImage(student.photo!) : null, // Basic network image for now, verify resolution
                                      child: student.photo == null 
                                          ? Text(student.firstName.isNotEmpty ? student.firstName[0] : '?', style: TextStyle(color: Colors.indigo[800], fontWeight: FontWeight.bold))
                                          : null,
                                    ),
                                    const SizedBox(width: 12),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text('${student.firstName} ${student.lastName}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                                        Text(student.email ?? '-', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              DataCell(Text(student.admissionNumber ?? 'N/A', style: const TextStyle(fontWeight: FontWeight.w500))),
                              DataCell(Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(6), border: Border.all(color: Colors.grey.shade300)),
                                child: Text(student.currentClassName ?? 'N/A', style: TextStyle(color: Colors.grey[800], fontSize: 13, fontWeight: FontWeight.w500)),
                              )),
                              DataCell(Text(student.mobilePrimary ?? '-', style: const TextStyle(fontSize: 13))),
                              DataCell(Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(color: (student.status == 'ACTIVE' ? Colors.green : Colors.grey).withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                                child: Text(student.status ?? 'UNKNOWN', style: TextStyle(color: (student.status == 'ACTIVE' ? Colors.green : Colors.grey)[700], fontSize: 11, fontWeight: FontWeight.bold)),
                              )),
                              DataCell(
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit_outlined, size: 20, color: Colors.blue),
                                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => StudentWrapperFormScreen(student: student))),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.badge_outlined, size: 20, color: Colors.purple),
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
                                          value: 'delete',
                                          child: Row(children: [Icon(Icons.delete, size: 18, color: Colors.red), SizedBox(width: 8), Text('Delete')]),
                                        ),
                                      ],
                                      onSelected: (value) {
                                        if (value == 'delete') _deleteStudent(context, ref, student);
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
                      child: Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 16,
                        runSpacing: 16,
                        children: [
                          Text(
                            'Showing ${((_page - 1) * _pageSize) + 1} to ${((_page - 1) * _pageSize) + response.results.length} of ${response.count} entries',
                            style: TextStyle(color: Colors.grey[600], fontSize: 13),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
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
                                decoration: BoxDecoration(color: Colors.indigo.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                                child: Text('$_page', style: const TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold)),
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
        ),
      ],
    );
  }

  Future<void> _exportPdf(StudentPaginationParams params) async {
    try {
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Generating Report...')));
       // Fetch all students matching filter
       final allStudents = await ref.read(studentRepositoryProvider).getStudents(
         search: params.search,
         classId: params.classId,
         sectionId: params.sectionId,
         academicYearId: params.academicYearId,
         hasOutstandingFees: params.hasOutstandingFees
       );

       if (allStudents.isEmpty) {
         if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No students to export')));
         return;
       }

       // Generate PDF
       // Assuming ExportService has a generic student list export or we reuse profile export logic iteratively?
       // Creating a new method in ExportService is best, but for now I will inline simple list generation or assume one exists.
       // Actually 'apps.core.services.export_service' was imported in previous code but logic might be missing.
       // I'll assume we need to use 'Printing' package here directly as I don't see Client-side ExportService for lists.
       
       final pdf = pw.Document();
       // Add page with table
       pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (context) => [
            pw.Header(level: 0, child: pw.Text('Student List Report', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold))),
            pw.Paragraph(text: 'Generated on: ${DateTime.now().toString()}'),
            if (params.classId != null) pw.Paragraph(text: 'Class Filter: Applied'),
            if (params.hasOutstandingFees != null) pw.Paragraph(text: 'Fee Status: ${params.hasOutstandingFees! ? "Unpaid" : "Paid"}'),
            pw.SizedBox(height: 20),
            pw.Table.fromTextArray(
              context: context,
              headers: ['Admission #', 'Name', 'Class', 'Gender', 'Status'],
              data: allStudents.map((s) => [
                s.admissionNumber ?? '',
                '${s.firstName} ${s.lastName}',
                s.currentClassName ?? '',
                s.gender ?? '',
                s.status ?? ''
              ]).toList(),
            ),
          ]
        )
       );

       await Printing.layoutPdf(
         onLayout: (format) async => pdf.save(),
         name: 'student_report.pdf',
       );

    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Export failed: $e')));
    }
  }

  // ... (Keep existing _generateIdCard and _deleteStudent methods)
  Future<void> _generateIdCard(BuildContext context, WidgetRef ref, Student student) async {
     if (student.id == null) return;
     try {
       if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Generating ID Card...')));
       final repo = ref.read(studentRepositoryProvider);
       final bytes = await repo.generateIdCard(student.id!);
       if (context.mounted) {
          await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              contentPadding: EdgeInsets.zero,
              content: Column(mainAxisSize: MainAxisSize.min, children: [
                  Image.memory(Uint8List.fromList(bytes), fit: BoxFit.contain, width: 300, errorBuilder: (ctx, err, stack) => const Text('Error loading image')),
              ]),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
                ElevatedButton.icon(
                  icon: const Icon(Icons.print),
                  label: const Text('Print / Save PDF'),
                  onPressed: () async {
                    final pdf = pw.Document();
                    final image = pw.MemoryImage(Uint8List.fromList(bytes));
                    pdf.addPage(pw.Page(build: (pw.Context context) => pw.Center(child: pw.Image(image))));
                    await Printing.layoutPdf(onLayout: (format) async => pdf.save(), name: '${student.admissionNumber}_id_card.pdf');
                  },
                ),
              ],
            ),
          );
       }
     } catch (e) {
       if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error generating ID: $e')));
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
         ref.invalidate(studentPaginationProvider);
       } catch (e) {
         if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
       }
     }
  }
}
