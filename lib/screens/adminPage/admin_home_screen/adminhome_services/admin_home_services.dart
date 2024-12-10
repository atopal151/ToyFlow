import 'package:cloud_firestore/cloud_firestore.dart';

class AdminHomeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  

  Future<int> fetchDailyStockOperations(String atelye) async {
    final DateTime today = DateTime.now();
    final DateTime startOfDay = DateTime(today.year, today.month, today.day);

    try {
      QuerySnapshot snapshot = await _firestore
          .collection('movers')
          .where('atelye', isEqualTo: atelye)
          .where('islemTuru', whereIn: ['Stok Ekleme', 'Stok Güncelleme'])
          .where('tarih', isGreaterThanOrEqualTo: startOfDay)
          .get();

      int totalStock = snapshot.docs.fold<int>(0, (previousValue, doc) {
        final num miktar = doc['miktar'] ?? 0;
        return previousValue + miktar.toInt();
      });

      return totalStock;
    } catch (e) {
      print("Error fetching data: $e");
      return 0; 
    }
  }

  /// Belirli bir koleksiyondaki tüm `miktar` değerlerinin toplamını alır.
  Future<int> fetchStockFromCollection(String collectionName) async {
    try {
      QuerySnapshot snapshot =
          await _firestore.collection(collectionName).get();

      int totalStock = snapshot.docs.fold<int>(0, (previousValue, doc) {
        final num miktar = doc['miktar'] ?? 0;
        return previousValue + miktar.toInt();
      });

      return totalStock;
    } catch (e) {
      print("Error fetching data from $collectionName: $e");
      return 0; 
    }
  }
}
