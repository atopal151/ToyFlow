// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toyflow/services/auth_service.dart';

class DikaHomeScreen extends StatefulWidget {
  const DikaHomeScreen({super.key});

  @override
  State<DikaHomeScreen> createState() => _DikaHomeScreenState();
}

class _DikaHomeScreenState extends State<DikaHomeScreen> {
  final AuthService _authService = Get.find();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Dikim Atölyesi"),
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
