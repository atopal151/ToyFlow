import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;
class WorkshopListItem extends StatefulWidget {
  final Map<String, dynamic> work;
  final String? atolye;
  final VoidCallback? onTap; // onTap fonksiyonunu opsiyonel olarak ekledik

  const WorkshopListItem(
      {super.key, required this.work, this.atolye, this.onTap});

  @override
  State<WorkshopListItem> createState() => _WorkshopListItemState();
}

class _WorkshopListItemState extends State<WorkshopListItem> {
  @override
  void initState() {
    super.initState();
    timeago.setLocaleMessages('tr', timeago.TrMessages());
  }

  @override
  Widget build(BuildContext context) {
    String eklemeTarihi = 'Bilinmiyor';
    String miktarTarihi = 'Bilinmiyor';

    // 'tarih' alanını göreceli formatta dönüştürme
    if (widget.work['tarih'] is Timestamp) {
      DateTime dateTime = (widget.work['tarih'] as Timestamp).toDate();
      eklemeTarihi = timeago.format(dateTime, locale: 'tr'); // Göreceli tarih
    }

    // 'miktar' alanını String formatına dönüştürme
    if (widget.work['miktar'] is Timestamp) {
      DateTime miktarDateTime = (widget.work['miktar'] as Timestamp).toDate();
      miktarTarihi = DateFormat('dd.MM.yyyy').format(miktarDateTime);
    } else {
      miktarTarihi = widget.work['miktar'].toString();
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
                    widget.atolye=="Dokuma Atölyesi"?"images/peluskumas.webp": widget.atolye=="Boyama Atölyesi"?"images/peluskumas.webp":
                    'images/toy.webp',
                    width: 60,
                    height: 90,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.work['urun'] ?? 'Ürün Yok',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "$miktarTarihi Adet",
                      style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          color: Color.fromARGB(255, 97, 190, 106)),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        if (widget.work['renk'] != null)
                          Row(
                            children: [
                              Text(
                                "Renk: " + widget.work['renk'],
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12),
                              ),
                              const SizedBox(width: 10),
                            ],
                          ),
                        if (widget.work['fine'] != null)
                          Row(
                            children: [
                              Text(
                                "Fine: " + widget.work['fine'],
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12),
                              ),
                              const SizedBox(width: 10),
                            ],
                          ),
                        if (widget.work['boyut'] != null)
                          Row(
                            children: [
                              Text(
                                "Boyut: ${widget.work['boyut']}",
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12),
                              ),
                              const SizedBox(height: 4),
                            ],
                          ),
                      ],
                    ),
                    if (widget.work['gramaj'] != null)
                      Row(
                        children: [
                          Text(
                            "Gramaj: " + widget.work['gramaj'],
                            style: const TextStyle(
                                fontWeight: FontWeight.w500, fontSize: 12),
                          ),
                          const SizedBox(width: 10),
                        ],
                      ),
                    if (widget.work['aksesuar'] != null)
                      Row(
                        children: [
                          Text(
                            "Aksesuar: ${widget.work['aksesuar']}",
                            style: const TextStyle(
                                fontWeight: FontWeight.w500, fontSize: 12),
                          ),
                        ],
                      ),
                    const SizedBox(height: 6),
                    Text(
                      "Son Güncelleme: $eklemeTarihi",
                      style: const TextStyle(
                          fontWeight: FontWeight.w400, fontSize: 10),
                    ),
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
