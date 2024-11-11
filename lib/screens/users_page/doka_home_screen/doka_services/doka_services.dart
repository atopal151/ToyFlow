// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toyflow/services/auth_service.dart';
import 'package:toyflow/services/record_services.dart';

import '../../../../services/product_services.dart';

class DokaServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ProductServices _productServices = Get.find();
  final RecordServices _recordServices = Get.find();
  final AuthService _authService = Get.find();
  User? user = FirebaseAuth.instance.currentUser;
  String? userRole;

  DokaServices() {
    _initializeUserRole();
  }

  // Kullanıcı rolünü bir defa al ve userRole değişkenine ata
  Future<void> _initializeUserRole() async {
    if (user != null) {
      userRole = await _authService.getUserRole(user!.uid);
    }
  }

  Future<void> _recordMovement({
    required String malzeme,
    required int miktar,
    required String islemTuru,
    required String aciklama,
  }) async {
    if (userRole != null) {
      await _recordServices.movementRecord(
        malzeme: malzeme,
        miktar: miktar,
        islemTuru: islemTuru,
        atelye: userRole!,
        aciklama: aciklama,
      );
    } else {
      print("Kullanıcı oturumu açık değil veya rol alınamadı.");
    }
  }

  Future<void> addOrUpdateKumasStock({
    required BuildContext context,
    required String kumas,
    required int miktar,
  }) async {
    if (kumas.isEmpty || miktar <= 0) {
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
          .where('urun', isEqualTo: kumas)
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
          SnackBar(
              content: Text(
                  '$userRole atölyesinden ${_productServices.firstName.value} ${_productServices.lastName.value} Mevcut stoğa $miktar kilo ekledi!')),
        );

        await _recordMovement(
          malzeme: kumas,
          miktar: miktar,
          islemTuru: 'Stok Güncelleme',
          aciklama:
              '$userRole atölyesinden ${_productServices.firstName.value} ${_productServices.lastName.value} Mevcut stoğa $miktar kilo $kumas ekledi!',
        );
      } else {
        await _firestore.collection('dokuma_stok').add({
          'urun': kumas,
          'miktar': miktar,
          'tarih': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Yeni stok başarıyla kaydedildi!')),
        );

        await _recordMovement(
          malzeme: kumas,
          miktar: miktar,
          islemTuru: 'Stok Ekleme',
          aciklama:
              '$userRole atölyesinden ${_productServices.firstName.value} ${_productServices.lastName.value} Yeni stoğa $miktar kilo $kumas ekledi!',
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

  Future<void> decreaseStock({
    required BuildContext context,
    required String malzeme,
    required int miktar,
  }) async {
    if (malzeme.isEmpty || miktar <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lütfen tüm alanları doldurun.")),
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
      QuerySnapshot existingRecord = await _firestore
          .collection('dokuma_work')
          .where('urun', isEqualTo: malzeme)
          .get();

      if (existingRecord.docs.isNotEmpty) {
        DocumentSnapshot doc = existingRecord.docs.first;
        int currentMiktar = doc['miktar'] ?? 0;

        if (currentMiktar >= miktar) {
          await _firestore.collection('dokuma_work').doc(doc.id).update({
            'miktar': currentMiktar - miktar,
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Stok başarıyla güncellendi.")),
          );

          await _recordMovement(
            malzeme: malzeme,
            miktar: miktar,
            islemTuru: 'Stok Düşümü',
            aciklama:
                '$userRole atölyesinden ${_productServices.firstName.value} ${_productServices.lastName.value} Stoktan $miktar kilo  $malzeme düşümü yaptı.',
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
    } finally {
      Navigator.pop(context);
    }
  }

  Future<void> addFireEntry({
    required String malzeme,
    required BuildContext context,
    required int miktar,
  }) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(child: CircularProgressIndicator());
      },
    );
    try {
      await _firestore.collection('dokuma_fire').add({
        'urun': malzeme,
        'miktar': miktar,
        'tarih': FieldValue.serverTimestamp(),
      });

      await _recordMovement(
        malzeme: malzeme,
        miktar: miktar,
        islemTuru: 'Fire Kaydı',
        aciklama:
            '$userRole atölyesinden ${_productServices.firstName.value} ${_productServices.lastName.value} Fire kaydı olarak $miktar kilo  $malzeme düşümü yaptı!',
      );

      print("Fire kaydı başarıyla eklendi.");
    } catch (e) {
      print("Fire kaydı sırasında hata oluştu: $e");
      rethrow;
    } finally {
      Navigator.pop(context);
    }
  }
}
