import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../services/user_services/product_services.dart';
import '../admin_setting_screen/admin_setting_screen.dart';
import '../admin_work_shop_screen/work_detail_screen/work_detail_screen.dart';
import '../mover_screen/mover_screen.dart';
import 'adminhome_services/work_shop_service.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  _AdminHomeScreenState createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  final ProductServices productServices = Get.find();
  final WorkshopService workshopService = Get.find();

  @override
  void initState() {
    super.initState();
    workshopService.fetchWorkshopStocks(); // Atölye stoklarını çekiyoruz
  }

  Future<void> _refreshPage() async {
    // Sayfayı yenileme işlemi
    await workshopService.fetchWorkshopStocks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            InkWell(
              onTap: () {
                Get.to(() => const AdminSettingScreen());
              },
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: CircleAvatar(
                  backgroundColor: Colors.transparent,
                  radius: 23,
                  backgroundImage: AssetImage('images/erkek.webp'),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${productServices.firstName.value} ${productServices.lastName.value}",
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                ),
                const Text(
                  "Yönetici",
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
        actions: [
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('movers')
                .where('okundu', isEqualTo: false)
                .snapshots(),
            builder: (context, snapshot) {
              int unreadCount =
                  snapshot.hasData ? snapshot.data!.docs.length : 0;

              return Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(13.0),
                    child: InkWell(
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Colors.black87,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.notifications,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      onTap: () {
                        Get.to(() => const MoverScreen());
                      },
                    ),
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      right: 8,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        child: Text(
                          unreadCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshPage, // Scroll aşağı çekildiğinde yenileme
        child: SingleChildScrollView(
          child: Obx(() {
            if (workshopService.workshopStocks.isEmpty) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            // En yüksek stok miktarını bul
            double maxStock = workshopService.workshopStocks.values.isNotEmpty
                ? workshopService.workshopStocks.values
                    .reduce((a, b) => a > b ? a : b)
                : 0;

            return Column(
              children: [
                // Pie Chart
                SizedBox(
                  height: 300, // Grafik boyutu
                  child: PieChart(
                    PieChartData(
                      sections:
                          workshopService.workshopStocks.entries.map((entry) {
                        // Renk paletini ayarlıyoruz
                        final List<Color> customColors = [
                          const Color.fromARGB(255, 233, 120, 50),
                          const Color.fromARGB(255, 170, 209, 239),
                          const Color.fromARGB(255, 213, 159, 77),
                          const Color.fromARGB(255, 211, 133, 225),
                          const Color.fromARGB(255, 220, 129, 123),
                          const Color.fromARGB(255, 105, 208, 109),
                          const Color.fromARGB(255, 101, 166, 219),
                          const Color.fromARGB(255, 231, 182, 109),
                          const Color.fromARGB(255, 183, 95, 198),
                          const Color.fromARGB(255, 139, 218, 142),
                          const Color.fromARGB(255, 44, 71, 93),
                          const Color.fromARGB(255, 87, 66, 34),
                          const Color.fromARGB(255, 86, 42, 93),
                        ];

                        // Renk paletindeki rengi seçiyoruz
                        final int index = workshopService.workshopStocks.keys
                            .toList()
                            .indexOf(entry.key);
                        final Color color =
                            customColors[index % customColors.length];

                        return PieChartSectionData(
                          value: entry.value,
                          title: "${entry.key}\n${entry.value.toInt()}",
                          color: color, // Belirlenen renk
                          radius: 80,
                          badgeWidget: InkWell(
                            onTap: () {
                              Get.to(
                                () => WorkDetailScreen(
                                  selectedWorkshop: entry.key,
                                ),
                              );
                            },
                            child:
                                const SizedBox(), // Boş widget, kullanılabilir
                          ),
                        );
                      }).toList(),
                      centerSpaceRadius: 50,
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                const Text(
                  "Atölye Stok Tablosu",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                // Tablo
                ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: workshopService.workshopStocks.length,
                  itemBuilder: (context, index) {
                    final entry =
                        workshopService.workshopStocks.entries.toList()[index];
                    double progress =
                        entry.value / maxStock; // Progress hesaplama

                    // Satırı GestureDetector ile sarmalıyoruz
                    return GestureDetector(
                      onTap: () {
                        // Tıklanınca detay sayfasına yönlendirme
                        Get.to(() => WorkDetailScreen(
                              selectedWorkshop: entry.key,
                            ));
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    entry.key,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    "${entry.value.toInt()} Adet",
                                    style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color:
                                            Color.fromARGB(255, 66, 143, 67)),
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 5),
                            // Progress Bar
                            LinearProgressIndicator(
                              value: progress,
                              backgroundColor: Colors.grey[300],
                              color: Colors.black,
                            ),
                            const SizedBox(height: 10),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
