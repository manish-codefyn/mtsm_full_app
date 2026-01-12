import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/exams_repository.dart';
import '../../domain/models.dart';
import '../../../academics/data/academics_repository.dart';
import '../../../academics/domain/models.dart';

class QuestionFormScreen extends ConsumerStatefulWidget {
  final Question? question; // If editing
  final String? id; // Parameter update

  const QuestionFormScreen({super.key, this.question, this.id});

  @override
  ConsumerState<QuestionFormScreen> createState() => _QuestionFormScreenState();
}

class _QuestionFormScreenState extends ConsumerState<QuestionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _textController = TextEditingController();
  final _marksController = TextEditingController();
  
  String _type = 'THEORY';
  String _complexity = 'MEDIUM';
  String? _selectedSubjectId;
  
  List<Subject> _subjects = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSubjects();
    if (widget.question != null) {
      _initFromQuestion(widget.question!);
    } else if (widget.id != null) {
       // Should load by ID if needed, but for now assuming passed via extra
    }
  }
  
  void _initFromQuestion(Question q) {
     _textController.text = q.questionText;
     _marksController.text = q.marks.toString();
     _type = q.questionType;
     _complexity = q.complexity;
     _selectedSubjectId = null; // Ideally match name to ID or fetch detail
     // Since Question model only has subjectName, we might need to rely on user re-selecting or fetch Detail.
     // For MVP, user re-selects subject if they edit.
  }

  Future<void> _loadSubjects() async {
    try {
      final repo = ref.read(academicsRepositoryProvider);
      final subjects = await repo.getAllSubjects();
      setState(() => _subjects = subjects);
    } catch (_) {}
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSubjectId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a subject')));
      return;
    }

    setState(() => _isLoading = true);
    final repo = ref.read(examRepositoryProvider);
    try {
      final data = {
        'question_text': _textController.text,
        'question_type': _type,
        'marks': double.parse(_marksController.text),
        'complexity': _complexity,
        'subject': _selectedSubjectId,
        'topic': '', // Optional
      };

      if (widget.question != null) {
         data['id'] = widget.question!.id;
      } else if (widget.id != null) {
         data['id'] = widget.id;
      }

      await repo.saveQuestion(data);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Question saved!')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.question == null ? 'New Question' : 'Edit Question')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                value: _selectedSubjectId,
                decoration: const InputDecoration(labelText: 'Subject', border: OutlineInputBorder()),
                items: _subjects.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name))).toList(),
                onChanged: (val) => setState(() => _selectedSubjectId = val),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _type,
                      decoration: const InputDecoration(labelText: 'Type', border: OutlineInputBorder()),
                      items: const [
                        DropdownMenuItem(value: 'MCQ', child: Text('MCQ')),
                        DropdownMenuItem(value: 'THEORY', child: Text('Theory')),
                        DropdownMenuItem(value: 'TRUE_FALSE', child: Text('True/False')),
                      ],
                      onChanged: (val) => setState(() => _type = val!),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _complexity,
                      decoration: const InputDecoration(labelText: 'Complexity', border: OutlineInputBorder()),
                      items: const [
                        DropdownMenuItem(value: 'EASY', child: Text('Easy')),
                        DropdownMenuItem(value: 'MEDIUM', child: Text('Medium')),
                        DropdownMenuItem(value: 'HARD', child: Text('Hard')),
                      ],
                      onChanged: (val) => setState(() => _complexity = val!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _marksController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Marks', border: OutlineInputBorder()),
                validator: (val) => (val == null || val.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _textController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Question Text', border: OutlineInputBorder(), alignLabelWithHint: true),
                validator: (val) => (val == null || val.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple, foregroundColor: Colors.white, padding: const EdgeInsets.all(16)),
                  child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Save Question'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
