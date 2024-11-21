import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../services/custom_app_bar.dart';
import 'package:toyflow/screens/users/transfer_screen/stok_transfer_screen.dart';
import 'transfer_detail_screen.dart';

class TransferScreen extends StatefulWidget {
  const TransferScreen({super.key});

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Map<String, dynamic>> workshops = [];

  @override
  void initState() {
    super.initState();
    _getDepolar(); // Dinamik olarak depoları al
  }

  // Dinamik olarak depoları Firestore'dan çeken fonksiyon
  Future<void> _getDepolar() async {
    try {
      final QuerySnapshot snapshot = await _firestore.collection('depolar').get();
      setState(() {
        workshops = snapshot.docs.map((doc) {
          return {
            'title': doc['title'],
            'image': doc['image'] ?? 'images/depo.webp', // Eğer image alanı yoksa varsayılan bir görsel ekleyin
            'collection': doc['collection'],
          };
        }).toList();
      });
    } catch (e) {
      print("Depolar alınırken hata oluştu: $e");
    }
  }

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
    await _getDepolar(); // Listeyi yenilediğimizde depoları tekrar çek
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
                      imagePath: workshop['image'], // Görsel yolunu dinamik olarak gönderiyoruz
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
    required String imagePath, // Dinamik olarak görsel yolu
  }) {
    return Container(
      height: 100,
      margin: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        image: DecorationImage(
          image: AssetImage(imagePath),
          fit: BoxFit.fitWidth,
        ),
      ),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: Colors.black.withOpacity(0.4),
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
