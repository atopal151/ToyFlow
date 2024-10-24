// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toyflow/screens/usersPage/kesaHomeScreen/kesa_edit_screen.dart';
import 'package:toyflow/services/product_services.dart';

import '../../../services/custom_app_bar.dart';

class KesaHomeScreen extends StatefulWidget {
  const KesaHomeScreen({super.key});

  @override
  State<KesaHomeScreen> createState() => _KesaHomeScreenState();
}

class _KesaHomeScreenState extends State<KesaHomeScreen> {
  final ProductServices productServices = Get.find();
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
          workshopName: "Kesim Atölyesi", chatPage: KesaEditScreen()),
      body: Center(),
    );
  }
}