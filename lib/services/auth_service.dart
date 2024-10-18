// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../screens/LoginScreen/login_screen.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  Future<User?> createUser(String email, String password, String firstName,
      String lastName, String role, String workshop, String gender) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Kullanıcıyı Firestore'a ekle
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'firstName': firstName,
        'lastName': lastName,
        'role': role,
        'workshop': workshop,
        'cins': gender
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
        return data?['role'] ?? 'user'; // Varsayılan rol 'user'
      }
      return 'user'; // Kullanıcı bulunamazsa varsayılan rol
    } catch (e) {
      print("Rol alınırken hata: $e");
      return 'user'; // Hata durumunda varsayılan rol
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
