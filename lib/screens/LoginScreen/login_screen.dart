// login_screen.dart
// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:toyflow/services/bottom_nav_bar.dart';
import '../../services/product_services.dart';
import '../usersPage/PakaHomeScreen/paka_home_screen.dart';
import '../usersPage/dikaHomeScreen/dika_home_screen.dart';
import '../usersPage/dokaHomeScreen/doka_home_screen.dart';
import '../usersPage/dolaHomeScreen/dola_home_screen.dart';
import '../usersPage/kesaHomeScreen/kesa_home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String email = '';
  String password = '';
  bool isLoading = false;

  Future<void> _login() async {
    setState(() {
      isLoading = true;
    });

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final ProductServices productServices = Get.find();
      productServices.userEmail.value =
          userCredential.user?.email ?? 'Email bulunamadı';

      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();
      if (userDoc.exists && userDoc.data() != null) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        productServices.firstName.value =
            userData['firstName'] ?? 'Ad bulunamadı';
        productServices.lastName.value =
            userData['lastName'] ?? 'Soyad bulunamadı';

        if (userData.containsKey('role')) {
          String role = userData['role'];
          Widget destination;

          switch (role) {
            case 'admin':
              destination = BottomNavBarWithPages();
              break;
            case 'Dikim':
              destination = const DikaHomeScreen();
              break;
            case 'Dokuma':
              destination = const DokaHomeScreen();
              break;
            case 'Dolum':
              destination = const DolaHomeScreen();
              break;
            case 'Kesim':
              destination = const KesaHomeScreen();
              break;
            case 'Paketleme':
              destination = const PakaHomeScreen();
              break;
            default:
              destination = const LoginScreen();
              break;
          }

          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => destination));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Bu kullanıcı bulunamadı")));
      }
    } on FirebaseAuthException catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Giriş Yapılamadı kullanıcı adı veya şifre hatalı!")));
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Koyu yeşil arka plan
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 1),
              // Logo ve başlık
              Column(
                children: [
                  Image.asset(
                    'images/iconozgn.png',
                    height: 80,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'ToyFlow`a',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  const Text(
                    'Hoşgeldin',
                    style: TextStyle(
                      fontSize: 28,
                     color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                ],
              ),
              const Spacer(flex: 1),
              // Giriş alanları
              Container(
                decoration: BoxDecoration(
                  color: Colors.white, // Arka plan rengini beyaz yapıyoruz
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 8,
                      offset: const Offset(0, 8), // Gölgenin pozisyonu
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 10, right: 10, top: 20),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Email',
                          filled: true,
                          fillColor: Colors.grey[100],
                          prefixIcon:
                              const Icon(Icons.person, color: Colors.grey),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            email = value;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 10, right: 10, bottom: 20),
                      child: TextField(
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: 'Şifre',
                          filled: true,
                          fillColor: Colors.grey[100],
                          prefixIcon:
                              const Icon(Icons.lock, color: Colors.grey),
                          suffixIcon:
                              const Icon(Icons.visibility, color: Colors.grey),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            password = value;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                               Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        child: isLoading
                            ? const CircularProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              )
                            : const Text(
                                'Giriş Yap',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                      ),
                    ),
                    
                  ],
                ),
              ),
              const Spacer(flex: 2),
              // Alt kısımda marka ismi
              const Text(
                "Özgüner Oyuncak",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                ),
              ),
              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }
}
