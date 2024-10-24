import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
      body: Column(
        children: [
          Expanded(
            flex: 5,
            child: Center(
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
          ),
          const Expanded(
            flex: 1,
            child: Center(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "®",
                    style: TextStyle(
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    "Özgüner Oyuncak",
                    style: TextStyle(
                      fontSize: 10,
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
