// ignore_for_file: file_names

import 'package:flutter/material.dart';

class KesaEditScreen extends StatefulWidget {
  const KesaEditScreen({super.key});

  @override
  State<KesaEditScreen> createState() => _KesaEditScreenState();
}

class _KesaEditScreenState extends State<KesaEditScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
      ),
      body: const Center(
        child: Text("Kesim Atölyesi Edit Ekranı"),
      ),
    );
  }
}
