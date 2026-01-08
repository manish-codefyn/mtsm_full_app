import 'package:flutter/material.dart';
import '../../domain/student_address.dart';

class AddressForm extends StatefulWidget {
  final Function(StudentAddress) onSaved;
  final VoidCallback onRemove;
  final int index;

  const AddressForm({
    Key? key, 
    required this.onSaved,
    required this.onRemove,
    required this.index,
  }) : super(key: key);

  @override
  State<AddressForm> createState() => _AddressFormState();
}

class _AddressFormState extends State<AddressForm> {
  final _formKey = GlobalKey<FormState>();
  
  final _line1Controller = TextEditingController();
  final _line2Controller = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _pincodeController = TextEditingController();
  
  String _type = 'PERMANENT';
  bool _isCurrent = true;

  final List<String> _types = ['PERMANENT', 'CORRESPONDENCE', 'LOCAL_GUARDIAN', 'HOSTEL'];

  @override
  void dispose() {
    _line1Controller.dispose();
    _line2Controller.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final address = StudentAddress(
        student: '',
        addressType: _type,
        addressLine1: _line1Controller.text,
        addressLine2: _line2Controller.text,
        city: _cityController.text,
        state: _stateController.text,
        pincode: _pincodeController.text,
        isCurrent: _isCurrent,
      );
      widget.onSaved(address);
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
                  Text('Address #${widget.index + 1}', style: Theme.of(context).textTheme.titleMedium),
                  IconButton(onPressed: widget.onRemove, icon: const Icon(Icons.delete, color: Colors.red)),
                ],
              ),
              const SizedBox(height: 16),
              
              DropdownButtonFormField<String>(
                value: _type,
                decoration: const InputDecoration(labelText: 'Address Type', border: OutlineInputBorder()),
                items: _types.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                onChanged: (v) => setState(() => _type = v!),
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _line1Controller,
                decoration: const InputDecoration(labelText: 'Address Line 1', border: OutlineInputBorder()),
                validator: (v) => v?.isNotEmpty == true ? null : 'Required',
                onChanged: (_) => _save(),
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _line2Controller,
                decoration: const InputDecoration(labelText: 'Address Line 2 (Optional)', border: OutlineInputBorder()),
                onChanged: (_) => _save(),
              ),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _cityController,
                      decoration: const InputDecoration(labelText: 'City', border: OutlineInputBorder()),
                      validator: (v) => v?.isNotEmpty == true ? null : 'Required',
                      onChanged: (_) => _save(),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _stateController,
                      decoration: const InputDecoration(labelText: 'State', border: OutlineInputBorder()),
                      validator: (v) => v?.isNotEmpty == true ? null : 'Required',
                      onChanged: (_) => _save(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _pincodeController,
                decoration: const InputDecoration(labelText: 'Pincode', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                validator: (v) => v?.length == 6 ? null : '6 digits required',
                onChanged: (_) => _save(),
              ),
               const SizedBox(height: 16),
               
               CheckboxListTile(
                 title: const Text('Is Current Address?'),
                 value: _isCurrent,
                 onChanged: (v) {
                   setState(() => _isCurrent = v!);
                   _save();
                 },
               ),
            ],
          ),
        ),
      ),
    );
  }
}
