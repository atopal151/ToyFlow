// pdf_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

class PdfService {
  static Future<void> generatePdf(BuildContext context, String workshopName, List<Map<String, dynamic>> data) async {
    final pdf = pw.Document();
    final now = DateTime.now();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text("Atölye Verileri - $workshopName", style: const pw.TextStyle(fontSize: 24)),
              pw.SizedBox(height: 20),
              // ignore: deprecated_member_use
              pw.Table.fromTextArray(
                context: context,
                data: <List<String>>[
                  <String>['Ürün', 'Tarih', 'Miktar'],
                  ...data.map((work) => [
                        work['urun'] ?? 'Bilinmiyor',
                        work['tarih'] != null
                            ? DateFormat('dd.MM.yyyy').format(
                                (work['tarih'] as Timestamp).toDate(),
                              )
                            : 'Bilinmiyor',
                        work['miktar']?.toString() ?? 'Bilinmiyor',
                      ])
                ],
              ),
            ],
          );
        },
      ),
    );

    // Cihazın platformunu kontrol edin ve Android'de Downloads klasörüne kaydedin
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

      // Dosya kaydedildiğinde kullanıcıya bilgi ver
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
