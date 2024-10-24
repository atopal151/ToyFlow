// ignore_for_file: file_names, avoid_print

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toyflow/services/product_services.dart';
import '../../../services/custom_app_bar.dart';
import 'dika_edit_screen.dart';

class DikaHomeScreen extends StatefulWidget {
  const DikaHomeScreen({super.key});

  @override
  State<DikaHomeScreen> createState() => _DikaHomeScreenState();
}

class _DikaHomeScreenState extends State<DikaHomeScreen> {
  final ProductServices productServices = Get.find();
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
          workshopName: "Dikim Atölyesi", chatPage: DikaEditScreen()),
      body: Center(),
    );
  }
}