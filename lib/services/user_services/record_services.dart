import 'package:cloud_firestore/cloud_firestore.dart';

class RecordServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> movementRecord({
    required String malzeme,
    String? renk,
    required int miktar,
    required String islemTuru,
    String? boyut,
    String? aksesuar,
    String? denye,
    String? gramaj,
    String? fine,
    required String aciklama,
    required String atelye,
  }) async {
    try {
      await _firestore.collection('movers').add({
        'malzeme': malzeme,
        'renk': renk,
        'miktar': miktar,
        'islemTuru': islemTuru,
        'boyut': boyut,
        'aksesuar': aksesuar,
        'aciklama': aciklama,
        'atelye': atelye,
        'tarih': FieldValue.serverTimestamp(),
        'okundu': false,  
      });
      print('Hareket kaydı başarıyla eklendi.');
    } catch (e, stackTrace) {
      print('Hareket kaydı sırasında hata oluştu: $e');
      print('Detaylı Hata: $stackTrace');
    }
  }
}
