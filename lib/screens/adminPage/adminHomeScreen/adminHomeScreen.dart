// ignore_for_file: file_names, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Firebase Auth'u ekle
import 'package:toyflow/screens/LoginScreen/loginScreen.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut(); // Kullanıcıyı oturumdan çıkar
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()), // Giriş ekranına yönlendir
      );
    } catch (e) {
      // Hata durumunda bir şey yap
      print("Oturum kapatma hatası: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Paneli"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout), // Çıkış ikonu
            onPressed: () => _logout(context), // Oturumu kapat
          ),
        ],
      ),
      body: const Center(
        child: Text("Admin Ana Sayfası"),
      ),
    );
  }
}
