import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:toyflow/screens/adminPage/new_work_shop/work_shop_add.dart';

class WorkShop extends StatefulWidget {
  const WorkShop({super.key});

  @override
  State<WorkShop> createState() => _WorkShopState();
}

class _WorkShopState extends State<WorkShop> {
  List<DocumentSnapshot> workshops = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchWorkshops();
  }

  Future<void> _fetchWorkshops() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('atolyeler').get();

      if (mounted) {
        setState(() {
          workshops = querySnapshot.docs;
          isLoading = false;
        });
      }
    } catch (e) {
      print("Atölyeler alınırken hata oluştu: $e");
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteWorkshop(String docId) async {
    try {
      await FirebaseFirestore.instance
          .collection('atolyeler')
          .doc(docId)
          .delete();
      setState(() {
        workshops.removeWhere((doc) => doc.id == docId);
      });
    } catch (e) {
      print("Atölye silinirken hata oluştu: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Atölyeler",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: InkWell(
              onTap: () => Get.to(const WorkShopNewAdd()),
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
          : workshops.isEmpty
              ? const Center(
                  child: Text(
                    "Hiç atölye bulunamadı.",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  itemCount: workshops.length,
                  itemBuilder: (context, index) {
                    final workshop = workshops[index];
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
                          workshop['name'] ?? "Atölye Adı Yok",
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Color.fromARGB(255, 201, 74, 74)),
                          onPressed: () {
                            _deleteWorkshop(workshop.id);
                          },
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
