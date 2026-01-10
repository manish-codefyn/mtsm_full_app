import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../shared/widgets/custom_search_bar.dart';
import '../data/academics_repository.dart';
import '../domain/models.dart';

class ClassSubjectListScreen extends ConsumerStatefulWidget {
  const ClassSubjectListScreen({super.key});

  @override
  ConsumerState<ClassSubjectListScreen> createState() => _ClassSubjectListScreenState();
}

class _ClassSubjectListScreenState extends ConsumerState<ClassSubjectListScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _currentPage = 1;
  static const int _pageSize = 10;
  String _searchQuery = '';
  bool _isInitializing = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    setState(() {
      _searchQuery = query;
      _currentPage = 1;
    });
  }

  Future<void> _refresh() async {
    ref.invalidate(classSubjectsPaginationProvider);
  }

  Future<void> _initializeClassSubjects() async {
    setState(() => _isInitializing = true);
    try {
      await ref.read(academicsRepositoryProvider).initializeClassSubjects();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Class Subjects Initialized Successfully'), backgroundColor: Colors.green),
        );
      }
      _refresh();
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
      page: _currentPage,
      pageSize: _pageSize,
      search: _searchQuery,
    );

    final classSubjectsAsync = ref.watch(classSubjectsPaginationProvider(params));

    return Scaffold(
      appBar: AppBar(
        title: Text('Class Subjects', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              context.push('/academics/class-subjects/create');
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'initialize') {
                _initializeClassSubjects();
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem<String>(
                  value: 'initialize',
                  child: Row(
                    children: [
                      Icon(Icons.auto_fix_high, color: Colors.blue),
                      SizedBox(width: 8),
                      Text('Auto-Initialize'),
                    ],
                  ),
                ),
              ];
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (_isInitializing)
             const LinearProgressIndicator(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: CustomSearchBar(
              controller: _searchController,
              onChanged: _onSearch,
              hintText: 'Search class subjects...',
            ),
          ),
          Expanded(
            child: classSubjectsAsync.when(
              data: (response) {
                if (response.results.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.subject, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'No class subjects found',
                          style: GoogleFonts.outfit(fontSize: 18, color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: _isInitializing ? null : _initializeClassSubjects,
                          icon: const Icon(Icons.auto_fix_high),
                          label: const Text('Initialize Defaults'),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: _refresh,
                  child: ListView.builder(
                    itemCount: response.results.length + 1,
                    itemBuilder: (context, index) {
                      if (index == response.results.length) {
                        return _buildPaginationControls(response.count);
                      }

                      final classSubject = response.results[index];
                      return _buildClassSubjectCard(classSubject);
                    },
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Error: $error')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
           context.push('/academics/class-subjects/create');
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildClassSubjectCard(ClassSubject classSubject) {
    final className = classSubject.classNameDetail?.name ?? 'Unknown Class';
    final subjectName = classSubject.subjectDetail?.name ?? 'Unknown Subject';
    // Handle Map<String, dynamic>? teacherDetail cleanly
    final teacherFirstName = classSubject.teacherDetail?['first_name'] ?? '';
    final teacherLastName = classSubject.teacherDetail?['last_name'] ?? '';
    final teacherName = (teacherFirstName.isNotEmpty || teacherLastName.isNotEmpty)
        ? '$teacherFirstName $teacherLastName'.trim()
        : 'No Teacher Assigned';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.cyan.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.book,
            color: Colors.cyan,
          ),
        ),
        title: Text(
          subjectName,
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              'Class: $className',
              style: GoogleFonts.outfit(color: Colors.black87, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                const Icon(Icons.person, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  teacherName,
                  style: GoogleFonts.outfit(color: Colors.grey[600], fontSize: 13),
                ),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
             IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () {
                 context.push('/academics/class-subjects/${classSubject.id}/edit');
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
               onPressed: () => _confirmDelete(classSubject),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(ClassSubject classSubject) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Class Subject'),
        content: Text('Are you sure you want to delete this mapping?'),
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

    if (confirmed == true) {
      try {
        await ref.read(academicsRepositoryProvider).deleteClassSubject(classSubject.id);
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Class Subject deleted successfully')),
          );
        }
        _refresh();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  Widget _buildPaginationControls(int totalCount) {
    if (totalCount == 0) return const SizedBox.shrink();
    
    final totalPages = (totalCount / _pageSize).ceil();
    if (totalPages <= 1) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: _currentPage > 1
                ? () => setState(() => _currentPage--)
                : null,
            icon: const Icon(Icons.chevron_left),
          ),
          Text(
            'Page $_currentPage of $totalPages',
            style: GoogleFonts.outfit(),
          ),
          IconButton(
            onPressed: _currentPage < totalPages
                ? () => setState(() => _currentPage++)
                : null,
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }
}
