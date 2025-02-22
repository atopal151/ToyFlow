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
  static Future<void> generateReportPdf(BuildContext context, String reportTitle, List<Map<String, dynamic>> data) async {
    final pdf = pw.Document();
    final now = DateTime.now();

    // Font yükleme
    final fontData = await rootBundle.load("assets/fonts/Roboto-Regular.ttf");
    final ttf = pw.Font.ttf(fontData.buffer.asByteData());

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                reportTitle,
                style: pw.TextStyle(font: ttf, fontSize: 24),
              ),
              pw.SizedBox(height: 20),
              pw.TableHelper.fromTextArray(
                context: context,
                headers: <String>[
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
                  'Açıklama',
                  'Tarih',
                ],
                data: data.map((report) => [
                  report['malzeme'] ?? '-',
                  report['islemTuru'] ?? '-',
                  report['atelye'] ?? '-',
                  report['miktar']?.toString() ?? '-',
                  report['renk'] ?? '-',
                  report['boyut'] ?? '-',
                  report['gramaj'] ?? '-',
                  report['fine'] ?? '-',
                  report['denye'] ?? '-',
                  report['aksesuar'] ?? '-',
                  report['aciklama'] ?? '-',
                  report['tarih'] != null
                      ? DateFormat('dd.MM.yyyy HH:mm').format((report['tarih'] as Timestamp).toDate())
                      : '-',
                ]).toList(),
                cellStyle: pw.TextStyle(font: ttf, fontSize: 10),
                headerStyle: pw.TextStyle(font: ttf, fontSize: 12, fontWeight: pw.FontWeight.bold),
                headerDecoration: pw.BoxDecoration(color: PdfColors.grey300),
                cellAlignment: pw.Alignment.centerLeft,
              ),
            ],
          );
        },
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
