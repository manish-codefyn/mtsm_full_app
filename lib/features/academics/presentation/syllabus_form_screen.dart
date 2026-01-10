import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:eduerp_app/features/academics/data/academics_repository.dart';

class SyllabusFormScreen extends ConsumerStatefulWidget {
  const SyllabusFormScreen({super.key});

  @override
  ConsumerState<SyllabusFormScreen> createState() => _SyllabusFormScreenState();
}

class _SyllabusFormScreenState extends ConsumerState<SyllabusFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _topicsController = TextEditingController();
  final _booksController = TextEditingController();
  
  String? _selectedClassId;
  String? _selectedSubjectId;
  bool _isLoading = false;

  @override
  void dispose() {
    _topicsController.dispose();
    _booksController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        // Parse topics
        final topicsList = _topicsController.text
            .split(RegExp(r'[\n,]'))
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();

        await ref.read(academicsRepositoryProvider).createSyllabus({
            'topics': topicsList,
            'recommended_books': _booksController.text,
            'class_name': _selectedClassId,
            'subject': _selectedSubjectId,
        });
         if (mounted) context.pop();
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Fetch classes and subjects
    final classesAsync = ref.watch(classesPaginationProvider(AcademicsPaginationParams(pageSize: 100)));
    final subjectsAsync = ref.watch(subjectsPaginationProvider(AcademicsPaginationParams(pageSize: 100)));

    return Scaffold(
      appBar: AppBar(title: const Text('Add Syllabus')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
               // Class Dropdown
               classesAsync.when(
                 data: (data) => DropdownButtonFormField<String>(
                   value: _selectedClassId,
                   decoration: const InputDecoration(labelText: 'Class'),
                   items: data.results.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                   onChanged: (v) => setState(() => _selectedClassId = v),
                   validator: (v) => v == null ? 'Required' : null,
                 ),
                 loading: () => const LinearProgressIndicator(),
                 error: (e, s) => Text('Error loading classes: $e'),
               ),
               const SizedBox(height: 16),
               
               // Subject Dropdown
               subjectsAsync.when(
                 data: (data) => DropdownButtonFormField<String>(
                   value: _selectedSubjectId,
                   decoration: const InputDecoration(labelText: 'Subject'),
                   items: data.results.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name))).toList(),
                   onChanged: (v) => setState(() => _selectedSubjectId = v),
                   validator: (v) => v == null ? 'Required' : null,
                 ),
                 loading: () => const LinearProgressIndicator(),
                 error: (e, s) => Text('Error loading subjects: $e'),
               ),
               const SizedBox(height: 16),

              TextFormField(
                controller: _topicsController,
                decoration: const InputDecoration(
                  labelText: 'Topics', 
                  helperText: 'Enter topics separated by newlines or commas',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
                validator: (v) => v?.isEmpty == true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _booksController,
                decoration: const InputDecoration(
                  labelText: 'Recommended Books',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _isLoading ? null : _submit,
                child: _isLoading ? const CircularProgressIndicator() : const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
