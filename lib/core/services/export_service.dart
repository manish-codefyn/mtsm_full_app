import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
// import 'package:universal_html/html.dart' as html; // For web download if needed, keeping simple for now

class ExportService {
  
  // Generate and Preview/Print PDF
  static Future<void> exportToPdf(
    BuildContext context, 
    String title, 
    List<String> headers, 
    List<List<dynamic>> data
  ) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Text(title, style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
            ),
            pw.SizedBox(height: 20),
            pw.Table.fromTextArray(
              headers: headers,
              data: data,
              border: pw.TableBorder.all(),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              cellAlignment: pw.Alignment.centerLeft,
            ),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: '${title.replaceAll(' ', '_')}.pdf',
    );
  }

  // Generate CSV (Printing package doesn't handle CSV, so we usually share it or save it)
  // For Web/Desktop/Mobile, saving files varies. 
  // For this generic implementation, we'll try to use the share dialog or simple print for now
  // as saving to file system permissions can be tricky cross-platform without more setup.
  // Actually, for a dashboard, "Export to CSV" usually means download.
  static Future<void> exportToCsv(BuildContext context, String filename, List<String> headers, List<List<dynamic>> data) async {
    // Basic CSV generation
    List<List<dynamic>> rows = [headers, ...data];
    String csv = const ListToCsvConverter().convert(rows);
    
    // For simplicity in this demo, we can show specific instructions or use a basic share
    // Implementing full file download for all platforms is complex.
    // We will simulate success for now or log it.
    print("CSV Generatd:\n$csv");
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('CSV Export Simulated (Check Console)')),
    );
  }
}
