import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class DocumentsForm extends StatefulWidget {
  final Function(Map<String, PlatformFile?>) onSaved;
  final Map<String, String?>? existingUrls;

  const DocumentsForm({
    super.key,
    required this.onSaved,
    this.existingUrls,
  });

  @override
  State<DocumentsForm> createState() => _DocumentsFormState();
}

class _DocumentsFormState extends State<DocumentsForm> {
  PlatformFile? _photo;
  PlatformFile? _birthCert;
  PlatformFile? _aadhaar;

  Future<void> _pickFile(String type) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
    );

    if (result != null) {
      setState(() {
        if (type == 'PHOTO') _photo = result.files.first;
        if (type == 'BIRTH_CERTIFICATE') _birthCert = result.files.first;
        if (type == 'AADHAAR') _aadhaar = result.files.first;
      });
      widget.onSaved({
        'PHOTO': _photo,
        'BIRTH_CERTIFICATE': _birthCert,
        'AADHAAR': _aadhaar,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildUploadCard('Student Photo', 'PHOTO', _photo, widget.existingUrls?['PHOTO']),
        const SizedBox(height: 16),
        _buildUploadCard('Birth Certificate', 'BIRTH_CERTIFICATE', _birthCert, widget.existingUrls?['BIRTH_CERTIFICATE']),
        const SizedBox(height: 16),
        _buildUploadCard('Aadhaar Card', 'AADHAAR', _aadhaar, widget.existingUrls?['AADHAAR']),
      ],
    );
  }

  Widget _buildUploadCard(String title, String type, PlatformFile? file, String? existingUrl) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.file_present, size: 40, color: Colors.blue),
        title: Text(title),
        subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                if (file != null) Text('Selected: ${file.name}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                if (file == null && existingUrl != null) Text('Existing file loaded', style: const TextStyle(color: Colors.grey)),
                if (file == null && existingUrl == null) const Text('No file selected'),
            ],
        ),
        trailing: ElevatedButton.icon(
          onPressed: () => _pickFile(type),
          icon: const Icon(Icons.upload_file),
          label: const Text('Select'),
        ),
      ),
    );
  }
}
