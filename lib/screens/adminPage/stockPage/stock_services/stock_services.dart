// services/stock_services.dart
// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../../services/record_services.dart';

class StockService {
  final RecordServices _recordServices = RecordServices();

  Future<void> saveStock({
    required String urun,
    required String renk,
    required int miktar,
    required BuildContext context,
  }) async {
    // Eğer miktar geçerli değilse uyarı göster
    if (miktar <= 0) {
      _showAlert(context, 'Lütfen geçerli bir miktar girin!');
      return;
    }

    // Yükleme animasyonunu göster
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    try {
      // Firestore'da aynı ürün ve renge sahip bir kayıt var mı kontrol et
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('dokuma_work')
          .where('urun', isEqualTo: urun)
          .where('renk', isEqualTo: renk)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Kayıt varsa miktarı güncelle
        DocumentSnapshot existingDoc = querySnapshot.docs.first;
        int existingMiktar = existingDoc['miktar'];

        int yeniMiktar = existingMiktar + miktar;
        await FirebaseFirestore.instance
            .collection('dokuma_work')
            .doc(existingDoc.id)
            .update({'miktar': yeniMiktar});

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Mevcut stoğa $miktar kilo eklendi!')),
        );

        await _recordServices.movementRecord(
          malzeme: urun,
          renk: renk,
          miktar: miktar,
          islemTuru: 'Stok Güncelleme',
          atelye: 'dokuma',
          aciklama: 'Mevcut stoğa $miktar kilo $renk $urun eklendi!',
        );
      } else {
        // Kayıt yoksa yeni bir kayıt oluştur
        await FirebaseFirestore.instance.collection('dokuma_work').add({
          'urun': urun,
          'renk': renk,
          'miktar': miktar,
          'tarih': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Yeni stok başarıyla kaydedildi!')),
        );

        await _recordServices.movementRecord(
          malzeme: urun,
          renk: renk,
          miktar: miktar,
          islemTuru: 'Stok Ekleme',
          atelye: 'dokuma',
          aciklama: 'Yeni stoğa $miktar kilo $renk $urun eklendi!',
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Stok kaydı sırasında hata oluştu: $e')),
      );
    }

    Navigator.pop(context);
    Navigator.pop(context);
  }

  void _showAlert(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Uyarı'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Tamam'),
            ),
          ],
        );
      },
    );
  }
}
