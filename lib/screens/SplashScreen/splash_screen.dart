// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:toyflow/screens/usersPage/boyaHomeScreen/boya_home_screen.dart';
import 'package:toyflow/screens/usersPage/transfer_page/transfer_screen.dart';
import 'package:toyflow/services/bottom_nav_bar.dart';
import '../LoginScreen/login_screen.dart';
import '../usersPage/PakaHomeScreen/paka_home_screen.dart';
import '../usersPage/dikaHomeScreen/dika_home_screen.dart';
import '../../services/auth_service.dart';
import '../usersPage/dokaHomeScreen/doka_home_screen.dart';
import '../usersPage/dolaHomeScreen/dola_home_screen.dart';
import '../usersPage/kesaHomeScreen/kesa_home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();

    // 3 saniye bekledikten sonra yönlendirme işlemi
    Timer(const Duration(seconds: 1), () async {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String role = await _authService.getUserRole(user.uid);
        print(role);
        if (role == 'admin') {
          Get.offAll(() => BottomNavBarWithPages());
        } else if (role == 'Dikim') {
          Get.offAll(() => const DikaHomeScreen());
        } else if (role == 'Dokuma') {
          Get.offAll(() => const DokaHomeScreen());
        } else if (role == 'Boyama') {
          Get.offAll(() => const BoyaHomeScreen());
        } else if (role == 'Dolum') {
          Get.offAll(() => const DolaHomeScreen());
        } else if (role == 'Kesim') {
          Get.offAll(() => const KesaHomeScreen());
        } else if (role == 'Paketleme') {
          Get.offAll(() => const PakaHomeScreen());
        } else if (role == 'Transfer') {
          Get.offAll(() => const TransferScreen());
        }
      } else {
        Get.offAll(() => const LoginScreen());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            flex: 5,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    'images/iconozgn.png',
                    width: 100.0,
                    height: 100.0,
                  ),
                ],
              ),
            ),
          ),
          const Expanded(
            flex: 1,
            child: Center(
              child: Column(
                children: [
                  Text(
                    "Özgüner Oyuncak",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black45,
                    ),
                  ),
                  Text(
                    'Toy Flow',
                    style: TextStyle(
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
