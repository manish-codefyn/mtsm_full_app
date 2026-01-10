import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart'; // Import Printing
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/custom_search_bar.dart';
// import '../../../../shared/widgets/loading_overlay.dart'; // Not found
import '../data/academics_repository.dart';
import '../domain/models.dart';

class SyllabusListScreen extends ConsumerStatefulWidget {
  const SyllabusListScreen({super.key});

  @override
  ConsumerState<SyllabusListScreen> createState() => _SyllabusListScreenState();
}

class _SyllabusListScreenState extends ConsumerState<SyllabusListScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _currentPage = 1;
  static const int _pageSize = 10;
  String? _searchQuery;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    setState(() {
      _searchQuery = query.isEmpty ? null : query;
      _currentPage = 1;
    });
  }

  Future<void> _handleAutoGenerate() async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Auto Generate Syllabus?'),
        content: const Text('This will generate syllabus for all subjects based on standard curriculum. Existing data may be updated.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Generate')),
        ],
      ),
    );

    if (confirmed == true) {
      // Show loading
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      try {
        await ref.read(academicsRepositoryProvider).autoGenerateSyllabus();
        if (mounted) {
          Navigator.pop(context); // Hide loading
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Syllabus generation initiated successfully')));
          setState(() {
             _currentPage = 1; // Refresh list
          });
        }
      } catch (e) {
        if (mounted) {
          Navigator.pop(context); // Hide loading
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Syllabus'),
        centerTitle: true,
        actions: [
           TextButton.icon(
            onPressed: _handleAutoGenerate,
            icon: const Icon(Icons.autorenew),
            label: const Text('Auto Gen'),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
               context.push('/academics/syllabus/add');
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
              hintText: 'Search syllabus...',
            ),
          ),
          Expanded(
            child: FutureBuilder<dynamic>( // Using dynamic because PaginatedResponse generics might be tricky without full typing import
              future: ref.read(academicsRepositoryProvider).getSyllabus(
                AcademicsPaginationParams(
                  page: _currentPage,
                  pageSize: _pageSize,
                  search: _searchQuery,
                ),
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.results.isEmpty) {
                  return const Center(child: Text('No syllabus found.'));
                }

                final syllabusList = snapshot.data!.results as List<Syllabus>;
                final totalCount = snapshot.data!.count as int;
                final totalPages = (totalCount / _pageSize).ceil();

                return Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: syllabusList.length,
                        itemBuilder: (context, index) {
                          final syllabus = syllabusList[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: ListTile(
                              title: Text('${syllabus.classNameDetail?.name ?? "Class"} - ${syllabus.subjectDetail?.name ?? "Subject"}'),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (syllabus.topics != null && syllabus.topics!.isNotEmpty)
                                    Text('Topics: ${(syllabus.topics as List).join(", ")}', maxLines: 2, overflow: TextOverflow.ellipsis),
                                  if (syllabus.recommendedBooks != null)
                                    Text('Books: ${syllabus.recommendedBooks}', maxLines: 1, overflow: TextOverflow.ellipsis),
                                ],
                              ),
                              trailing: IconButton( // Change to IconButton
                                icon: const Icon(Icons.download),
                                onPressed: () async {
                                    try {
                                      // Show loading feedback
                                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Downloading PDF...')));
                                      
                                      final bytes = await ref.read(academicsRepositoryProvider).downloadSyllabusPdf(syllabus.id);
                                      
                                      await Printing.sharePdf(
                                        bytes: bytes, 
                                        filename: 'syllabus_${syllabus.classNameDetail?.name ?? "Class"}_${syllabus.subjectDetail?.name ?? "Subject"}.pdf'
                                      );
                                    } catch (e) {
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Download failed: $e')));
                                    }
                                  },
                              ),
                              onTap: () {
                                // View details if needed, or do nothing as verified by user
                              },
                            ),
                          );
                        },
                      ),
                    ),
                    if (totalPages > 1)
                      Padding(
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
                            Text('Page $_currentPage of $totalPages'),
                            IconButton(
                              onPressed: _currentPage < totalPages
                                  ? () => setState(() => _currentPage++)
                                  : null,
                              icon: const Icon(Icons.chevron_right),
                            ),
                          ],
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
