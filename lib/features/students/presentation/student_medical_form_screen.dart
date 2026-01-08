import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/student_repository.dart';
import '../domain/student.dart';

class StudentMedicalFormScreen extends ConsumerStatefulWidget {
  final String studentId;
  const StudentMedicalFormScreen({super.key, required this.studentId});

  @override
  ConsumerState<StudentMedicalFormScreen> createState() => _StudentMedicalFormScreenState();
}

class _StudentMedicalFormScreenState extends ConsumerState<StudentMedicalFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = true;
  
  // Fields
  String? _bloodGroup;
  final _heightCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _allergiesCtrl = TextEditingController();
  final _medicationsCtrl = TextEditingController();
  
  // Insurance
  bool _hasInsurance = false;
  final _insuranceProviderCtrl = TextEditingController();
  final _policyNumberCtrl = TextEditingController();
  
  // Emergency Contact
  final _emergencyNameCtrl = TextEditingController();
  final _emergencyPhoneCtrl = TextEditingController();
  final _emergencyRelationCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }
  
  Future<void> _loadData() async {
    try {
      final data = await ref.read(studentRepositoryProvider).getMedicalInfo(widget.studentId);
      setState(() {
        _bloodGroup = data['blood_group'];
        _heightCtrl.text = (data['height_cm'] ?? '').toString();
        _weightCtrl.text = (data['weight_kg'] ?? '').toString();
        _allergiesCtrl.text = data['known_allergies'] ?? '';
        _medicationsCtrl.text = data['current_medications'] ?? '';
        
        _hasInsurance = data['has_medical_insurance'] ?? false;
        _insuranceProviderCtrl.text = data['insurance_provider'] ?? '';
        _policyNumberCtrl.text = data['insurance_policy_number'] ?? '';
        
        _emergencyNameCtrl.text = data['emergency_contact_name'] ?? '';
        _emergencyPhoneCtrl.text = data['emergency_contact_phone'] ?? '';
        _emergencyRelationCtrl.text = data['emergency_contact_relation'] ?? '';
        _isLoading = false;
      });
    } catch (e) {
      // If 404/not found, it means new. Just stop loading.
       setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Medical Information')),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Physical Attributes'),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _bloodGroup,
                          decoration: const InputDecoration(labelText: 'Blood Group', border: OutlineInputBorder()),
                          items: ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-']
                              .map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                          onChanged: (v) => setState(() => _bloodGroup = v),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _heightCtrl,
                           keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Height (cm)', border: OutlineInputBorder()),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _weightCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Weight (kg)', border: OutlineInputBorder()),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildSectionTitle('Medical History'),
                  TextFormField(
                    controller: _allergiesCtrl,
                    maxLines: 2,
                    decoration: const InputDecoration(labelText: 'Known Allergies', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _medicationsCtrl,
                    maxLines: 2,
                    decoration: const InputDecoration(labelText: 'Current Medications', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 20),
                  
                  _buildSectionTitle('Emergency Contact'),
                  TextFormField(
                    controller: _emergencyNameCtrl,
                    decoration: const InputDecoration(labelText: 'Contact Name', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 16),
                   Row(
                    children: [
                       Expanded(
                        child: TextFormField(
                          controller: _emergencyRelationCtrl,
                          decoration: const InputDecoration(labelText: 'Relation', border: OutlineInputBorder()),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _emergencyPhoneCtrl,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(labelText: 'Phone', border: OutlineInputBorder()),
                        ),
                      ),
                    ],
                   ),
                  const SizedBox(height: 20),
                  
                  Row(
                    children: [
                      Checkbox(
                        value: _hasInsurance, 
                        onChanged: (v) => setState(() => _hasInsurance = v!),
                      ),
                      const Text('Has Medical Insurance'),
                    ],
                  ),
                  if (_hasInsurance) ...[
                     const SizedBox(height: 8),
                     TextFormField(
                        controller: _insuranceProviderCtrl,
                        decoration: const InputDecoration(labelText: 'Provider', border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _policyNumberCtrl,
                        decoration: const InputDecoration(labelText: 'Policy Number', border: OutlineInputBorder()),
                      ),
                  ],
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('SAVE INFORMATION'),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }
  
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    final data = {
      'blood_group': _bloodGroup,
      'height_cm': double.tryParse(_heightCtrl.text),
      'weight_kg': double.tryParse(_weightCtrl.text),
      'known_allergies': _allergiesCtrl.text,
      'current_medications': _medicationsCtrl.text,
      'emergency_contact_name': _emergencyNameCtrl.text,
      'emergency_contact_relation': _emergencyRelationCtrl.text,
      'emergency_contact_phone': _emergencyPhoneCtrl.text,
      'has_medical_insurance': _hasInsurance,
      if (_hasInsurance) 'insurance_provider': _insuranceProviderCtrl.text,
      if (_hasInsurance) 'insurance_policy_number': _policyNumberCtrl.text,
      // Need student ID? The backend retrieves by URL param, but validatior might assume payload issues. 
      // The View I created uses get_object with student_id from kwargs.
      // So payload is just fields.
    };

    try {
      setState(() => _isLoading = true);
      await ref.read(studentRepositoryProvider).updateMedicalInfo(widget.studentId, data);
      if (mounted) {
        Navigator.pop(context, true); // Return true to refresh
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }
}
