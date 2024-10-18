import 'package:flutter/material.dart';

class DokaEditScreen extends StatefulWidget {
  const DokaEditScreen({super.key});

  @override
  State<DokaEditScreen> createState() => _DokaEditScreenState();
}

class _DokaEditScreenState extends State<DokaEditScreen> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(),     
      body: const Center(child: Text("Dokuma Atölyesi Edit Ekranı"),),);
  }
}