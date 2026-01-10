import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import 'package:eduerp_app/features/academics/data/academics_repository.dart';
import 'package:eduerp_app/features/academics/domain/models.dart';

class StudyMaterialFormScreen extends ConsumerStatefulWidget {
  const StudyMaterialFormScreen({super.key});

  @override
  ConsumerState<StudyMaterialFormScreen> createState() => _StudyMaterialFormScreenState();
}

class _StudyMaterialFormScreenState extends ConsumerState<StudyMaterialFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  String? _selectedClassId;
  String? _selectedSubjectId;
  String _selectedMaterialType = 'NOTE';

  final List<String> _materialTypes = [
    'NOTE', 'PRESENTATION', 'WORKSHEET', 'ASSIGNMENT', 'REFERENCE', 'VIDEO', 'AUDIO', 'OTHER'
  ];
  
  // In a real app, we'd use file picker. For now, we might simulate or just skip file upload logic 
  // until we have a proper file picker package. 
  // Assuming API accepts JSON for now or FormData without file if nullable.
  
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final data = {
          'title': _titleController.text,
          'description': _descriptionController.text,
          'class_name': _selectedClassId,
          'subject': _selectedSubjectId,
          'material_type': _selectedMaterialType,
        };
        
         await ref.read(academicsRepositoryProvider).createStudyMaterial(data);
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
      appBar: AppBar(title: const Text('Add Study Material')),
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
                
                // Material Type Dropdown
                DropdownButtonFormField<String>(
                  value: _selectedMaterialType,
                  decoration: const InputDecoration(labelText: 'Material Type'),
                  items: _materialTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                  onChanged: (v) => setState(() => _selectedMaterialType = v!),
                  validator: (v) => v == null ? 'Required' : null,
                ),
                const SizedBox(height: 16),

               TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (v) => v?.isEmpty == true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
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
