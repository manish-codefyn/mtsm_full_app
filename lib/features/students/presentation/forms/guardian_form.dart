import 'package:flutter/material.dart';
import '../../domain/guardian.dart';

class GuardianForm extends StatefulWidget {
  final Function(Guardian) onSaved;
  final VoidCallback onRemove;
  final int index;

  const GuardianForm({
    Key? key, 
    required this.onSaved,
    required this.onRemove,
    required this.index,
  }) : super(key: key);

  @override
  State<GuardianForm> createState() => _GuardianFormState();
}

class _GuardianFormState extends State<GuardianForm> {
  final _formKey = GlobalKey<FormState>();
  
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _occupationController = TextEditingController();
  final _aadhaarController = TextEditingController();
  final _panController = TextEditingController();
  
  String _relation = 'FATHER';
  bool _isPrimary = false;
  bool _isEmergency = false;

  final List<String> _relations = [
    'FATHER', 'MOTHER', 'GUARDIAN', 'GRANDFATHER', 
    'GRANDMOTHER', 'UNCLE', 'AUNT', 'BROTHER', 'SISTER', 'OTHER'
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _occupationController.dispose();
    _aadhaarController.dispose();
    _panController.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final guardian = Guardian(
        student: '', // Will be set by parent
        relation: _relation,
        fullName: _nameController.text,
        email: _emailController.text,
        phonePrimary: _phoneController.text,
        occupation: _occupationController.text,
        aadhaarNumber: _aadhaarController.text,
        panNumber: _panController.text,
        isPrimary: _isPrimary,
        isEmergencyContact: _isEmergency,
      );
      widget.onSaved(guardian);
    }
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Guardian #${widget.index + 1}', style: Theme.of(context).textTheme.titleMedium),
                  IconButton(onPressed: widget.onRemove, icon: const Icon(Icons.delete, color: Colors.red)),
                ],
              ),
              const SizedBox(height: 16),
              
              DropdownButtonFormField<String>(
                value: _relation,
                decoration: const InputDecoration(labelText: 'Relation', border: OutlineInputBorder()),
                items: _relations.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                onChanged: (v) => setState(() => _relation = v!),
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Full Name', border: OutlineInputBorder()),
                validator: (v) => v?.isNotEmpty == true ? null : 'Required',
                onChanged: (_) => _save(),
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Primary Phone', border: OutlineInputBorder()),
                keyboardType: TextInputType.phone,
                validator: (v) => v?.isNotEmpty == true ? null : 'Required',
                onChanged: (_) => _save(),
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email (Optional)', border: OutlineInputBorder()),
                keyboardType: TextInputType.emailAddress,
                onChanged: (_) => _save(),
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _occupationController,
                decoration: const InputDecoration(labelText: 'Occupation (Optional)', border: OutlineInputBorder()),
                onChanged: (_) => _save(),
              ),
               const SizedBox(height: 16),
               
              Row(
                children: [
                  Expanded(
                    child: CheckboxListTile(
                      title: const Text('Is Primary?'),
                      value: _isPrimary,
                      onChanged: (v) {
                        setState(() => _isPrimary = v!);
                        _save();
                      },
                    ),
                  ),
                  Expanded(
                    child: CheckboxListTile(
                      title: const Text('Emergency?'),
                      value: _isEmergency,
                      onChanged: (v) {
                        setState(() => _isEmergency = v!);
                        _save();
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
