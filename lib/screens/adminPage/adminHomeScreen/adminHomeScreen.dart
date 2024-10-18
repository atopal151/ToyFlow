// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toyflow/screens/adminPage/adminSettingScreen/adminSettingScreen.dart';
import 'package:toyflow/screens/usersPage/usersNotificationScreen/usersNotificationScreen.dart';
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Obx(() => Row(
              children: [
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AdminSettingScreen()),
                    );
                  },
                  child:  CircleAvatar(
                    backgroundColor: Colors.transparent,
                    radius: 25,
                    child: Icon(
                      Icons.face,
                      size: 35,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      "${productServices.firstName.value} ${productServices.lastName.value}", // Kullanıcının e-posta adresini göster
                      style: const TextStyle(fontSize: 15),
                    ),
                    const Text(
                      "Yönetici", // Kullanıcının e-posta adresini göster
                      style:  TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ],
            )),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const UsersNotificationScreen()),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.black,
                    width: 1.0,
                  ),
                ),
                padding: const EdgeInsets.all(8.0),
                child: const Icon(
                  Icons.notifications,
                  size: 15,
                  color: Colors.white,
                ),
              ),
            ),
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
