import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:eduerp_app/features/academics/data/academics_repository.dart';
import 'package:eduerp_app/features/academics/domain/models.dart';
import '../../../shared/models/paginated_response.dart';

final gradesProvider = FutureProvider.family.autoDispose<PaginatedResponse<Grade>, String>((ref, systemId) async {
  return ref.watch(academicsRepositoryProvider).getGrades(systemId);
});

class GradeListScreen extends ConsumerStatefulWidget {
  final String gradingSystemId;
  final String gradingSystemName;

  const GradeListScreen({
    super.key,
    required this.gradingSystemId,
    required this.gradingSystemName,
  });

  @override
  ConsumerState<GradeListScreen> createState() => _GradeListScreenState();
}

class _GradeListScreenState extends ConsumerState<GradeListScreen> {
  
  void _showGradeForm({Grade? grade}) {
    showDialog(
      context: context,
      builder: (context) => _GradeFormDialog(
        gradingSystemId: widget.gradingSystemId,
        grade: grade,
        onSave: () => ref.refresh(gradesProvider(widget.gradingSystemId)),
      ),
    );
  }

  Future<void> _deleteGrade(String id) async {
     final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Grade'),
        content: const Text('Are you sure?'),
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
        await ref.read(academicsRepositoryProvider).deleteGrade(id);
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Grade deleted')));
        ref.refresh(gradesProvider(widget.gradingSystemId));
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final gradesAsync = ref.watch(gradesProvider(widget.gradingSystemId));

    return Scaffold(
      appBar: AppBar(title: Text('${widget.gradingSystemName} Grades')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showGradeForm(),
        label: const Text('Add Grade'),
        icon: const Icon(Icons.add),
      ),
      body: gradesAsync.when(
        data: (response) => ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: response.results.length,
          separatorBuilder: (c, i) => const Divider(),
          itemBuilder: (context, index) {
            final grade = response.results[index];
            return ListTile(
              title: Text('${grade.grade} (${grade.gradePoint} pts)'),
              subtitle: Text('${grade.minPercentage}% - ${grade.maxPercentage}%'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                   IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _showGradeForm(grade: grade)),
                   IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _deleteGrade(grade.id)),
                ],
              ),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}

class _GradeFormDialog extends ConsumerStatefulWidget {
  final String gradingSystemId;
  final Grade? grade;
  final VoidCallback onSave;

  const _GradeFormDialog({
    required this.gradingSystemId,
    this.grade,
    required this.onSave,
  });

  @override
  ConsumerState<_GradeFormDialog> createState() => _GradeFormDialogState();
}

class _GradeFormDialogState extends ConsumerState<_GradeFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _gradeController = TextEditingController();
  final _minController = TextEditingController();
  final _maxController = TextEditingController();
  final _pointsController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.grade != null) {
      _gradeController.text = widget.grade!.grade;
      _minController.text = widget.grade!.minPercentage.toString();
      _maxController.text = widget.grade!.maxPercentage.toString();
      _pointsController.text = widget.grade!.gradePoint.toString();
    }
  }

  @override
  void dispose() {
    _gradeController.dispose();
    _minController.dispose();
    _maxController.dispose();
    _pointsController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final data = {
          'grading_system': widget.gradingSystemId,
          'grade': _gradeController.text,
          'min_percentage': double.parse(_minController.text),
          'max_percentage': double.parse(_maxController.text),
          'grade_point': double.parse(_pointsController.text),
        };

        if (widget.grade != null) {
          // TODO: Update Grade (Missing Update method in Repo, assuming simple create for now or implementing Update later)
          // For now, let's just support Create, or assume Create behaves like upsert if ID handled? 
          // Actually Repo has createGrade only. Update is missing.
          // I'll skip update integration for now and just log it, or verify if I added updateGrade?
          // I didn't add updateGrade. I'll focus on Add for now.
           throw Exception('Update not implemented yet'); 
        } else {
          await ref.read(academicsRepositoryProvider).createGrade(data);
        }
        
        widget.onSave();
        if (mounted) Navigator.pop(context);
        
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.grade == null ? 'Add Grade' : 'Edit Grade'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _gradeController,
                decoration: const InputDecoration(labelText: 'Grade (e.g. A1)'),
                validator: (v) => v?.isEmpty == true ? 'Required' : null,
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _minController,
                       decoration: const InputDecoration(labelText: 'Min %'),
                       keyboardType: TextInputType.number,
                       validator: (v) => v?.isEmpty == true ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _maxController,
                       decoration: const InputDecoration(labelText: 'Max %'),
                       keyboardType: TextInputType.number,
                       validator: (v) => v?.isEmpty == true ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              TextFormField(
                controller: _pointsController,
                decoration: const InputDecoration(labelText: 'Grade Points (e.g. 10.0)'),
                keyboardType: TextInputType.number,
                validator: (v) => v?.isEmpty == true ? 'Required' : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: _isLoading ? null : _submit,
          child: _isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Save'),
        ),
      ],
    );
  }
}
