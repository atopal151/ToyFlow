
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveUserRole(String userId, String role, String workshop, String ad, String soyad) async {
    await _firestore.collection('users').doc(userId).set({
      'role': role,
      'workshop': workshop,
    });
  }

 
}
