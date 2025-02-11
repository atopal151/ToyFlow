import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class WorkshopService extends GetxController {
  // Atölye stoklarının tutulduğu reaktif map
  RxMap<String, double> workshopStocks = <String, double>{}.obs;

  // Firestore referansı
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Atölye verilerini getir ve işleme
  Future<void> fetchWorkshopStocks() async {
    try {
      // Atölye koleksiyonunu getir
      final atolyelerSnapshot =
          await _firestore.collection('atolyeler').get();

      // Geçici bir map oluştur
      Map<String, double> tempStocks = {};

      // Her atölyeyi işle
      for (var atolyeDoc in atolyelerSnapshot.docs) {
        // Atölye ismi ve ilgili collection ismini al
        String name = atolyeDoc.data()['name'];
        String collectionName = atolyeDoc.data()['collection'];

        // İlgili koleksiyonun var olup olmadığını kontrol et
        final collectionSnapshot =
            await _firestore.collection(collectionName).get();

        if (collectionSnapshot.docs.isNotEmpty) {
          // Koleksiyondaki ürün miktarlarının toplamını hesapla
          double totalStock = 0;
          for (var doc in collectionSnapshot.docs) {
            totalStock += (doc.data()['miktar'] as num).toDouble();
          }

          // Map'e ekle
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
