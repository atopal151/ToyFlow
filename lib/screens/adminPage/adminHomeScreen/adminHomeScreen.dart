import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toyflow/screens/adminPage/adminSettingScreen/adminSettingScreen.dart';
import '../../../services/product_services.dart'; // Servisi içe aktar

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  _AdminHomeScreenState createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  // ProductServices kontrolörünü al
  final ProductServices productServices = Get.find();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(
              productServices.userEmail.value, // Kullanıcının e-posta adresini göster
              style: const TextStyle(fontSize: 20),
            )),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AdminSettingScreen()),
              ),
            },
          ),
        ],
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            Text("Admin Ana Sayfası"),
          ],
        ),
      ),
    );
  }
}
