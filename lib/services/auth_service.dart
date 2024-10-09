// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../screens/LoginScreen/loginScreen.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<User?> createUser(String email, String password) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
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
        // Burada 'data()' metodunun geri dönüş tipini belirtiyoruz
        Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
        return data?['role'] ?? 'user'; // Varsayılan rol 'user'
      }
      return 'user'; // Kullanıcı bulunamazsa varsayılan rol
    } catch (e) {
      print("Rol alınırken hata: $e");
      return 'user'; // Hata durumunda varsayılan rol
    }
  }

  Future<void> logout() async {
    try {
      await _auth.signOut(); // Firebase oturumu kapat
      print("Oturum kapatıldı.");

      // LoginScreen'e yönlendir
      Get.offAll(() =>
          const LoginScreen()); // Tüm sayfa yığınını temizleyip LoginScreen'e yönlendir
    } catch (e) {
      print("Oturum kapatma hatası: $e");
    }
  }
}
