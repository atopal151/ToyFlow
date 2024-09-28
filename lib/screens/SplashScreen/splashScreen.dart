// ignore_for_file: file_names
import 'dart:async';
import 'package:flutter/material.dart';
import '../LoginScreen/loginScreen.dart';

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

    // 3 saniye sonra LoginScreen'e yönlendir
    Timer(const Duration(seconds: 2), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
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
