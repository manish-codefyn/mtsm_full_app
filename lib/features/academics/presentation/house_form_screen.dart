import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:eduerp_app/features/academics/data/academics_repository.dart';

class HouseFormScreen extends ConsumerStatefulWidget {
  const HouseFormScreen({super.key});

  @override
  ConsumerState<HouseFormScreen> createState() => _HouseFormScreenState();
}

class _HouseFormScreenState extends ConsumerState<HouseFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  
  // Standard colors matching backend AutoGen
  final List<String> _colors = ['Red', 'Blue', 'Green', 'Yellow', 'Purple', 'Orange', 'White', 'Black'];
  String _selectedColor = 'Red';
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        await ref.read(academicsRepositoryProvider).createHouse({
          'name': _nameController.text,
          'code': _codeController.text,
          'color': _selectedColor,
          // 'house_master': null // TODO: Implement staff selection
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('House created successfully!')),
          );
          context.pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add House')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'House Name',
                  hintText: 'e.g., Red House',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v?.isEmpty == true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _codeController,
                decoration: const InputDecoration(
                  labelText: 'House Code',
                  hintText: 'e.g., RED',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v?.isEmpty == true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              
              DropdownButtonFormField<String>(
                value: _selectedColor,
                decoration: const InputDecoration(
                  labelText: 'House Color',
                  border: OutlineInputBorder(),
                ),
                items: _colors.map((c) => DropdownMenuItem(
                  value: c,
                  child: Row(
                    children: [
                      Container(
                        width: 16, 
                        height: 16, 
                        color: _getColor(c),
                        margin: const EdgeInsets.only(right: 8),
                      ),
                      Text(c),
                    ],
                  ),
                )).toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _selectedColor = v);
                },
              ),
              const SizedBox(height: 24),
              
              FilledButton(
                onPressed: _isLoading ? null : _submit,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.white) 
                  : const Text('Create House'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getColor(String name) {
    switch (name.toLowerCase()) {
      case 'red': return Colors.red;
      case 'blue': return Colors.blue;
      case 'green': return Colors.green;
      case 'yellow': return Colors.yellow;
      case 'purple': return Colors.purple;
      case 'orange': return Colors.orange;
      case 'black': return Colors.black;
      default: return Colors.grey;
    }
  }
}
