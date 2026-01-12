import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/exams_repository.dart';
import '../domain/models.dart';
import '../../academics/data/academics_repository.dart';
import '../../academics/domain/models.dart';

class ExamResultsListScreen extends ConsumerStatefulWidget {
  const ExamResultsListScreen({super.key});

  @override
  ConsumerState<ExamResultsListScreen> createState() => _ExamResultsListScreenState();
}

class _ExamResultsListScreenState extends ConsumerState<ExamResultsListScreen> {
  int _page = 1;
  int _pageSize = 10;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  // Filters
  String? _selectedClassId;
  String? _selectedAcademicYearId;
  List<SchoolClass> _classes = [];
  List<AcademicYear> _academicYears = [];

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
          try {
             _selectedAcademicYearId = _academicYears.firstWhere((y) => y.isActive == true).id;
          } catch (_) {}
        });
        await _loadClasses(_selectedAcademicYearId);
      }
    } catch (e) {
      print(e);
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
      appBar: AppBar(title: const Text('Exam Results')),
      body: Column(
        children: [
          // Filters
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
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
                    width: 200,
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) => setState(() { _searchQuery = val; _page = 1; }),
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
          
          Expanded(
            child: examsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
              data: (response) => ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: response.results.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  final exam = response.results[index];
                  return ListTile(
                    title: Text(exam.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Class: ${exam.className ?? "-"} • ${exam.startDate}'),
                    trailing: ElevatedButton.icon(
                      onPressed: () => context.push('/exams/results/${exam.id}'),
                      icon: const Icon(Icons.assessment),
                      label: const Text('View Results'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
