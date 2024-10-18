// ignore_for_file: use_build_context_synchronously, avoid_print, unused_element

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toyflow/services/auth_service.dart';

import '../../../services/product_services.dart';
import '../../LoginScreen/loginScreen.dart';
import '../../registerPage/registerScreen.dart';

class AdminSettingScreen extends StatefulWidget {
  const AdminSettingScreen({super.key});

  @override
  State<AdminSettingScreen> createState() => _AdminSettingScreenState();
}

class _AdminSettingScreenState extends State<AdminSettingScreen> {
  final ProductServices productServices = Get.find();
  final AuthService _authService = Get.find();

  Future<void> _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut(); // Kullanıcıyı oturumdan çıkar
      print("Oturum kapatıldı.");
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
            builder: (context) =>
                const LoginScreen()), // Giriş ekranına yönlendir
      );
    } catch (e) {
      // Hata durumunda bir şey yap
      print("Oturum kapatma hatası: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back), // Geri ikonu
          onPressed: () {
            Navigator.pop(
                context); // Geri tuşuna basıldığında önceki sayfaya dön
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.logout,
              color: Colors.black,
            ), // Çıkış ikonu
            onPressed: () async {
              await _authService.logout();
            }, // Oturumu kapat
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                 Expanded(
                  flex: 2,
                  child: CircleAvatar(
                    backgroundColor: Colors.transparent,
                    child: Icon(
                      Icons.account_circle,
                      size: 80, // Simgenin boyutu
                      color: Colors.grey.shade500,
                    ),
                  ),
                ),
                const SizedBox(width: 10), // Araya boşluk eklemek için
                Expanded(
                  flex: 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Hoşgeldiniz", style: TextStyle(fontSize: 17)),
                      Obx(() => Text(
                            "${productServices.firstName.value} ${productServices.lastName.value}", // Kullanıcının e-posta adresini göster
                            style: const TextStyle(fontSize: 22),
                          )),
                      Obx(() => Text(
                            productServices.userEmail
                                .value, // Kullanıcının e-posta adresini göster
                            style: const TextStyle(fontSize: 14),
                          )),
                    ],
                  ),
                )
              ]),
          const SizedBox(
            height: 50,
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const RegisterScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
              child: const Row(
                mainAxisAlignment:
                    MainAxisAlignment.center, // İkon ve metni ortala
                children: [
                  Icon(
                    Icons.person_add, // Person Plus iconu
                    color: Colors.white, // İkon rengi
                  ),
                  SizedBox(width: 8), // İkon ile metin arasına boşluk
                  Text(
                    'Kullanıcı Ekle',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // Yazı rengi
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
