// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:toyflow/services/user_services/product_services.dart';
import '../../../services/user_services/custom_app_bar.dart';
import 'atolye_edit_screen.dart';
import 'package:timeago/timeago.dart' as timeago;

class AtolyeHomeScreen extends StatefulWidget {
  const AtolyeHomeScreen({super.key});

  @override
  State<AtolyeHomeScreen> createState() => _AtolyeHomeScreenState();
}

class _AtolyeHomeScreenState extends State<AtolyeHomeScreen> {
  final ProductServices productServices = Get.find();
  final TextEditingController searchController = TextEditingController();
  RxString searchQuery = ''.obs;

  @override
  void initState() {
    super.initState();
    // Türkçe dil desteğini ekleyin
    timeago.setLocaleMessages('tr', timeago.TrMessages());
  }

  Stream<List<Map<String, dynamic>>> getStokData() async* {
    // Kullanıcının atölye ismine göre 'collection' alanını getir
    final workshopName = productServices.workshopName.value;

    try {
      // Atolyeler koleksiyonunda workshopName ile eşleşen belgeyi getir
      final querySnapshot = await FirebaseFirestore.instance
          .collection('atolyeler')
          .where('name', isEqualTo: workshopName)
          .get();

      if (querySnapshot.docs.isEmpty) {
        throw Exception('Atölye bulunamadı!');
      }

      // İlk belgeyi al ve 'collection' alanını oku
      final collectionName = querySnapshot.docs.first.data()['collection'];

      // Dinamik olarak koleksiyondan veri çek
      if (productServices.role.value == "Dokuma") {
        yield* FirebaseFirestore.instance
            .collection(collectionName)
            .orderBy('tarih', descending: true)
            .snapshots()
            .map((snapshot) {
          return snapshot.docs.where((doc) => doc['miktar'] != 0).map((doc) {
            return {
              'urun': doc['urun'],
              'gramaj': doc['gramaj'],
              'fine': doc['fine'],
              'miktar': doc['miktar'],
              'tarih': doc['tarih'],
            };
          }).toList();
        });
      }
      if (productServices.role.value == "Boyama") {
        yield* FirebaseFirestore.instance
            .collection(collectionName)
            .orderBy('tarih', descending: true)
            .snapshots()
            .map((snapshot) {
          return snapshot.docs.where((doc) => doc['miktar'] != 0).map((doc) {
            return {
              'urun': doc['urun'],
              'renk': doc['renk'],
              'gramaj': doc['gramaj'],
              'fine': doc['fine'],
              'miktar': doc['miktar'],
              'tarih': doc['tarih'],
            };
          }).toList();
        });
      }
      if (productServices.role.value == "Kesim" ||
          productServices.role.value == "Dikim" ||
          productServices.role.value == "Dolum") {
        yield* FirebaseFirestore.instance
            .collection(collectionName)
            .orderBy('tarih', descending: true)
            .snapshots()
            .map((snapshot) {
          return snapshot.docs.where((doc) => doc['miktar'] != 0).map((doc) {
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
      if (productServices.role.value == "Paketleme") {
        yield* FirebaseFirestore.instance
            .collection(collectionName)
            .orderBy('tarih', descending: true)
            .snapshots()
            .map((snapshot) {
          return snapshot.docs.where((doc) => doc['miktar'] != 0).map((doc) {
            return {
              'urun': doc['urun'],
              'renk': doc['renk'],
              'boyut': doc['boyut'],
              'aksesuar': doc['aksesuar'],
              'miktar': doc['miktar'],
              'tarih': doc['tarih'],
            };
          }).toList();
        });
      }
    } catch (e) {
      print('Hata: $e');
      yield [];
    }
  }

  // Resmi belirleyen bir fonksiyon
  String getImageForRole(String role) {
    switch (role) {
      case "Dokuma":
        return 'images/dokuma.webp';
      case "Kesim":
        return 'images/kesim.webp';
      case "Dikim":
        return 'images/dikim.webp';
      case "Boyama":
        return 'images/boyama.webp';
      case "Dolum":
        return 'images/dolum.webp';
      case "Paketleme":
        return 'images/paketleme.webp';
      default:
        return 'images/backgorund.webp'; // Varsayılan resim
    }
  }

  // Resmi belirleyen bir fonksiyon
  String getTextForRole(String role) {
    switch (role) {
      case "Dokuma":
        return 'Dokunmuş';
      case "Kesim":
        return 'Kesilmiş';
      case "Dikim":
        return 'Dikilmiş';
      case "Boyama":
        return 'Boyanmış';
      case "Dolum":
        return 'Doldurulmuş';
      case "Paketleme":
        return '';
      default:
        return ''; // Varsayılan resim
    }
  }

  Future<void> _refreshData() async {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        workshopName: productServices.workshopName.value,
        chatPage: const AtolyeEditScreen(),
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
                stream: getStokData(),
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
                          eklemeTarihi = timeago.format(dateTime, locale: 'tr');
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
                                    getImageForRole(productServices.role
                                        .value), // Dinamik olarak resim belirle
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
                                        "${getTextForRole(productServices.role.value)} ${work['urun']}",
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
                                            Icons.shopping_cart,
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
                                          if (productServices.role.value == "Kesim" ||
                                              productServices.role.value ==
                                                  "Boyama" ||
                                              productServices.role.value ==
                                                  "Dikim" ||
                                              productServices.role.value ==
                                                  "Dolum" ||
                                              productServices.role.value ==
                                                  "Paketleme" ||
                                              productServices.role.value ==
                                                  "Transfer") ...[
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
                                          ],
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      Row(
                                        children: [
                                          if (productServices.role.value == "Kesim" ||
                                              productServices.role.value ==
                                                  "Dikim" ||
                                              productServices.role.value ==
                                                  "Dolum" ||
                                              productServices.role.value ==
                                                  "Paketleme" ||
                                              productServices.role.value ==
                                                  "Transfer") ...[
                                            const Icon(
                                              Icons.straighten,
                                              color: Color.fromARGB(
                                                  255, 225, 191, 66),
                                              size: 16,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              ' ${work['boyut'] != null ? "${work['boyut']}" : 'Bilinmiyor'}',
                                              style:
                                                  const TextStyle(fontSize: 12),
                                            ),
                                            const SizedBox(width: 4),
                                          ],
                                          if (productServices.role.value ==
                                                  "Dokuma" ||
                                              productServices.role.value ==
                                                  "Boyama") ...[
                                            const Icon(
                                              Icons.scale,
                                              color: Color.fromARGB(
                                                  255, 225, 191, 66),
                                              size: 16,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              ' ${work['gramaj'] != null ? "${work['gramaj']}" : 'Bilinmiyor'}',
                                              style:
                                                  const TextStyle(fontSize: 12),
                                            ),
                                            const SizedBox(width: 4),
                                            const Icon(
                                              Icons.linear_scale,
                                              color: Color.fromARGB(255, 75, 172, 68),
                                              size: 16,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              ' ${work['fine'] != null ? "${work['fine']} fine" : 'Bilinmiyor'}',
                                              style:
                                                  const TextStyle(fontSize: 12),
                                            ),
                                          ],
                                        ],
                                      ),
                                      if (productServices.role.value ==
                                              "Paketleme"||
                                          productServices.role.value ==
                                              "Transfer") ...[
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.style,
                                              color: Color.fromARGB(
                                                  255, 225, 191, 66),
                                              size: 16,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              ' ${work['aksesuar'] != null ? "${work['aksesuar']}" : 'Bilinmiyor'}',
                                              style:
                                                  const TextStyle(fontSize: 12),
                                            ),
                                            const SizedBox(width: 4),
                                          ],
                                        ),
                                      ],
                                      const SizedBox(height: 5),
                                      Text(
                                        eklemeTarihi,
                                        style: const TextStyle(fontSize: 10),
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
