// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:toyflow/services/product_services.dart';
import '../../../services/custom_app_bar.dart';
import 'dika_edit_screen.dart';
import 'package:timeago/timeago.dart' as timeago;


class DikaHomeScreen extends StatefulWidget {
  const DikaHomeScreen({super.key});

  @override
  State<DikaHomeScreen> createState() => _DikaHomeScreenState();
}

class _DikaHomeScreenState extends State<DikaHomeScreen> {
  final ProductServices productServices = Get.find();
  final TextEditingController searchController = TextEditingController();
  RxString searchQuery = ''.obs;


@override
  void initState() {
    super.initState();
    // Türkçe dil desteğini ekleyin
    timeago.setLocaleMessages('tr', timeago.TrMessages());
  }

  Stream<List<Map<String, dynamic>>> getDikimStokData() {
    return FirebaseFirestore.instance
        .collection('dikim_stok')
        .orderBy('tarih',descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return {
          'urun': doc['urun'],
          'renk': doc['renk'],
          'boyut': doc['boyut'],
          'miktar': doc['miktar'],
          'tarih': doc['tarih'],
        };
      }).toList();
    });
  }

  Future<void> _refreshData() async {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        workshopName: "Dikim Atölyesi",
        chatPage: DikaEditScreen(),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Arama TextField'i
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white, // Arka plan rengini beyaz yapıyoruz
                      borderRadius: BorderRadius.circular(50),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 8,
                          offset: const Offset(0, 4), // Gölgenin pozisyonu
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: searchController,
                      onChanged: (value) {
                        searchQuery.value = value;
                      },
                      decoration: InputDecoration(
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 15),
                        prefixIcon: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: const BoxDecoration(
                              color: Colors.black,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.search,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                        hintText: 'Ara',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshData,
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: getDikimStokData(),
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

                  return Obx(() {
                    // searchQuery'ye göre veriyi filtrele
                    final dokumaStokList = snapshot.data!
                        .where((work) => work['urun']
                            .toString()
                            .toLowerCase()
                            .contains(searchQuery.value.toLowerCase()))
                        .toList();

                    return ListView.builder(
                      itemCount: dokumaStokList.length,
                      itemBuilder: (context, index) {
                        final work = dokumaStokList[index];
                        String eklemeTarihi = 'Bilinmiyor';

                        if (work['tarih'] != null) {
                          Timestamp timestamp = work['tarih'];
                          DateTime dateTime = timestamp.toDate();
                          eklemeTarihi =timeago.format(dateTime, locale: 'tr');
                        }

                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
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
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.asset(
                                    'images/dikim.webp', // Profil resmi
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  // Expanded kullanarak metnin alanı aşmamasını sağlıyoruz
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Dikilmiş ${work['urun']}",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                        softWrap:
                                            true, // Alt satıra geçmesini sağlar
                                        maxLines:
                                            2, // En fazla 2 satır gösterir
                                        overflow: TextOverflow
                                            .ellipsis, // 2 satırı aşarsa üç nokta ekler
                                      ),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.color_lens,
                                            color: Color.fromARGB(
                                                255, 207, 124, 118),
                                            size: 16,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            ' ${work['renk'] ?? 'Bilinmiyor'}',
                                            style:
                                                const TextStyle(fontSize: 12),
                                          ),
                                          const SizedBox(width: 10),
                                          const Icon(
                                            Icons.layers_sharp,
                                            color: Color.fromARGB(
                                                255, 81, 124, 146),
                                            size: 16,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            ' ${work['miktar'] ?? 'Bilinmiyor'} adet',
                                            style:
                                                const TextStyle(fontSize: 12),
                                          ),

                                          const SizedBox(width: 10),
                                          const Icon(
                                            Icons.straighten,
                                            color: Color.fromARGB(
                                                255, 207, 124, 118),
                                            size: 16,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                              ' ${work['boyut'] != null ? "${work['boyut']} cm" : 'Bilinmiyor'}',
                                            style:
                                                const TextStyle(fontSize: 12),
                                          ),
                                          const SizedBox(width: 10),
                                        ],
                                      ),const SizedBox(height: 5,),
                                      Text(
                                            eklemeTarihi,
                                            style:
                                                const TextStyle(fontSize: 10),
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
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
