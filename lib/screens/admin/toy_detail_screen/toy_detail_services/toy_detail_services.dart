import 'package:cloud_firestore/cloud_firestore.dart';

class ToyDetailServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Dinamik olarak depo isimlerini almak için fonksiyon
  Future<List<String>> getDepotNames() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('depolar').get();
      return snapshot.docs.map((doc) => doc['title'] as String).toList();
    } catch (e) {
      print("Depo isimleri alınırken hata oluştu: $e");
      return [];
    }
  }

  // Seçilen kriterlere göre ürünleri listeleyen fonksiyon
  Future<List<Map<String, dynamic>>> listToys({
    required String malzeme,
    required String renk,
    String? boyut,
    String? aksesuar,
  }) async {
    List<Map<String, dynamic>> toyDetails = [];
    List<String> depotNames = await getDepotNames();

    for (String depo in depotNames) {
      String collectionName = await _getDepoCollection(depo);
      Query query = _firestore
          .collection(collectionName)
          .where('urun', isEqualTo: malzeme)
          .where('renk', isEqualTo: renk);

      if (boyut != null) {
        query = query.where('boyut', isEqualTo: boyut);
      }
      if (aksesuar != null) {
        query = query.where('aksesuar', isEqualTo: aksesuar);
      }

      try {
        QuerySnapshot snapshot = await query.get();
        if (snapshot.docs.isNotEmpty) {
          int miktar = snapshot.docs.fold<int>(
            0,
            // ignore: avoid_types_as_parameter_names
            (sum, doc) => sum + ((doc['miktar'] ?? 0) as int),
          );
          toyDetails.add({
            'depo': depo,
            'miktar': miktar,
          });
        } else {
          toyDetails.add({
            'depo': depo,
            'miktar': 'Yok',
          });
        }
      } catch (e) {
        print("Hata oluştu: $e");
      }
    }

    return toyDetails;
  }

  // Depo koleksiyonunu Firestore'dan çekerek döndüren yardımcı fonksiyon
  Future<String> _getDepoCollection(String depoTitle) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('depolar')
          .where('title', isEqualTo: depoTitle)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first['collection'];
      } else {
        return 'varsayilan_koleksiyon';
      }
    } catch (e) {
      print("Depo koleksiyonunu alırken hata oluştu: $e");
      return 'varsayilan_koleksiyon';
    }
  }
}
