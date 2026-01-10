import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/academics_repository.dart';
import '../domain/models.dart';

class ClassFormScreen extends ConsumerStatefulWidget {
  final String? id;

  const ClassFormScreen({super.key, this.id});

  @override
  ConsumerState<ClassFormScreen> createState() => _ClassFormScreenState();
}

class _ClassFormScreenState extends ConsumerState<ClassFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  
  // Controllers
  final _nameController = TextEditingController();
  final _availableSeatsController = TextEditingController();
  
  // State
  int? _numericLevel;
  String? _classTeacherId;
  List<Map<String, dynamic>> _teachers = [];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    try {
      // Load teachers
      _teachers = await ref.read(academicsRepositoryProvider).getTeachers();

      // If editing, load class data
      if (widget.id != null) {
        final schoolClass = await ref.read(academicsRepositoryProvider).getClass(widget.id!);
        _nameController.text = schoolClass.name;
        _numericLevel = schoolClass.numericLevel;
        _availableSeatsController.text = schoolClass.availableSeats.toString();
        
        // Handle teacher mapping if exists
        if (schoolClass.classTeacherDetail != null) {
          _classTeacherId = schoolClass.classTeacherDetail!['id'];
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e', style: const TextStyle(color: Colors.white)), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _availableSeatsController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final data = {
      'name': _nameController.text.trim(),
      if (_numericLevel != null) 'numeric_level': _numericLevel,
      if (_classTeacherId != null) 'class_teacher': _classTeacherId,
      if (_availableSeatsController.text.isNotEmpty) 
        'available_seats': int.tryParse(_availableSeatsController.text) ?? 60,
    };

    try {
      final repository = ref.read(academicsRepositoryProvider);
      if (widget.id != null) {
        await repository.updateClass(widget.id!, data);
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Class updated successfully')));
      } else {
        await repository.createClass(data);
         if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Class created successfully')));
      }
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving class: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.id != null ? 'Edit Class' : 'Add Class'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Name
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Class Name',
                        hintText: 'e.g. Class 10',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.class_),
                      ),
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Please enter class name' : null,
                    ),
                    const SizedBox(height: 24),

                    // Numeric Level (1-12)
                    DropdownButtonFormField<int>(
                      value: _numericLevel,
                      decoration: const InputDecoration(
                        labelText: 'Numeric Level (Optional)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.numbers),
                        helperText: 'Used for automatic sorting and stream assignment',
                      ),
                      items: List.generate(12, (index) => index + 1)
                          .map((level) => DropdownMenuItem(
                                value: level,
                                child: Text('Level $level'),
                              ))
                          .toList(),
                      onChanged: (val) => setState(() => _numericLevel = val),
                    ),
                    const SizedBox(height: 24),

                    // Class Teacher
                    DropdownButtonFormField<String>(
                      value: _classTeacherId,
                      decoration: const InputDecoration(
                        labelText: 'Class Teacher (Optional)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                      items: _teachers.map((teacher) {
                        return DropdownMenuItem<String>(
                          value: teacher['id'].toString(),
                          child: Text(teacher['full_name'] ?? 'Unknown'),
                        );
                      }).toList(),
                      onChanged: (val) => setState(() => _classTeacherId = val),
                    ),
                     const SizedBox(height: 24),

                    // Available Seats
                    TextFormField(
                      controller: _availableSeatsController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Available Seats',
                         hintText: 'Default: 60',
                        border: OutlineInputBorder(),
                         prefixIcon: Icon(Icons.event_seat),
                      ),
                    ),
                    const SizedBox(height: 32),

                    ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      child: Text(widget.id != null ? 'Update Class' : 'Create Class'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
