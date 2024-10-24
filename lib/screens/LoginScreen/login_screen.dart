// ignore_for_file: unused_element

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

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String email = '';
  String password = '';
  bool isLoading = false; // Yükleme durumunu takip etmek için

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }


// AlertDialog gösteren metod
  void _showAlertDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text("Tamam"),
              onPressed: () {
                Navigator.of(context).pop(); // Dialogu kapat
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _login() async {
    setState(() {
      isLoading = true;
    });

    try {
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

        // Kullanıcı verilerini güncelle
        productServices.firstName.value =
            userData['firstName'] ?? 'Ad bulunamadı';
        productServices.lastName.value =
            userData['lastName'] ?? 'Soyad bulunamadı';

        // Rol alanı mevcut mu kontrol et
        if (userData.containsKey('role')) {
          String role = userData['role'];

          if (role == 'admin') {
            // Eğer rol admin ise admin sayfasına yönlendir
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => BottomNavBarWithPages()));
          } else if (role == 'Dikim') {
            // Rol admin değilse kullanıcı sayfasına yönlendir
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => const DikaHomeScreen()));
          } else if (role == 'Dokuma') {
            // Rol admin değilse kullanıcı sayfasına yönlendir
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => const DokaHomeScreen()));
          } else if (role == 'Dolum') {
            // Rol admin değilse kullanıcı sayfasına yönlendir
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => const DolaHomeScreen()));
          } else if (role == 'Kesim') {
            // Rol admin değilse kullanıcı sayfasına yönlendir
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => const KesaHomeScreen()));
          } else if (role == 'Paketleme') {
            // Rol admin değilse kullanıcı sayfasına yönlendir
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => const PakaHomeScreen()));
          }
        } else {
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
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true, // Ekranı küçültmek için
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                height: 100,
              ),
              Expanded(
                flex: 1,
                child: SizedBox(
                  height: MediaQuery.of(context).size.height *
                      0.25, // Ekranın %25'i kadar yer ayır
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 40.0, right: 40.0, bottom: 10.0, top: 30.0),
                    child: Image.asset(
                      'images/iconozgn.png',
                      width: 100.0,
                      height: 50.0,
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: SizedBox(
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
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
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
                        Row(
                          children: [
                            const Expanded(
                              flex: 1,
                              child: Center(
                                child: Text(
                                  "Şifreni mi unuttun?",
                                  style: TextStyle(fontSize: 10),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: InkWell(
                                onTap: isLoading
                                    ? null
                                    : () {
                                        setState(() {
                                          // Butona tıkladığında yükleme durumunu başlat
                                          isLoading = true;
                                        });
                                        _login(); // Giriş işlemini başlat
                                      },
                                child: Container(
                                  width: double.infinity,
                                  height: 50.0,
                                  decoration: BoxDecoration(
                                    color: isLoading
                                        ? Colors.grey
                                        : const Color(
                                            0xFF9FCE4D), // Yükleme durumuna göre renk
                                    borderRadius: BorderRadius.circular(50.0),
                                    border: Border.all(
                                      color: Colors.grey,
                                      width: 0.20,
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: isLoading
                                      ? const CircularProgressIndicator(
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  Colors.white),
                                        )
                                      : const Text(
                                          'Giriş Yap',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 100,
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
        ),
      ),
    );
  }
}
