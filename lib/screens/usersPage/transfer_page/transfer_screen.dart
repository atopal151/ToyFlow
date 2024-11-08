import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../services/custom_app_bar.dart';
import 'package:toyflow/screens/usersPage/transfer_page/stok_transfer_page.dart';
import 'transfer_detail_screen.dart'; // Detay sayfasını import etmeyi unutmayın

class TransferScreen extends StatefulWidget {
  const TransferScreen({super.key});

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final List<Map<String, dynamic>> workshops = [
    {
      'title': 'Paketleme Atölyesi',
      'image': 'images/depo.webp',
      'collection': 'paketleme_stok',
    },
    {
      'title': 'Denizli Ana Depo',
      'image': 'images/depo.webp',
      'collection': 'denizli_depo',
    },
    {
      'title': 'Almanya Depo',
      'image': 'images/depo.webp',
      'collection': 'almanya_depo',
    },
    {
      'title': 'İstanbul Depo',
      'image': 'images/depo.webp',
      'collection': 'istanbul_depo',
    },
  ];

  Future<int> fetchStockFromCollection(String collectionName) async {
    try {
      QuerySnapshot snapshot = await _firestore.collection(collectionName).get();

      int totalStock = snapshot.docs.fold<int>(0, (previousValue, doc) {
        final num miktar = doc['miktar'] ?? 0;
        return previousValue + miktar.toInt();
      });

      return totalStock;
    } catch (e) {
      print("Error fetching data from $collectionName: $e");
      return 0; // Eğer hata oluşursa varsayılan değer döndür
    }
  }

  Future<void> _refreshList() async {
    setState(() {});
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        workshopName: "Transfer Birimi",
        chatPage: StokTransfer(),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshList,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView.builder(
            itemCount: workshops.length,
            itemBuilder: (context, index) {
              final workshop = workshops[index];
              return FutureBuilder<int>(
                future: fetchStockFromCollection(workshop['collection']),
                builder: (context, snapshot) {
                  String occupancyText;
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    occupancyText = "Yükleniyor...";
                  } else if (snapshot.hasError) {
                    occupancyText = "Hata oluştu";
                  } else {
                    occupancyText = "Mevcut Stok: ${snapshot.data} adet";
                  }

                  return GestureDetector(
                    onTap: () {
                      // Detay sayfasına yönlendirme
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TransferDetailScreen(
                            title: workshop['title'],
                            collection: workshop['collection'],
                          ),
                        ),
                      );
                    },
                    child: _buildStockCardButton(
                      roomName: workshop['title'],
                      occupancy: occupancyText,
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildStockCardButton({
    required String roomName,
    required String occupancy,
  }) {
    return Container(
      height: 100,
      margin: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        image: const DecorationImage(
          image: AssetImage('images/depo.webp'),
          fit: BoxFit.fitWidth,
        ),
      ),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: Colors.black.withOpacity(0.6),
            ),
          ),
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      roomName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      occupancy,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
