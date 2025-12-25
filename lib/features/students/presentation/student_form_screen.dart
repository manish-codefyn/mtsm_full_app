import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/student_repository.dart';
import '../domain/student.dart';

class StudentFormScreen extends ConsumerStatefulWidget {
  final Student? student; // If null, it's Add mode
  const StudentFormScreen({super.key, this.student});

  @override
  ConsumerState<StudentFormScreen> createState() => _StudentFormScreenState();
}

class _StudentFormScreenState extends ConsumerState<StudentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _admissionNoController;
  late TextEditingController _emailController;
  late TextEditingController _mobileController;
  
  String _gender = 'M';
  DateTime? _dob;
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: widget.student?.firstName ?? '');
    _lastNameController = TextEditingController(text: widget.student?.lastName ?? '');
    _admissionNoController = TextEditingController(text: widget.student?.admissionNumber ?? '');
    _emailController = TextEditingController(text: widget.student?.email ?? '');
    _mobileController = TextEditingController(text: widget.student?.mobilePrimary ?? '');
    
    if (widget.student != null) {
       // Only if editing (and if we had these fields in domain, which we might not yet)
       // For now defaults or partial data.
       // _gender = widget.student!.gender ?? 'M'; 
       // _dob = widget.student!.dob;
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _admissionNoController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    super.dispose();
  }

  Future<void> _saveStudent() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final repo = ref.read(studentRepositoryProvider);
      
      final studentData = {
        'first_name': _firstNameController.text,
        'last_name': _lastNameController.text,
        'admission_number': _admissionNoController.text,
        'personal_email': _emailController.text, // Changed key to match backend
        'mobile_primary': _mobileController.text,
        'gender': _gender,
        'date_of_birth': _dob?.toIso8601String().split('T')[0] ?? '2015-01-01',
        'academic_year': '2c95558f-f77f-4193-9f77-ea6cc5868390', // Hardcoded valid Academic Year 2025-2026 for now
        'admission_type': 'REGULAR',
        'status': 'ACTIVE',
      };

      if (widget.student != null && widget.student!.id != null) {
        // Update
        await repo.updateStudent(widget.student!.id!, studentData);
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Student updated successfully')));
      } else {
        // Create
        await repo.createStudent(studentData);
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Student created successfully')));
      }
      
      if (mounted) context.pop(); // Go back
      ref.invalidate(studentListProvider); // Refresh list
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.student != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit Student' : 'Add Student')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(labelText: 'First Name', border: OutlineInputBorder()),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(labelText: 'Last Name', border: OutlineInputBorder()),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                   Expanded(
                     child: TextFormField(
                        controller: _admissionNoController,
                        decoration: const InputDecoration(labelText: 'Admission Number', border: OutlineInputBorder()),
                        validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                      ),
                   ),
                   const SizedBox(width: 16),
                   Expanded(
                     child: DropdownButtonFormField<String>(
                       value: _gender,
                       decoration: const InputDecoration(labelText: 'Gender', border: OutlineInputBorder()),
                       items: const [
                         DropdownMenuItem(value: 'M', child: Text('Male')),
                         DropdownMenuItem(value: 'F', child: Text('Female')),
                         DropdownMenuItem(value: 'O', child: Text('Other')),
                       ],
                       onChanged: (val) => setState(() => _gender = val!),
                     ),
                   ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _dob ?? DateTime.now().subtract(const Duration(days: 365 * 5)),
                          firstDate: DateTime(1990),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) setState(() => _dob = picked);
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(labelText: 'Date of Birth', border: OutlineInputBorder()),
                        child: Text(_dob != null ? "${_dob!.day}-${_dob!.month}-${_dob!.year}" : 'Select Date'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _mobileController,
                      decoration: const InputDecoration(labelText: 'Mobile Number', border: OutlineInputBorder()),
                      validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                      keyboardType: TextInputType.phone,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Personal Email', border: OutlineInputBorder()),
                 // 'personal_email' is required and unique in backend
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveStudent,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.white) 
                  : Text(isEditing ? 'Update Student' : 'Create Student'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
