import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveUserRole(String userId, String role, String workshop,
      String ad, String soyad) async {
    await _firestore.collection('users').doc(userId).set({
      'role': role,
      'workshop': workshop,
    });
  }

  Future<int> getTotalMiktar(String collectionName) async {
    try {
      QuerySnapshot snapshot = await _firestore.collection(collectionName).get();

      int totalMiktar = snapshot.docs.fold<int>(0, (total, doc) {
        int miktar = doc['miktar'] ?? 0;
        return total + miktar;
      });

      return totalMiktar;
    } catch (e) {
      print('Hata: $e');
      throw Exception('Miktar hesaplanırken bir hata oluştu.');
    }
  }
}