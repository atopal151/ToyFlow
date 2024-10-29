import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DokaMoverScreen extends StatelessWidget {
  const DokaMoverScreen({super.key});

  Icon _getIcon(String islemTuru) {
    switch (islemTuru) {
      case "Stok Ekleme":
        return const Icon(Icons.add_circle, color: Colors.green);
      case "Stok Güncelleme":
        return const Icon(Icons.update, color: Colors.blue);
      case "Fire Kaydı":
        return const Icon(Icons.delete_rounded, color: Colors.red);
      case "Stok Düşümü":
        return const Icon(Icons.download, color: Colors.orange);
      default:
        return const Icon(Icons.info, color: Colors.grey);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Atölye Hareketleri',
          style: TextStyle(fontSize: 18),
        ),
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('dokuma_mover')
            .orderBy('tarih', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 130,
                    backgroundImage: AssetImage('images/empty.webp'),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text("Hareket Yok"),
                  )
                ],
              ),
            );
          }

          final hareketler = snapshot.data!.docs;

          return ListView.builder(
            itemCount: hareketler.length,
            itemBuilder: (context, index) {
              final hareket = hareketler[index];
              final tarih = (hareket['tarih'] as Timestamp).toDate();
              final formattedDate =
                  '${tarih.day}/${tarih.month}/${tarih.year} ${tarih.hour}:${tarih.minute}';
              final islemTuru = hareket['islemTuru'] as String;
              final aciklama = hareket['aciklama'] as String;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // İşlem türüne göre ikon
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          shape: BoxShape.circle,
                        ),
                        child: _getIcon(islemTuru),
                      ),
                      const SizedBox(width: 12),
                      // Orta kısımda işlem bilgisi
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              islemTuru,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$aciklama - $formattedDate',
                              style: const TextStyle(fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
