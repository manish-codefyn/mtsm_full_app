import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/academics_repository.dart';
import '../domain/models.dart';

class SubjectFormScreen extends ConsumerStatefulWidget {
  final String? id; // If null, create mode

  const SubjectFormScreen({super.key, this.id});

  @override
  ConsumerState<SubjectFormScreen> createState() => _SubjectFormScreenState();
}

class _SubjectFormScreenState extends ConsumerState<SubjectFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  String _type = 'THEORY'; // Default
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    if (widget.id == null) return;

    setState(() => _isLoading = true);
    try {
      // We don't have getSubject(id) yet in repository, need to add it or use list
      // For now, I'll assume list is cached or I need to add getSubject
      // Checking local repo: I only see getSubjectsPaginated. 
      // I should add getSubject(id) to repo.
      // But for speed, I will implement getSubject in repo now.
      final subject = await ref.read(academicsRepositoryProvider).getSubject(widget.id!);
      _nameController.text = subject.name;
      _codeController.text = subject.code ?? '';
      _type = subject.type ?? 'THEORY';
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
        'name': _nameController.text,
        'code': _codeController.text,
        'type': _type,
      };

      if (widget.id != null) {
        await ref.read(academicsRepositoryProvider).updateSubject(widget.id!, data);
      } else {
        await ref.read(academicsRepositoryProvider).createSubject(data);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.id != null ? 'Subject updated' : 'Subject created'),
            backgroundColor: Colors.green,
          ),
        );
        // Invalidate specific providers if needed
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
    if (_isLoading && widget.id != null && _nameController.text.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.id != null ? 'Edit Subject' : 'Add Subject',
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
               TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Subject Name (e.g. Mathematics)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.book),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _codeController,
                decoration: const InputDecoration(
                  labelText: 'Subject Code (e.g. MATH101)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.code),
                ),
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: _type,
                decoration: const InputDecoration(
                  labelText: 'Subject Type',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
                items: const [
                  DropdownMenuItem(value: 'THEORY', child: Text('Theory')),
                  DropdownMenuItem(value: 'PRACTICAL', child: Text('Practical')),
                  DropdownMenuItem(value: 'CORE', child: Text('Core')),
                  DropdownMenuItem(value: 'ELECTIVE', child: Text('Elective')),
                ],
                onChanged: (val) => setState(() => _type = val!),
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
                        widget.id != null ? 'Update Subject' : 'Create Subject',
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
