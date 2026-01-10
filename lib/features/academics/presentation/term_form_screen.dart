import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../data/academics_repository.dart';
import '../domain/models.dart';

class TermFormScreen extends ConsumerStatefulWidget {
  final String? id; // If null, create mode

  const TermFormScreen({super.key, this.id});

  @override
  ConsumerState<TermFormScreen> createState() => _TermFormScreenState();
}

class _TermFormScreenState extends ConsumerState<TermFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  final TextEditingController _orderController = TextEditingController();
  
  String? _selectedAcademicYearId;
  String? _selectedTermType;
  bool _isActive = false;
  
  bool _isLoading = false;
  List<AcademicYear> _academicYears = [];

  final List<Map<String, String>> _termTypes = [
    {'value': 'FIRST_TERM', 'label': 'First Term'},
    {'value': 'SECOND_TERM', 'label': 'Second Term'},
    {'value': 'THIRD_TERM', 'label': 'Third Term'},
    {'value': 'FOURTH_TERM', 'label': 'Fourth Term'},
    {'value': 'ANNUAL', 'label': 'Annual'},
  ];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _orderController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    try {
      // Load Academic Years
      _academicYears = await ref.read(academicsRepositoryProvider).getAllAcademicYears();
      
      // If edit mode, load term data
      if (widget.id != null) {
        final term = await ref.read(academicsRepositoryProvider).getTerm(widget.id!);
        _nameController.text = term.name;
        _startDateController.text = term.startDate;
        _endDateController.text = term.endDate;
        _selectedAcademicYearId = term.academicYearId;
        _selectedTermType = term.termType;
        _isActive = term.isActive;
        // _orderController.text = term.order.toString(); // If we add order to model
      } else {
        // Default to active academic year if creating
        try {
           final currentYear = await ref.read(academicsRepositoryProvider).getCurrentAcademicYear();
           _selectedAcademicYearId = currentYear.id;
        } catch (_) {}
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

  Future<void> _selectDate(TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
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
        'academic_year': _selectedAcademicYearId,
        'name': _nameController.text,
        'term_type': _selectedTermType,
        'start_date': _startDateController.text,
        'end_date': _endDateController.text,
        'is_current': _isActive,
        'order': int.tryParse(_orderController.text) ?? 1, // Default order 1
      };

      if (widget.id != null) {
        await ref.read(academicsRepositoryProvider).updateTerm(widget.id!, data);
      } else {
        await ref.read(academicsRepositoryProvider).createTerm(data);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.id != null ? 'Term updated' : 'Term created'),
            backgroundColor: Colors.green,
          ),
        );
        ref.invalidate(termsPaginationProvider); 
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
          widget.id != null ? 'Edit Term' : 'Add Term',
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
                value: _selectedAcademicYearId,
                decoration: const InputDecoration(
                  labelText: 'Academic Year',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                items: _academicYears.map((year) {
                  return DropdownMenuItem<String>(
                    value: year.id,
                    child: Text(year.name),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _selectedAcademicYearId = val),
                 validator: (value) => value == null ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Term Name (e.g. First Term)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.label),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              
               DropdownButtonFormField<String>(
                value: _selectedTermType,
                decoration: const InputDecoration(
                  labelText: 'Term Type',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
                items: _termTypes.map((type) {
                  return DropdownMenuItem<String>(
                    value: type['value'],
                    child: Text(type['label']!),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() => _selectedTermType = val);
                  // Auto-fill name if empty
                  if (_nameController.text.isEmpty && val != null) {
                     final label = _termTypes.firstWhere((t) => t['value'] == val)['label'];
                     _nameController.text = label!;
                  }
                },
                 validator: (value) => value == null ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _startDateController,
                      decoration: const InputDecoration(
                        labelText: 'Start Date',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.date_range),
                      ),
                      readOnly: true,
                      onTap: () => _selectDate(_startDateController),
                      validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _endDateController,
                      decoration: const InputDecoration(
                        labelText: 'End Date',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.date_range),
                      ),
                      readOnly: true,
                      onTap: () => _selectDate(_endDateController),
                      validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Order Field (Optional but good to have)
               TextFormField(
                controller: _orderController,
                decoration: const InputDecoration(
                  labelText: 'Term Order (1, 2, 3...)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.sort),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                   if (value != null && value.isNotEmpty && int.tryParse(value) == null) {
                     return 'Must be a number';
                   }
                   return null;
                },
              ),
               const SizedBox(height: 16),
              
              SwitchListTile(
                title: const Text('Is Current/Active?'),
                subtitle: const Text('Set this as the currently active term'),
                value: _isActive,
                onChanged: (val) => setState(() => _isActive = val),
                 secondary: const Icon(Icons.check_circle_outline),
                contentPadding: EdgeInsets.zero,
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
                        widget.id != null ? 'Update Term' : 'Create Term',
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
