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
  final TextEditingController searchController = TextEditingController();
  RxString searchQuery = ''.obs;

  Stream<List<Map<String, dynamic>>> getDokumaStokData() {
    return FirebaseFirestore.instance
        .collection('dokuma_stok')
        .orderBy('kumas')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return {
          'kumas': doc['kumas'],
          'kumas_renk': doc['kumas_renk'],
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
        workshopName: "Dokuma Atölyesi",
        chatPage: DokaEditScreen(),
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

                  return Obx(() {
                    // searchQuery'ye göre veriyi filtrele
                    final dokumaStokList = snapshot.data!
                        .where((work) => work['kumas']
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
                          eklemeTarihi =
                              DateFormat('dd.MM.yyyy').format(dateTime);
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
                                Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.asset(
                                        'images/kumas.webp', // Profil resmi
                                        width: 60,
                                        height: 60,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          work['kumas'] ?? 'Kumaş Yok',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            const Icon(Icons.color_lens,
                                                color: Colors.amber, size: 16),
                                            const SizedBox(width: 4),
                                            Text(
                                              ' ${work['kumas_renk'] ?? 'Bilinmiyor'}',
                                              style:
                                                  const TextStyle(fontSize: 12),
                                            ),
                                            const SizedBox(width: 10),
                                            const Icon(Icons.layers_sharp,
                                                color: Colors.blueGrey,
                                                size: 16),
                                            const SizedBox(width: 4),
                                            Text(
                                              ' ${work['miktar'] ?? 'Bilinmiyor'} adet',
                                              style:
                                                  const TextStyle(fontSize: 12),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: const BoxDecoration(
                                    color: Colors.black,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.arrow_forward_ios,
                                    color: Colors.white,
                                    size: 12,
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
