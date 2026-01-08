import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../data/student_repository.dart';
import '../domain/student.dart';
import '../../../shared/widgets/app_data_table.dart';
import '../../../core/services/export_service.dart';
import 'package:go_router/go_router.dart';
import 'package:printing/printing.dart';
import 'student_wrapper_form_screen.dart';



class StudentListScreen extends ConsumerWidget {
  const StudentListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studentsAsync = ref.watch(studentListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Students')),
      body: studentsAsync.when(
        data: (students) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              AppDataTable<Student>(
                title: 'Student Directory',
                // onAdd removed as per request
                onExport: (type) async {
                   final headers = ['ID', 'First Name', 'Last Name', 'Admission #', 'Email'];
                   final data = students.map((s) => [s.id ?? '', s.firstName, s.lastName, s.admissionNumber ?? '', s.email ?? '']).toList();
                   
                   if (type == 'PDF') {
                     await ExportService.exportToPdf(context, 'Student List', headers, data);
                   } else if (type == 'CSV' || type == 'Excel') { 
                     await ExportService.exportToCsv(context, 'student_list', headers, data);
                   }
                },
                columns: const ['Admission #', 'Name', 'Contact', 'Actions'],
                data: students,
                buildRow: (student) {
                   return [
                     DataCell(
                       Text(student.admissionNumber ?? 'N/A', style: const TextStyle(fontWeight: FontWeight.bold)),
                       onTap: () => context.push('/students/detail', extra: student),
                     ),
                     DataCell(
                       Column(
                         crossAxisAlignment: CrossAxisAlignment.start,
                         mainAxisAlignment: MainAxisAlignment.center,
                         children: [
                           Text('${student.firstName} ${student.lastName}', style: const TextStyle(fontWeight: FontWeight.w500)),
                           Text(student.email ?? '', style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                         ],
                       ),
                       onTap: () => context.push('/students/detail', extra: student),
                     ),
                     DataCell(Text(student.mobilePrimary ?? 'N/A')),
                     DataCell(Row(
                       mainAxisSize: MainAxisSize.min,
                       children: [
                         IconButton(
                           icon: const Icon(Icons.visibility, color: Colors.indigo),
                           onPressed: () => context.push('/students/detail', extra: student),
                           tooltip: 'View Details',
                         ),
                         IconButton(
                           icon: const Icon(Icons.badge_outlined, color: Colors.purple),
                           onPressed: () async {
                             if (student.id == null) return;
                             try {
                               // Show loading
                               if (context.mounted) {
                                 ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Generating ID Card...')));
                               }
                               
                               final repo = ref.read(studentRepositoryProvider);
                               final bytes = await repo.generateIdCard(student.id!);
                               
                               if (context.mounted) {
                                  // Show preview dialog first
                                  await showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      contentPadding: EdgeInsets.zero,
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Image.memory(
                                            Uint8List.fromList(bytes),
                                            fit: BoxFit.contain,
                                            width: 300, // Reasonable preview size
                                            errorBuilder: (context, error, stackTrace) => 
                                               Padding(padding: const EdgeInsets.all(20), child: Text('Error loading image: $error')),
                                          ),
                                        ],
                                      ),
                                      actions: [
                                        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
                                        ElevatedButton.icon(
                                          icon: const Icon(Icons.print),
                                          label: const Text('Print / Save PDF'),
                                          onPressed: () async {
                                            // Wrap PNG in PDF
                                            final pdf = pw.Document();
                                            final image = pw.MemoryImage(Uint8List.fromList(bytes));
                                            
                                            pdf.addPage(pw.Page(
                                              build: (pw.Context context) {
                                                return pw.Center(
                                                  child: pw.Image(image),
                                                );
                                              },
                                            ));

                                            await Printing.layoutPdf(
                                              onLayout: (format) async => pdf.save(),
                                              name: '${student.admissionNumber ?? "card"}_id_card.pdf',
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  );
                               }
                             } catch (e) {
                               if (context.mounted) {
                                 ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error generating ID: $e')));
                               }
                             }
                           },
                           tooltip: 'Generate ID Card',
                         ),
                         IconButton(
                           icon: const Icon(Icons.edit, color: Colors.blue),
                           onPressed: () {
                             Navigator.push(context, MaterialPageRoute(builder: (_) => StudentWrapperFormScreen(student: student)));
                           },
                           tooltip: 'Edit',
                         ),
                         IconButton(
                           icon: const Icon(Icons.delete, color: Colors.red),
                           onPressed: () async {
                             if (student.id == null) return;
                             final confirm = await showDialog<bool>(
                               context: context,
                               builder: (context) => AlertDialog(
                                 title: const Text('Delete Student'),
                                 content: Text('Are you sure you want to delete ${student.firstName}?'),
                                 actions: [
                                   TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                                   TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
                                 ],
                               ),
                             );
                             
                             if (confirm == true) {
                               try {
                                 await ref.read(studentRepositoryProvider).deleteStudent(student.id!);
                                 ref.invalidate(studentListProvider);
                               } catch (e) {
                                 if (context.mounted) {
                                   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                                 }
                               }
                             }
                           },
                           tooltip: 'Delete',
                         ),
                       ],
                     )),
                   ];
                },
              ),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
