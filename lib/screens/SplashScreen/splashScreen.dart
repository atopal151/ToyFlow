// ignore_for_file: file_names, library_private_types_in_public_api
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Firebase Auth ekleniyor
import '../LoginScreen/loginScreen.dart'; // Giriş ekranı
import '../adminPage/adminHomeScreen/adminHomeScreen.dart';
import '../usersPage/dikaHomeScreen/dikaHomeScreen.dart'; // Kullanıcı ana sayfası

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();
    // Animasyon kontrolcüsü
    _controller = AnimationController(
      duration: const Duration(seconds: 2), // Animasyon süresi
      vsync: this,
    );

    // Animasyonu tanımla (düşüş ve hafif zıplama)
    _animation = Tween<Offset>(
      begin: const Offset(0, -1), // Yukarıdan başla
      end: const Offset(0, 0.1), // Normal pozisyona git (hafif zıplama)
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.bounceOut, // Bounce etkisi
    ));

    // Kontrolcüyü başlat
    _controller.forward();

    // 2 saniye sonra yönlendirme
    Timer(const Duration(seconds: 2), () async {
      // Kullanıcı oturum durumunu kontrol et
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Kullanıcı zaten oturum açmış
        // Firestore'dan rolünü almayı düşün
        // Burada rol kontrolü yaparak yönlendirme yapabilirsiniz
        // Örnek: String role = await getUserRole(user.uid);
        String role = 'admin'; // Örnek rol, bunu Firestore'dan alın

        if (role == 'admin') {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const AdminHomeScreen()),
          );
        } else {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const DikaHomeScreen()),
          );
        }
      } else {
        // Kullanıcı oturum açmamış
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose(); // Kontrolcü temizleme
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SlideTransition(
          position: _animation, // Animasyonu uygula
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                'images/iconozgn.png', // İkonun yolu
                width: 100.0, // Genişlik
                height: 100.0, // Yükseklik
              ),
            ],
          ),
        ),
      ),
    );
  }
}
