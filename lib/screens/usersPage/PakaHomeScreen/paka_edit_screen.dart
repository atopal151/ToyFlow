// ignore_for_file: file_names

import 'package:flutter/material.dart';

class PakaEditScreen extends StatefulWidget {
  const PakaEditScreen({super.key});

  @override
  State<PakaEditScreen> createState() => _PakaEditScreenState();
}

class _PakaEditScreenState extends State<PakaEditScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
      ),
      body: const Center(
        child: Text("Paketleme Atölyesi Edit Sayfası"),
      ),
    );
  }
}