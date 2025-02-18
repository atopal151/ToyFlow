import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class WorkshopService extends GetxController {
  // Atölye stoklarının tutulduğu reaktif map
  RxMap<String, double> workshopStocks = <String, double>{}.obs;

  // Firestore referansı
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Atölye verilerini getir ve işleme
  Future<void> fetchWorkshopStocks(DateTime selectedDate) async {
    try {
      // Atölye koleksiyonunu getir
      final atolyelerSnapshot = await _firestore.collection('atolyeler').get();

      // Geçici bir map oluştur
      Map<String, double> tempStocks = {};

      // Seçilen tarihin başlangıcı ve sonunu belirle
      final DateTime startOfDay = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
      final DateTime endOfDay = startOfDay.add(const Duration(days: 1));

      for (var atolyeDoc in atolyelerSnapshot.docs) {
        String name = atolyeDoc.data()['name'];
        String collectionName = atolyeDoc.data()['collection'];

        final collectionQuery = _firestore.collection(collectionName);

        // Tarih aralığına göre sorgula
      
          final QuerySnapshot<Map<String, dynamic>> collectionSnapshot =
            await collectionQuery
                .where('tarih', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
                .where('tarih', isLessThan: Timestamp.fromDate(endOfDay))
                .get();

        if (collectionSnapshot.docs.isNotEmpty) {
          double totalStock = 0;
          for (var doc in collectionSnapshot.docs) {
            totalStock += (doc.data()['miktar'] as num).toDouble();
          }

          tempStocks[name] = totalStock;
        }
        
        
        
      }

      // Reaktif map'i güncelle
      workshopStocks.value = tempStocks;
    } catch (e) {
      print("Hata oluştu: $e");
    }
  }

  Future<void> fetchWorkAllshopStocks() async {
    try {
      // Atölye koleksiyonunu getir
      final atolyelerSnapshot = await _firestore.collection('atolyeler').get();

      // Geçici bir map oluştur
      Map<String, double> tempStocks = {};

      // Seçilen tarihin başlangıcı ve sonunu belirle

      for (var atolyeDoc in atolyelerSnapshot.docs) {
        String name = atolyeDoc.data()['name'];
        String collectionName = atolyeDoc.data()['collection'];

        final collectionQuery = _firestore.collection(collectionName);

        // Tarih aralığına göre sorgula
      
          final QuerySnapshot<Map<String, dynamic>> collectionSnapshot =
            await collectionQuery
                .get();

        if (collectionSnapshot.docs.isNotEmpty) {
          double totalStock = 0;
          for (var doc in collectionSnapshot.docs) {
            totalStock += (doc.data()['miktar'] as num).toDouble();
          }

          tempStocks[name] = totalStock;
        }
        
        
        
      }

      // Reaktif map'i güncelle
      workshopStocks.value = tempStocks;
    } catch (e) {
      print("Hata oluştu: $e");
    }
  }
}
