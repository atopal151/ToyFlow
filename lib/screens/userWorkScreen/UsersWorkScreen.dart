import 'package:flutter/material.dart';

class UsersWorkScreen extends StatefulWidget {
  const UsersWorkScreen({super.key});

  @override
  State<UsersWorkScreen> createState() => _UsersWorkScreenState();
}

class _UsersWorkScreenState extends State<UsersWorkScreen> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(),
      body: const Center(child: Text("Bekleyen İşler")),);
  }
}