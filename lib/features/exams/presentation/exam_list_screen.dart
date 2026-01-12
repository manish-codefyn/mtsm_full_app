import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/exams_repository.dart';
import '../domain/models.dart';
import '../../academics/data/academics_repository.dart';
import '../../academics/domain/models.dart';

class ExamListScreen extends ConsumerStatefulWidget {
  const ExamListScreen({super.key});

  @override
  ConsumerState<ExamListScreen> createState() => _ExamListScreenState();
}

class _ExamListScreenState extends ConsumerState<ExamListScreen> {
  int _page = 1;
  int _pageSize = 10;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;

  // Filters
  String? _selectedClassId;
  String? _selectedAcademicYearId;
  List<SchoolClass> _classes = [];
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
      final years = await academicsRepo.getAcademicYears(const AcademicsPaginationParams(pageSize: 100));
      
      if (mounted) {
        setState(() {
          _academicYears = years.results;
          // Default to active year
          /*
          try {
             _selectedAcademicYearId = _academicYears.firstWhere((y) => y.isActive == true).id;
          } catch (_) {}
          */
        });
        await _loadClasses(_selectedAcademicYearId); // Will be null (All)
        setState(() => _isLoadingFilters = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingFilters = false);
    }
  }

  Future<void> _loadClasses(String? yearId) async {
    try {
      final academicsRepo = ref.read(academicsRepositoryProvider);
      final classes = await academicsRepo.getClassesPaginated(
        AcademicsPaginationParams(page: 1, pageSize: 100, academicYearId: yearId)
      );
      if (mounted) setState(() => _classes = classes.results);
    } catch (e) {
      print(e);
    }
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
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final params = ExamPaginationParams(
      page: _page,
      pageSize: _pageSize,
      search: _searchQuery,
      classId: _selectedClassId,
      academicYearId: _selectedAcademicYearId,
    );
    final examsAsync = ref.watch(examsPaginationProvider(params));

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // Header
         Container(
          padding: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
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
                      IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Exam Schedule', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.indigo[900])),
                          Text('Manage Exam Timelines', style: TextStyle(color: Colors.grey[600])),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                       // Create Exam Button
                       ElevatedButton.icon(
                        onPressed: () => context.push('/exams/create'),
                        icon: const Icon(Icons.add),
                        label: const Text('New Exam'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton.icon(
                        onPressed: () {
                          // Trigger PDF Export of current list
                           examsAsync.whenData((data) {
                               ref.read(examRepositoryProvider).exportExamListPdf(data.results);
                           });
                        },
                        icon: const Icon(Icons.picture_as_pdf), 
                        label: const Text('Export List')
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Filters
                // Filters
                 Padding(
                   padding: const EdgeInsets.symmetric(horizontal: 16),
                   child: SingleChildScrollView(
                     scrollDirection: Axis.horizontal,
                     child: ConstrainedBox(
                       constraints: const BoxConstraints(minWidth: 600), // Ensure minimum width for desktop, scroll on mobile
                       child: Row(
                         children: [
                           SizedBox(
                             width: 200,
                             child: DropdownButtonFormField<String>(
                               value: _selectedAcademicYearId,
                               decoration: const InputDecoration(labelText: 'Academic Year', border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 10)),
                               items: [
                                  const DropdownMenuItem(value: null, child: Text('All')),
                                 ..._academicYears.map((y) => DropdownMenuItem(value: y.id, child: Text(y.name, overflow: TextOverflow.ellipsis))),
                               ],
                               onChanged: (val) {
                                  setState(() { _selectedAcademicYearId = val; _selectedClassId = null; });
                                  _loadClasses(val);
                               },
                             ),
                           ),
                           const SizedBox(width: 12),
                           SizedBox(
                             width: 180,
                             child: DropdownButtonFormField<String>(
                               value: _selectedClassId,
                               decoration: const InputDecoration(labelText: 'Class', border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 10)),
                               items: [
                                 const DropdownMenuItem(value: null, child: Text('All Classes')),
                                 ..._classes.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name, overflow: TextOverflow.ellipsis))),
                               ],
                               onChanged: (val) => setState(() => _selectedClassId = val),
                             ),
                           ),
                           const SizedBox(width: 12),
                           SizedBox(
                             width: 250,
                             child: TextField(
                               controller: _searchController,
                               onChanged: _onSearchChanged,
                               decoration: const InputDecoration(
                                 hintText: 'Search Exams...',
                                 prefixIcon: Icon(Icons.search),
                                 border: OutlineInputBorder(),
                                 contentPadding: EdgeInsets.symmetric(horizontal: 10),
                               ),
                             ),
                           ),
                         ],
                       ),
                     ),
                   ),
                 ),
            ],
          ),
         ),

         Expanded(
           child: examsAsync.when(
             loading: () => const Center(child: CircularProgressIndicator()),
             error: (err, stack) => Center(child: Text('Error: $err')),
             data: (response) => SingleChildScrollView(
               padding: const EdgeInsets.all(24),
               child: Card(
                 child: DataTable(
                   columns: const [
                     DataColumn(label: Text('Exam Name')),
                     DataColumn(label: Text('Class')),
                     DataColumn(label: Text('Dates')),
                     DataColumn(label: Text('Status')),
                     DataColumn(label: Text('Actions')),
                   ],
                   rows: response.results.map((exam) {
                     return DataRow(
                       cells: [
                         DataCell(Text(exam.name, style: const TextStyle(fontWeight: FontWeight.bold))),
                         DataCell(Text(exam.className ?? '-')),
                         DataCell(Text('${exam.startDate} to ${exam.endDate}')),
                         DataCell(Container(
                           padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                           decoration: BoxDecoration(
                             color: exam.status == 'SCHEDULED' ? Colors.blue[50] : (exam.status == 'COMPLETED' ? Colors.green[50] : Colors.grey[50]),
                             borderRadius: BorderRadius.circular(4)
                           ),
                           child: Text(exam.status, style: TextStyle(
                             color: exam.status == 'SCHEDULED' ? Colors.blue : (exam.status == 'COMPLETED' ? Colors.green : Colors.grey),
                             fontSize: 12, fontWeight: FontWeight.bold
                           )),
                         )),
                         DataCell(Row(
                           children: [
                             // Results icon removed to separate concerns
                             Tooltip(
                               message: 'Edit',
                               child: IconButton(icon: const Icon(Icons.edit, size: 20), onPressed: () => context.push('/exams/edit/${exam.id}')),
                             ),
                             Tooltip(
                               message: 'Delete',
                               child: IconButton(
                                 icon: const Icon(Icons.delete, size: 20, color: Colors.red), 
                                 onPressed: () async {
                                   final confirm = await showDialog<bool>(
                                     context: context, 
                                     builder: (c) => AlertDialog(
                                       title: const Text('Delete Exam?'),
                                       content: const Text('This will delete the exam and all results.'),
                                       actions: [
                                          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
                                          TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('Delete')),
                                       ],
                                     )
                                   );
                                   if (confirm == true) {
                                      await ref.read(examRepositoryProvider).deleteExam(exam.id);
                                      ref.refresh(examsPaginationProvider(params));
                                   }
                                 }
                               ),
                             ),
                           ],
                         )),
                       ]
                     );
                   }).toList(),
                 ),
               ),
             ),
           ),
         ),
        ],
      ),
    );
  }
}
