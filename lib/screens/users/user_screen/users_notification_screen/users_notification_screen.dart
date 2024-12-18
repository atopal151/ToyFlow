
import 'package:flutter/material.dart';

class UsersNotificationScreen extends StatefulWidget {
  const UsersNotificationScreen({super.key});

  @override
  State<UsersNotificationScreen> createState() =>
      _UsersNotificationScreenState();
}

class _UsersNotificationScreenState extends State<UsersNotificationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Bildirimler"),
      ),
      body: const Center(
        child: Text(""),
      ),
    );
  }
}