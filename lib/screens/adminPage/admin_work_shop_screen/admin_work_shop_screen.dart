import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:toyflow/screens/adminPage/admin_work_shop_screen/work_detail_screen/work_detail_screen.dart';

import '../../../services/user_services/firestore_service.dart';
import '../admin_home_screen/adminhome_services/admin_home_services.dart';

class AdminWorkShopScreen extends StatefulWidget {
  const AdminWorkShopScreen({super.key});

  @override
  State<AdminWorkShopScreen> createState() => _AdminWorkShopScreenState();
}

class _AdminWorkShopScreenState extends State<AdminWorkShopScreen> {
  final AdminHomeService adminHomeService = AdminHomeService();

  List<Map<String, dynamic>> _atolyeList = [];
  List<int> _atolyeDailyCounts = [];
  bool _isAtolyeLoaded = false;

  @override
  void initState() {
    super.initState();
    if (!_isAtolyeLoaded) {
      _fetchAtolyeList();
    }
  }

  Future<void> _fetchAtolyeList() async {
    if (_isAtolyeLoaded) return; // Eğer zaten yüklenmişse tekrar çağırma

    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('atolyeler')
          .orderBy("name")
          .get();

      List<Map<String, dynamic>> fetchedAtolyeler =
          querySnapshot.docs.map((doc) {
        return {
          'name': doc['name'],
          'nitelik': doc['nitelik'],
          'collection': doc['collection'],
        };
      }).toList();

      // **Tüm günlük üretim miktarlarını paralel olarak al**
      List<Future<int>> dailyCountFutures = fetchedAtolyeler.map((atolye) {
        return adminHomeService.fetchDailyStockOperations(atolye['nitelik']);
      }).toList();

      List<int> fetchedDailyCounts = await Future.wait(dailyCountFutures);

      if (!mounted) return; // Eğer widget ekrandan kaldırılmışsa işlem yapma

      setState(() {
        _atolyeList = fetchedAtolyeler;
        _atolyeDailyCounts = fetchedDailyCounts;
        _isAtolyeLoaded = true;
      });
    } catch (e) {
      print("Atölyeler alınırken hata oluştu: $e");
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
      body: !_isAtolyeLoaded // Eğer atölyeler yüklenmemişse loading göster
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _atolyeList.isEmpty
              ? const Center(
                  child: Text(
                    "Hiç atölye bulunamadı.",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 1,
                        crossAxisSpacing: 8.0,
                        mainAxisSpacing: 8.0,
                        childAspectRatio: 1.6,
                      ),
                      itemCount: _atolyeList.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        final atolye = _atolyeList[index];
                        final dailyCount = _atolyeDailyCounts[index];
                        return _buildAtolyeRow(
                            atolye['name'], dailyCount, atolye['collection']);
                      },
                    ),
                  ),
                ),
    );
  }

  Widget _buildAtolyeRow(String name, int dailyCount, String collection) {
    const int maxCapacity = 10000;
    const int dailyGoal = 1000;
    double dailyProductionRate = (dailyCount / dailyGoal) * 100;
    return FutureBuilder<int>(
      future: FirestoreService().getTotalMiktar(collection),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }

        if (snapshot.hasError) {
          return Center(
            child: Text("Hata oluştu: ${snapshot.error}"),
          );
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return Center(
            child: Text("Veri bulunamadı."),
          );
        }

        // Toplam miktar ve doluluk oranı
      int totalMiktar = snapshot.data ?? 0;
      double totalCapacityRate = ((totalMiktar / maxCapacity) * 100).clamp(0, 100);

        return Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () {
                  Get.to(() => WorkDetailScreen(selectedWorkshop: name));
                },
                child: Container(
                  padding: const EdgeInsets.all(15.0),
                  margin: const EdgeInsets.symmetric(
                      horizontal: 4.0, vertical: 8.0),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color.fromARGB(255, 0, 0, 0),
                        Color.fromARGB(255, 0, 0, 0),
                        Color.fromARGB(255, 74, 74, 74),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    image: DecorationImage(
                      image: const AssetImage("images/atolyearkaplan.webp"),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                        Colors.white.withOpacity(0.2),
                        BlendMode.dstATop,
                      ),
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 3,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Günlük üretim miktarı barı
                            const Text("Günlük Üretim"),
                            const SizedBox(height: 4),
                            Stack(
                              children: [
                                Container(
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                Container(
                                  height: 10,
                                  width: (dailyProductionRate > 100
                                              ? 100
                                              : dailyProductionRate)
                                          .clamp(0, 100) *
                                      MediaQuery.of(context).size.width /
                                      100,
                                  decoration: BoxDecoration(
                                    color: Colors.blue,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "${dailyProductionRate.toStringAsFixed(1)}% tamamlandı",
                              style: const TextStyle(fontSize: 12),
                            ),
                            const SizedBox(height: 8),
                            // Toplam üretim miktarı barı
                            const Text("Toplam Üretim"),
                            const SizedBox(height: 4),
                            Stack(
                              children: [
                                Container(
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                Container(
                                  height: 10,
                                  width: (totalCapacityRate > 100
                                              ? 100
                                              : totalCapacityRate)
                                          .clamp(0, 100) *
                                      MediaQuery.of(context).size.width /
                                      100,
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "${totalCapacityRate.toStringAsFixed(1)}% kapasite dolu",
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildProgressBar(String title, double percentage, Color color) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title, style: const TextStyle(color: Colors.white, fontSize: 12)),
      const SizedBox(height: 4),
      Stack(
        children: [
          Container(
            height: 10,
            decoration: BoxDecoration(color: Colors.grey.withOpacity(0.3), borderRadius: BorderRadius.circular(10)),
          ),
          Container(
            height: 10,
            width: (percentage > 100 ? 100 : percentage)
                .clamp(0, 100) * MediaQuery.of(context).size.width / 100,
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)),
          ),
        ],
      ),
    ],
  );
}

}
