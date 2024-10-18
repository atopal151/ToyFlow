// ignore_for_file: file_names

import 'package:flutter/material.dart';

class DolaEditScreen extends StatefulWidget {
  const DolaEditScreen({super.key});

  @override
  State<DolaEditScreen> createState() => _DolaEditScreenState();
}

class _DolaEditScreenState extends State<DolaEditScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
      ),
      body: const Center(
        child: Text("Dolum Atölyesi Edit Ekranı"),
      ),
    );
  }
}
