// ignore_for_file: file_names


import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toyflow/services/auth_service.dart';
import 'package:toyflow/services/product_services.dart';

class DolaHomeScreen extends StatefulWidget {
  const DolaHomeScreen({super.key});

  @override
  State<DolaHomeScreen> createState() => _DolaHomeScreenState();
}

class _DolaHomeScreenState extends State<DolaHomeScreen> {
  final AuthService _authService = Get.find();
  final ProductServices productServices=Get.find();
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
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
              icon: const Icon(Icons.settings,color: Colors.grey,),
              onPressed: () => {
                
              },
            ),
          ),
        ],),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Dolum Atölyesi"),
            IconButton(
              icon: const Icon(Icons.logout), // Çıkış ikonu
              onPressed: () async {
                await _authService.logout();
              }, // Oturumu kapat
            ),
          ],
        ),
      ),
    );
  }
}
