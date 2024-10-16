import 'package:flutter/material.dart';

class PakaEditScreen extends StatefulWidget {
  const PakaEditScreen({super.key});

  @override
  State<PakaEditScreen> createState() => _PakaEditScreenState();
}

class _PakaEditScreenState extends State<PakaEditScreen> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(),
      body: const Center(child: Text("Paketleme Atölyesi Edit Sayfası"),),);
  }
}