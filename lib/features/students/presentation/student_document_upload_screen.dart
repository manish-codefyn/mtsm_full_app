import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:go_router/go_router.dart';
import '../data/student_repository.dart';
import '../domain/student_document.dart';

final studentDocumentsProvider = FutureProvider.family.autoDispose<List<StudentDocument>, String>((ref, studentId) async {
  return ref.watch(studentRepositoryProvider).getDocuments(studentId);
});

class StudentDocumentUploadScreen extends ConsumerStatefulWidget {
  final String studentId;
  const StudentDocumentUploadScreen({super.key, required this.studentId});

  @override
  ConsumerState<StudentDocumentUploadScreen> createState() => _StudentDocumentUploadScreenState();
}

class _StudentDocumentUploadScreenState extends ConsumerState<StudentDocumentUploadScreen> {
  bool _isUploading = false;

  Future<void> _pickAndUpload() async {
    // 1. Pick File
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'png', 'pdf', 'doc', 'docx'],
        withData: kIsWeb, // Important for web
      );
  
      if (result == null || result.files.isEmpty) return;
  
      final file = result.files.first;
      
      // 2. Select Type
      if (!mounted) return;
      final docType = await showDialog<String>(
        context: context,
        builder: (context) => SimpleDialog(
          title: const Text('Select Document Type'),
          children: [
            SimpleDialogOption(child: const Text('Photo'), onPressed: () => Navigator.pop(context, 'PHOTO')),
            SimpleDialogOption(child: const Text('Aadhaar Card'), onPressed: () => Navigator.pop(context, 'AADHAAR')),
            SimpleDialogOption(child: const Text('Transfer Certificate'), onPressed: () => Navigator.pop(context, 'TC')),
            SimpleDialogOption(child: const Text('Mark Sheet'), onPressed: () => Navigator.pop(context, 'MARK_SHEET')),
            SimpleDialogOption(child: const Text('Birth Certificate'), onPressed: () => Navigator.pop(context, 'BIRTH_CERTIFICATE')),
            SimpleDialogOption(child: const Text('Other'), onPressed: () => Navigator.pop(context, 'OTHER')),
          ],
        ),
      );
  
      if (docType == null) return;
  
      // 3. Upload
      setState(() => _isUploading = true);
      
      await ref.read(studentRepositoryProvider).uploadDocument(
        studentId: widget.studentId,
        docType: docType,
        filePath: kIsWeb ? null : file.path, 
        fileBytes: file.bytes,
        fileName: file.name,
      );
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Upload successful')));
      ref.invalidate(studentDocumentsProvider(widget.studentId));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final docsAsync = ref.watch(studentDocumentsProvider(widget.studentId));

    return Scaffold(
      appBar: AppBar(title: const Text('Student Documents')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isUploading ? null : _pickAndUpload,
        label: _isUploading ? const CircularProgressIndicator(color: Colors.white) : const Text('Upload Document'),
        icon: _isUploading ? null : const Icon(Icons.upload_file),
      ),
      body: docsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (docs) {
          if (docs.isEmpty) return const Center(child: Text('No documents uploaded yet.'));
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              return ListTile(
                leading: const Icon(Icons.description),
                title: Text(doc.docType.replaceAll('_', ' ')),
                subtitle: Text(doc.fileName ?? 'Unknown file'),
                trailing: doc.isVerified 
                  ? const Icon(Icons.check_circle, color: Colors.green) 
                  : const Icon(Icons.pending, color: Colors.orange),
              );
            },
          );
        },
      ),
    );
  }
}
