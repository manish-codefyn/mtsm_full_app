import 'package:flutter/material.dart';

class AppDataTable<T> extends StatelessWidget {
  final List<String> columns;
  final List<T> data;
  final List<DataCell> Function(T data) buildRow;
  final VoidCallback? onAdd;
  final Function(String type)? onExport; // 'PDF', 'CSV', 'Excel'
  final String title;

  const AppDataTable({
    super.key,
    required this.columns,
    required this.data,
    required this.buildRow,
    this.title = 'Data Table',
    this.onAdd,
    this.onExport,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                // Export Buttons
                _buildExportButton(context, 'PDF', Colors.red, Icons.picture_as_pdf),
                const SizedBox(width: 8),
                _buildExportButton(context, 'Excel', Colors.green, Icons.table_chart),
                 const SizedBox(width: 8),
                _buildExportButton(context, 'CSV', Colors.blue, Icons.description),
                
                if (onAdd != null) ...[
                  const SizedBox(width: 24),
                  ElevatedButton.icon(
                    onPressed: onAdd,
                    icon: const Icon(Icons.add_rounded, size: 20),
                    label: const Text('Add New'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      elevation: 2,
                      shadowColor: Theme.of(context).primaryColor.withOpacity(0.3),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
          // Table
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width - 40),
              child: DataTable(
                headingRowColor: MaterialStateProperty.all(Colors.grey.shade50),
                columnSpacing: 24,
                horizontalMargin: 16,
                columns: columns.map((col) => DataColumn(label: Text(col, style: const TextStyle(fontWeight: FontWeight.bold)))).toList(),
                rows: data.map((item) {
                  return DataRow(cells: buildRow(item));
                }).toList(),
              ),
            ),
          ),
          if (data.isEmpty)
             const Padding(
               padding: EdgeInsets.all(32.0),
               child: Center(child: Text('No records found', style: TextStyle(color: Colors.grey))),
             ),
        ],
      ),
    );
  }

  Widget _buildExportButton(BuildContext context, String label, Color color, IconData icon) {
    return Tooltip(
      message: 'Export to $label',
      child: InkWell(
        onTap: () => onExport?.call(label),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Icon(icon, size: 20, color: color),
        ),
      ),
    );
  }
}
