import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/custom_search_bar.dart';
import '../data/academics_repository.dart';
import 'package:printing/printing.dart';
import '../data/academics_repository.dart';
import '../domain/models.dart';

class StudyMaterialListScreen extends ConsumerStatefulWidget {
  const StudyMaterialListScreen({super.key});

  @override
  ConsumerState<StudyMaterialListScreen> createState() => _StudyMaterialListScreenState();
}

class _StudyMaterialListScreenState extends ConsumerState<StudyMaterialListScreen> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Study Materials'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_awesome),
            tooltip: 'Auto Generate',
            onPressed: () async {
              try {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Auto-generating study materials...')),
                );
                await ref.read(academicsRepositoryProvider).autoGenerateStudyMaterial();
                setState(() {
                  _currentPage = 1; // Refresh list
                });
                if (context.mounted) {
                   ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Study materials generated successfully!')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                   ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
               context.push('/academics/study-materials/add');
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
              hintText: 'Search study materials...',
            ),
          ),
          Expanded(
            child: FutureBuilder<dynamic>(
              future: ref.read(academicsRepositoryProvider).getStudyMaterials(
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
                  return const Center(child: Text('No study materials found.'));
                }

                final materialList = snapshot.data!.results as List<StudyMaterial>;
                final totalCount = snapshot.data!.count as int;
                final totalPages = (totalCount / _pageSize).ceil();

                return Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: materialList.length,
                        itemBuilder: (context, index) {
                          final material = materialList[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: ListTile(
                              title: Text(material.title),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (material.classSubjectDetail != null)
                                    Text('${material.classSubjectDetail?.classNameDetail?.name ?? "Class"} - ${material.classSubjectDetail?.subjectDetail?.name ?? "Subject"}'),
                                  if (material.uploadedAt != null)
                                    Text('Uploaded: ${material.uploadedAt}'),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.download),
                                    onPressed: () async {
                                      try {
                                         ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Downloading file...')),
                                        );
                                        final pdfData = await ref.read(academicsRepositoryProvider).downloadStudyMaterial(material.id!, material.title);
                                        await Printing.sharePdf(bytes: pdfData, filename: '${material.title}.pdf');
                                      } catch (e) {
                                         if (context.mounted) {
                                           ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('Download failed: $e')),
                                          );
                                         }
                                      }
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () async {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text('Confirm Delete'),
                                          content: const Text('Are you sure you want to delete this study material?'),
                                          actions: [
                                            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                                            TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
                                          ],
                                        ),
                                      );
                                      
                                      if (confirm == true) {
                                        try {
                                          await ref.read(academicsRepositoryProvider).deleteStudyMaterial(material.id!);
                                          setState(() {}); // Refresh
                                          if (context.mounted) {
                                             ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text('Study material deleted.')),
                                            );
                                          }
                                        } catch (e) {
                                          if (context.mounted) {
                                             ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text('Delete failed: $e')),
                                            );
                                          }
                                        }
                                      }
                                    },
                                  ),
                                ],
                              ),
                              onTap: () {
                                // View details if needed
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
