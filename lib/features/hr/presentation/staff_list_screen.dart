import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/widgets/app_data_table.dart';
import '../../../../core/services/export_service.dart';
import '../data/models/staff.dart';
import 'controllers/hr_controller.dart';

class StaffListScreen extends ConsumerWidget {
  const StaffListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final staffAsync = ref.watch(staffListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Staff Directory'),
        centerTitle: true,
      ),
      body: staffAsync.when(
        data: (staffList) {
          if (staffList.isEmpty) {
            return const Center(child: Text('No staff members found'));
          }
          if (staffList.isEmpty) {
            return const Center(child: Text('No staff members found'));
          }
           return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                AppDataTable<Staff>(
                  title: 'Staff Directory',
                  onAdd: () {},
                  onExport: (type) async {
                     final headers = ['ID', 'Name', 'Designation', 'Department', 'Email'];
                     final data = staffList.map((s) => [s.employeeId, s.fullName, s.designationTitle ?? '', s.departmentName ?? '', s.email]).toList();
                     
                     if (type == 'PDF') {
                       await ExportService.exportToPdf(context, 'Staff List', headers, data);
                     } else if (type == 'CSV' || type == 'Excel') {
                       await ExportService.exportToCsv(context, 'staff_list', headers, data);
                     }
                  },
                  columns: const ['Name', 'Designation', 'Department', 'Actions'],
                  data: staffList,
                  buildRow: (Staff staff) {
                    return [
                       DataCell(Text(staff.fullName)),
                       DataCell(Text(staff.designationTitle ?? '-')),
                       DataCell(Text(staff.departmentName ?? '-')),
                       DataCell(Row(
                         mainAxisSize: MainAxisSize.min,
                         children: [
                           IconButton(
                             icon: const Icon(Icons.edit, color: Colors.blue),
                             onPressed: () {},
                             tooltip: 'Edit',
                           ),
                           IconButton(
                             icon: const Icon(Icons.delete, color: Colors.red),
                             onPressed: () {},
                             tooltip: 'Delete',
                           ),
                         ],
                       )),
                    ];
                  },
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
