import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../shared/widgets/custom_search_bar.dart';
import '../data/academics_repository.dart';
import '../domain/models.dart';

class StreamListScreen extends ConsumerStatefulWidget {
  const StreamListScreen({super.key});

  @override
  ConsumerState<StreamListScreen> createState() => _StreamListScreenState();
}

class _StreamListScreenState extends ConsumerState<StreamListScreen> {
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
    ref.invalidate(streamsPaginationProvider);
  }

  Future<void> _autoGenerate() async {
    try {
      await ref.read(academicsRepositoryProvider).autoGenerateStreams();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Auto-generation triggered successfully')),
        );
        _refresh();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final params = AcademicsPaginationParams(
      page: _currentPage,
      pageSize: _pageSize,
      search: _searchQuery,
    );

    final streamsAsync = ref.watch(streamsPaginationProvider(params));

    return Scaffold(
      appBar: AppBar(
        title: Text('Streams', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.autorenew),
            tooltip: 'Auto Generate Standard Streams',
            onPressed: _autoGenerate,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Create Stream',
            onPressed: () {
              context.push('/academics/streams/create');
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
              hintText: 'Search streams...',
            ),
          ),
          Expanded(
            child: streamsAsync.when(
              data: (response) {
                if (response.results.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.account_tree, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'No streams found',
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

                      final stream = response.results[index];
                      return _buildStreamCard(stream);
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
           context.push('/academics/streams/create');
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildStreamCard(Stream stream) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.lightBlue.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.account_tree,
            color: Colors.lightBlue,
          ),
        ),
        title: Text(
          stream.name,
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              'Code: ${stream.code}',
              style: GoogleFonts.outfit(color: Colors.grey[600]),
            ),
            if (stream.description != null && stream.description!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  stream.description!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.outfit(color: Colors.grey[500], fontSize: 13),
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
                 context.push('/academics/streams/${stream.id}/edit');
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
               onPressed: () => _confirmDelete(stream),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(Stream stream) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Stream'),
        content: Text('Are you sure you want to delete "${stream.name}"?'),
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
        await ref.read(academicsRepositoryProvider).deleteStream(stream.id);
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Stream deleted successfully')),
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
