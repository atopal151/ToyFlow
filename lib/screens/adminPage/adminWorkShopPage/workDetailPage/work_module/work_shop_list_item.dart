import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class WorkshopListItem extends StatelessWidget {
  final Map<String, dynamic> work;

  const WorkshopListItem({super.key, required this.work});

  @override
  Widget build(BuildContext context) {
    String eklemeTarihi = 'Bilinmiyor';
    String miktarTarihi = 'Bilinmiyor';

    // 'tarih' alanını String formatına dönüştürme
    if (work['tarih'] is Timestamp) {
      DateTime dateTime = (work['tarih'] as Timestamp).toDate();
      eklemeTarihi = DateFormat('dd.MM.yyyy').format(dateTime);
    }

    // 'miktar' alanını String formatına dönüştürme
    if (work['miktar'] is Timestamp) {
      DateTime miktarDateTime = (work['miktar'] as Timestamp).toDate();
      miktarTarihi = DateFormat('dd.MM.yyyy').format(miktarDateTime);
    } else {
      // Eğer miktar bir sayı ise direkt 'miktarTarihi' olarak atıyoruz
      miktarTarihi = work['miktar'].toString();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    'images/depo.webp',
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      work['urun'] ?? 'Ürün Yok',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    if (work['boyut'] != null)
                      Text(
                        "${work['boyut']} cm",
                        style: const TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 12),
                      ),
                    Text(
                      eklemeTarihi, // 'tarih' değeri
                      style: const TextStyle(
                          fontWeight: FontWeight.w400, fontSize: 10),
                    ),
                    Text(
                      "$miktarTarihi Adet", // 'miktar' değeri
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                    // Diğer alanlar...
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
