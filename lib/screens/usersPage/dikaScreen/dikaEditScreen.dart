// ignore_for_file: file_names

import 'package:flutter/material.dart';

class DikaEditScreen extends StatefulWidget {
  const DikaEditScreen({super.key});

  @override
  State<DikaEditScreen> createState() => _DikaEditScreenState();
}

class _DikaEditScreenState extends State<DikaEditScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
      ),
      body: const Center(
        child: Text("Dikim Atölyesi Edit Ekranı"),
      ),
    );
  }
}
