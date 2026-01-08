import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/student_repository.dart';

class StudentIdentificationFormScreen extends ConsumerStatefulWidget {
  final String studentId;
  const StudentIdentificationFormScreen({super.key, required this.studentId});

  @override
  ConsumerState<StudentIdentificationFormScreen> createState() => _StudentIdentificationFormScreenState();
}

class _StudentIdentificationFormScreenState extends ConsumerState<StudentIdentificationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = true;

  final _aadhaarCtrl = TextEditingController();
  final _panCtrl = TextEditingController();
  final _passportCtrl = TextEditingController();
  
  final _bankAccountCtrl = TextEditingController();
  final _bankNameCtrl = TextEditingController();
  final _ifscCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final data = await ref.read(studentRepositoryProvider).getIdentification(widget.studentId);
      setState(() {
        _aadhaarCtrl.text = data['aadhaar_number'] ?? '';
        _panCtrl.text = data['pan_number'] ?? '';
        _passportCtrl.text = data['passport_number'] ?? '';
        _bankAccountCtrl.text = data['bank_account_number'] ?? '';
        _bankNameCtrl.text = data['bank_name'] ?? '';
        _ifscCtrl.text = data['ifsc_code'] ?? '';
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Identification & Bank Details')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Government ID'),
                    TextFormField(
                      controller: _aadhaarCtrl,
                      decoration: const InputDecoration(labelText: 'Aadhaar Number', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _panCtrl,
                      decoration: const InputDecoration(labelText: 'PAN Number', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passportCtrl,
                      decoration: const InputDecoration(labelText: 'Passport Number', border: OutlineInputBorder()),
                    ),
                    
                    const SizedBox(height: 24),
                    _buildSectionTitle('Bank Details'),
                     TextFormField(
                      controller: _bankNameCtrl,
                      decoration: const InputDecoration(labelText: 'Bank Name', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _bankAccountCtrl,
                      decoration: const InputDecoration(labelText: 'Account Number', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _ifscCtrl,
                      decoration: const InputDecoration(labelText: 'IFSC Code', border: OutlineInputBorder()),
                    ),

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
      'aadhaar_number': _aadhaarCtrl.text,
      'pan_number': _panCtrl.text,
      'passport_number': _passportCtrl.text,
      'bank_account_number': _bankAccountCtrl.text,
      'bank_name': _bankNameCtrl.text,
      'ifsc_code': _ifscCtrl.text,
    };

    try {
      setState(() => _isLoading = true);
      await ref.read(studentRepositoryProvider).updateIdentification(widget.studentId, data);
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }
}
