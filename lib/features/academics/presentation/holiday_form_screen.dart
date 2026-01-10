import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../data/academics_repository.dart';

class HolidayFormScreen extends ConsumerStatefulWidget {
  final String? id;

  const HolidayFormScreen({super.key, this.id});

  @override
  ConsumerState<HolidayFormScreen> createState() => _HolidayFormScreenState();
}

class _HolidayFormScreenState extends ConsumerState<HolidayFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  final _nameController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  String _holidayType = 'Festival'; // Default

  final List<String> _holidayTypes = [
    'National Holiday',
    'Festival',
    'Academic Break',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    if (widget.id == null) return;

    setState(() => _isLoading = true);
    try {
      final holiday = await ref.read(academicsRepositoryProvider).getHoliday(widget.id!);
      _nameController.text = holiday.name;
      _holidayType = _holidayTypes.contains(holiday.holidayType) ? holiday.holidayType : 'Other';
      _startDateController.text = holiday.startDate;
      _endDateController.text = holiday.endDate ?? '';
      _descriptionController.text = holiday.description ?? '';
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
    _startDateController.dispose();
    _endDateController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        controller.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final data = {
      'name': _nameController.text.trim(),
      'holiday_type': _holidayType,
      'start_date': _startDateController.text.trim(),
      if (_endDateController.text.isNotEmpty) 'end_date': _endDateController.text.trim(),
      if (_descriptionController.text.isNotEmpty) 'description': _descriptionController.text.trim(),
    };

    try {
      final repository = ref.read(academicsRepositoryProvider);
      if (widget.id != null) {
        await repository.updateHoliday(widget.id!, data);
         if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Holiday updated successfully')));
      } else {
        await repository.createHoliday(data);
         if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Holiday created successfully')));
      }
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving holiday: $e'), backgroundColor: Colors.red),
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
        title: Text(widget.id != null ? 'Edit Holiday' : 'Add Holiday'),
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
                        labelText: 'Holiday Name',
                        hintText: 'e.g. Diwali',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.celebration),
                      ),
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Please enter name' : null,
                    ),
                    const SizedBox(height: 24),

                    // Type
                    DropdownButtonFormField<String>(
                      value: _holidayType,
                      decoration: const InputDecoration(
                        labelText: 'Holiday Type',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.category),
                      ),
                      items: _holidayTypes.map((type) {
                        return DropdownMenuItem<String>(
                          value: type,
                          child: Text(type),
                        );
                      }).toList(),
                      onChanged: (val) => setState(() => _holidayType = val!),
                    ),
                    const SizedBox(height: 24),

                    // Start Date
                    TextFormField(
                      controller: _startDateController,
                      decoration: const InputDecoration(
                        labelText: 'Start Date',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      readOnly: true,
                      onTap: () => _selectDate(_startDateController),
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Please select start date' : null,
                    ),
                    const SizedBox(height: 24),

                    // End Date
                    TextFormField(
                      controller: _endDateController,
                      decoration: const InputDecoration(
                        labelText: 'End Date (Optional)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.calendar_today_outlined),
                        helperText: 'Leave empty for single day holiday',
                      ),
                      readOnly: true,
                      onTap: () => _selectDate(_endDateController),
                    ),
                    const SizedBox(height: 24),

                    // Description
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Description (Optional)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.description),
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
                      child: Text(widget.id != null ? 'Update Holiday' : 'Create Holiday'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
