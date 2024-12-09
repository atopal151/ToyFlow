// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class WorkShopServices {
   final FirebaseFirestore _firestore = FirebaseFirestore.instance;


Future<void> addNewWorkShop({
    required String nitelik,
    required String name,
    required String collectionName,
    required BuildContext context,
  }) async {
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
      // Firestore'da "toy_name" koleksiyonuna veri ekle
      await _firestore.collection('atolyeler').add({
        'nitelik': nitelik,
        'name':name,
        'collection':collectionName,
      });

      // Başarılı bir işlem mesajı göster
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Atölye başarıyla kaydedildi!')),
      );
    } catch (e) {
      // Hata mesajı göster
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Atölye kaydı sırasında hata oluştu: $e')),
      );
    }

    // Yükleme animasyonunu kapat
    Navigator.pop(context);
  }


Future<void> connectedWorkShop({
    required String oncekiBirim,
    required String rol,
    required String sonrakiBirim,
    required BuildContext context,
  }) async {
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
      // Firestore'da "toy_name" koleksiyonuna veri ekle
      await _firestore.collection('connected_work_shop').add({
        'onceki': oncekiBirim,
        'rol':rol,
        'sonraki':sonrakiBirim,
      });

      // Başarılı bir işlem mesajı göster
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bağlılıklar başarıyla kaydedildi!')),
      );
    } catch (e) {
      // Hata mesajı göster
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bağlılıkların kaydı sırasında hata oluştu: $e')),
      );
    }

    // Yükleme animasyonunu kapat
    Navigator.pop(context);
  }

}