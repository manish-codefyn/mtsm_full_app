import 'package:flutter/material.dart';
import '../../domain/student_identification.dart';

class IdentificationForm extends StatefulWidget {
  final Function(StudentIdentification) onSaved;

  const IdentificationForm({Key? key, required this.onSaved}) : super(key: key);

  @override
  State<IdentificationForm> createState() => _IdentificationFormState();
}

class _IdentificationFormState extends State<IdentificationForm> {
  final _aadhaarController = TextEditingController();
  final _panController = TextEditingController();
  final _bankAccController = TextEditingController();
  final _ifscController = TextEditingController();

  @override
  void dispose() {
    _aadhaarController.dispose();
    _panController.dispose();
    _bankAccController.dispose();
    _ifscController.dispose();
    super.dispose();
  }

  void _save() {
    final id = StudentIdentification(
      aadhaarNumber: _aadhaarController.text,
      panNumber: _panController.text,
      bankAccountNumber: _bankAccController.text,
      ifscCode: _ifscController.text,
    );
    widget.onSaved(id);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Identification Documents', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _aadhaarController,
              decoration: const InputDecoration(labelText: 'Aadhaar Number', border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
              maxLength: 12,
              onChanged: (_) => _save(),
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _panController,
              decoration: const InputDecoration(labelText: 'PAN Number', border: OutlineInputBorder()),
              maxLength: 10,
              onChanged: (_) => _save(),
            ),
            
            const Divider(),
            Text('Bank Details', style: Theme.of(context).textTheme.titleSmall),
             const SizedBox(height: 8),
             
             TextFormField(
              controller: _bankAccController,
              decoration: const InputDecoration(labelText: 'Bank Account Number', border: OutlineInputBorder()),
              onChanged: (_) => _save(),
            ),
             const SizedBox(height: 16),
             
             TextFormField(
              controller: _ifscController,
              decoration: const InputDecoration(labelText: 'IFSC Code', border: OutlineInputBorder()),
              onChanged: (_) => _save(),
            ),
          ],
        ),
      ),
    );
  }
}
