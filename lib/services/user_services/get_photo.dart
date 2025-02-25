import 'package:cloud_firestore/cloud_firestore.dart';


  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
/// Firestore'dan ilgili ürünün fotoğraf URL'sini alır
  Future<String?> getToyPhoto(String urunAdi) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('toy_name')
          .where('name', isEqualTo: urunAdi)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.first['photo'];
      } else {
        print("Ürün bulunamadı: $urunAdi");
        return null;
      }
    } catch (e) {
      print("Fotoğraf alınırken hata oluştu: $e");
      return null;
    }
  }
