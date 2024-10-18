// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toyflow/screens/usersPage/dokaScreen/dokaEditScreen.dart';
import 'package:toyflow/services/product_services.dart';

import '../../../services/CustomAppBar.dart';

class DokaHomeScreen extends StatefulWidget {
  const DokaHomeScreen({super.key});

  @override
  State<DokaHomeScreen> createState() => _DokaHomeScreenState();
}

class _DokaHomeScreenState extends State<DokaHomeScreen> {
  final ProductServices productServices = Get.find();
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
          workshopName: "Dokuma Atölyesi", chatPage: DokaEditScreen()),
      body: Center(),
    );
  }
}
