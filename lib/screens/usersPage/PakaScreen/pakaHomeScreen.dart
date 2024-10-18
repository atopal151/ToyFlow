// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toyflow/screens/usersPage/PakaScreen/pakaEditScreen.dart';
import 'package:toyflow/services/product_services.dart';

import '../../../services/CustomAppBar.dart';

class PakaHomeScreen extends StatefulWidget {
  const PakaHomeScreen({super.key});

  @override
  State<PakaHomeScreen> createState() => _PakaHomeScreenState();
}

class _PakaHomeScreenState extends State<PakaHomeScreen> {
  final ProductServices productServices = Get.find();
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
          workshopName: "Paketleme Atölyesi", chatPage: PakaEditScreen()),
      body: Center(),
    );
  }
}
