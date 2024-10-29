// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DokaServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stok ekleme veya mevcut stoğu güncelleme
  Future<void> addOrUpdateKumasStock({
    required BuildContext context,
    required String kumas,
    required String kumasRenk,
    required int miktar,
  }) async {
    if (kumas.isEmpty || kumasRenk.isEmpty || miktar <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gerekli Alanları Doldur!!')),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(child: CircularProgressIndicator());
      },
    );

    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('dokuma_stok')
          .where('kumas', isEqualTo: kumas)
          .where('kumas_renk', isEqualTo: kumasRenk)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        DocumentSnapshot existingDoc = querySnapshot.docs.first;
        int existingMiktar = existingDoc['miktar'];
        int yeniMiktar = existingMiktar + miktar;

        await _firestore
            .collection('dokuma_stok')
            .doc(existingDoc.id)
            .update({'miktar': yeniMiktar});

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Mevcut stoğa $miktar kilo eklendi!')),
        );
        await addMovementRecord(
          malzeme: kumas,
          renk: kumasRenk,
          miktar: miktar,
          islemTuru: 'Stok Güncelleme',
          aciklama: 'Mevcut stoğa $miktar kilo $kumasRenk $kumas eklendi!',
        );
      } else {
        await _firestore.collection('dokuma_stok').add({
          'kumas': kumas,
          'kumas_renk': kumasRenk,
          'miktar': miktar,
          'tarih': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Yeni stok başarıyla kaydedildi!')),
        );
        await addMovementRecord(
          malzeme: kumas,
          renk: kumasRenk,
          miktar: miktar,
          islemTuru: 'Stok Ekleme',
          aciklama: 'Yeni stoğa $miktar kilo $kumasRenk $kumas eklendi!',
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Stok kaydı sırasında hata oluştu: $e')),
      );
    } finally {
      Navigator.pop(context); // Yükleme animasyonunu kapat
    }
  }

  // Stok düşme işlemi
  Future<void> decreaseStock({
    required BuildContext context,
    required String malzeme,
    required String renk,
    required int miktar,
  }) async {
    if (malzeme.isEmpty || renk.isEmpty || miktar <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lütfen tüm alanları doldurun.")),
      );
      return;
    }

    try {
      QuerySnapshot existingRecord = await _firestore
          .collection('ipler')
          .where('urun', isEqualTo: malzeme)
          .where('renk', isEqualTo: renk)
          .get();

      if (existingRecord.docs.isNotEmpty) {
        DocumentSnapshot doc = existingRecord.docs.first;
        int currentMiktar = doc['miktar'] ?? 0;

        if (currentMiktar >= miktar) {
          await _firestore.collection('ipler').doc(doc.id).update({
            'miktar': currentMiktar - miktar,
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Stok başarıyla güncellendi.")),
          );
          await addMovementRecord(
            malzeme: malzeme,
            renk: renk,
            miktar: miktar,
            islemTuru: 'Stok Düşümü',
            aciklama: 'Stoktan $miktar kilo $renk $malzeme düşüldü.',
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Yetersiz stok miktarı.")),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Böyle bir ürün bulunmamaktadır.")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Kaydetme işlemi sırasında hata oluştu: $e")),
      );
    }
  }

  // Fire kaydı
  Future<void> addFireEntry({
    required String malzeme,
    required String renk,
    required int miktar,
  }) async {
    try {
      await _firestore.collection('dokuma_fire').add({
        'malzeme': malzeme,
        'renk': renk,
        'miktar': miktar,
        'tarih': FieldValue.serverTimestamp(),
      });
      await addMovementRecord(
        malzeme: malzeme,
        renk: renk,
        miktar: miktar,
        islemTuru: 'Fire Kaydı',
        aciklama:
            'Fire kaydı olarak $miktar kilo $renk $malzeme düşümü yapıldı!',
      );
      print("Fire kaydı başarıyla eklendi.");
    } catch (e) {
      print("Fire kaydı sırasında hata oluştu: $e");
      rethrow;
    }
  }

  Future<void> addMovementRecord({
    required String malzeme,
    required String renk,
    required int miktar,
    required String islemTuru,
    required String aciklama,
  }) async {
    try {
      await _firestore.collection('dokuma_mover').add({
        'malzeme': malzeme,
        'renk': renk,
        'miktar': miktar,
        'islemTuru': islemTuru,
        'aciklama': aciklama,
        'tarih': FieldValue.serverTimestamp(),
      });
      print('Hareket kaydı başarıyla eklendi.');
    } catch (e) {
      print('Hareket kaydı sırasında hata oluştu: $e');
    }
  }
}
