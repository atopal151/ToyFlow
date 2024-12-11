// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:toyflow/screens/adminPage/new_toy_add_screen/new_toy_add_screen.dart';
import '../../../services/user_component/dropdown_selector.dart';

class NewToyDetail extends StatefulWidget {
  const NewToyDetail({super.key});

  @override
  State<NewToyDetail> createState() => _NewToyDetailState();
}

class _NewToyDetailState extends State<NewToyDetail> {
  // Map olarak tablo isimleri
  final Map<String, String> tableNames = {
    'toy_aksesuar': "Aksesuarlar",
    'toy_height': "Boyutlar",
    'toy_renk': "Renkler",
    'fine': "Fine",
    'iplik': "İpler",
    'gramaj': "Gramaj",
    'denye': "Denye",
    'kumas': "Kumaşlar",
  };

  String? selectedTableKey; // Seçilen tablonun anahtarı (koleksiyon ismi)
  List<Map<String, dynamic>> currentData = [];

  Future<void> fetchTableData(String tableName) async {
    try {
      final querySnapshot =
          await FirebaseFirestore.instance.collection(tableName).get();
      final List<Map<String, dynamic>> fetchedData =
          querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();

      setState(() {
        currentData = fetchedData;
      });
    } catch (e) {
      print('Veri çekme hatası: $e');
    }
  }

  Future<void> deleteItem(String tableName, String docId) async {
    try {
      await FirebaseFirestore.instance
          .collection(tableName)
          .doc(docId)
          .delete();
      setState(() {
        currentData.removeWhere((item) => item['id'] == docId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Öğe başarıyla silindi')),
      );
    } catch (e) {
      print('Silme hatası: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silme işlemi başarısız')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detay'),
        actions: [
          InkWell(
            onTap: () => Get.to(() => const NewToyAddScreen()),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Icon(Icons.edit),
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownSelector(
            hintText: 'Bir tablo seçin',
            items: tableNames.values.toList(), // Görüntülenecek isimler
            selectedValue: selectedTableKey != null
                ? tableNames[selectedTableKey!] // Seçilen tablo adı
                : null,
            onChanged: (value) {
              if (value != null) {
                // Seçilen tablo anahtarını bul
                final selectedKey = tableNames.entries
                    .firstWhere((entry) => entry.value == value)
                    .key;

                setState(() {
                  selectedTableKey = selectedKey;
                  currentData = [];
                });

                // Verileri getir
                fetchTableData(selectedKey);
              }
            },
            icon: Icons.table_chart,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: currentData.isEmpty
                ? const Center(
                    child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: currentData.length,
                    itemBuilder: (context, index) {
                      final item = currentData[index];
                      return Column(
                        children: [
                          ListTile(
                            title: Padding(
                              padding:
                                  const EdgeInsets.only(left: 16.0, right: 16),
                              child: Text(
                                item.values.first.toString(),
                                style: const TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.w400),
                              ),
                            ),
                            trailing: IconButton(
                              icon:
                                  const Icon(Icons.delete, color: Colors.black),
                              onPressed: () {
                                if (selectedTableKey != null &&
                                    item['id'] != null) {
                                  deleteItem(selectedTableKey!, item['id']);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content:
                                            Text('Silme işlemi başarısız')),
                                  );
                                }
                              },
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.only(left: 16.0, right: 16),
                            child: Divider(),
                          )
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
