// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toyflow/screens/users/transfer_screen/transfer_screen.dart';
import 'package:toyflow/services/user_services/bottom_nav_bar.dart';
import '../../screens/login_screen/login_screen.dart';
import '../../screens/users/atolye_screen/atolye_home_screen.dart';
import 'product_services.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  Future<void> login({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
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
              destination = const AtolyeHomeScreen();
              break;
            case 'Dokuma':
              destination = const AtolyeHomeScreen();
              break;
            case 'Boyama':
              destination = const AtolyeHomeScreen();
              break;
            case 'Dolum':
              destination = const AtolyeHomeScreen();
              break;
            case 'Kesim':
              destination = const AtolyeHomeScreen();
              break;
            case 'Paketleme':
              destination = const AtolyeHomeScreen();
              break;
            case 'Transfer':
              destination = const TransferScreen();
              break;
            default:
              logout();
              destination = const LoginScreen();
              break;
          }

          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => destination));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Bu kullanıcı bulunamadı")));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Bu kullanıcı bulunamadı")));
      }
    } on FirebaseAuthException catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Giriş Yapılamadı kullanıcı adı veya şifre hatalı!")));
    }
  }

  Future<User?> createUser(String email, String password, String firstName,
      String lastName, String role, String workshop, String gender,) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
bool isActive=true;
      // Kullanıcıyı Firestore'a ekle
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'firstName': firstName,
        'lastName': lastName,
        'role': role,
        'workshop': workshop,
        'cins': gender,
        "isActive": isActive

      });

      return userCredential.user;
    } catch (e) {
      print("Kullanıcı oluşturulamadı: $e");
      return null;
    }
  }

  Future<String> getUserRole(String uid) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
        return data?['role'] ?? 'user';
      }
      return 'user';
    } catch (e) {
      print("Rol alınırken hata: $e");
      return 'user';
    }
  }

  Future<String> getUserCins(String uid) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
        return data?['cins'] ?? 'user';
      }
      return 'user';
    } catch (e) {
      print("Cinsiyet alınırken hata: $e");
      return 'user';
    }
  }

  Future<void> logout() async {
    try {
      await _auth.signOut();
      print("Oturum kapatıldı.");
      Get.offAll(() => const LoginScreen());
    } catch (e) {
      print("Oturum kapatma hatası: $e");
    }
  }
}
