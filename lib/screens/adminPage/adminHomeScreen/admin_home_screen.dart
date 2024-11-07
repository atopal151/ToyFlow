// ignore_for_file: unrelated_type_equality_checks

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toyflow/screens/adminPage/adminSettingScreen/admin_setting_screen.dart';
import 'package:toyflow/screens/moverScreen/mover_screen.dart';
import '../../../services/product_services.dart';
import '../adminWorkShopPage/workDetailPage/work_detail_screen.dart';
import 'adminhome_services/adminhome_services.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  _AdminHomeScreenState createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  final ProductServices productServices = Get.find();
  final AdminHomeService adminHomeService = AdminHomeService();

  int dokumaAllStock = 0;
  int kesimAllStock = 0;
  int dikimAllStock = 0;
  int dolumAllStock = 0;
  int paketlemeAllStock = 0;

  String selectedFilter = "Gün"; // Varsayılan filtre
  int dokumaAtolyesiStock = 0;
  int kesimAtolyesiStock = 0;
  int dikimAtolyesiStock = 0;
  int dolumAtolyesiStock = 0;
  int paketlemeAtolyesiStock = 0;

  @override
  void initState() {
    super.initState();
    _loadStockData();
  }

  Future<void> _loadStockData() async {
    int dokumaStock = await adminHomeService.fetchDailyStockOperations("Dokuma");
    int kesimStock = await adminHomeService.fetchDailyStockOperations("Kesim");
    int dikimStock = await adminHomeService.fetchDailyStockOperations("Dikim");
    int dolumStock = await adminHomeService.fetchDailyStockOperations("Dolum");
    int paketlemeStock = await adminHomeService.fetchDailyStockOperations("Paketleme");

    int dokuma = await adminHomeService.fetchStockFromCollection("dokuma_stok");
    int kesim = await adminHomeService.fetchStockFromCollection("kesim_stok");
    int dikim = await adminHomeService.fetchStockFromCollection("dikim_stok");
    int dolum = await adminHomeService.fetchStockFromCollection("dolum_stok");
    int paketleme = await adminHomeService.fetchStockFromCollection("paketleme_stok");

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
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('movers')
                .where('okundu', isEqualTo: false) // Sadece okunmamış olanlar
                .snapshots(),
            builder: (context, snapshot) {
              int unreadCount = 0;
              if (snapshot.hasData) {
                unreadCount = snapshot.data!.docs.length;
              }

              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications, color: Colors.black,size: 30,),
                    onPressed: () {
                      Get.to(() => const MoverScreen());
                    },
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
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
                  const SizedBox(width: 10),
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
                        padding: EdgeInsets.all(3.0),
                        child: Icon(
                          Icons.refresh,
                          color: Colors.white,
                          size: 11,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Buraya atölye kartları ekleniyor
              _buildAtolyeRow("Dokuma Atölyesi", dokumaAllStock, dokumaAtolyesiStock),
              const SizedBox(height: 10,),
              _buildAtolyeRow("Kesim Atölyesi", kesimAllStock, kesimAtolyesiStock),
              const SizedBox(height: 10,),
              _buildAtolyeRow("Dikim Atölyesi", dikimAllStock, dikimAtolyesiStock),
              const SizedBox(height: 10,),
              _buildAtolyeRow("Dolum Atölyesi", dolumAllStock, dolumAtolyesiStock),
              const SizedBox(height: 10,),
              _buildAtolyeRow("Paketleme Atölyesi", paketlemeAllStock, paketlemeAtolyesiStock),
              const SizedBox(height: 20),
              const Text(
                "Depo Stok Miktarları",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              // Depo kartları burada eklenir
              _buildDepoRow("Denizli Depo", "Denizli/.......", "30.10.2024"),
              _buildDepoRow("İstanbul Depo", "İstanbul/......", "29.10.2024"),
              _buildDepoRow("Almanya Depo", "Almanya/.....", "31.10.2024"),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAtolyeRow(String title, int totalStock, int dailyStock) {
    return Row(
      children: [
        Expanded(
          child: _buildInfoCard(
              title, " $totalStock Adet", "Günlük İşlem: +$dailyStock kg/adet"),
        ),
      ],
    );
  }

  Widget _buildDepoRow(String roomName, String occupancy, String temperature) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Expanded(
          child: _buildStockCardButton(
            roomName: roomName,
            occupancy: occupancy,
            temperature: temperature,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(String title, String count, String percentage) {
    return InkWell(
      onTap: () {
        Get.to(() => WorkDetailScreen(selectedWorkshop: title));
      },
      child: Container(
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
                  Row(
                    children: [
                      const Text(
                        "Toplam Stok: ",
                        style:  TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w200,
                        ),
                      ),
                      Text(count)
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    percentage,
                    style: TextStyle(
                      fontSize: 12,
                      color: percentage != 'Günlük İşlem: +0 kg/adet'
                          ? const Color.fromARGB(255, 83, 158, 86)
                          : const Color.fromARGB(255, 207, 109, 102),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.8),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_forward_ios,
                color: Colors.white,
                size: 11,
              ),
            ),
          ],
        ),
      ),
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
          image: AssetImage('images/depo.webp'),
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
}
