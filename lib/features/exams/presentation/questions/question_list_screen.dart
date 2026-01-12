import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/exams_repository.dart';
import '../../domain/models.dart';
import '../../../academics/data/academics_repository.dart';
import '../../../academics/domain/models.dart';

class QuestionListScreen extends ConsumerStatefulWidget {
  const QuestionListScreen({super.key});

  @override
  ConsumerState<QuestionListScreen> createState() => _QuestionListScreenState();
}

class _QuestionListScreenState extends ConsumerState<QuestionListScreen> {
  int _page = 1;
  int _pageSize = 20;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  // Filters
  String? _selectedSubjectId;
  String? _selectedType;
  List<Subject> _subjects = [];

  bool _isLoading = true;
  List<Question> _questions = [];
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _loadSubjects();
    _loadQuestions();
  }

  Future<void> _loadSubjects() async {
    try {
      final repo = ref.read(academicsRepositoryProvider);
      final subjects = await repo.getAllSubjects();
      if (mounted) setState(() => _subjects = subjects);
    } catch (_) {}
  }

  Future<void> _loadQuestions() async {
    setState(() => _isLoading = true);
    try {
      final repo = ref.read(examRepositoryProvider);
      final response = await repo.getQuestions(
        page: _page,
        pageSize: _pageSize,
        search: _searchQuery,
        subjectId: _selectedSubjectId,
        type: _selectedType,
      );
      if (mounted) {
        setState(() {
          _questions = response.results;
          _hasMore = response.next != null;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Question Bank'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'Export List',
            onPressed: () async {
               final repo = ref.read(examRepositoryProvider);
               await repo.exportQuestionListPdf(_questions);
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => context.push('/exams/questions/create'),
      ),
      body: Column(
        children: [
          // Filters
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    labelText: 'Search Questions',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (val) {
                    _searchQuery = val;
                   _page = 1;
                   _loadQuestions();
                  },
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedSubjectId,
                        decoration: const InputDecoration(labelText: 'Subject', border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 10)),
                        items: [
                          const DropdownMenuItem(value: null, child: Text('All Subjects')),
                          ..._subjects.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name, overflow: TextOverflow.ellipsis))),
                        ],
                        onChanged: (val) {
                          _selectedSubjectId = val;
                          _page = 1;
                          _loadQuestions();
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedType,
                        decoration: const InputDecoration(labelText: 'Type', border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 10)),
                        items: const [
                          DropdownMenuItem(value: null, child: Text('All Types')),
                          DropdownMenuItem(value: 'MCQ', child: Text('MCQ')),
                          DropdownMenuItem(value: 'THEORY', child: Text('Theory')),
                          DropdownMenuItem(value: 'TRUE_FALSE', child: Text('True/False')),
                        ],
                        onChanged: (val) {
                          _selectedType = val;
                          _page = 1;
                          _loadQuestions();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _questions.isEmpty 
                ? const Center(child: Text('No questions found.'))
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _questions.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, index) {
                      final q = _questions[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: q.questionType == 'MCQ' ? Colors.orange[100] : Colors.blue[100],
                          child: Text(q.questionType.substring(0, 1), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                        title: Text(q.questionText, maxLines: 2, overflow: TextOverflow.ellipsis),
                        subtitle: Text('${q.subjectName ?? "General"} • ${q.marks} Marks • ${q.complexity}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => context.push('/exams/questions/edit/${q.id}', extra: q),
                            ),
                             IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context, 
                                  builder: (c) => AlertDialog(
                                    title: const Text('Delete Question?'), 
                                    actions: [
                                      TextButton(onPressed: ()=>Navigator.pop(c,false), child: const Text('Cancel')),
                                      TextButton(onPressed: ()=>Navigator.pop(c,true), child: const Text('Delete')),
                                    ]
                                  ));
                                if (confirm == true) {
                                  await ref.read(examRepositoryProvider).deleteQuestion(q.id);
                                  _loadQuestions();
                                }
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
