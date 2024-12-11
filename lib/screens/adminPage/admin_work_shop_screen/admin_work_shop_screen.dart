import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:toyflow/screens/adminPage/admin_work_shop_screen/work_detail_screen/work_detail_screen.dart';

class AdminWorkShopScreen extends StatefulWidget {
  const AdminWorkShopScreen({super.key});

  @override
  State<AdminWorkShopScreen> createState() => _AdminWorkShopScreenState();
}

class _AdminWorkShopScreenState extends State<AdminWorkShopScreen> {
  List<Map<String, dynamic>> workshops = [];
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
          workshops = querySnapshot.docs.map((doc) {
            return {
              'title': doc['name'],
              'icon': Icons.settings,
              'image': 'images/toy.webp',
            };
          }).toList();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Atölyeler",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
        ),
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
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1,
                    ),
                    itemCount: workshops.length,
                    itemBuilder: (context, index) {
                      final workshop = workshops[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => WorkDetailScreen(
                                  selectedWorkshop: workshop['title']),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            image: DecorationImage(
                              image: AssetImage(workshop['image']),
                              fit: BoxFit.cover,
                              colorFilter: ColorFilter.mode(
                                Colors.black.withOpacity(0.7),
                                BlendMode.darken,
                              ),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(height: 8),
                              Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Text(
                                  workshop['title'],
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
