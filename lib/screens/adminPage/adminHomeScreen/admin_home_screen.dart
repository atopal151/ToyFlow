// ignore_for_file: unrelated_type_equality_checks

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toyflow/screens/adminPage/adminSettingScreen/admin_setting_screen.dart';
import 'package:toyflow/screens/moverScreen/mover_screen.dart';
import '../../../services/product_services.dart';
import '../adminWorkShopPage/workDetailPage/work_detail_screen.dart';
import 'adminhome_services/adminhome_services.dart'; // AdminHomeService için eklenmiştir

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  _AdminHomeScreenState createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  final ProductServices productServices = Get.find();
  final AdminHomeService adminHomeService =
      AdminHomeService(); // AdminHomeService instance

  int dokumaAllStock = 0;
  int kesimAllStock = 0;
  int dikimAllStock = 0;
  int dolumAllStock = 0;
  int paketlemeAllStock = 0;

  String selectedFilter = "Gün"; // Varsayılan filtre
  int dokumaAtolyesiStock = 0; // Dokuma Atölyesi stoğunu tutacak değişken
  int kesimAtolyesiStock =
      0; // Geçici veri, diğer atölyeler için örnek değerler
  int dikimAtolyesiStock = 0;
  int dolumAtolyesiStock = 0;
  int paketlemeAtolyesiStock = 0;

  @override
  void initState() {
    super.initState();
    _loadStockData();
  }

  Future<void> _loadStockData() async {
    int dokumaStock =
        await adminHomeService.fetchDailyStockOperations("Dokuma");
    print("Dokuma stok: $dokumaStock"); // Debugging için

    int kesimStock = await adminHomeService.fetchDailyStockOperations("Kesim");
    print("Kesim stok: $kesimStock"); // Debugging için

    int dikimStock = await adminHomeService.fetchDailyStockOperations("Dikim");
    print("Dikim stok: $dikimStock"); // Debugging için

    int dolumStock = await adminHomeService.fetchDailyStockOperations("Dolum");
    print("Dolum stok: $dolumStock"); // Debugging için

    int paketlemeStock =
        await adminHomeService.fetchDailyStockOperations("Paketleme");
    print("Paketleme stok: $paketlemeStock"); // Debugging için

    int dokuma = await adminHomeService.fetchStockFromCollection("dokuma_stok");
    int kesim = await adminHomeService.fetchStockFromCollection("kesim_stok");
    int dikim = await adminHomeService.fetchStockFromCollection("dikim_stok");
    int dolum = await adminHomeService.fetchStockFromCollection("dolum_stok");
    int paketleme =
        await adminHomeService.fetchStockFromCollection("paketleme_stok");

    if (mounted) {
      setState(() {
        dokumaAtolyesiStock = dokumaStock;
        kesimAtolyesiStock = kesimStock;
        dikimAtolyesiStock = dikimStock;
        dolumAtolyesiStock = dolumStock;
        paketlemeAtolyesiStock = paketlemeStock;

        dokumaAllStock = dokuma;
        kesimAllStock = kesim;
        dikimAllStock = dikim;
        dolumAllStock = dolum;
        paketlemeAllStock = paketleme;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
                  style: const TextStyle(fontSize: 16, color: Colors.black),
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
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.black),
            onPressed: () {
              Get.to(() => const MoverScreen());
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Row(
                children: [
                  const Text(
                    "Günlük Aktivite",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  InkWell(
                    onTap: () {
                      _loadStockData();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.8),
                        shape: BoxShape.circle,
                      ),
                      child: const Padding(
                        // ignore: unnecessary_const
                        padding: const EdgeInsets.all(3.0),
                        child: Icon(
                          Icons.refresh, // Atölye ikonunu dinamik olarak göster
                          color: Colors.white,
                          size: 11,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: _buildInfoCard(
                        "Dokuma Atölyesi",
                        " $dokumaAllStock kg",
                        "Günlük İşlem: +$dokumaAtolyesiStock kg/adet"),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: _buildInfoCard(
                        "Kesim Atölyesi",
                        " $kesimAllStock Adet",
                        "Günlük İşlem: +$kesimAtolyesiStock kg/adet"),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: _buildInfoCard(
                        "Dikim Atölyesi",
                        " $dikimAllStock Adet",
                        "Günlük İşlem: +$dikimAtolyesiStock kg/adet"),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: _buildInfoCard(
                        "Dolum Atölyesi",
                        " $dolumAllStock Adet",
                        "Günlük İşlem: +$dolumAtolyesiStock kg/adet"),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: _buildInfoCard(
                        "Paketleme Atölyesi",
                        " $paketlemeAllStock Adet",
                        "Günlük İşlem: +$paketlemeAtolyesiStock kg/adet"),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Text(
                "Depo Stok Miktarları",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    child: _buildStockCardButton(
                      roomName: "Denizli Depo",
                      occupancy: "Denizli/.......",
                      temperature: "30.10.2024",
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    child: _buildStockCardButton(
                      roomName: "İstanbul Depo",
                      occupancy: "İstanbul/......",
                      temperature: "29.10.2024",
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    child: _buildStockCardButton(
                      roomName: "Almanya Depo",
                      occupancy: "Almanya/.....",
                      temperature: "31.10.2024",
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Hızlı Erişim Butonu
  Widget _buildQuickAccessButton(IconData icon, String label) {
    return Column(
      children: [
        CircleAvatar(
          backgroundColor: const Color.fromARGB(255, 207, 186, 124),
          radius: 25,
          child: Icon(icon, color: Colors.white),
        ),
        const SizedBox(height: 5),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildStockCardButton({
    required String roomName,
    required String occupancy,
    required String temperature,
  }) {
    return Container(
      height: 150,
      margin: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        image: const DecorationImage(
          image: AssetImage('images/depo.webp'), // Arka plan resmi
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: Colors.black.withOpacity(0.3),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  roomName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  occupancy,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 4.0,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.refresh, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            'Son güncelleme: $temperature',
                            style: const TextStyle(fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, String count, String percentage) {
    // Atölye bilgileri listesi
    final List<Map<String, dynamic>> workshops = [
      {
        'title': 'Dokuma Atölyesi',
      },
      {
        'title': 'Kesim Atölyesi',
      },
      {
        'title': 'Dikim Atölyesi',
      },
      {
        'title': 'Dolum Atölyesi',
      },
      {
        'title': 'Paketleme Atölyesi',
      },
    ];

    // İlgili atölyeyi bulma
    final workshop = workshops.firstWhere(
      (workshop) => workshop['title'] == title,
      orElse: () =>
          {'image': 'images/default.webp', 'icon': Icons.help_outline},
    );

    return Container(
      padding: const EdgeInsets.all(16.0),
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 3,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Atölye Resmi
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              percentage != "Günlük İşlem: +0 kg/adet"
                  ? "images/fullmov.webp"
                  : "images/emptymov.webp",
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 10),

          // Bilgi Bölümü
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Toplam Stok: $count",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w200,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  percentage,
                  style: TextStyle(
                    fontSize: 12,
                    color: percentage != 'Günlük İşlem: +0 kg/adet'
                        ? Colors.green
                        : Colors.red,
                  ),
                ),
              ],
            ),
          ),

          // İkon Butonu
          InkWell(
            onTap: () {
              Get.to(
                  () => WorkDetailScreen(selectedWorkshop: workshop['title']));
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.8),
                shape: BoxShape.circle,
              ),
              child: const Padding(
                // ignore: unnecessary_const
                padding: const EdgeInsets.all(3.0),
                child: Icon(
                  Icons
                      .arrow_forward_ios, // Atölye ikonunu dinamik olarak göster
                  color: Colors.white,
                  size: 11,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
