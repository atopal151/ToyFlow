import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../adminWorkShopPage/workDetailPage/work_module/work_shop_list_item.dart';

class AdminSearchScreen extends StatefulWidget {
  const AdminSearchScreen({super.key});

  @override
  State<AdminSearchScreen> createState() => _AdminSearchScreenState();
}

class _AdminSearchScreenState extends State<AdminSearchScreen> {
  List<Map<String, dynamic>> allItems = []; // Firestore'dan alınan tüm veriler
  List<Map<String, dynamic>> filteredItems = []; // Filtrelenmiş veriler
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchData(); // Verileri çeker
  }

  // Firestore'dan verileri çekme
  Future<void> fetchData() async {
    try {
      final querySnapshot =
          await FirebaseFirestore.instance.collection('paketleme_stok').get();
      final data = querySnapshot.docs
          .map((doc) => doc.data())
          .toList();

      setState(() {
        allItems = data;
        filteredItems = allItems; // Başlangıçta tüm veriler gösterilir
      });
    } catch (e) {
      print("Veri alınırken hata oluştu: $e");
    }
  }

  // Arama fonksiyonu
  void searchItems(String query) {
    final results = allItems.where((item) {
      final itemName = item['urun'].toString().toLowerCase();
      final input = query.toLowerCase();
      return itemName.contains(input);
    }).toList();

    setState(() {
      filteredItems = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text(
        "Ürünler",
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
      )),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              
              // Arama TextField'i
              Expanded(
                flex: 1,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(50),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: searchController,
                    onChanged: (value) => searchItems(value),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(vertical: 15),
                      prefixIcon: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Container(
                          padding: const EdgeInsets.all(10),
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
              // Ürün Listesi
              const SizedBox(height: 10,),
              Expanded(
                flex: 10,
                child: filteredItems.isEmpty
                    ? const Center(child: Text("Ürün bulunamadı"))
                    : ListView.builder(
                        itemCount: filteredItems.length,
                        itemBuilder: (context, index) {
                          final item = filteredItems[index];
                          return WorkshopListItem(work: item);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
