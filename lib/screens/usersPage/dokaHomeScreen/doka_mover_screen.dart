import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DokaMoverScreen extends StatelessWidget {
  const DokaMoverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Atölye Hareketleri',
                        style: const TextStyle(fontSize: 18),),
        backgroundColor: Colors.white,
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
                    backgroundImage:
                        AssetImage('images/empty.webp'), // Profil resmi
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

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(
                    hareket['islemTuru'],
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Açıklama: ${hareket['aciklama']}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      Text(
                        'Tarih: $formattedDate',
                        style: const TextStyle(fontSize: 12),
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
