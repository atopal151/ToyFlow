import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:toyflow/screens/adminPage/stock_screen/stock_add_screen.dart';

class StockScreen extends StatefulWidget {
  const StockScreen({super.key});

  @override
  State<StockScreen> createState() => _StockScreenState();
}

class _StockScreenState extends State<StockScreen> {
  final searchQuery = ''.obs;

  Stream<List<Map<String, dynamic>>> getDokumaStokData() {
    return FirebaseFirestore.instance.collection('dokuma_work').snapshots().map(
        (snapshot) => snapshot.docs
            .where((doc) => doc['miktar'] != 0)
            .map((doc) => {...doc.data(), 'id': doc.id})
            .toList());
  }

  Future<void> _refreshData() async {
    // Veri yenileme işlemleri burada yapılabilir
  }

  Future<void> _deleteStock(String docId) async {
    try {
      await FirebaseFirestore.instance.collection('dokuma_work').doc(docId).delete();
    } catch (e) {
      print("Stok silinirken hata oluştu: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Dokuma Stok Durumu",
          style: TextStyle(fontSize: 15),
        ),
        actions: [
          InkWell(
            onTap: () {
              Get.to(() => const StockAddScreen());
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 0, 0, 0),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.edit,
                  color: Colors.white,
                  size: 15,
                ),
              ),
            ),
          )
        ],
      ),
      body: RefreshIndicator(
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                              'images/box.webp', 
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${work['urun']}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                  softWrap: true,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.layers_sharp,
                                      color: Color.fromARGB(255, 81, 124, 146),
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      ' ${work['miktar'] ?? 'Bilinmiyor'} kg/adet',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                     const SizedBox(width: 4),
                                    const Icon(
                                      Icons.texture,
                                      color: Color.fromARGB(255, 146, 109, 81),
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      ' ${work['denye'] ?? 'Bilinmiyor'}',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  eklemeTarihi,
                                  style: const TextStyle(fontSize: 10),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.blueGrey,
                            ),
                            onPressed: () {
                              _deleteStock(work['id']);
                            },
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
    );
  }
}
