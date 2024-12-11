import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../../../services/user_component/dropdown_selector.dart';
import '../admin_work_shop_screen/work_detail_screen/work_module/work_shop_list_item.dart';
import '../toy_detail_screen/toy_detail_screen.dart';

class AdminSearchScreen extends StatefulWidget {
  const AdminSearchScreen({super.key});

  @override
  State<AdminSearchScreen> createState() => _AdminSearchScreenState();
}

class _AdminSearchScreenState extends State<AdminSearchScreen> {
  List<Map<String, dynamic>> allItems = [];
  List<Map<String, dynamic>> filteredItems = [];
  TextEditingController searchController = TextEditingController();
  String? _depoSelected;

  List<String> _depolar = [];
  List<String> _depoCollection = [];

  @override
  void initState() {
    super.initState();
    _fetchDepoData();
  }

  Future<void> _fetchDepoData() async {
    try {
      final querySnapshot =
          await FirebaseFirestore.instance.collection('depolar').get();
      List<String> depoNames = [];
      List<String> depoCollections = [];

      for (var doc in querySnapshot.docs) {
        depoNames.add(doc['title']);
        depoCollections.add(doc['collection']);
      }

      setState(() {
        _depolar = depoNames;
        _depoCollection = depoCollections;
        if (_depolar.isNotEmpty) {
          _depoSelected = _depolar.last;
          fetchData(_depoCollection.first);
        }
      });
    } catch (e) {
      print("Depo verileri alınırken hata oluştu: $e");
    }
  }

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
              DropdownSelector(
                hintText: 'Depo seç',
                items: _depolar,
                selectedValue: _depoSelected,
                onChanged: (String? newValue) {
                  setState(() {
                    _depoSelected = newValue;
                    final collectionIndex = _depolar.indexOf(newValue!);
                    final collectionName = _depoCollection[collectionIndex];
                    fetchData(collectionName);
                  });
                },
                icon: Icons.arrow_drop_down,
              ),
              const SizedBox(height: 10),
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
              const SizedBox(height: 10),
              Expanded(
                flex: 10,
                child: filteredItems.isEmpty
                    ? const Center(child: Text("Ürün bulunamadı"))
                    : ListView.builder(
                        itemCount: filteredItems.length,
                        itemBuilder: (context, index) {
                          final item = filteredItems[index];
                          return InkWell(
                            onTap: () {
                              print("object");
                              Get.to(() => ToyDetailScreen(
                                    urun: item['urun'],
                                    renk: item['renk'],
                                    boyut: item['boyut'],
                                    aksesuar: item['aksesuar'],
                                  ));
                            },
                            child: WorkshopListItem(
                              work: item,
                              atolye: _depoSelected,
                            ),
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
