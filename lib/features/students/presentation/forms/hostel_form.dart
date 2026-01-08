import 'package:flutter/material.dart';
import '../../domain/student_hostel.dart';

class HostelForm extends StatefulWidget {
  final Function(StudentHostel) onSaved;

  const HostelForm({Key? key, required this.onSaved}) : super(key: key);

  @override
  State<HostelForm> createState() => _HostelFormState();
}

class _HostelFormState extends State<HostelForm> {
  final _hostelNameController = TextEditingController();
  final _roomNumberController = TextEditingController();
  final _bedNumberController = TextEditingController();
  final _floorController = TextEditingController();
  final _wardenNameController = TextEditingController();
  final _wardenPhoneController = TextEditingController();
  final _feeController = TextEditingController();
  final _remarksController = TextEditingController();

  String _roomType = 'DOUBLE';
  bool _isActive = true;
  DateTime? _admissionDate;

  final List<String> _roomTypes = ['SINGLE', 'DOUBLE', 'TRIPLE', 'DORMITORY'];

  @override
  void dispose() {
    _hostelNameController.dispose();
    _roomNumberController.dispose();
    _bedNumberController.dispose();
    _floorController.dispose();
    _wardenNameController.dispose();
    _wardenPhoneController.dispose();
    _feeController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  void _save() {
    final hostel = StudentHostel(
      student: '',
      hostelName: _hostelNameController.text,
      roomNumber: _roomNumberController.text,
      bedNumber: _bedNumberController.text,
      floor: int.tryParse(_floorController.text),
      roomType: _roomType,
      wardenName: _wardenNameController.text,
      wardenPhone: _wardenPhoneController.text,
      monthlyFee: double.tryParse(_feeController.text),
      admissionDate: _admissionDate?.toIso8601String().split('T')[0],
      isActive: _isActive,
      remarks: _remarksController.text,
    );
    widget.onSaved(hostel);
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
            Text('Hostel Details', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            
            TextFormField(controller: _hostelNameController, decoration: const InputDecoration(labelText: 'Hostel Name', border: OutlineInputBorder()), onChanged: (_) => _save()),
            const SizedBox(height: 16),
            
            Row(children: [
              Expanded(child: TextFormField(controller: _roomNumberController, decoration: const InputDecoration(labelText: 'Room Number', border: OutlineInputBorder()), onChanged: (_) => _save())),
              const SizedBox(width: 16),
              Expanded(child: TextFormField(controller: _bedNumberController, decoration: const InputDecoration(labelText: 'Bed Number', border: OutlineInputBorder()), onChanged: (_) => _save())),
            ]),
            const SizedBox(height: 16),
            
            Row(children: [
              Expanded(child: TextFormField(controller: _floorController, decoration: const InputDecoration(labelText: 'Floor', border: OutlineInputBorder()), keyboardType: TextInputType.number, onChanged: (_) => _save())),
              const SizedBox(width: 16),
              Expanded(child: DropdownButtonFormField<String>(
                value: _roomType,
                items: _roomTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                onChanged: (v) {
                  setState(() => _roomType = v!);
                  _save();
                },
                decoration: const InputDecoration(labelText: 'Room Type', border: OutlineInputBorder()),
              )),
            ]),
            const SizedBox(height: 16),
            
            const Divider(),
            Text('Warden Details', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            
            Row(children: [
              Expanded(child: TextFormField(controller: _wardenNameController, decoration: const InputDecoration(labelText: 'Warden Name', border: OutlineInputBorder()), onChanged: (_) => _save())),
              const SizedBox(width: 16),
              Expanded(child: TextFormField(controller: _wardenPhoneController, decoration: const InputDecoration(labelText: 'Warden Phone', border: OutlineInputBorder()), keyboardType: TextInputType.phone, onChanged: (_) => _save())),
            ]),
            const SizedBox(height: 16),
            
            Row(children: [
              Expanded(child: TextFormField(controller: _feeController, decoration: const InputDecoration(labelText: 'Monthly Fee', border: OutlineInputBorder()), keyboardType: TextInputType.number, onChanged: (_) => _save())),
              const SizedBox(width: 16),
              Expanded(child: InkWell(
                onTap: () async {
                  final d = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime.now());
                  if (d != null) {
                    setState(() => _admissionDate = d);
                    _save();
                  }
                },
                child: InputDecorator(decoration: const InputDecoration(labelText: 'Admission Date', border: OutlineInputBorder()), child: Text(_admissionDate?.toLocal().toString().split(' ')[0] ?? 'Select')),
              )),
            ]),
            const SizedBox(height: 16),
            
            TextFormField(controller: _remarksController, decoration: const InputDecoration(labelText: 'Remarks', border: OutlineInputBorder()), maxLines: 2, onChanged: (_) => _save()),
            const SizedBox(height: 16),
            
            CheckboxListTile(
              title: const Text('Is Active?'),
              value: _isActive,
              onChanged: (v) {
                setState(() => _isActive = v!);
                _save();
              },
              controlAffinity: ListTileControlAffinity.leading,
            ),
          ],
        ),
      ),
    );
  }
}
