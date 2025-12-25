import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../domain/student.dart';

class StudentIdCardDialog extends StatelessWidget {
  final Student student;

  const StudentIdCardDialog({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        height: 500,
        width: 400,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Student ID Card", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ],
            ),
            const Divider(),
            Expanded(
              child: PdfPreview(
                build: (format) => _generateIdCard(format, student),
                canDebug: false,
                canChangeOrientation: false,
                canChangePageFormat: false,
                actions: const [], // Standard print/share actions provided by package
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<Uint8List> _generateIdCard(PdfPageFormat format, Student student) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pw.Center(
            child: pw.Container(
              width: 300,
              height: 180,
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.blue, width: 2),
                borderRadius: pw.BorderRadius.circular(10),
                color: PdfColors.white,
              ),
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Photo Placeholder
                  pw.Container(
                    width: 70,
                    height: 90,
                    color: PdfColors.grey300,
                    child: pw.Center(child: pw.Text("PHOTO")),
                  ),
                  pw.SizedBox(width: 15),
                  // Details
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text("SCHOOL NAME", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14, color: PdfColors.blue)),
                        pw.Divider(thickness: 1, color: PdfColors.blue),
                        pw.SizedBox(height: 5),
                        pw.Text("Name: ${student.firstName} ${student.lastName}", style: const pw.TextStyle(fontSize: 12)),
                        pw.Text("Reg No: ${student.admissionNumber}", style: const pw.TextStyle(fontSize: 12)),
                        pw.Text("Email: ${student.email ?? 'N/A'}", style: const pw.TextStyle(fontSize: 10)),
                        pw.Spacer(),
                         pw.BarcodeWidget(
                          data: student.admissionNumber,
                          barcode: pw.Barcode.code128(),
                          width: 100,
                          height: 30,
                          drawText: false,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );

    return pdf.save();
  }
}
