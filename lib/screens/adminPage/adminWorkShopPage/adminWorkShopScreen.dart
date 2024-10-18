// ignore_for_file: file_names

import 'package:flutter/material.dart';

class AdminWorkShopScreen extends StatefulWidget {
  const AdminWorkShopScreen({super.key});

  @override
  State<AdminWorkShopScreen> createState() => _AdminWorkShopScreenState();
}

class _AdminWorkShopScreenState extends State<AdminWorkShopScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          backgroundColor: Colors.white,
          title: const Text(
            "Atölyeler",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
          )),
      body: const Center(
        child: Text("WorkShop"),
      ),
    );
  }
}
