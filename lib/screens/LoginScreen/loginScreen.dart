// ignore_for_file: avoid_print, use_build_context_synchronously, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:toyflow/screens/adminPage/adminHomeScreen/adminHomeScreen.dart';
import 'package:toyflow/screens/usersPage/dikaHomeScreen/dikaHomeScreen.dart';

import '../../services/product_services.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String email = '';
  String password = '';
  bool isLoading = false; // Yükleme durumunu takip etmek için
  bool isControllerDisposed =
      false; // Kontrolcünün boşaltılıp boşaltılmadığını takip etmek için

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
    if (!isControllerDisposed && !_controller.isAnimating) {
      // Kontrolcü boşaltılmadıysa ve animasyon çalışmıyorsa başlat
      _controller.forward(from: 0.0);
      Future.delayed(const Duration(seconds: 2), () {
        if (!isControllerDisposed) {
          // Animasyon kontrolcüsü boşaltılmadıysa tekrarla
          _controller.repeat();
        }
      });
    }
  }

  Future<void> _login() async {
    setState(() {
      isLoading = true;
    });

    try {
      _startAnimation();
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Giriş yapıldıktan sonra email'i güncelle
      final ProductServices productServices = Get.find();
      productServices.userEmail.value =
          userCredential.user?.email ?? 'Email bulunamadı';

      // Kullanıcı verisini Firestore'dan al
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (userDoc.exists && userDoc.data() != null) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        print(userData.containsKey("role"));
        // Rol alanı mevcut mu kontrol et
        if (userData.containsKey('role')) {
          String role = userData['role'];

          if (role == 'admin') {
            // Eğer rol admin ise admin sayfasına yönlendir
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => const AdminHomeScreen()));
          } else {
            // Rol admin değilse kullanıcı sayfasına yönlendir
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => const DikaHomeScreen()));
          }
        } else {
          // Rol bulunamadıysa hata ver
          print("Kullanıcı rolü bulunamadı.");
        }
      } else {
        print("Kullanıcı veritabanında bulunamadı.");
      }
    } on FirebaseAuthException catch (e) {
      print("Giriş yapılamadı: ${e.message}");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, // Ekranı küçültmek için
      body: SingleChildScrollView(
        // Kaydırılabilir hale getir
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height *
                      0.25, // Ekranın %25'i kadar yer ayır
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 40.0, right: 40.0, bottom: 10.0, top: 30.0),
                    child: AnimatedBuilder(
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
                  ),
                ),
                SizedBox(
                  width: 320.0,
                  child: Container(
                    padding: const EdgeInsets.all(20.0),
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
                        const SizedBox(height: 10),
                        TextField(
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.person, color: Colors.grey),
                            enabledBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10.0)),
                              borderSide: BorderSide(
                                color: Colors.grey,
                                width: 0.9,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10.0)),
                              borderSide: BorderSide(
                                color: Colors.black,
                                width: 0.5,
                              ),
                            ),
                            labelText: 'Kullanıcı Adı',
                            labelStyle: TextStyle(
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
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.lock, color: Colors.grey),
                            enabledBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10.0)),
                              borderSide: BorderSide(
                                color: Colors.grey,
                                width: 0.9,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10.0)),
                              borderSide: BorderSide(
                                color: Colors.black,
                                width: 0.5,
                              ),
                            ),
                            labelText: 'Şifre',
                            labelStyle: TextStyle(
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
                          onPressed: isLoading
                              ? null
                              : () {
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
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40.0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
