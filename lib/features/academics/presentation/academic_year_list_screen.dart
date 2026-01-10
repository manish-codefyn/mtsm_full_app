import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../shared/widgets/custom_search_bar.dart';
import '../data/academics_repository.dart';
import '../domain/models.dart';

class AcademicYearListScreen extends ConsumerStatefulWidget {
  const AcademicYearListScreen({super.key});

  @override
  ConsumerState<AcademicYearListScreen> createState() => _AcademicYearListScreenState();
}

class _AcademicYearListScreenState extends ConsumerState<AcademicYearListScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _currentPage = 1;
  static const int _pageSize = 10;
  String _searchQuery = '';

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
    ref.invalidate(academicYearsPaginationProvider);
  }

  @override
  Widget build(BuildContext context) {
    final params = AcademicsPaginationParams(
      page: _currentPage,
      pageSize: _pageSize,
      search: _searchQuery,
    );

    final academicYearsAsync = ref.watch(academicYearsPaginationProvider(params));

    return Scaffold(
      appBar: AppBar(
        title: Text('Academic Years', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              context.push('/academics/academic-years/create');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: CustomSearchBar(
              controller: _searchController,
              onChanged: _onSearch,
              hintText: 'Search academic years...',
            ),
          ),
          Expanded(
            child: academicYearsAsync.when(
              data: (response) {
                if (response.results.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.calendar_today_outlined, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'No academic years found',
                          style: GoogleFonts.outfit(fontSize: 18, color: Colors.grey[600]),
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

                      final academicYear = response.results[index];
                      return _buildAcademicYearCard(academicYear);
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
           context.push('/academics/academic-years/create');
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildAcademicYearCard(AcademicYear academicYear) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: (academicYear.isActive ?? false) ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.calendar_today,
            color: (academicYear.isActive ?? false) ? Colors.green : Colors.grey,
          ),
        ),
        title: Text(
          academicYear.name,
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              '${academicYear.startDate} - ${academicYear.endDate}',
              style: GoogleFonts.outfit(color: Colors.grey[600]),
            ),
            if (academicYear.isActive ?? false)
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Active',
                  style: GoogleFonts.outfit(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
             IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () {
                 context.push('/academics/academic-years/${academicYear.id}/edit');
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
               onPressed: () => _confirmDelete(academicYear),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(AcademicYear academicYear) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Academic Year'),
        content: Text('Are you sure you want to delete "${academicYear.name}"?'),
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
        await ref.read(academicsRepositoryProvider).deleteAcademicYear(academicYear.id);
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Academic Year deleted successfully')),
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
