import 'package:cloud_firestore/cloud_firestore.dart';

class WorkshopDataService {
  static const List<String> workshops = [
    'Dokuma Atölyesi',
    'Boyama Atölyesi',
    'Kesim Atölyesi',
    'Dikim Atölyesi',
    'Dolum Atölyesi',
    'Paketleme Atölyesi',
  ];

  static Stream<List<Map<String, dynamic>>> getWorkshopData(String? workshop) {
    switch (workshop) {
      case 'Dokuma Atölyesi':
        return _getCollectionData('dokuma_stok', ['urun', 'miktar', 'tarih']);
      case 'Boyama Atölyesi':
        return _getCollectionData(
            'boyama_stok', ['urun', 'renk', 'miktar', 'tarih']);
      case 'Kesim Atölyesi':
        return _getCollectionData(
            'kesim_stok', ['urun', 'renk', 'boyut', 'miktar', 'tarih']);
      case 'Dikim Atölyesi':
        return _getCollectionData(
            'dikim_stok', ['urun', 'renk', 'boyut', 'miktar', 'tarih']);
      case 'Dolum Atölyesi':
        return _getCollectionData(
            'dolum_stok', ['urun', 'renk', 'boyut', 'miktar', 'tarih']);
      case 'Paketleme Atölyesi':
        return _getCollectionData('paketleme_stok',
            ['urun', 'renk', 'boyut', 'aksesuar', 'miktar', 'tarih']);
      default:
        return _getCollectionData('paketleme_stok',
            ['urun', 'renk', 'boyut', 'aksesuar', 'miktar', 'tarih']);
    }
  }

  static Stream<List<Map<String, dynamic>>> _getCollectionData(
      String collectionName, List<String> fields) {
    return FirebaseFirestore.instance
        .collection(collectionName)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.where((doc) => doc['miktar'] != 0).map((doc) {
              return {for (var field in fields) field: doc[field]};
            }).toList());
  }
}
