import 'package:flutter/material.dart';
import '../../domain/student_medical_info.dart';

class MedicalInfoForm extends StatefulWidget {
  final Function(StudentMedicalInfo) onSaved;

  const MedicalInfoForm({Key? key, required this.onSaved}) : super(key: key);

  @override
  State<MedicalInfoForm> createState() => _MedicalInfoFormState();
}

class _MedicalInfoFormState extends State<MedicalInfoForm> {
  final _formKey = GlobalKey<FormState>();
  
  String? _bloodGroup;
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _allergiesController = TextEditingController();
  final _conditionsController = TextEditingController();
  final _medicationsController = TextEditingController();
  
  // Emergency Contact
  final _emNameController = TextEditingController();
  final _emRelController = TextEditingController();
  final _emPhoneController = TextEditingController();

  final List<String> _bloodGroups = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    _allergiesController.dispose();
    _conditionsController.dispose();
    _medicationsController.dispose();
    _emNameController.dispose();
    _emRelController.dispose();
    _emPhoneController.dispose();
    super.dispose();
  }

  void _save() {
    final info = StudentMedicalInfo(
      bloodGroup: _bloodGroup,
      heightCm: double.tryParse(_heightController.text),
      weightKg: double.tryParse(_weightController.text),
      knownAllergies: _allergiesController.text,
      chronicConditions: _conditionsController.text,
      currentMedications: _medicationsController.text,
      emergencyContactName: _emNameController.text,
      emergencyContactRelation: _emRelController.text,
      emergencyContactPhone: _emPhoneController.text,
      hasMedicalInsurance: false,
      hasDisability: false,
    );
    widget.onSaved(info);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Medical Information', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 16),
              
              DropdownButtonFormField<String>(
                value: _bloodGroup,
                decoration: const InputDecoration(labelText: 'Blood Group', border: OutlineInputBorder()),
                items: _bloodGroups.map((bg) => DropdownMenuItem(value: bg, child: Text(bg))).toList(),
                onChanged: (v) {
                  setState(() => _bloodGroup = v);
                  _save();
                },
              ),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _heightController,
                      decoration: const InputDecoration(labelText: 'Height (cm)', border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                      onChanged: (_) => _save(),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _weightController,
                      decoration: const InputDecoration(labelText: 'Weight (kg)', border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                      onChanged: (_) => _save(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _allergiesController,
                decoration: const InputDecoration(labelText: 'Known Allergies', border: OutlineInputBorder()),
                onChanged: (_) => _save(),
              ),
              const SizedBox(height: 16),
              
              const Divider(),
              Text('Emergency Contact (Medical)', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              
              TextFormField(
                controller: _emNameController,
                decoration: const InputDecoration(labelText: 'Contact Name', border: OutlineInputBorder()),
                onChanged: (_) => _save(),
              ),
              const SizedBox(height: 8),
               TextFormField(
                controller: _emPhoneController,
                decoration: const InputDecoration(labelText: 'Contact Phone', border: OutlineInputBorder()),
                keyboardType: TextInputType.phone,
                onChanged: (_) => _save(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
