import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:printing/printing.dart';
import '../data/academics_repository.dart';
import '../domain/models.dart';

import 'package:dio/dio.dart';

class TimetableScreen extends ConsumerStatefulWidget {
  const TimetableScreen({super.key});

  @override
  ConsumerState<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends ConsumerState<TimetableScreen> {
  // ... existing variables ...
  String? _selectedClassId;
  String? _selectedSectionId;
  List<SchoolClass> _classes = [];
  List<Section> _sections = [];
  bool _isLoadingFilters = false;
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    _loadClasses();
  }

  Future<void> _loadClasses() async {
    setState(() => _isLoadingFilters = true);
    try {
      _classes = await ref.read(academicsRepositoryProvider).getAllClasses();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error loading classes: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoadingFilters = false);
    }
  }

  Future<void> _loadSections(String classId) async {
    setState(() => _isLoadingFilters = true);
    try {
      // Fetch sections for class. Using getSectionsPaginated with filter. 
      // Ideally should have getAllSections(classId) helper, but pagination works if page size large enough.
      final response = await ref.read(academicsRepositoryProvider).getSectionsPaginated(
        AcademicsPaginationParams(classId: classId, pageSize: 100)
      );
      _sections = response.results;
      _selectedSectionId = null; 
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error loading sections: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoadingFilters = false);
    }
  }

  Future<void> _autoGenerate() async {
    if (_selectedClassId == null || _selectedSectionId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select Class and Section first')));
      return;
    }

    setState(() => _isGenerating = true);
    try {
      final academicYear = await ref.read(currentAcademicYearProvider.future);
      await ref.read(academicsRepositoryProvider).autoGenerateTimetable(
        classId: _selectedClassId!,
        sectionId: _selectedSectionId!,
        academicYearId: academicYear.id,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Timetable auto-generation triggered!')));
        ref.invalidate(timetableProvider);
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Generation failed. Please try again.';
        String? technicalDetails;

        if (e is DioException) {
          if (e.response?.data != null && e.response!.data is Map) {
             final data = e.response!.data as Map;
             if (data['error'] != null) {
               errorMessage = data['error'].toString();
               // Remove brackets if list
               if (errorMessage.startsWith('[') && errorMessage.endsWith(']')) {
                  errorMessage = errorMessage.substring(1, errorMessage.length - 1);
               }
               // Remove quotes if present
               if (errorMessage.startsWith("'") && errorMessage.endsWith("'")) {
                  errorMessage = errorMessage.substring(1, errorMessage.length - 1);
               }
             }
          } else {
            errorMessage = e.message ?? e.toString();
          }
        } else {
          technicalDetails = e.toString();
        }

        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red[700]),
                const SizedBox(width: 8),
                const Text('Generation Failed'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(errorMessage, style: const TextStyle(fontSize: 16)),
                if (technicalDetails != null) ...[
                  const SizedBox(height: 8),
                  Text(technicalDetails, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                ]
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  bool _isGridView = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Timetable', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(_isGridView ? Icons.list : Icons.grid_view),
            onPressed: () => setState(() => _isGridView = !_isGridView),
            tooltip: _isGridView ? 'Switch to List View' : 'Switch to Grid View',
          ),
          if (_selectedClassId != null && _selectedSectionId != null)
            IconButton(
              icon: const Icon(Icons.download),
              onPressed: _downloadPdf,
              tooltip: 'Download PDF',
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(timetableProvider),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filters
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                   Row(
                     children: [
                       Expanded(
                         child: DropdownButtonFormField<String>(
                           value: _selectedClassId,
                           decoration: const InputDecoration(labelText: 'Class', border: OutlineInputBorder()),
                           items: _classes.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                           onChanged: (val) {
                             if (val != null) {
                               setState(() => _selectedClassId = val);
                               _loadSections(val);
                             }
                           },
                         ),
                       ),
                       const SizedBox(width: 16),
                       Expanded(
                         child: DropdownButtonFormField<String>(
                           value: _selectedSectionId,
                           decoration: const InputDecoration(labelText: 'Section', border: OutlineInputBorder()),
                           items: _sections.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name))).toList(),
                           onChanged: _selectedClassId == null ? null : (val) => setState(() => _selectedSectionId = val),
                         ),
                       ),
                     ],
                   ),
                   const SizedBox(height: 16),
                   Row(
                     children: [
                       Expanded(
                         child: ElevatedButton.icon(
                           onPressed: (_selectedClassId != null && _selectedSectionId != null && !_isGenerating) 
                              ? _autoGenerate 
                              : null,
                           icon: _isGenerating 
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : const Icon(Icons.auto_awesome),
                           label: const Text('Auto-Generate'),
                           style: ElevatedButton.styleFrom(
                             backgroundColor: Colors.purple,
                             foregroundColor: Colors.white,
                             padding: const EdgeInsets.symmetric(vertical: 12),
                           ),
                         ),
                       ),
                       const SizedBox(width: 16),
                       Expanded(
                         child: OutlinedButton.icon(
                           onPressed: (_selectedClassId != null && _selectedSectionId != null) 
                              ? _showAddEntryDialog 
                              : null,
                           icon: const Icon(Icons.add),
                           label: const Text('Add Entry'),
                           style: OutlinedButton.styleFrom(
                             padding: const EdgeInsets.symmetric(vertical: 12),
                           ),
                         ),
                       ),
                     ],
                   ),
                ],
              ),
            ),
          ),

          // Content
          Expanded(
            child: (_selectedClassId == null || _selectedSectionId == null)
                ? Center(child: Text('Select Class and Section to view timetable', style: GoogleFonts.outfit(color: Colors.grey)))
                : _buildTimetableContent(),
          ),
        ],
      ),
    );
  }

  Future<void> _downloadPdf() async {
    try {
      final bytes = await ref.read(academicsRepositoryProvider).downloadTimetablePdf(_selectedClassId!, _selectedSectionId!);
      // Ensure bytes are valid before sharing
      if (bytes.isEmpty) throw Exception('Received empty PDF file');
      
      await Printing.sharePdf(bytes: bytes, filename: 'Timetable_${_selectedClassId}_$_selectedSectionId.pdf');
    } on DioException catch (e) {
       _showErrorDialog(e);
    } catch (e) {
       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Download failed: $e')));
    }
  }

  void _showErrorDialog(DioException e) {
    String message = 'An unexpected error occurred.';
    String title = 'Operation Failed';
    IconData icon = Icons.error_outline;
    Color color = Colors.red;

    if (e.response != null) {
      if (e.response?.statusCode == 404) {
         title = 'No Data Found';
         message = 'No timetable entries exist for this class. Please create a timetable first.';
         icon = Icons.info_outline;
         color = Colors.orange;
      } else if (e.response?.data != null && e.response?.data is Map && e.response?.data.containsKey('error')) {
         message = e.response?.data['error'].toString() ?? message;
      }
    }
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 8),
            Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          message,
          style: GoogleFonts.outfit(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddEntryDialog({TimeTable? entry}) async {
    // If entry is provided, it's an Edit operation
    final isEdit = entry != null;
    
    // Initial Values
    String day = entry?.day ?? 'MONDAY';
    int period = entry?.periodNumber ?? 1;
    String startTime = entry?.startTime ?? '09:00';
    String endTime = entry?.endTime ?? '10:00';
    String? subjectId = entry?.classSubjectId;
    String? teacherId = entry?.teacherDetail?['id']?.toString();
    String? room = entry?.room;

    // Fetch dropdown data
    List<ClassSubject> subjects = [];
    List<Map<String, dynamic>> teachers = [];
    bool isLoadingData = true;

    // We need a stateful builder for the dialog content to handle async data loading
    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          
          // Load data once
          if (isLoadingData) {
            Future.wait([
               ref.read(academicsRepositoryProvider).getAllClassSubjects(_selectedClassId!),
               ref.read(academicsRepositoryProvider).getTeachers()
            ]).then((results) {
               if (context.mounted) {
                 setStateDialog(() {
                   subjects = results[0] as List<ClassSubject>;
                   teachers = results[1] as List<Map<String, dynamic>>;
                   isLoadingData = false;
                   
                   // Ensure initial subjectId/teacherId are valid or null if not found
                   if (subjectId == null && subjects.isNotEmpty) subjectId = subjects.first.id;
                   // Don't auto-set teacher if not present, let user pick
                 });
               }
            });
          }

          if (isLoadingData) {
            return const AlertDialog(content: SizedBox(height: 100, child: Center(child: CircularProgressIndicator())));
          }

          return AlertDialog(
            title: Text(isEdit ? 'Edit Entry' : 'Add Entry'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: day,
                    decoration: const InputDecoration(labelText: 'Day'),
                    items: ['MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY', 'SATURDAY']
                        .map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                    onChanged: (val) => setStateDialog(() => day = val!),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    initialValue: period.toString(),
                    decoration: const InputDecoration(labelText: 'Period Number'),
                    keyboardType: TextInputType.number,
                    onChanged: (val) => period = int.tryParse(val) ?? period,
                  ),
                   const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          initialValue: startTime,
                          decoration: const InputDecoration(labelText: 'Start (HH:MM)'),
                          onChanged: (val) => startTime = val,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          initialValue: endTime,
                          decoration: const InputDecoration(labelText: 'End (HH:MM)'),
                          onChanged: (val) => endTime = val,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: subjectId,
                    decoration: const InputDecoration(labelText: 'Subject'),
                    items: subjects.map((s) => DropdownMenuItem(value: s.id, child: Text(s.subjectDetail?.name ?? 'Unknown'))).toList(),
                    onChanged: (val) => setStateDialog(() => subjectId = val),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: teacherId,
                    decoration: const InputDecoration(labelText: 'Teacher'),
                    items: teachers.map((t) => DropdownMenuItem(
                      value: t['id'].toString(), 
                      child: Text("${t['first_name']} ${t['last_name']}")
                    )).toList(),
                    onChanged: (val) => setStateDialog(() => teacherId = val),
                  ),
                   const SizedBox(height: 8),
                  TextFormField(
                    initialValue: room,
                    decoration: const InputDecoration(labelText: 'Room No.'),
                    onChanged: (val) => room = val,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () async {
                   if (subjectId == null) {
                     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a subject')));
                     return;
                   }
                   
                   final data = {
                     'class_name': _selectedClassId,
                     'section': _selectedSectionId,
                     'day': day,
                     'period_number': period,
                     'start_time': startTime,
                     'end_time': endTime,
                     'subject': subjectId,
                     'room': room,
                     // Only include teacher if selected (nullable)
                     if (teacherId != null) 'teacher': teacherId, 
                     // Assuming backend year is handled or we pass it? 
                     // Usually derived from active year in backend, but let's see. Views use active year.
                   };
                   
                   try {
                     if (isEdit) {
                       await ref.read(academicsRepositoryProvider).updateTimetableEntry(entry.id, data);
                       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Entry updated')));
                     } else {
                       await ref.read(academicsRepositoryProvider).createTimetableEntry(data);
                       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Entry added')));
                     }
                     Navigator.pop(context);
                     ref.invalidate(timetableProvider);
                   } on DioException catch (e) {
                      Navigator.pop(context);
                      _showErrorDialog(e);
                   } catch (e) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                   }
                },
                child: Text(isEdit ? 'Update' : 'Create'),
              ),
            ],
          );
        }
      ),
    );
  }
  
  Future<void> _deleteEntry(String id) async {
     try {
       await ref.read(academicsRepositoryProvider).deleteTimetableEntry(id);
       ref.invalidate(timetableProvider);
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Entry deleted')));
     } catch (e) {
       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Delete failed: $e')));
     }
  }

  Widget _buildTimetableContent() {
    final params = AcademicsPaginationParams(
      classId: _selectedClassId,
      sectionId: _selectedSectionId,
      pageSize: 100, // Fetch all entries
    );
    
    return Consumer(
      builder: (context, ref, child) {
        final timetableAsync = ref.watch(timetableProvider(params));
        
        return timetableAsync.when(
          data: (response) {
            if (response.results.isEmpty) {
               return const Center(child: Text('No timetable entries found. Try Auto-Generate or Add Entry.'));
            }
            return _isGridView 
              ? _buildTimetableGrid(response.results)
              : _buildTimetableList(response.results);
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, s) => Center(child: Text('Error: $e')),
        );
      },
    );
  }

  Widget _buildTimetableList(List<TimeTable> entries) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        return Card(
           child: ListTile(
             title: Text('${entry.day} - Period ${entry.periodNumber}'),
             subtitle: Text('${entry.subjectDetail?.subjectDetail?.name} (${entry.startTime}-${entry.endTime})'),
             trailing: Row(
               mainAxisSize: MainAxisSize.min,
               children: [
                 IconButton(
                   icon: const Icon(Icons.edit, color: Colors.blue),
                   onPressed: () => _showAddEntryDialog(entry: entry),
                 ),
                 IconButton(
                   icon: const Icon(Icons.delete, color: Colors.red),
                   onPressed: () => _deleteEntry(entry.id),
                 ),
               ],
             ),
           ),
        );
      },
    );
  }

  Widget _buildTimetableGrid(List<TimeTable> entries) {
    // Group by Day
    final days = ['MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY', 'SATURDAY'];
    
    return DefaultTabController(
      length: days.length,
      child: Column(
        children: [
          TabBar(
            isScrollable: true,
            labelColor: Colors.purple,
            unselectedLabelColor: Colors.grey,
            tabs: days.map((day) => Tab(text: day)).toList(),
          ),
          Expanded(
            child: TabBarView(
              children: days.map((day) {
                final dayEntries = entries.where((e) => e.day == day).toList();
                dayEntries.sort((a, b) => a.periodNumber.compareTo(b.periodNumber));
                
                if (dayEntries.isEmpty) {
                   return Center(
                     child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('No classes scheduled'),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: _showAddEntryDialog, 
                            child: const Text('Add Class This Day')
                          )
                        ]
                     )
                   );
                }
                
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: dayEntries.length,
                  itemBuilder: (context, index) {
                    final entry = dayEntries[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 2,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.purple.withOpacity(0.1),
                          child: Text(
                            '${entry.periodNumber}',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.purple),
                          ),
                        ),
                        title: Text(
                          entry.subjectDetail?.subjectDetail?.name ?? 'Unknown Subject',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          // Simple teacher name extraction
                           '${entry.startTime.substring(0, 5)} - ${entry.endTime.substring(0, 5)} • ${entry.room ?? "No Room"}',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (entry.teacherDetail != null) 
                            Chip(
                              label: Text(
                                '${entry.teacherDetail!['first_name']} ${entry.teacherDetail!['last_name']}',
                                style: const TextStyle(fontSize: 10),
                              ),
                              backgroundColor: Colors.grey[100],
                            ),
                            IconButton(
                               icon: const Icon(Icons.edit, size: 20, color: Colors.blue),
                               onPressed: () => _showAddEntryDialog(entry: entry),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                              onPressed: () => _deleteEntry(entry.id),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
