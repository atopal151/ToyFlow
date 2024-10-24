// ignore_for_file: file_names

import 'package:flutter/material.dart';

class DokaEditScreen extends StatefulWidget {
  const DokaEditScreen({super.key});

  @override
  State<DokaEditScreen> createState() => _DokaEditScreenState();
}

class _DokaEditScreenState extends State<DokaEditScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
      ),
      body: const Center(
        child: Text("Dokuma Atölyesi Edit Ekranı"),
      ),
    );
  }
}