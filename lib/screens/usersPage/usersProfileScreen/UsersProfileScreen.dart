import 'package:flutter/material.dart';

class UsersProfileScreen extends StatefulWidget {
  const UsersProfileScreen({super.key});

  @override
  State<UsersProfileScreen> createState() => _UsersProfileScreenState();
}

class _UsersProfileScreenState extends State<UsersProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(),
      body: const Center(child: Text("Users Profile Screen"),),);
  }
}