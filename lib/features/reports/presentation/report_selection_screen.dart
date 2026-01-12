import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:printing/printing.dart';
import '../../../../core/theme/app_theme.dart';
import '../data/report_repository.dart';

class ReportSelectionScreen extends ConsumerStatefulWidget {
  const ReportSelectionScreen({super.key});

  @override
  ConsumerState<ReportSelectionScreen> createState() => _ReportSelectionScreenState();
}

class _ReportSelectionScreenState extends ConsumerState<ReportSelectionScreen> {
  bool _isLoading = false;

  Future<void> _downloadReport(String type) async {
    setState(() => _isLoading = true);
    try {
      final bytes = await ref.read(reportRepositoryProvider).downloadReport(type);
      await Printing.layoutPdf(
        onLayout: (_) => bytes,
        name: '${type}_report.pdf',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error generating report: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Reports Center", style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator()) 
        : Padding(
            padding: const EdgeInsets.all(20.0),
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildReportCard(
                  'Attendance Report', 
                  Icons.calendar_today, 
                  Colors.blue, 
                  () => _downloadReport('attendance')
                ),
                _buildReportCard(
                  'Finance Report', 
                  Icons.attach_money, 
                  Colors.green, 
                  () => _downloadReport('finance')
                ),
                _buildReportCard(
                  'Staff List', 
                  Icons.badge, 
                  Colors.orange, 
                  () => _downloadReport('staff')
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildReportCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 32, color: color),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "Export PDF",
              style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
