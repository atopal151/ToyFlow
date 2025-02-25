import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

class WorkshopListItem extends StatefulWidget {
  final Map<String, dynamic> work;
  final String? atolye;
  final VoidCallback? onTap;

  const WorkshopListItem(
      {super.key, required this.work, this.atolye, this.onTap});

  @override
  State<WorkshopListItem> createState() => _WorkshopListItemState();
}

class _WorkshopListItemState extends State<WorkshopListItem> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  @override
  void initState() {
    super.initState();
    timeago.setLocaleMessages('tr', timeago.TrMessages());
  }

  /// Firestore'dan ilgili ürünün fotoğraf URL'sini alır
  Future<String?> getToyPhoto(String urunAdi) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('toy_name')
          .where('name', isEqualTo: urunAdi)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.first['photo'];
      } else {
        print("Ürün bulunamadı: $urunAdi");
        return null;
      }
    } catch (e) {
      print("Fotoğraf alınırken hata oluştu: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    String eklemeTarihi = 'Bilinmiyor';
    String miktarTarihi = 'Bilinmiyor';

    if (widget.work['tarih'] is Timestamp) {
      DateTime dateTime = (widget.work['tarih'] as Timestamp).toDate();
      eklemeTarihi = timeago.format(dateTime, locale: 'tr');
    }

    if (widget.work['miktar'] is Timestamp) {
      DateTime miktarDateTime = (widget.work['miktar'] as Timestamp).toDate();
      miktarTarihi = DateFormat('dd.MM.yyyy').format(miktarDateTime);
    } else {
      miktarTarihi = widget.work['miktar'].toString();
    }
    final String urunAdi = widget.work['urun']; 
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
                // Fotoğraf için FutureBuilder
                FutureBuilder<String?>(
                  future: getToyPhoto(urunAdi),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return const Icon(Icons.error, size: 60);
                    } else if (snapshot.hasData && snapshot.data != null) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          snapshot.data!,
                          width: 60,
                          height: 90,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.broken_image, size: 60),
                        ),
                      );
                    } else {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.asset(
                          'images/kumas.webp',
                          width: 60,
                          height: 90,
                          fit: BoxFit.cover,
                        ),
                      );
                    }
                  },
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
                                    fontWeight: FontWeight.w500, fontSize: 12),
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
                                    fontWeight: FontWeight.w500, fontSize: 12),
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
                                    fontWeight: FontWeight.w500, fontSize: 12),
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
