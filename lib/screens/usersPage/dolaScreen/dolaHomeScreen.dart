// ignore_for_file: file_names


import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toyflow/services/product_services.dart';

import '../../../services/CustomAppBar.dart';
import 'dolaEditScreen.dart';

class DolaHomeScreen extends StatefulWidget {
  const DolaHomeScreen({super.key});

  @override
  State<DolaHomeScreen> createState() => _DolaHomeScreenState();
}

class _DolaHomeScreenState extends State<DolaHomeScreen> {
  final ProductServices productServices=Get.find();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
     appBar: CustomAppBar(workshopName: "Dolum Atölyesi",chatPage: const DolaEditScreen()),
      body: const Center(
        
      ),
    );
  }
}