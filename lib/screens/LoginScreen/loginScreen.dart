import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:toyflow/screens/adminPage/adminHomeScreen/adminHomeScreen.dart';
import 'package:toyflow/screens/usersPage/dikaHomeScreen/dikaHomeScreen.dart';
import '../registerPage/registerScreen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String email = '';
  String password = '';
  bool isLoading = false; // Yükleme durumunu takip etmek için
  bool isControllerDisposed = false; // Kontrolcünün boşaltılıp boşaltılmadığını takip etmek için

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 2 * 3.14159).animate(_controller);
  }

  @override
  void dispose() {
    isControllerDisposed = true; // Kontrolcünün boşaltıldığı bilgisini güncelle
    _controller.dispose();
    super.dispose();
  }

  void _startAnimation() {
    if (!isControllerDisposed && !_controller.isAnimating) { // Kontrolcü boşaltılmadıysa ve animasyon çalışmıyorsa başlat
      _controller.forward(from: 0.0);
      Future.delayed(const Duration(seconds: 2), () {
        if (!isControllerDisposed) { // Animasyon kontrolcüsü boşaltılmadıysa tekrarla
          _controller.repeat();
        }
      });
    }
  }

  Future<void> _login() async {
    setState(() {
      isLoading = true; // Giriş işlemi başlarken yükleme durumunu ayarlıyoruz
    });

    _startAnimation(); // Animasyonu başlat

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Kullanıcının rolünü Firestore'dan al
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(userCredential.user!.uid).get();
      
      if (userDoc.exists) {
        String role = userDoc['role']; // 'role' alanı Firestore'daki belgenizden alınır
        if (role == 'admin') {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AdminHomeScreen()));
        } else {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => DikaHomeScreen()));
        }
      }
    } on FirebaseAuthException catch (e) {
      print("Giriş yapılamadı: ${e.message}");
    } finally {
      setState(() {
        isLoading = false; // Giriş işlemi tamamlandığında yükleme durumunu kapat
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center, // Eşit kenar ortalamak için
              children: [
                AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    return Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.rotationZ(_animation.value),
                      child: Image.asset(
                        'images/iconozgn.png',
                        width: 200.0,
                        height: 100.0,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 40.0),

                Container(
                  width: 320.0,
                  padding: const EdgeInsets.all(30.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.0),
                    border: Border.all(
                      color: Colors.grey,
                      width: 0.9,
                    ),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 40),
                      TextField(
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.person, color: Colors.grey),
                          enabledBorder: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10.0)),
                            borderSide: BorderSide(
                              color: Colors.grey,
                              width: 0.9,
                            ),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10.0)),
                            borderSide: BorderSide(
                              color: Colors.black,
                              width: 0.5,
                            ),
                          ),
                          labelText: 'Kullanıcı Adı',
                          labelStyle: const TextStyle(
                            color: Colors.grey,
                            fontSize: 13,
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            email = value;
                          });
                        },
                      ),
                      const SizedBox(height: 20.0),

                      TextField(
                        obscureText: true,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.lock, color: Colors.grey),
                          enabledBorder: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10.0)),
                            borderSide: BorderSide(
                              color: Colors.grey,
                              width: 0.9,
                            ),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10.0)),
                            borderSide: BorderSide(
                              color: Colors.black,
                              width: 0.5,
                            ),
                          ),
                          labelText: 'Şifre',
                          labelStyle: const TextStyle(
                            color: Colors.grey,
                            fontSize: 13,
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            password = value;
                          });
                        },
                      ),
                      const SizedBox(height: 40.0),

                      ElevatedButton(
                        onPressed: isLoading ? null : () {
                          _login(); // Giriş işlemi
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF9FCE4D),
                          minimumSize: const Size(double.infinity, 50.0),
                        ),
                        child: const Text(
                          'Giriş Yap',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const RegisterScreen()),
                          );
                        },
                        child: const Text(
                          'Kayıt Ol',
                          style: TextStyle(
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
