// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toyflow/services/auth_service.dart';
import 'package:toyflow/services/record_services.dart';

import '../../../../services/product_services.dart';
import '../../../../services/user_services/alert_dialog_service.dart';

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
    required String gramaj,
    required String fine,
    required int miktar,
  }) async {
    if (kumas.isEmpty || gramaj.isEmpty || fine.isEmpty || miktar <= 0) {
      showAlertDialog(context, "Gerekli alanları doldur.");

      return;
    }

    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('dokuma_stok')
          .where('urun', isEqualTo: kumas)
          .where('gramaj', isEqualTo: gramaj)
          .where('fine', isEqualTo: fine)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Mevcut kayıt varsa güncelleme yap
        DocumentSnapshot existingDoc = querySnapshot.docs.first;
        int existingMiktar = existingDoc['miktar'];
        int yeniMiktar = existingMiktar + miktar;

        await _firestore
            .collection('dokuma_stok')
            .doc(existingDoc.id)
            .update({'miktar': yeniMiktar,'tarih':FieldValue.serverTimestamp()});
        showAlertDialog(context,
            "'$userRole atölyesinden ${_productServices.firstName.value} ${_productServices.lastName.value} Mevcut  $kumas $gramaj $fine stoğa $miktar kilo ekledi!");

        await _recordMovement(
          malzeme: kumas,
          miktar: miktar,
          islemTuru: 'Stok Güncelleme',
          aciklama:
              '$userRole atölyesinden ${_productServices.firstName.value} ${_productServices.lastName.value} Mevcut $kumas $gramaj $fine stoğa $miktar kilo ekledi!',
        );
      } else {
        // Yeni kayıt oluştur
        await _firestore.collection('dokuma_stok').add({
          'urun': kumas,
          'gramaj': gramaj,
          'fine': fine,
          'miktar': miktar,
          'tarih': FieldValue.serverTimestamp(),
        });
        showAlertDialog(context, "Yeni stok başarıyla kaydedildi.");

        await _recordMovement(
          malzeme: kumas,
          miktar: miktar,
          islemTuru: 'Stok Ekleme',
          aciklama:
              '$userRole atölyesinden ${_productServices.firstName.value} ${_productServices.lastName.value} Yeni $kumas $gramaj $fine stoğa $miktar kilo  ekledi!',
        );
      }
    } catch (e) {
      showAlertDialog(context, "Stok kaydı sırasından hata $e");
    } finally {
      if (context.mounted) {
      }
    }
  }

  Future<void> decreaseStock({
    required BuildContext context,
    required String malzeme,
    required String denye,
    required int miktar,
  }) async {
    if (malzeme.isEmpty || denye.isEmpty || miktar <= 0) {
      showAlertDialog(context, "Lütfen tüm alanları doldur.");

      return;
    }

    try {
      // Denye ve malzeme değerine göre stok sorgulama
      QuerySnapshot existingRecord = await _firestore
          .collection('dokuma_work')
          .where('urun', isEqualTo: malzeme)
          .where('denye', isEqualTo: denye)
          .get();

      if (existingRecord.docs.isNotEmpty) {
        DocumentSnapshot doc = existingRecord.docs.first;
        int currentMiktar = doc['miktar'] ?? 0;

        if (currentMiktar >= miktar) {
          // Stok güncelleme
          await _firestore.collection('dokuma_work').doc(doc.id).update({
            'miktar': currentMiktar - miktar,
          });
          showAlertDialog(context, "Stok başarıyla güncellendi.");

          // Hareket kaydı
          await _recordMovement(
            malzeme: malzeme,
            miktar: miktar,
            islemTuru: 'Stok Düşümü',
            aciklama:
                '$userRole atölyesinden ${_productServices.firstName.value} ${_productServices.lastName.value} stoktan $denye denye $malzeme için $miktar kilo düşüm yaptı.',
          );
        } else {
          showAlertDialog(context,
              "Yetersiz stok miktarı: Mevcut stok $currentMiktar kilo.");
        }
      } else {
        showAlertDialog(
            context, "Bu denye ve malzeme için stok bulunmamaktadır.");
      }
    } catch (e) {
      showAlertDialog(context, "Kaydetme işlemi sırasında hata oluştu: $e");
    } finally {
  if (context.mounted) {
  }
}

  }

  Future<void> addFireEntry({
    required String malzeme,
    required String denye,
    required BuildContext context,
    required int miktar,
  }) async {
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
            '$userRole atölyesinden ${_productServices.firstName.value} ${_productServices.lastName.value} Fire kaydı olarak $miktar kilo  $denye denyeli $malzeme düşümü yaptı!',
      );

      print("Fire kaydı başarıyla eklendi.");
    } catch (e) {
      print("Fire kaydı sırasında hata oluştu: $e");
      rethrow;
    } finally {
  if (context.mounted) {
  }
}

  }
}
