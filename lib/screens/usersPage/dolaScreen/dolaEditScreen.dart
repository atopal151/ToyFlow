import 'package:flutter/material.dart';

class DolaEditScreen extends StatefulWidget {
  const DolaEditScreen({super.key});

  @override
  State<DolaEditScreen> createState() => _DolaEditScreenState();
}

class _DolaEditScreenState extends State<DolaEditScreen> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(), 
      body: const Center(child: Text("Dolum Atölyesi Edit Ekranı"),),);
  }
}