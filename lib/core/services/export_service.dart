import 'dart:convert';
import 'package:csv/csv.dart';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:html' as html;

import '../../features/students/domain/student.dart';

class ExportService {
  static Future<void> exportToExcel(BuildContext context, String fileName, List<String> headers, List<List<dynamic>> data) async {
    final excel = Excel.createExcel();
    final sheet = excel['Sheet1'];

    // Add headers
    sheet.appendRow(headers.map((e) => TextCellValue(e.toString())).toList());
    
    // Add data
    for (var row in data) {
      sheet.appendRow(row.map((e) => TextCellValue(e.toString())).toList());
    }

    final bytes = excel.encode();
    if (bytes != null) {
      _downloadFile(bytes, '$fileName.xlsx', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
    }
  }

  static Future<void> exportToCsv(BuildContext context, String fileName, List<String> headers, List<List<dynamic>> data) async {
    final List<List<dynamic>> csvRows = [headers, ...data];
    final csvData = const ListToCsvConverter().convert(csvRows);
    final bytes = utf8.encode(csvData);
    _downloadFile(bytes, '$fileName.csv', 'text/csv');
  }

  static Future<void> exportToPdf(BuildContext context, String fileName, List<String> headers, List<List<dynamic>> data) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        orientation: pw.PageOrientation.landscape,
        build: (pw.Context context) {
          return [
            pw.Header(level: 0, child: pw.Text(fileName, style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900))),
            pw.SizedBox(height: 20),
            pw.TableHelper.fromTextArray(
              headers: headers,
              data: data,
              border: pw.TableBorder.all(color: PdfColors.grey300),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.blue900),
              cellAlignment: pw.Alignment.centerLeft,
            ),
          ];
        },
      ),
    );

    await Printing.sharePdf(bytes: await pdf.save(), filename: '$fileName.pdf');
  }

  static Future<void> exportProfileToPdf(BuildContext context, Student student) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(
                level: 0,
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Student Profile', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                    pw.Text('MTSM ERP', style: pw.TextStyle(fontSize: 18, color: PdfColors.grey)),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Name: ${student.firstName} ${student.lastName}', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                      pw.Text('Admission No: ${student.admissionNumber ?? "N/A"}'),
                      pw.Text('Roll No: ${student.rollNumber ?? "N/A"}'),
                      pw.Text('Gender: ${student.gender ?? "N/A"}'),
                      pw.Text('DOB: ${student.dateOfBirth ?? "N/A"}'),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Divider(),
              pw.SizedBox(height: 10),
              pw.Text('Contact Information', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.Text('Email: ${student.email ?? "N/A"}'),
              pw.Text('Mobile: ${student.mobilePrimary ?? "N/A"}'),
              pw.SizedBox(height: 20),
              pw.Text('Parent Information', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.Text('Father: ${student.fatherName ?? "N/A"}'),
              pw.Text('Mother: ${student.motherName ?? "N/A"}'),
              pw.SizedBox(height: 20),
              pw.Text('Academic Information', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.Text('Class: ${student.currentClassName ?? "N/A"}'),
              pw.Text('Section: ${student.section ?? "N/A"}'),
              pw.Text('Stream: ${student.stream ?? "N/A"}'),
            ],
          );
        },
      ),
    );

    await Printing.sharePdf(bytes: await pdf.save(), filename: 'student_profile_${student.admissionNumber ?? student.firstName}.pdf');
  }

  static void _downloadFile(List<int> bytes, String fileName, String mimeType) {
    // Web-compatible download using dart:html
    final blob = html.Blob([bytes], mimeType);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', fileName)
      ..click();
    html.Url.revokeObjectUrl(url);
  }
}
