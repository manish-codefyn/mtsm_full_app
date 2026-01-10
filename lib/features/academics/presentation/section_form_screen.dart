import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/academics_repository.dart';
import '../domain/models.dart';

class SectionFormScreen extends ConsumerStatefulWidget {
  final String? id;

  const SectionFormScreen({super.key, this.id});

  @override
  ConsumerState<SectionFormScreen> createState() => _SectionFormScreenState();
}

class _SectionFormScreenState extends ConsumerState<SectionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Controllers
  final _nameController = TextEditingController();
  final _roomNumberController = TextEditingController();

  // State
  String? _selectedClassId;
  String? _sectionInchargeId;
  
  List<SchoolClass> _classes = [];
  List<Map<String, dynamic>> _teachers = [];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    try {
      final repository = ref.read(academicsRepositoryProvider);
      
      // Load classes and teachers concurrently
      final results = await Future.wait([
        repository.getAllClasses(),
        repository.getTeachers(),
      ]);
      
      _classes = results[0] as List<SchoolClass>;
      _teachers = results[1] as List<Map<String, dynamic>>;

      // If editing, load section data
      if (widget.id != null) {
        final section = await repository.getSection(widget.id!);
        _nameController.text = section.name;
        _roomNumberController.text = section.roomNumber ?? '';
        
        // Handle dropdowns
        if (section.classNameDetail != null) {
             // Find matching class ID even if it's name (backend returns detail obj)
             // We need to match ID.
             _selectedClassId = section.classNameDetail!.id;
        }
        
        if (section.sectionInchargeDetail != null) {
          _sectionInchargeId = section.sectionInchargeDetail!['id'];
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _roomNumberController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final data = {
      'name': _nameController.text.trim(),
      'class_name': _selectedClassId, // Creates dependency
      if (_sectionInchargeId != null) 'section_incharge': _sectionInchargeId,
      if (_roomNumberController.text.isNotEmpty) 'room_number': _roomNumberController.text.trim(),
    };

    try {
      final repository = ref.read(academicsRepositoryProvider);
      if (widget.id != null) {
        await repository.updateSection(widget.id!, data);
         if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Section updated successfully')));
      } else {
        await repository.createSection(data);
         if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Section created successfully')));
      }
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving section: $e'), backgroundColor: Colors.red),
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
        title: Text(widget.id != null ? 'Edit Section' : 'Add Section'),
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
                    // Class Dropdown
                    DropdownButtonFormField<String>(
                      value: _selectedClassId,
                      decoration: const InputDecoration(
                        labelText: 'Select Class',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.class_),
                      ),
                      items: _classes.map((cls) {
                        return DropdownMenuItem<String>(
                          value: cls.id,
                          child: Text(cls.name),
                        );
                      }).toList(),
                      onChanged: (val) => setState(() => _selectedClassId = val),
                      validator: (val) => val == null ? 'Please select a class' : null,
                    ),
                    const SizedBox(height: 24),

                    // Name
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Section Name',
                        hintText: 'e.g. A, B, Rose',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.label),
                      ),
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Please enter section name' : null,
                    ),
                    const SizedBox(height: 24),

                    // Section Incharge
                    DropdownButtonFormField<String>(
                      value: _sectionInchargeId,
                      decoration: const InputDecoration(
                        labelText: 'Section Incharge (Optional)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                      items: _teachers.map((teacher) {
                        return DropdownMenuItem<String>(
                          value: teacher['id'].toString(),
                          child: Text(teacher['full_name'] ?? 'Unknown'),
                        );
                      }).toList(),
                      onChanged: (val) => setState(() => _sectionInchargeId = val),
                    ),
                    const SizedBox(height: 24),

                     // Room Number
                    TextFormField(
                      controller: _roomNumberController,
                      decoration: const InputDecoration(
                        labelText: 'Room Number (Optional)',
                        hintText: 'e.g. 101',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.meeting_room),
                      ),
                    ),
                    const SizedBox(height: 32),

                    ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      child: Text(widget.id != null ? 'Update Section' : 'Create Section'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
