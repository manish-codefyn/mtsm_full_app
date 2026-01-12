import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/exams_repository.dart';
import '../domain/models.dart';
import '../../academics/data/academics_repository.dart';

class ExamResultsScreen extends ConsumerStatefulWidget {
  final String examId;
  const ExamResultsScreen({super.key, required this.examId});

  @override
  ConsumerState<ExamResultsScreen> createState() => _ExamResultsScreenState();
}

class _ExamResultsScreenState extends ConsumerState<ExamResultsScreen> {
  bool _isLoading = true;
  List<ExamResult> _results = [];

  @override
  void initState() {
    super.initState();
    _loadResults();
  }

  Future<void> _loadResults() async {
    setState(() => _isLoading = true);
    try {
      final repo = ref.read(examRepositoryProvider);
      final response = await repo.getExamResults(examId: widget.examId, pageSize: 100);
      
      // If no results, we might need to initialize them?
      // Or show empty list.
      if (mounted) {
        setState(() {
          _results = response.results;
        });
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exam Results'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () {
               if (_results.isNotEmpty) {
                 ref.read(examRepositoryProvider).exportExamResultsPdf('Export', _results);
               }
            },
          ),
        ],
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : _results.isEmpty 
           ? Center(
               child: Column(
                 mainAxisAlignment: MainAxisAlignment.center,
                 children: [
                   const Text('No results found for this exam.'),
                   const SizedBox(height: 16),
                   ElevatedButton(
                     onPressed: () {
                         // TODO: Call initialize endpoint if we had one
                         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Initialization not implemented yet. Please add manually.')));
                     },
                     child: const Text('Initialize Results'),
                   ),
                 ],
               ),
             )
           : ListView.separated(
               padding: const EdgeInsets.all(16),
               itemCount: _results.length,
               separatorBuilder: (_, __) => const Divider(),
               itemBuilder: (context, index) {
                 final result = _results[index];
                 return ListTile(
                   leading: CircleAvatar(child: Text(result.studentName.substring(0, 1).toUpperCase())),
                   title: Text(result.studentName),
                   subtitle: Text('Adm: ${result.studentAdmissionNumber}'),
                   trailing: Row(
                     mainAxisSize: MainAxisSize.min,
                     children: [
                       Column(
                         crossAxisAlignment: CrossAxisAlignment.end,
                         mainAxisAlignment: MainAxisAlignment.center,
                         children: [
                           Text(result.percentageDisplay, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                           Text(result.isPass ? 'PASS' : 'FAIL', style: TextStyle(
                             color: result.isPass ? Colors.green : Colors.red,
                             fontSize: 12, fontWeight: FontWeight.bold
                           )),
                         ],
                       ),
                       const SizedBox(width: 8),
                       IconButton(
                         icon: const Icon(Icons.edit),
                         onPressed: () {
                           // Open Marks Entry Dialog/Screen
                           showModalBottomSheet(
                             context: context,
                             isScrollControlled: true,
                             builder: (_) => StudentMarksSheet(examResultId: result.id, studentName: result.studentName),
                           );
                         },
                       ),
                     ],
                   ),
                 );
               },
             ),
    );
  }
}

class StudentMarksSheet extends ConsumerStatefulWidget {
  final String examResultId;
  final String studentName;
  const StudentMarksSheet({super.key, required this.examResultId, required this.studentName});

  @override
  ConsumerState<StudentMarksSheet> createState() => _StudentMarksSheetState();
}

class _StudentMarksSheetState extends ConsumerState<StudentMarksSheet> {
  bool _isLoading = true;
  List<SubjectResult> _subjectResults = [];
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    _loadSubjectResults();
  }
  
  @override
  void dispose() {
    _controllers.values.forEach((c) => c.dispose());
    super.dispose();
  }

  Future<void> _loadSubjectResults() async {
    setState(() => _isLoading = true);
    try {
      final repo = ref.read(examRepositoryProvider);
      final results = await repo.getSubjectResults(widget.examResultId);
      
      if (mounted) {
        setState(() {
          _subjectResults = results;
          for (var r in results) {
            _controllers[r.id] = TextEditingController(text: r.marksObtained.toString());
          }
        });
      }
    } catch (e) {
      print(e);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveMarks() async {
    setState(() => _isLoading = true);
    try {
      final repo = ref.read(examRepositoryProvider);
      for (var r in _subjectResults) {
        final val = double.tryParse(_controllers[r.id]?.text ?? '0') ?? 0;
        if (val != r.marksObtained) {
          await repo.saveSubjectResult({
            'id': r.id,
            'exam_result': widget.examResultId,
            'exam_subject': r.subjectId,
            'marks_obtained': val,
          });
        }
      }
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Marks saved!')));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error saving: $e')));
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 24, left: 16, right: 16, bottom: MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Enter Marks: ${widget.studentName}', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          _isLoading 
            ? const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()))
            : _subjectResults.isEmpty
              ? const Text('No subjects found for this exam result.')
              : ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.6),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _subjectResults.length,
                    itemBuilder: (context, index) {
                      final item = _subjectResults[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            Expanded(child: Text(item.subjectName ?? 'Subject', style: const TextStyle(fontWeight: FontWeight.bold))),
                            SizedBox(
                              width: 100,
                              child: TextFormField(
                                controller: _controllers[item.id],
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: 'Marks (Out of ${item.maxMarks})',
                                  border: const OutlineInputBorder(),
                                  isDense: true,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
           const SizedBox(height: 24),
           SizedBox(
             width: double.infinity,
             child: ElevatedButton(onPressed: _isLoading ? null : _saveMarks, child: const Text('Save Marks')),
           ),
        ],
      ),
    );
  }
}
