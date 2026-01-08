import 'package:flutter/material.dart';
import '../../domain/student_transport.dart';

class TransportForm extends StatefulWidget {
  final Function(StudentTransport) onSaved;

  const TransportForm({Key? key, required this.onSaved}) : super(key: key);

  @override
  State<TransportForm> createState() => _TransportFormState();
}

class _TransportFormState extends State<TransportForm> {
  final _busRouteController = TextEditingController();
  final _busStopController = TextEditingController();
  final _pickupTimeController = TextEditingController();
  final _dropTimeController = TextEditingController();
  final _distanceController = TextEditingController();
  final _feeController = TextEditingController();
  final _emergencyContactController = TextEditingController();
  final _emergencyPhoneController = TextEditingController();
  final _remarksController = TextEditingController();

  bool _isActive = true;

  @override
  void dispose() {
    _busRouteController.dispose();
    _busStopController.dispose();
    _pickupTimeController.dispose();
    _dropTimeController.dispose();
    _distanceController.dispose();
    _feeController.dispose();
    _emergencyContactController.dispose();
    _emergencyPhoneController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  void _save() {
    final transport = StudentTransport(
      student: '',
      busRoute: _busRouteController.text,
      busStop: _busStopController.text,
      pickupTime: _pickupTimeController.text,
      dropTime: _dropTimeController.text,
      distanceKm: double.tryParse(_distanceController.text),
      monthlyFee: double.tryParse(_feeController.text),
      emergencyContact: _emergencyContactController.text,
      emergencyPhone: _emergencyPhoneController.text,
      remarks: _remarksController.text,
      isActive: _isActive,
    );
    widget.onSaved(transport);
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
            Text('Transport Details', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            
            Row(children: [
              Expanded(child: TextFormField(controller: _busRouteController, decoration: const InputDecoration(labelText: 'Bus Route', border: OutlineInputBorder()), onChanged: (_) => _save())),
              const SizedBox(width: 16),
              Expanded(child: TextFormField(controller: _busStopController, decoration: const InputDecoration(labelText: 'Bus Stop', border: OutlineInputBorder()), onChanged: (_) => _save())),
            ]),
            const SizedBox(height: 16),
            
            Row(children: [
              Expanded(child: TextFormField(controller: _pickupTimeController, decoration: const InputDecoration(labelText: 'Pickup Time (HH:MM)', border: OutlineInputBorder()), onChanged: (_) => _save())),
              const SizedBox(width: 16),
              Expanded(child: TextFormField(controller: _dropTimeController, decoration: const InputDecoration(labelText: 'Drop Time (HH:MM)', border: OutlineInputBorder()), onChanged: (_) => _save())),
            ]),
            const SizedBox(height: 16),
            
            Row(children: [
              Expanded(child: TextFormField(controller: _distanceController, decoration: const InputDecoration(labelText: 'Distance (km)', border: OutlineInputBorder()), keyboardType: TextInputType.number, onChanged: (_) => _save())),
              const SizedBox(width: 16),
              Expanded(child: TextFormField(controller: _feeController, decoration: const InputDecoration(labelText: 'Monthly Fee', border: OutlineInputBorder()), keyboardType: TextInputType.number, onChanged: (_) => _save())),
            ]),
            const SizedBox(height: 16),
            
            const Divider(),
            Text('Emergency Contact', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            
            Row(children: [
              Expanded(child: TextFormField(controller: _emergencyContactController, decoration: const InputDecoration(labelText: 'Contact Name', border: OutlineInputBorder()), onChanged: (_) => _save())),
              const SizedBox(width: 16),
              Expanded(child: TextFormField(controller: _emergencyPhoneController, decoration: const InputDecoration(labelText: 'Contact Phone', border: OutlineInputBorder()), keyboardType: TextInputType.phone, onChanged: (_) => _save())),
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
