import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/exams_repository.dart';
import '../domain/models.dart';
import '../../../core/network/api_client.dart';

class ExamConfigScreen extends ConsumerStatefulWidget {
  const ExamConfigScreen({super.key});

  @override
  ConsumerState<ExamConfigScreen> createState() => _ExamConfigScreenState();
}

class _ExamConfigScreenState extends ConsumerState<ExamConfigScreen> {
  bool _isLoading = true;
  List<ExamType> _types = [];

  @override
  void initState() {
    super.initState();
    _loadTypes();
  }

  Future<void> _loadTypes() async {
    setState(() => _isLoading = true);
    try {
      final repo = ref.read(examRepositoryProvider);
      final types = await repo.getExamTypes();
      if (mounted) setState(() => _types = types);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _addOrEditType({ExamType? type}) async {
    final nameController = TextEditingController(text: type?.name);
    final codeController = TextEditingController(text: type?.code);
    final descController = TextEditingController(text: type?.description);
    final weightageController = TextEditingController(text: type != null ? type.weightage.toString() : '0');

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(type == null ? 'Add Exam Type' : 'Edit Exam Type'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name *')),
            const SizedBox(height: 10),
            TextField(controller: codeController, decoration: const InputDecoration(labelText: 'Code')),
            const SizedBox(height: 10),
            TextField(controller: weightageController, decoration: const InputDecoration(labelText: 'Weightage (%)'), keyboardType: TextInputType.number),
            const SizedBox(height: 10),
            TextField(controller: descController, decoration: const InputDecoration(labelText: 'Description')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              ElevatedButton(
            onPressed: () async {
              if (nameController.text.isEmpty) return;
              Navigator.pop(context);
              
              setState(() => _isLoading = true);
              try {
                final repo = ref.read(examRepositoryProvider);
                final data = {
                  'name': nameController.text,
                  'code': codeController.text,
                  'description': descController.text,
                  'weightage': double.tryParse(weightageController.text) ?? 0.0,
                };
                if (type == null) {
                  await repo.createExamType(data);
                } else {
                  await repo.updateExamType(type.id, data);
                }
                _loadTypes();
              } catch (e) {
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                setState(() => _isLoading = false);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exam Configuration'),
        leading: const BackButton(color: Colors.black),
        actions: [
           IconButton(
             icon: const Icon(Icons.picture_as_pdf),
             onPressed: () {
               ref.read(examRepositoryProvider).exportExamTypesPdf(_types);
             },
           ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrEditType(),
        child: const Icon(Icons.add),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _types.length,
            itemBuilder: (context, index) {
              final type = _types[index];
              return Card(
                child: ListTile(
                  title: Text(type.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${type.description ?? '-'} | Weightage: ${type.weightage}%'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _addOrEditType(type: type),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                           final confirm = await showDialog<bool>(context: context, builder: (c) => AlertDialog(
                             title: const Text('Delete Exam Type?'),
                             actions: [
                               TextButton(onPressed: ()=>Navigator.pop(c,false), child: const Text('Cancel')),
                               TextButton(onPressed: ()=>Navigator.pop(c,true), child: const Text('Delete')),
                             ]
                           ));
                           if (confirm == true) {
                             setState(() => _isLoading = true);
                             try {
                               await ref.read(examRepositoryProvider).deleteExamType(type.id);
                               _loadTypes();
                             } catch (e) {
                               if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                                  setState(() => _isLoading = false);
                               }
                             }
                           }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
    );
  }
}
