import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import 'new_storage_add.dart';

class Storage extends StatefulWidget {
  const Storage({super.key});

  @override
  State<Storage> createState() => _StorageState();
}

class _StorageState extends State<Storage> {
  List<DocumentSnapshot> storages = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStorages();
  }

  Future<void> _fetchStorages() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('depolar').get();

      if (mounted) {
        setState(() {
          storages = querySnapshot.docs;
          isLoading = false;
        });
      }
    } catch (e) {
      print("Depolar alınırken hata oluştu: $e");
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteStorage(String docId) async {
    try {
      await FirebaseFirestore.instance.collection('depolar').doc(docId).delete();
      setState(() {
        storages.removeWhere((doc) => doc.id == docId);
      });
    } catch (e) {
      print("Depo silinirken hata oluştu: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Depolar",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: InkWell(
              onTap: () => Get.to(const StorageNewAdd()),
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
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : storages.isEmpty
              ? const Center(
                  child: Text(
                    "Hiç depo bulunamadı.",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  itemCount: storages.length,
                  itemBuilder: (context, index) {
                    final storage = storages[index];
                    return Card(
                      color: Colors.white,
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.blueGrey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: const Icon(
                            Icons.work,
                            color: Colors.blueGrey,
                            size: 28,
                          ),
                        ),
                        title: Text(
                          storage['title'] ?? "Atölye Adı Yok",
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.grey),
                          onPressed: () {
                            _deleteStorage(storage.id);
                          },
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}