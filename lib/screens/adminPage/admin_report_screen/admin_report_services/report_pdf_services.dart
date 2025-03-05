// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show rootBundle;

class ReportPdfService {
  static Future<void> generateReportPdf(BuildContext context,
      String reportTitle, List<Map<String, dynamic>> data) async {
    final pdf = pw.Document();
    final now = DateTime.now();

    // Font yükleme
    final fontData = await rootBundle.load("assets/fonts/Roboto-Regular.ttf");
    final ttf = pw.Font.ttf(fontData.buffer.asByteData());
    
   // Helper function to sanitize null values
String sanitize(dynamic value) => value == null ? '-' : value.toString();

// PDF Generation
pdf.addPage(
  pw.MultiPage(
    pageFormat: PdfPageFormat.a4, // Change to PdfPageFormat.a3 for larger pages
    build: (pw.Context context) => [
      pw.Text(
        reportTitle,
        style: pw.TextStyle(font: ttf, fontSize: 16),
      ),
      pw.SizedBox(height: 20),
      pw.Table(
        border: pw.TableBorder.all(),
        columnWidths: {
          0: pw.FlexColumnWidth(1.2),
          1: pw.FlexColumnWidth(1.2),
          2: pw.FlexColumnWidth(1.2),
          3: pw.FlexColumnWidth(1.2),
          4: pw.FlexColumnWidth(1.2),
          5: pw.FlexColumnWidth(1.2),
          6: pw.FlexColumnWidth(1.2),
          7: pw.FlexColumnWidth(1.2),
          8: pw.FlexColumnWidth(1.2),
          9: pw.FlexColumnWidth(1.2),
          10: pw.FlexColumnWidth(1.2),
        },
        children: [
          pw.TableRow(
            decoration: pw.BoxDecoration(color: PdfColors.grey300),
            children: <String>[
              'Malzeme',
              'İşlem Türü',
              'Atölye',
              'Miktar',
              'Renk',
              'Boyut',
              'Gramaj',
              'Fine',
              'Denye',
              'Aksesuar',
              'Tarih',
            ].map((header) => pw.Padding(
                  padding: const pw.EdgeInsets.all(4),
                  child: pw.Text(
                    header,
                    style: pw.TextStyle(
                      font: ttf,
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                )).toList(),
          ),
          ...data.map((report) => pw.TableRow(
                children: [
                  sanitize(report['malzeme']),
                  sanitize(report['islemTuru']),
                  sanitize(report['atelye']),
                  sanitize(report['miktar']),
                  sanitize(report['renk']),
                  sanitize(report['boyut']),
                  sanitize(report['gramaj']),
                  sanitize(report['fine']),
                  sanitize(report['denye']),
                  sanitize(report['aksesuar']),
                  report['tarih'] != null
                      ? DateFormat('dd.MM.yyyy HH:mm').format(
                          (report['tarih'] as Timestamp).toDate())
                      : '-',
                ].map((cell) => pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text(
                        cell,
                        style: pw.TextStyle(font: ttf, fontSize: 8),
                        softWrap: true, // Enables text wrapping
                      ),
                    )).toList(),
              )),
        ],
      ),
    ],
  ),
);


    // PDF dosyasını kaydetme
    Directory? directory;
    if (Platform.isAndroid) {
      directory = Directory('/storage/emulated/0/Download');
    } else if (Platform.isIOS) {
      directory = await getApplicationDocumentsDirectory();
    }

    if (directory != null) {
      final file = File(
        "${directory.path}/${reportTitle}_raporu_${now.year}_${now.month}_${now.day}_${now.hour}_${now.minute}_${now.second}.pdf",
      );
      await file.writeAsBytes(await pdf.save());

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PDF başarıyla kaydedildi: ${file.path}')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Klasör bulunamadı')),
      );
    }
  }
}
