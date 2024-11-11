// services/getDataTable.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class DataTableService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Belirli bir koleksiyondan veri almak için genel bir metod
  Future<List<String>> getCollectionData(String collectionName,String docName) async {
    try {
      final QuerySnapshot snapshot = await _firestore.collection(collectionName).get();

      // Her bir belgenin 'name' alanını String olarak listeye ekliyoruz
      return snapshot.docs.map((doc) => doc[docName].toString()).toList();
    } catch (e) {
      print('Veri çekme hatası: $e');
      return [];
    }
  }
}
