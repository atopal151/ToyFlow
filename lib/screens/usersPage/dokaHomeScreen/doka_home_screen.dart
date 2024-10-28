// ignore_for_file: file_names, depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:toyflow/screens/usersPage/dokaHomeScreen/doka_edit_screen.dart';
import 'package:toyflow/services/product_services.dart';
import '../../../services/custom_app_bar.dart';

class DokaHomeScreen extends StatefulWidget {
  const DokaHomeScreen({super.key});

  @override
  State<DokaHomeScreen> createState() => _DokaHomeScreenState();
}

class _DokaHomeScreenState extends State<DokaHomeScreen> {
  final ProductServices productServices = Get.find();

  // Firestore'dan 'dokuma_stok' verilerini çekmek için bir Stream fonksiyonu
  Stream<List<Map<String, dynamic>>> getDokumaStokData() {
    return FirebaseFirestore.instance
        .collection('dokuma_stok')
        .orderBy('kumas')
        .snapshots()
        .map(
      (snapshot) {
        return snapshot.docs.map((doc) {
          return {
            'kumas': doc['kumas'],
            'kumas_renk': doc['kumas_renk'],
            'miktar': doc['miktar'],
            'tarih': doc['tarih'],
          };
        }).toList();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(
        workshopName: "Dokuma Atölyesi",
        chatPage: DokaEditScreen(),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: getDokumaStokData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Hata: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Veri bulunamadı.'));
          }

          final dokumaStokList = snapshot.data!;

          return ListView.builder(
            itemCount: dokumaStokList.length,
            itemBuilder: (context, index) {
              final work = dokumaStokList[index];
              String eklemeTarihi = 'Bilinmiyor';

              if (work['tarih'] != null) {
                Timestamp timestamp = work['tarih'];
                DateTime dateTime = timestamp.toDate();
                eklemeTarihi = DateFormat('dd.MM.yyyy').format(dateTime);
              }

              return Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
                child: Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: Colors.grey,
                        width: 1.5), // Çerçeve rengi ve kalınlığı
                    borderRadius: BorderRadius.circular(15), // Köşe yuvarlama
                    color: Colors.white, // Arka plan rengi
                  ),
                  child: ListTile(
                    leading: const CircleAvatar(
                    radius: 10,
                    backgroundImage:
                        AssetImage('images/empty.webp'), // Profil resmi
                  ),
                    title: Text(
                      work['kumas'] ?? 'Kumaş Yok',
                      style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 15),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Renk: ${work['kumas_renk'] ?? 'Bilinmiyor'}'),
                        Text(
                          'Son Güncelleme Tarihi: $eklemeTarihi',
                          style: const TextStyle(fontSize: 10),
                        ),
                      ],
                    ),
                    trailing: Text('Miktar: ${work['miktar'] ?? 0} kg'),
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
