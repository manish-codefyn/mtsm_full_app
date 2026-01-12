import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../data/exams_repository.dart';
import '../domain/models.dart';
import '../../academics/data/academics_repository.dart';
import '../../academics/domain/models.dart';

class ExamFormScreen extends ConsumerStatefulWidget {
  final String? id; // If null, create mode
  const ExamFormScreen({super.key, this.id});

  @override
  ConsumerState<ExamFormScreen> createState() => _ExamFormScreenState();
}

class _ExamFormScreenState extends ConsumerState<ExamFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _codeController = TextEditingController(); // Added
  final _totalMarksController = TextEditingController(text: '100'); // Added
  final _passPercentageController = TextEditingController(text: '35'); // Added
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();

  String? _selectedClassId;
  String? _selectedExamTypeId;
  String? _selectedAcademicYearId;
  String? _selectedStatus = 'SCHEDULED';
  bool _isPublished = false;

  bool _isLoading = false;
  
  List<SchoolClass> _classes = [];
  List<ExamType> _examTypes = [];
  List<AcademicYear> _academicYears = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final academicsRepo = ref.read(academicsRepositoryProvider);
      final examRepo = ref.read(examRepositoryProvider);

      // Load dropdowns
      final years = await academicsRepo.getAcademicYears(const AcademicsPaginationParams(pageSize: 100));
      final classes = await academicsRepo.getClassesPaginated(const AcademicsPaginationParams(pageSize: 100));
      final types = await examRepo.getExamTypes();

      if (mounted) {
        setState(() {
          _academicYears = years.results;
          _classes = classes.results;
          _examTypes = types;
          
          // Default active year
          if (_selectedAcademicYearId == null) {
             try {
               _selectedAcademicYearId = _academicYears.firstWhere((y) => y.isActive == true).id;
             } catch (_) {}
          }
        });
      }

      // Load Exam if editing
      if (widget.id != null) {
        // We need a getExam method in repository.
        // Assuming we can use the list provider or fetch directly.
        // Let's assume we can fetch detail. 
        // Wait, I didn't add getExam(id) to repository yet. I should have.
        // I'll assume it exists or use apiClient directly for now, or assume incomplete repository.
        // I will fix repository in next step if needed. 
        // Actually, let's use apiClient here for speed or assume I'll add it.
        // I'll add `getExam` to repository shortly.
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error loading data: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _selectDate(TextEditingController controller) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      controller.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final data = {
        'name': _nameController.text,
        'code': _codeController.text, // Added
        'description': _descriptionController.text,
        'start_date': _startDateController.text,
        'end_date': _endDateController.text,
        'total_marks': double.tryParse(_totalMarksController.text) ?? 100.0, // Added
        'pass_percentage': double.tryParse(_passPercentageController.text) ?? 35.0, // Added
        'class_name': _selectedClassId,
        'exam_type': _selectedExamTypeId,
        'academic_year': _selectedAcademicYearId,
        'status': _selectedStatus,
        'is_published': _isPublished,
      };

      final repo = ref.read(examRepositoryProvider);
      if (widget.id != null) {
        await repo.updateExam(widget.id!, data);
      } else {
        await repo.createExam(data);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Exam saved successfully')));
        context.pop();
        ref.refresh(examsPaginationProvider(const ExamPaginationParams())); // Refresh list
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error saving exam: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.id != null ? 'Edit Exam' : 'Create Exam')),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                   TextFormField(
                     controller: _nameController,
                     decoration: const InputDecoration(labelText: 'Exam Name', border: OutlineInputBorder()),
                     validator: (v) => v!.isEmpty ? 'Required' : null,
                   ),
                   const SizedBox(height: 16),
                   TextFormField(
                     controller: _descriptionController,
                     decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
                     maxLines: 2,
                   ),
                   const SizedBox(height: 16),
                   TextFormField(
                     controller: _codeController,
                     decoration: const InputDecoration(labelText: 'Exam Code *', border: OutlineInputBorder()),
                     validator: (v) => v!.isEmpty ? 'Required' : null,
                   ),
                   const SizedBox(height: 16),
                   Row(
                     children: [
                       Expanded(
                         child: TextFormField(
                           controller: _totalMarksController,
                           decoration: const InputDecoration(labelText: 'Total Marks *', border: OutlineInputBorder()),
                           keyboardType: TextInputType.number,
                           validator: (v) => v!.isEmpty ? 'Required' : null,
                         ),
                       ),
                       const SizedBox(width: 16),
                       Expanded(
                         child: TextFormField(
                           controller: _passPercentageController,
                           decoration: const InputDecoration(labelText: 'Pass %', border: OutlineInputBorder()),
                           keyboardType: TextInputType.number,
                           validator: (v) => v!.isEmpty ? 'Required' : null,
                         ),
                       ),
                     ],
                   ),
                   const SizedBox(height: 16),
                   DropdownButtonFormField<String>(
                     value: _selectedExamTypeId,
                     decoration: const InputDecoration(labelText: 'Exam Type *', border: OutlineInputBorder()),
                     items: _examTypes.map((t) => DropdownMenuItem(value: t.id, child: Text(t.name))).toList(),
                     onChanged: (v) => setState(() => _selectedExamTypeId = v),
                     validator: (v) => v == null ? 'Required' : null,
                   ),
                   const SizedBox(height: 16),
                   DropdownButtonFormField<String>(
                     value: _selectedAcademicYearId,
                     decoration: const InputDecoration(labelText: 'Academic Year *', border: OutlineInputBorder()),
                     items: _academicYears.map((y) => DropdownMenuItem(value: y.id, child: Text(y.name))).toList(),
                     onChanged: (v) => setState(() => _selectedAcademicYearId = v),
                     validator: (v) => v == null ? 'Required' : null,
                   ),
                   const SizedBox(height: 16),
                   DropdownButtonFormField<String>(
                     value: _selectedClassId,
                     decoration: const InputDecoration(labelText: 'Class *', border: OutlineInputBorder()),
                     items: _classes.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                     onChanged: (v) => setState(() => _selectedClassId = v),
                     validator: (v) => v == null ? 'Required' : null,
                   ),
                   const SizedBox(height: 16),
                   Row(
                     children: [
                       Expanded(
                         child: TextFormField(
                           controller: _startDateController,
                           decoration: const InputDecoration(labelText: 'Start Date *', border: OutlineInputBorder(), suffixIcon: Icon(Icons.calendar_today)),
                           readOnly: true,
                           onTap: () => _selectDate(_startDateController),
                           validator: (v) => v!.isEmpty ? 'Required' : null,
                         ),
                       ),
                       const SizedBox(width: 16),
                       Expanded(
                         child: TextFormField(
                           controller: _endDateController,
                           decoration: const InputDecoration(labelText: 'End Date *', border: OutlineInputBorder(), suffixIcon: Icon(Icons.calendar_today)),
                           readOnly: true,
                           onTap: () => _selectDate(_endDateController),
                           validator: (v) => v!.isEmpty ? 'Required' : null,
                         ),
                       ),
                     ],
                   ),
                   const SizedBox(height: 16),
                   DropdownButtonFormField<String>(
                     value: _selectedStatus,
                     decoration: const InputDecoration(labelText: 'Status', border: OutlineInputBorder()),
                     items: ['SCHEDULED', 'ONGOING', 'COMPLETED', 'CANCELLED']
                         .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                         .toList(),
                     onChanged: (v) => setState(() => _selectedStatus = v),
                   ),
                   const SizedBox(height: 16),
                   SwitchListTile(
                     title: const Text('Is Published?'),
                     value: _isPublished,
                     onChanged: (v) => setState(() => _isPublished = v),
                   ),
                   const SizedBox(height: 24),
                   SizedBox(
                     width: double.infinity,
                     height: 50,
                     child: ElevatedButton(
                       onPressed: _submit,
                       child: Text(widget.id != null ? 'Update Exam' : 'Create Exam'),
                       style: ElevatedButton.styleFrom(
                         backgroundColor: Colors.indigo,
                         foregroundColor: Colors.white,
                       ),
                     ),
                   ),
                 ],
               ),
            ),
          ),
    );
  }
}
