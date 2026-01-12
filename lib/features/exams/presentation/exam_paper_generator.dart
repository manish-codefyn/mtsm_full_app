import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../academics/data/academics_repository.dart';
import '../../academics/domain/models.dart';
import '../data/exams_repository.dart';
import '../domain/models.dart';

class ExamPaperGeneratorScreen extends ConsumerStatefulWidget {
  const ExamPaperGeneratorScreen({super.key});

  @override
  ConsumerState<ExamPaperGeneratorScreen> createState() => _ExamPaperGeneratorScreenState();
}

class _ExamPaperGeneratorScreenState extends ConsumerState<ExamPaperGeneratorScreen> {
  final _formKey = GlobalKey<FormState>();
  
  String? _selectedClassId;
  String? _selectedSubjectId;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _marksController = TextEditingController(text: '100');
  final TextEditingController _durationController = TextEditingController(text: '180');
  final TextEditingController _instructionsController = TextEditingController(text: '1. All questions are compulsory.\n2. Write answers clearly.');

  bool _isGenerating = false;
  List<SchoolClass> _classes = [];
  List<Subject> _subjects = [];

  @override
  void initState() {
    super.initState();
    _loadClasses();
  }

  Future<void> _loadClasses() async {
    final results = await ref.read(academicsRepositoryProvider).getClassesPaginated(
      const AcademicsPaginationParams(page: 1, pageSize: 100)
    );
    if(mounted) setState(() => _classes = results.results);
  }

  Future<void> _loadSubjects(String classId) async {
    // Assuming we have a way to get subjects for a class.
    // For now, let's just fetch all subjects or mock it, as getSubjects isn't filtered by class in basic repo usually.
    // We'll use the generic getSubjects.
    final results = await ref.read(academicsRepositoryProvider).getSubjects(page: 1, pageSize: 100);
    if(mounted) setState(() => _subjects = results.results);
  }

  Future<void> _generatePaper() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isGenerating = true);
    
    try {
      await ref.read(examRepositoryProvider).generateExamPaper(
        name: _nameController.text,
        subjectId: _selectedSubjectId!,
        classId: _selectedClassId!,
        totalMarks: double.parse(_marksController.text),
        durationMinutes: int.parse(_durationController.text),
        instructions: _instructionsController.text,
        questionTypes: ['THEORY', 'MCQ'], // Hardcoded preference for now
      );
      
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Paper Generated Successfully!')));
        context.pop();
      }
    } catch (e) {
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if(mounted) setState(() => _isGenerating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Generate Exam Paper')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Paper Name', border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedClassId,
                      decoration: const InputDecoration(labelText: 'Class', border: OutlineInputBorder()),
                      items: _classes.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                      onChanged: (val) {
                         setState(() => _selectedClassId = val);
                         if (val != null) _loadSubjects(val);
                      },
                      validator: (v) => v == null ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                   Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedSubjectId,
                      decoration: const InputDecoration(labelText: 'Subject', border: OutlineInputBorder()),
                      items: _subjects.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name))).toList(),
                      onChanged: (val) => setState(() => _selectedSubjectId = val),
                      validator: (v) => v == null ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _marksController,
                      decoration: const InputDecoration(labelText: 'Total Marks', border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _durationController,
                      decoration: const InputDecoration(labelText: 'Duration (Mins)', border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _instructionsController,
                decoration: const InputDecoration(labelText: 'Instructions', border: OutlineInputBorder()),
                maxLines: 4,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isGenerating ? null : _generatePaper,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                 ),
                child: _isGenerating 
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white))
                  : const Text('GENERATE & PREVIEW PDF', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
