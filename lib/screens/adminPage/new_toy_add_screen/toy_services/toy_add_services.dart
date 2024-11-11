// services/stock_services.dart
// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ToyAddServices {
  // Firestore instance'ını al
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;


Future<void> addNewKumas({
    required String kumas,
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
      await _firestore.collection('kumas').add({
        'kumas': kumas,
      });

      // Başarılı bir işlem mesajı göster
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kumaş başarıyla kaydedildi!')),
      );
    } catch (e) {
      // Hata mesajı göster
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Stok kaydı sırasında hata oluştu: $e')),
      );
    }

    // Yükleme animasyonunu kapat
    Navigator.pop(context);
  }


Future<void> addNewIp({
    required String iplik,
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
      await _firestore.collection('iplik').add({
        'iplik': iplik,
      });

      // Başarılı bir işlem mesajı göster
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('İplik başarıyla kaydedildi!')),
      );
    } catch (e) {
      // Hata mesajı göster
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Stok kaydı sırasında hata oluştu: $e')),
      );
    }

    // Yükleme animasyonunu kapat
    Navigator.pop(context);
  }


  Future<void> addNewToy({
    required String urun,
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
      await _firestore.collection('toy_name').add({
        'name': urun,
      });

      // Başarılı bir işlem mesajı göster
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Oyuncak başarıyla kaydedildi!')),
      );
    } catch (e) {
      // Hata mesajı göster
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Stok kaydı sırasında hata oluştu: $e')),
      );
    }

    // Yükleme animasyonunu kapat
    Navigator.pop(context);
  }

Future<void> addNewAksesuar({
    required String aksesuar,
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
      // Firestore'da "toy_aksesuar" koleksiyonuna veri ekle
      await _firestore.collection('toy_aksesuar').add({
        'aksesuar': aksesuar,
      });

      // Başarılı bir işlem mesajı göster
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aksesuar başarıyla kaydedildi!')),
      );
    } catch (e) {
      // Hata mesajı göster
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Stok kaydı sırasında hata oluştu: $e')),
      );
    }

    // Yükleme animasyonunu kapat
    Navigator.pop(context);
  }



 Future<void> addNewColor({
    required String renk,
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
      // Firestore'da "toy_renk" koleksiyonuna veri ekle
      await _firestore.collection('toy_renk').add({
        'renk': renk,
      });

      // Başarılı bir işlem mesajı göster
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Renk başarıyla kaydedildi!')),
      );
    } catch (e) {
      // Hata mesajı göster
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Stok kaydı sırasında hata oluştu: $e')),
      );
    }

    // Yükleme animasyonunu kapat
    Navigator.pop(context);
  }



 Future<void> addNewHeight({
    required String boyut,
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
      // Firestore'da "toy_height" koleksiyonuna veri ekle
      await _firestore.collection('toy_height').add({
        'boyut': boyut,
      });

      // Başarılı bir işlem mesajı göster
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Boyut başarıyla kaydedildi!')),
      );
    } catch (e) {
      // Hata mesajı göster
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Stok kaydı sırasında hata oluştu: $e')),
      );
    }

    // Yükleme animasyonunu kapat
    Navigator.pop(context);
  }

  // Uyarı gösterme fonksiyonu
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
