import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/academics_repository.dart';
import '../domain/models.dart';
import '../../../shared/models/paginated_response.dart';

final housesPaginationProvider = FutureProvider.family.autoDispose<PaginatedResponse<House>, AcademicsPaginationParams>((ref, params) async {
  return ref.watch(academicsRepositoryProvider).getHouses(params);
});

class HouseListScreen extends ConsumerStatefulWidget {
  const HouseListScreen({super.key});

  @override
  ConsumerState<HouseListScreen> createState() => _HouseListScreenState();
}

class _HouseListScreenState extends ConsumerState<HouseListScreen> {
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
        _page = 1;
      });
    });
  }

  Future<void> _handleAutoGenerate() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Auto-Generate Houses'),
        content: const Text(
            'This will generate 4 standard houses (Red, Blue, Green, Yellow). Continue?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Generate'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref.read(academicsRepositoryProvider).autoGenerateHouses();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Houses generated successfully!')));
        ref.refresh(housesPaginationProvider(AcademicsPaginationParams(page: _page, pageSize: _pageSize)));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _deleteHouse(String id) async {
     final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete House'),
        content: const Text('Are you sure you want to delete this house?'),
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
        await ref.read(academicsRepositoryProvider).deleteHouse(id);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('House deleted successfully!')));
        ref.refresh(housesPaginationProvider(AcademicsPaginationParams(page: _page, pageSize: _pageSize)));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final params = AcademicsPaginationParams(
      page: _page,
      pageSize: _pageSize,
      search: _searchQuery,
    );
    final housesAsync = ref.watch(housesPaginationProvider(params));

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: housesAsync.when(
        data: (response) => _buildContent(context, response),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text('Error loading houses: $err'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(housesPaginationProvider(params)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, PaginatedResponse<House> response) {
    return Column(
      children: [
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Houses',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.teal[900],
                              ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Manage school houses',
                          style: TextStyle(color: Colors.grey[600]),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: _handleAutoGenerate,
                    icon: const Icon(Icons.auto_awesome),
                    label: const Text('Auto Generate'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.teal,
                      side: const BorderSide(color: Colors.teal),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () => context.go('/academics/houses/add'),
                    icon: const Icon(Icons.add),
                    label: const Text('Add House'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  hintText: 'Search houses...',
                  prefixIcon: const Icon(Icons.search, color: Colors.teal),
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
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: Theme(
                data: Theme.of(context).copyWith(
                  dividerColor: Colors.transparent,
                  dataTableTheme: DataTableThemeData(
                    headingTextStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                    dataRowColor: MaterialStateProperty.resolveWith((states) {
                      if (states.contains(MaterialState.selected)) return Colors.teal.withOpacity(0.1);
                      return Colors.white;
                    }),
                  ),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    horizontalMargin: 24,
                    columnSpacing: 24,
                    headingRowHeight: 56,
                    dataRowHeight: 72,
                    columns: const [
                      DataColumn(label: Text('Name')),
                      DataColumn(label: Text('Code')),
                      DataColumn(label: Text('Color')),
                      DataColumn(label: Text('Master')),
                      DataColumn(label: Text('Actions')),
                    ],
                    rows: response.results.map((house) {
                      return DataRow(
                        cells: [
                          DataCell(Text(house.name, style: const TextStyle(fontWeight: FontWeight.w600))),
                          DataCell(Text(house.code)),
                          DataCell(Row(
                            children: [
                              Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: _getColor(house.color),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.grey.shade300)
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(house.color),
                            ],
                          )),
                          DataCell(Text(house.houseMasterDetail?['full_name'] ?? 'Not Assigned', style: const TextStyle(fontSize: 13))),
                          DataCell(
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                 IconButton(
                                  icon: const Icon(Icons.edit_outlined, size: 20, color: Colors.blue),
                                  onPressed: () {},
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
                                  onPressed: () => _deleteHouse(house.id),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Color _getColor(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'red': return Colors.red;
      case 'blue': return Colors.blue;
      case 'green': return Colors.green;
      case 'yellow': return Colors.yellow;
      default: return Colors.grey;
    }
  }
}
