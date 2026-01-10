import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/academics_repository.dart';
import '../domain/models.dart';

class ClassSubjectFormScreen extends ConsumerStatefulWidget {
  final String? id; // If null, create mode

  const ClassSubjectFormScreen({super.key, this.id});

  @override
  ConsumerState<ClassSubjectFormScreen> createState() => _ClassSubjectFormScreenState();
}

class _ClassSubjectFormScreenState extends ConsumerState<ClassSubjectFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  String? _selectedClassId;
  String? _selectedSubjectId;
  String? _selectedTeacherId;
  
  bool _isLoading = false;
  List<SchoolClass> _classes = [];
  List<Subject> _subjects = [];
  List<Map<String, dynamic>> _teachers = [];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    try {
      // Load dependencies
      final results = await Future.wait([
        ref.read(academicsRepositoryProvider).getAllClasses(),
        ref.read(academicsRepositoryProvider).getAllSubjects(),
        ref.read(academicsRepositoryProvider).getTeachers(),
      ]);
      
      _classes = results[0] as List<SchoolClass>;
      _subjects = results[1] as List<Subject>;
      _teachers = results[2] as List<Map<String, dynamic>>;
      
      // If edit mode, load data
      if (widget.id != null) {
        final classSubject = await ref.read(academicsRepositoryProvider).getClassSubject(widget.id!);
        _selectedClassId = classSubject.classNameDetail?.id;
        _selectedSubjectId = classSubject.subjectDetail?.id;
        // Teacher detail might be a map, need ID. 
        // Assuming the map has an 'id' or we need to extract it. 
        // Based on typical serializers, it might be nested. 
        // But for update, we usually send IDs. 
        // Let's assume teacherDetail has 'id'.
        if (classSubject.teacherDetail != null) {
          _selectedTeacherId = classSubject.teacherDetail!['id']?.toString();
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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final data = {
        'class_name': _selectedClassId,
        'subject': _selectedSubjectId,
        'teacher': _selectedTeacherId, // Optional
      };

      if (widget.id != null) {
        await ref.read(academicsRepositoryProvider).updateClassSubject(widget.id!, data);
      } else {
        await ref.read(academicsRepositoryProvider).createClassSubject(data);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.id != null ? 'Class Subject updated' : 'Class Subject created'),
            backgroundColor: Colors.green,
          ),
        );
        ref.invalidate(classSubjectsPaginationProvider); 
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _classes.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.id != null ? 'Edit Class Subject' : 'Add Class Subject',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<String>(
                value: _selectedClassId,
                decoration: const InputDecoration(
                  labelText: 'Class',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.class_outlined),
                ),
                items: _classes.map((cls) {
                  return DropdownMenuItem<String>(
                    value: cls.id,
                    child: Text(cls.name),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _selectedClassId = val),
                 validator: (value) => value == null ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              
              DropdownButtonFormField<String>(
                value: _selectedSubjectId,
                decoration: const InputDecoration(
                  labelText: 'Subject',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.book_outlined),
                ),
                items: _subjects.map((sub) {
                  return DropdownMenuItem<String>(
                    value: sub.id,
                    child: Text(sub.name),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _selectedSubjectId = val),
                 validator: (value) => value == null ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              
              DropdownButtonFormField<String>(
                value: _selectedTeacherId,
                decoration: const InputDecoration(
                  labelText: 'Teacher (Optional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person_outline),
                ),
                items: _teachers.map((teacher) {
                  final String name = '${teacher['first_name'] ?? ''} ${teacher['last_name'] ?? ''}'.trim();
                  return DropdownMenuItem<String>(
                    value: teacher['id']?.toString(),
                    child: Text(name.isNotEmpty ? name : 'Unknown (${teacher['username']})'),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _selectedTeacherId = val),
              ),
              
              const SizedBox(height: 32),
              
              ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: _isLoading 
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text(
                        widget.id != null ? 'Update Class Subject' : 'Create Class Subject',
                        style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
