import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/academics_repository.dart';
import '../domain/models.dart';

class StreamFormScreen extends ConsumerStatefulWidget {
  final String? id; // If null, create mode

  const StreamFormScreen({super.key, this.id});

  @override
  ConsumerState<StreamFormScreen> createState() => _StreamFormScreenState();
}

class _StreamFormScreenState extends ConsumerState<StreamFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  
  String? _selectedClassId;
  
  bool _isLoading = false;
  List<SchoolClass> _classes = [];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    try {
      // Load Classes
      _classes = await ref.read(academicsRepositoryProvider).getAllClasses();
      
      // If edit mode, load stream data
      if (widget.id != null) {
        final stream = await ref.read(academicsRepositoryProvider).getStream(widget.id!);
        _nameController.text = stream.name;
        _codeController.text = stream.code;
        _descriptionController.text = stream.description ?? '';
        _selectedClassId = stream.availableFromClassId;
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
        'name': _nameController.text,
        'code': _codeController.text,
        'description': _descriptionController.text,
        'available_from_class': _selectedClassId,
      };

      if (widget.id != null) {
        await ref.read(academicsRepositoryProvider).updateStream(widget.id!, data);
      } else {
        await ref.read(academicsRepositoryProvider).createStream(data);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.id != null ? 'Stream updated' : 'Stream created'),
            backgroundColor: Colors.green,
          ),
        );
        ref.invalidate(streamsPaginationProvider); 
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
          widget.id != null ? 'Edit Stream' : 'Add Stream',
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
                  labelText: 'Stream Name (e.g. Science)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.label),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _codeController,
                decoration: const InputDecoration(
                  labelText: 'Stream Code (e.g. SCI-20)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.code),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: _selectedClassId,
                decoration: const InputDecoration(
                  labelText: 'Available From Class',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.class_outlined),
                  helperText: 'Select the class where this stream starts (e.g. Class 11)',
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
              
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3,
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
                        widget.id != null ? 'Update Stream' : 'Create Stream',
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
