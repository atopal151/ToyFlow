// ignore_for_file: library_private_types_in_public_api

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
        title: Obx(() => Row(
          children: [
            const CircleAvatar(
              backgroundColor: Colors.transparent,
              radius: 25, // Avatarın büyüklüğü
              child: Icon(
                Icons.account_circle, // Koymak istediğin ikon
                size: 35, // İkonun boyutu
                color: Colors.black87, // İkonun rengi
              ),
            ),
            Text(
                  "${productServices.firstName.value} ${productServices.lastName.value}", // Kullanıcının e-posta adresini göster
                  style: const TextStyle(fontSize: 15),
                ),
          ],
        )),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings,color: Colors.grey,),
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
