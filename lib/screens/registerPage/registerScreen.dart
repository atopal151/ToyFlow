// ignore_for_file: avoid_print, library_private_types_in_public_api

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  final TextEditingController _adController = TextEditingController();
  final TextEditingController _soyadController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _roleController = TextEditingController();
  final TextEditingController _workshopController = TextEditingController();

  Future<void> registerUser() async {

    String ad = _adController.text;
    String soyad = _soyadController.text;
    String email = _emailController.text;
    String password = _passwordController.text;
    String role = _roleController.text;
    String workshop = _workshopController.text;

    User? user = await _authService.createUser(email, password);
    if (user != null) {
      await _firestoreService.saveUserRole(user.uid, role, workshop, ad, soyad);
      print("Kullanıcı oluşturuldu ve rol atandı.");
      // Başka bir ekrana yönlendirme veya kullanıcıya bir mesaj gösterme
    } else {
      print("Kullanıcı oluşturulamadı.");
      // Hata mesajı gösterme
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Personel Kaydet"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
               TextField(
                controller: _adController,
                decoration: const InputDecoration(labelText: "Ad"),
              ),
               TextField(
                controller: _soyadController,
                decoration: const InputDecoration(labelText: "Soyad"),
              ),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: "E-posta"),
              ),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: "Şifre"),
                obscureText: true,
              ),
              TextField(
                controller: _roleController,
                decoration: const InputDecoration(labelText: "Rol"),
              ),
              TextField(
                controller: _workshopController,
                decoration: const InputDecoration(labelText: "Atölye"),
              ),
              const SizedBox(height: 20),
              Padding(
              padding: const EdgeInsets.all(10.0),
              child: ElevatedButton(
                onPressed: () {
                  registerUser();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const  Row(
                  mainAxisAlignment:
                      MainAxisAlignment.center, // İkon ve metni ortala
                  children: [
                     Text(
                      'Kaydet',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white, // Yazı rengi
                      ),
                    ),
                  ],
                ),
              ),
            ),
              
            ],
          ),
        ),
      ),
    );
  }
}
