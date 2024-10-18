// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api, file_names

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:toyflow/services/BottomNavBar.dart';
import '../LoginScreen/loginScreen.dart';
import '../usersPage/PakaScreen/pakaHomeScreen.dart';
import '../usersPage/dikaScreen/dikaHomeScreen.dart';
import '../../services/auth_service.dart';
import '../usersPage/dokaScreen/dokaHomeScreen.dart';
import '../usersPage/dolaScreen/dolaHomeScreen.dart';
import '../usersPage/kesaScreen/kesaHomeScreen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;
  final AuthService _authService = AuthService(); // AuthService örneği

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _animation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: const Offset(0, 0.1),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.bounceOut,
    ));

    _controller.forward();

    Timer(const Duration(seconds: 2), () async {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String role = await _authService.getUserRole(user.uid); // Rolü al
        if (role == 'admin') {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => BottomNavBarWithPages()));
        } else if (role == 'Dikim') {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => const DikaHomeScreen()));
        } else if (role == 'Dokuma') {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => const DokaHomeScreen()));
        } else if (role == 'Dolum') {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => const DolaHomeScreen()));
        } else if (role == 'Kesim') {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => const KesaHomeScreen()));
        } else if (role == 'Paketleme') {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => const PakaHomeScreen()));
        }
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SlideTransition(
          position: _animation,
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
    );
  }
}
