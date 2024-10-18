import 'package:flutter/material.dart';

class DikaEditScreen extends StatefulWidget {
  const DikaEditScreen({super.key});

  @override
  State<DikaEditScreen> createState() => _DikaEditScreenState();
}

class _DikaEditScreenState extends State<DikaEditScreen> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold( 
      backgroundColor: Colors.white,
      appBar: AppBar(),
      body: const Center(child: Text("Dikim Atölyesi Edit Ekranı"),),);
  }
}