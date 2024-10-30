import 'package:flutter/material.dart';
import 'package:toyflow/screens/adminPage/adminWorkShopPage/work_detail_screen.dart';

class AdminWorkShopScreen extends StatefulWidget {
  const AdminWorkShopScreen({super.key});

  @override
  State<AdminWorkShopScreen> createState() => _AdminWorkShopScreenState();
}

class _AdminWorkShopScreenState extends State<AdminWorkShopScreen> {
  // ToyFlow atölye bilgileri, her biri için özel bir arka plan görseliyle
  final List<Map<String, dynamic>> workshops = [
    {
      'title': 'Dokuma Atölyesi',
      'icon': Icons.abc_sharp,
      'image': 'images/dokuma.webp'
    },
    {
      'title': 'Kesim Atölyesi',
      'icon': Icons.cut,
      'image': 'images/kesim.webp'
    },
    {
      'title': 'Dikim Atölyesi',
      'icon': Icons.ad_units,
      'image': 'images/dikim.webp'
    },
    {
      'title': 'Dolum Atölyesi',
      'icon': Icons.local_florist,
      'image': 'images/dolum.webp'
    },
    {
      'title': 'Paketleme Atölyesi',
      'icon': Icons.archive,
      'image': 'images/paketleme.webp'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Atölyeler",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // İki sütunlu grid
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1, // Kare görünüm
          ),
          itemCount: workshops.length,
          itemBuilder: (context, index) {
            final workshop = workshops[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        WorkDetailScreen(selectedWorkshop: workshop['title']),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  image: DecorationImage(
                    image: AssetImage(
                        workshop['image']), // Atölye için arka plan görseli
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                      Colors.black.withOpacity(0.3), // Görseli koyulaştırma
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
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Text(
                      workshop['title'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
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
