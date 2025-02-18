import 'dart:math';

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
  bool isLoadingAll = false; // Yüklenme durumu
  bool isLoadingDate = false; // Yüklenme durumu
  String? selectedCheckDate = "Tümü";
  DateTime? selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    workshopService.fetchWorkAllshopStocks(); // Atölye stoklarını çekiyoruz
  }

  Future<void> _refreshPage() async {
    // Sayfayı yenileme işlemi
    setState(() {
      selectedCheckDate = "Tarih Seç"; // ✅ "Tarih Seç" seçili yap

      isLoadingDate = true;
      isLoadingAll = false;
    });

    await workshopService.fetchWorkshopStocks(selectedDate!);

    setState(() {
      isLoadingDate = false;
    });
  }

  Future<void> _refreshAllDataPage() async {
    setState(() {
      selectedCheckDate = "Tümü"; // ✅ "Tümü" seçili yap

      isLoadingAll = true;
      isLoadingDate = false;
    });

    await workshopService.fetchWorkAllshopStocks();

    setState(() {
      isLoadingAll = false;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate, // Varsayılan tarih olarak bugünü kullan
      firstDate: DateTime(2000), // Seçilebilecek en erken tarih
      lastDate: DateTime(2100), // Seçilebilecek en geç tarih
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Colors.black,
            hintColor: Colors.black,
            colorScheme: const ColorScheme.light(primary: Colors.black),
            buttonTheme:
                const ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
      await _refreshPage(); // Tarihi seçtikten sonra `_refreshPage` fonksiyonunu çağır.
    }
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
        onRefresh: _refreshAllDataPage, // Scroll aşağı çekildiğinde yenileme
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () => {
                      setState(() {
                        _refreshAllDataPage();
                      })
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: selectedCheckDate == "Tümü"
                            ? Colors.black
                            : Colors.grey[300],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: isLoadingAll
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              "Tümü",
                              style: TextStyle(
                                color: selectedCheckDate == "Tümü"
                                    ? Colors.white
                                    : Colors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () => _selectDate(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: selectedCheckDate == "Tarih Seç"
                            ? Colors.black
                            : Colors.grey[300],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: isLoadingDate
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              "Tarih Seç",
                              style: TextStyle(
                                color: selectedCheckDate == "Tarih Seç"
                                    ? Colors.white
                                    : Colors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
              Obx(() {
                if (isLoadingAll || isLoadingDate) {
                  return Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.black,
                    ),
                  );
                }

                if (workshopService.workshopStocks.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(
                          Icons.error_outline,
                          color: Colors.grey,
                          size: 80,
                        ),
                        SizedBox(height: 16),
                        Text(
                          "Seçilen tarihte veri bulunamadı.",
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                // En yüksek stok miktarını bul
                double maxStock =
                    workshopService.workshopStocks.values.isNotEmpty
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
                          sections: workshopService.workshopStocks.entries
                              .map((entry) {
                            // Rastgele renk üretmek için Random sınıfını kullan
                            final Random random = Random();
                            final Color randomColor = Color.fromARGB(
                              255, // Opaklık (her zaman 255, tamamen görünür)
                              random.nextInt(256), // Kırmızı (0-255)
                              random.nextInt(256), // Yeşil (0-255)
                              random.nextInt(256), // Mavi (0-255)
                            );

                            return PieChartSectionData(
                              value: entry.value,
                              title: "${entry.key}\n${entry.value.toInt()}",
                              color: randomColor, // Rastgele belirlenen renk
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

                    selectedCheckDate == "Tarih Seç"
                        ? Text(
                            "${selectedDate?.day}/${selectedDate?.month}/${selectedDate?.year}",
                            style: const TextStyle(fontSize: 18),
                          )
                        : Text("Tümü"),
                    const SizedBox(height: 20),
                    const Text(
                      "Atölye Stok Tablosu",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    // Tablo
                    ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: workshopService.workshopStocks.length,
                      itemBuilder: (context, index) {
                        final entry = workshopService.workshopStocks.entries
                            .toList()[index];
                        double progress =
                            entry.value / maxStock; // Progress hesaplama

                        // Satırı GestureDetector ile sarmalıyoruz
                        return GestureDetector(
                          onTap: () {
                            // Tıklanınca detay sayfasına yönlendirme
                            Get.to(() => WorkDetailScreen(
                                  selectedWorkshop: entry.key,
                                  date: selectedDate,
                                  dataType: selectedCheckDate,
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
                                            color: Color.fromARGB(
                                                255, 66, 143, 67)),
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
            ],
          ),
        ),
      ),
    );
  }
}
