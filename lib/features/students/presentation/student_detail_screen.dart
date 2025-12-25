import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:typed_data';
import 'package:intl/intl.dart';
import '../domain/student.dart';
import '../../../core/theme/app_theme.dart';

class StudentDetailScreen extends ConsumerWidget {
  final Student student;

  const StudentDetailScreen({super.key, required this.student});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildAppBar(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                   _buildSummaryCard(context),
                   const SizedBox(height: 20),
                   _buildSectionTitle('Personal Information'),
                   _buildInfoCard([
                     _InfoItem('Gender', student.gender ?? 'N/A', Icons.person),
                     _InfoItem('Date of Birth', student.dateOfBirth ?? 'N/A', Icons.cake),
                     _InfoItem('Mobile', student.mobilePrimary ?? 'N/A', Icons.phone),
                     _InfoItem('Email', student.email ?? 'N/A', Icons.email),
                   ]),
                   const SizedBox(height: 20),
                   _buildSectionTitle('Academic Information'),
                   _buildInfoCard([
                     _InfoItem('Admission Number', student.admissionNumber ?? 'N/A', Icons.badge),
                     _InfoItem('Academic Year', '2025-2026', Icons.calendar_today), // Mocked for now
                     _InfoItem('Status', 'Active', Icons.check_circle, color: Colors.green),
                   ]),
                   const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _generateAndPrintPdf(context, student),
        label: const Text('Export PDF'),
        icon: const Icon(Icons.picture_as_pdf),
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar.large(
      expandedHeight: 200,
      pinned: true,
      stretch: true,
      backgroundColor: Theme.of(context).primaryColor,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        title: Text(
          '${student.firstName} ${student.lastName}',
          style: const TextStyle(
            fontSize: 18, 
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [Shadow(color: Colors.black45, blurRadius: 2)],
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
              ),
            ),
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.white,
                child: Text(
                  student.firstName[0],
                  style: TextStyle(fontSize: 40, color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.share, color: Colors.white),
          onPressed: () {}, // TODO: Implement Share
        ),
      ],
    );
  }
  
  Widget _buildSummaryCard(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.blue.withOpacity(0.1)),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(context, 'Attendance', '95%', Colors.green),
            _buildStatItem(context, 'Grade', 'A', Colors.blue),
            _buildStatItem(context, 'Fees', 'Paid', Colors.orange),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatItem(BuildContext context, String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
      ),
    );
  }

  Widget _buildInfoCard(List<_InfoItem> items) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: items.map((item) => ListTile(
            leading: div(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (item.color ?? Colors.grey).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(item.icon, color: item.color ?? Colors.grey[700], size: 20),
            ),
            title: Text(item.label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            subtitle: Text(item.value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87)),
          )).toList(),
        ),
      ),
    );
  }
  
  // Helper for container shortcut
  Widget div({required Widget child, EdgeInsetsGeometry? padding, Decoration? decoration}) {
    return Container(padding: padding, decoration: decoration, child: child);
  }

  Future<void> _generateAndPrintPdf(BuildContext context, Student student) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Header(
                level: 0,
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Student Profile', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                    pw.Text('School ERP', style: const pw.TextStyle(fontSize: 14, color: PdfColors.grey)),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),
              
              // Profile Section
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Container(
                    width: 100,
                    height: 100,
                    decoration: pw.BoxDecoration(
                      color: PdfColors.grey300,
                      shape: pw.BoxShape.circle,
                    ),
                    child: pw.Center(
                      child: pw.Text(student.firstName[0], style: pw.TextStyle(fontSize: 40, fontWeight: pw.FontWeight.bold)),
                    ),
                  ),
                  pw.SizedBox(width: 20),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('${student.firstName} ${student.lastName}', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
                      pw.Text('Admission #: ${student.admissionNumber ?? "N/A"}'),
                      pw.Text('Email: ${student.email ?? "N/A"}'),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 30),
              
              // Details Table
              pw.TableHelper.fromTextArray(
                context: context,
                border: pw.TableBorder.all(color: PdfColors.grey300),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.blue50),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                headers: ['Field', 'Value'],
                data: [
                  ['First Name', student.firstName],
                  ['Last Name', student.lastName],
                  ['Gender', student.gender ?? 'N/A'],
                  ['Date of Birth', student.dateOfBirth ?? 'N/A'],
                  ['Mobile', student.mobilePrimary ?? 'N/A'],
                  ['Academic Year', '2025-2026'],
                  ['Status', 'Active'],
                ],
              ),
              
              pw.SizedBox(height: 30),
              pw.Footer(
                leading: pw.Text('Generated by School ERP'),
                trailing: pw.Text(DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: '${student.admissionNumber ?? "student"}_profile.pdf',
    );
  }
}

class _InfoItem {
  final String label;
  final String value;
  final IconData icon;
  final Color? color;

  _InfoItem(this.label, this.value, this.icon, {this.color});
}
