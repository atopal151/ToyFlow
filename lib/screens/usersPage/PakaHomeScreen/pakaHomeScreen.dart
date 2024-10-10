// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toyflow/services/auth_service.dart';
import 'package:toyflow/services/product_services.dart';

class PakaHomeScreen extends StatefulWidget {
  const PakaHomeScreen({super.key});

  @override
  State<PakaHomeScreen> createState() => _PakaHomeScreenState();
}

class _PakaHomeScreenState extends State<PakaHomeScreen> {
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
              radius: 25, 
              child: Icon(
                Icons.account_circle, 
                size: 35, 
                color: Colors.black87, 
              ),
            ),
            Text(
                  "${productServices.firstName.value} ${productServices.lastName.value}", 
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
            const Text("Paketleme Atölyesi"),
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await _authService.logout();
              },
            ),
          ],
        ),
      ),
    );
  }
}
