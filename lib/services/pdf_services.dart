// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show rootBundle; // Yazı tipi dosyasını yüklemek için

class PdfService {
  static Future<void> generatePdf(BuildContext context, String workshopName, List<Map<String, dynamic>> data) async {
    final pdf = pw.Document();
    final now = DateTime.now();

    // Yazı tipini yükle
    final fontData = await rootBundle.load("assets/fonts/Roboto-Regular.ttf");
    final ttf = pw.Font.ttf(fontData.buffer.asByteData());

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                "$workshopName Stokları",
                style: pw.TextStyle(font: ttf, fontSize: 24),
              ),
              pw.SizedBox(height: 20),
              pw.TableHelper.fromTextArray(
                context: context,
                headers: <String>['Ürün', 'Renk','Boyut','Aksesuar','Ekleme Tarihi', 'Miktar'],
                data: data.map((work) => [
                  '${work['urun']}',
                  '${work['renk'] ?? " "}',
                  '${work['boyut'] ?? " "}',
                  '${work['aksesuar'] ?? " "}',
                  work['tarih'] != null
                      ? DateFormat('dd.MM.yyyy').format(
                          (work['tarih'] as Timestamp).toDate(),
                        )
                      : 'Bilinmiyor',
                  work['miktar']?.toString() ?? 'Bilinmiyor',
                ]).toList(),
                cellStyle: pw.TextStyle(font: ttf),
                headerStyle: pw.TextStyle(font: ttf, fontSize: 14, fontWeight: pw.FontWeight.bold),
              ),
            ],
          );
        },
      ),
    );

    Directory? directory;
    if (Platform.isAndroid) {
      directory = Directory('/storage/emulated/0/Download');
    } else if (Platform.isIOS) {
      directory = await getApplicationDocumentsDirectory();
    }

    if (directory != null) {
      final file = File(
          "${directory.path}/${workshopName}_verileri_${now.year}_${now.month}_${now.day}_${now.hour}_${now.minute}_${now.second}.pdf");
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
