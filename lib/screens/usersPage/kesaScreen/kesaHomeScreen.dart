// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toyflow/screens/usersPage/kesaScreen/kesaEditScreen.dart';
import 'package:toyflow/services/product_services.dart';

import '../../../services/CustomAppBar.dart';

class KesaHomeScreen extends StatefulWidget {
  const KesaHomeScreen({super.key});

  @override
  State<KesaHomeScreen> createState() => _KesaHomeScreenState();
}

class _KesaHomeScreenState extends State<KesaHomeScreen> {
  final ProductServices productServices = Get.find();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
    
     appBar: CustomAppBar(workshopName: "Kesim Atölyesi",chatPage: const  KesaEditScreen()),
      body: const Center(
      ),
    );
  }
}
