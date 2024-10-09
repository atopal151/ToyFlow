
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveUserRole(String userId, String role, String workshop, String ad, String soyad) async {
    await _firestore.collection('users').doc(userId).set({
      'role': role,
      'workshop': workshop,
    });
  }

  Future<String?> getUserRole(String userId) async {
    DocumentSnapshot snapshot = await _firestore.collection('users').doc(userId).get();
    if (snapshot.exists) {
      return snapshot['role'];
    }
    return null;
  }
}
