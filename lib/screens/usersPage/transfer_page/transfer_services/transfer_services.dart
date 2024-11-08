// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toyflow/services/auth_service.dart';
import 'package:toyflow/services/product_services.dart';
import 'package:toyflow/services/record_services.dart';

class TransferServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ProductServices _productServices = Get.find();
  final RecordServices _recordServices = Get.find();
  final AuthService _authService = Get.find();
  User? user = FirebaseAuth.instance.currentUser;
  String? userRole;

  TransferServices() {
    _initializeUserRole();
  }

  // Kullanıcı rolünü bir defa al ve userRole değişkenine ata
  Future<void> _initializeUserRole() async {
    if (user != null) {
      userRole = await _authService.getUserRole(user!.uid);
    }
  }

//-----hareket kayıt-------
  Future<void> _recordMovement({
    required String malzeme,
    required String renk,
    String? boyut,
    String? aksesuar,
    required int miktar,
    required String islemTuru,
    required String aciklama,
  }) async {
    if (userRole != null) {
      await _recordServices.movementRecord(
        malzeme: malzeme,
        renk: renk,
        miktar: miktar,
        islemTuru: islemTuru,
        boyut: boyut,
        aksesuar: aksesuar,
        atelye: userRole!,
        aciklama: aciklama,
      );
    } else {
      print("Kullanıcı oturumu açık değil veya rol alınamadı.");
    }
  }

  //--------kayıt ekleme -----------
  Future<void> addOrUpdateUrunStock({
    required BuildContext context,
    required String addDepo,
    required String urun,
    required String boyut,
    required String urunRenk,
    required String aksesuar,
    required int miktar,
  }) async {
    if (addDepo.isEmpty ||
        urun.isEmpty ||
        urunRenk.isEmpty ||
        boyut.isEmpty ||
        aksesuar.isEmpty ||
        miktar <= 0) {
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
          .collection(addDepo == 'Paketleme Atölyesi'
              ? 'paketleme_stok'
              : addDepo == 'Denizli Ana Depo'
                  ? 'denizli_depo'
                  : addDepo == 'İstanbul Depo'
                      ? 'istanbul_depo'
                      : addDepo == 'Almanya Depo'
                          ? 'almanya_depo'
                          : 'varsayilan_koleksiyon')
          .where('urun', isEqualTo: urun)
          .where('renk', isEqualTo: urunRenk)
          .where('boyut', isEqualTo: boyut)
          .where('aksesuar', isEqualTo: aksesuar)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        DocumentSnapshot existingDoc = querySnapshot.docs.first;
        int existingMiktar = existingDoc['miktar'];
        int yeniMiktar = existingMiktar + miktar;
        await _firestore
             .collection(addDepo == 'Paketleme Atölyesi'
              ? 'paketleme_stok'
              : addDepo == 'Denizli Ana Depo'
                  ? 'denizli_depo'
                  : addDepo == 'İstanbul Depo'
                      ? 'istanbul_depo'
                      : addDepo == 'Almanya Depo'
                          ? 'almanya_depo'
                          : 'varsayilan_koleksiyon')
            .doc(existingDoc.id)
            .update({'miktar': yeniMiktar});

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  '$userRole atölyesinden ${_productServices.firstName.value} ${_productServices.lastName.value} Mevcut stoğa $miktar adet ürün ekledi!')),
        );

        await _recordMovement(
          malzeme: urun,
          renk: urunRenk,
          boyut: boyut,
          aksesuar: aksesuar,
          miktar: miktar,
          islemTuru: 'Stok Güncelleme',
          aciklama:
              '$userRole atölyesinden ${_productServices.firstName.value} ${_productServices.lastName.value} Mevcut stoğa $miktar adet $urunRenk $boyut $urun ekledi!',
        );
      } else {
        await _firestore
          .collection(addDepo == 'Paketleme Atölyesi'
              ? 'paketleme_stok'
              : addDepo == 'Denizli Ana Depo'
                  ? 'denizli_depo'
                  : addDepo == 'İstanbul Depo'
                      ? 'istanbul_depo'
                      : addDepo == 'Almanya Depo'
                          ? 'almanya_depo'
                          : 'varsayilan_koleksiyon')
            .add({
          'urun': urun,
          'renk': urunRenk,
          'boyut': boyut,
          'aksesuar': aksesuar,
          'miktar': miktar,
          'tarih': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Yeni stok başarıyla kaydedildi!')),
        );

        await _recordMovement(
          malzeme: urun,
          renk: urunRenk,
          boyut: boyut,
          aksesuar: aksesuar,
          miktar: miktar,
          islemTuru: 'Stok Ekleme',
          aciklama:
              '$userRole atölyesinden ${_productServices.firstName.value} ${_productServices.lastName.value}  Yeni stoğa $miktar adet $urunRenk $boyut cm $urun ekledi!',
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Stok kaydı sırasında hata oluştu: $e')),
      );
    } finally {
      Navigator.pop(context);
    }
  }

//-----stok düşümü-------
  Future<void> decreaseStock({
    required BuildContext context,
    required String downDepo,
    required String malzeme,
    required String boyut,
    required String renk,
    required String aksesuar,
    required int miktar,
  }) async {
    if (downDepo.isEmpty ||
        malzeme.isEmpty ||
        renk.isEmpty ||
        boyut.isEmpty ||
        aksesuar.isEmpty ||
        miktar <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lütfen tüm alanları doldurun.")),
      );
      return;
    }

    try {
      QuerySnapshot existingRecord = await _firestore
          .collection(downDepo == 'Paketleme Atölyesi'
              ? 'paketleme_stok'
              : downDepo == 'Denizli Depo'
                  ? 'denizli_depo'
                  : downDepo == 'İstanbul Depo'
                  ? 'istanbul_depo'
                  : downDepo == 'Almanya Depo'
                      ? 'almanya_depo'
                      : 'varsayilan_koleksiyon')
          .where('urun', isEqualTo: malzeme)
          .where('boyut', isEqualTo: boyut)
          .where('renk', isEqualTo: renk)
          .where('aksesuar', isEqualTo: aksesuar)
          .get();

      if (existingRecord.docs.isNotEmpty) {
        DocumentSnapshot doc = existingRecord.docs.first;
        int currentMiktar = doc['miktar'] ?? 0;

        if (currentMiktar >= miktar) {
          await _firestore
              .collection(downDepo == 'Paketleme Atölyesi'
              ? 'paketleme_stok'
              : downDepo == 'Denizli Depo'
                  ? 'denizli_depo'
                  : downDepo == 'İstanbul Depo'
                  ? 'istanbul_depo'
                  : downDepo == 'Almanya Depo'
                      ? 'almanya_depo'
                      : 'varsayilan_koleksiyon')
              .doc(doc.id)
              .update({
            'miktar': currentMiktar - miktar,
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Stok başarıyla güncellendi.")),
          );

          await _recordMovement(
            malzeme: malzeme,
            boyut: boyut,
            renk: renk,
            miktar: miktar,
            aksesuar: aksesuar,
            islemTuru: 'Stok Düşümü',
            aciklama:
                '$userRole atölyesinden ${_productServices.firstName.value} ${_productServices.lastName.value} Stoktan $miktar adet $renk $boyut cm $malzeme düşümü yaptı.',
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
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Kaydetme işlemi sırasında hata oluştu: $e")),
      );
    }
  }
}
