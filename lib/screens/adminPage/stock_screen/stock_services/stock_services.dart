// services/stock_services.dart
// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:toyflow/services/user_component/alert_dialog_service.dart';
import '../../../../services/user_services/record_services.dart';

class StockService {
  final RecordServices _recordServices = RecordServices();

  Future<void> saveStock({
    required String urun,
    required String denye,
    required int miktar,
    required BuildContext context,
  }) async { 
    if (miktar <= 0) {
      showAlertDialog(context, 'Lütfen geçerli bir miktar girin!');
      return;
    }

    try { 
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('dokuma_work')
          .where('urun', isEqualTo: urun)
          .where('denye', isEqualTo: denye)
          .get();

      if (querySnapshot.docs.isNotEmpty) { 
        DocumentSnapshot existingDoc = querySnapshot.docs.first;
        int existingMiktar = existingDoc['miktar'];

        int yeniMiktar = existingMiktar + miktar;
        await FirebaseFirestore.instance
            .collection('dokuma_work')
            .doc(existingDoc.id)
            .update({'miktar': yeniMiktar,'tarih':FieldValue.serverTimestamp()});

        showAlertDialog(
            context, "Mevcut stoğa $miktar kilo $urun $denye eklendi!");

        await _recordServices.movementRecord(
          malzeme: urun,
          miktar: miktar,
          islemTuru: 'Stok Güncelleme',
          atelye: 'dokuma',
          aciklama: 'Mevcut stoğa $miktar kilo $urun $denye eklendi!',
        );
      } else { 
        await FirebaseFirestore.instance.collection('dokuma_work').add({
          'urun': urun,
          'denye': denye,
          'miktar': miktar,
          'tarih': FieldValue.serverTimestamp(),
        });
        showAlertDialog(context, 'Yeni stok başarıyla kaydedildi!');

        await _recordServices.movementRecord(
          malzeme: urun,
          miktar: miktar,
          islemTuru: 'Stok Ekleme',
          atelye: 'dokuma',
          aciklama: 'Yeni stoğa $miktar kilo $urun $denye eklendi!',
        );
      }
    } catch (e) {
      showAlertDialog(context, "Stok kaydı sırasında hata oluştu: $e");
    }
  }
}
