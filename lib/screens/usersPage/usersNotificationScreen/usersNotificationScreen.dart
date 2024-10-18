// ignore_for_file: file_names

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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
      ),
      body: const Center(
        child: Text("Users Notificcation"),
      ),
    );
  }
}
