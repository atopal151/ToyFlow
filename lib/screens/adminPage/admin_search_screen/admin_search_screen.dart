import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../services/user_services/dropdown_selector.dart';
import '../admin_work_shop_screen/work_detail_screen/work_module/work_shop_list_item.dart';

class AdminSearchScreen extends StatefulWidget {
  const AdminSearchScreen({super.key});

  @override
  State<AdminSearchScreen> createState() => _AdminSearchScreenState();
}

class _AdminSearchScreenState extends State<AdminSearchScreen> {

  List<Map<String, dynamic>> allItems = []; // Firestore'dan alınan tüm veriler
  List<Map<String, dynamic>> filteredItems = []; // Filtrelenmiş veriler
  TextEditingController searchController = TextEditingController();
  String? _depoSelected;

  List<String> _depolar = []; // Depo isimleri listesi
  List<String> _depoCollection = []; // Depo collection isimleri listesi

  @override
  void initState() {
    super.initState();
    _fetchDepoData(); // Depo isimlerini ve collection verilerini çekiyoruz
  }

  Future<void> _fetchDepoData() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('depolar')
          .get(); // Depolar koleksiyonundan verileri çek
      List<String> depoNames = [];
      List<String> depoCollections = [];

      for (var doc in querySnapshot.docs) {
        depoNames.add(doc['title']);
        depoCollections.add(doc['collection']);
      }

      setState(() {
        _depolar = depoNames;
        _depoCollection = depoCollections;
      });
    } catch (e) {
      print("Depo verileri alınırken hata oluştu: $e");
    }
  }

  // Firestore'dan verileri çekme
  Future<void> fetchData(String? collectionName) async {
    if (collectionName == null) return;
    try {
      final querySnapshot =
          await FirebaseFirestore.instance.collection(collectionName).get();
      final data = querySnapshot.docs
          .where((doc) => doc['miktar'] != 0)
          .map((doc) => doc.data())
          .toList();

      setState(() {
        allItems = data;
        filteredItems = allItems;
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
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              Expanded(
                flex: 1,
                child: DropdownSelector(
                  hintText: 'Depo seç',
                  items: _depolar,
                  selectedValue: _depoSelected,
                  onChanged: (String? newValue) {
                    setState(() {
                      _depoSelected = newValue;
                      final collectionIndex =
                          _depolar.indexOf(newValue!); // Seçilen depo indexi
                      final collectionName = _depoCollection[collectionIndex];
                      fetchData(collectionName); // Seçilen collection ile veri çekme
                    });
                  },
                  icon: Icons.arrow_drop_down,
                ),
              ),
              const SizedBox(height: 10),
              // Arama TextField'i
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: searchController,
                    onChanged: (value) => searchItems(value),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Colors.grey,
                        size: 20,
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
              const SizedBox(height: 10),
              Expanded(
                flex: 10,
                child: filteredItems.isEmpty
                    ? const Center(child: Text("Ürün bulunamadı"))
                    : ListView.builder(
                        itemCount: filteredItems.length,
                        itemBuilder: (context, index) {
                          final item = filteredItems[index];
                          return WorkshopListItem(
                            work: item,
                            atolye: _depoSelected,
                          );
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
