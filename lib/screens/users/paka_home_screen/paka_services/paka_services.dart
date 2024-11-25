// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toyflow/services/auth_service.dart';
import 'package:toyflow/services/product_services.dart';
import 'package:toyflow/services/record_services.dart';

import '../../../../services/user_services/alert_dialog_service.dart';

class PakaServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ProductServices _productServices = Get.find();
  final RecordServices _recordServices = Get.find();
  final AuthService _authService = Get.find();
  User? user = FirebaseAuth.instance.currentUser;
  String? userRole;

  PakaServices() {
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
    required String urun,
    required String boyut,
    required String urunRenk,
    required String aksesuar,
    required int miktar,
  }) async {
    if (urun.isEmpty || urunRenk.isEmpty || boyut.isEmpty || miktar <= 0) {

      showAlertDialog(context, "Gerekli Alanları Doldur! ");
      
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
          .collection('paketleme_stok')
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
            .collection('paketleme_stok')
            .doc(existingDoc.id)
            .update({'miktar': yeniMiktar});

      showAlertDialog(context, "$userRole atölyesinden ${_productServices.firstName.value} ${_productServices.lastName.value} Mevcut stoğa $miktar adet ürün ekledi! ");
        

        await _recordMovement(
          malzeme: urun,
          renk: urunRenk,
          boyut: boyut,
          miktar: miktar,
          islemTuru: 'Stok Güncelleme',
          aciklama:
              '$userRole atölyesinden ${_productServices.firstName.value} ${_productServices.lastName.value} Mevcut stoğa $miktar adet $urunRenk $boyut $urun ekledi!',
        );
      } else {
        await _firestore.collection('paketleme_stok').add({
          'urun': urun,
          'renk': urunRenk,
          'boyut': boyut,
          'aksesuar': aksesuar,
          'miktar': miktar,
          'tarih': FieldValue.serverTimestamp(),
        });

      showAlertDialog(context, "Yeni stok başarıyla kaydedildi! ");
       

        await _recordMovement(
          malzeme: urun,
          renk: urunRenk,
          boyut: boyut,
          miktar: miktar,
          islemTuru: 'Stok Ekleme',
          aciklama:
              '$userRole atölyesinden ${_productServices.firstName.value} ${_productServices.lastName.value}  Yeni stoğa $miktar adet $urunRenk $boyut cm $urun ekledi!',
        );
      }
    } catch (e) {

      showAlertDialog(context, "Stok kaydı sırasında hata oluştu: $e ");
    
    } finally {
      Navigator.pop(context);
    }
  }

//-----stok düşümü-------
  Future<void> decreaseStock({
    required BuildContext context,
    required String malzeme,
    required String boyut,
    required String renk,
    required int miktar,
  }) async {
    if (malzeme.isEmpty ||
        renk.isEmpty ||
        renk.isEmpty ||
        renk.isEmpty ||
        miktar <= 0) {

      showAlertDialog(context, "Lütfen tüm alanları doldurun. ");
     
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
          .collection('dolum_stok')
          .where('urun', isEqualTo: malzeme)
          .where('boyut', isEqualTo: boyut)
          .where('renk', isEqualTo: renk)
          .get();

      if (existingRecord.docs.isNotEmpty) {
        DocumentSnapshot doc = existingRecord.docs.first;
        int currentMiktar = doc['miktar'] ?? 0;

        if (currentMiktar >= miktar) {
          await _firestore.collection('dolum_stok').doc(doc.id).update({
            'miktar': currentMiktar - miktar,
          });

      showAlertDialog(context, "Stok başarıyla güncellendi. ");
         

          await _recordMovement(
            malzeme: malzeme,
            boyut: boyut,
            renk: renk,
            miktar: miktar,
            islemTuru: 'Stok Düşümü',
            aciklama:
                '$userRole atölyesinden ${_productServices.firstName.value} ${_productServices.lastName.value} Stoktan $miktar adet $renk $boyut cm $malzeme düşümü yaptı.',
          );
        } else {

      showAlertDialog(context, "Yetersiz stok miktarı. ");
         
        }
      } else {

      showAlertDialog(context, "Böyle bir ürün bulunmamaktadır. ");
      
      }
    } catch (e) {

      showAlertDialog(context, "Kaydetme işlemi sırasında hata oluştu: $e ");
     
    } finally {
      Navigator.pop(context);
    }
  }

//----fire kayıt alanı-----
  Future<void> addFireEntry({
    required String malzeme,
    required BuildContext context,
    required String boyut,
    required String renk,
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
      await _firestore.collection('paketleme_fire').add({
        'urun': malzeme,
        'boyut': boyut,
        'renk': renk,
        'miktar': miktar,
        'tarih': FieldValue.serverTimestamp(),
      });

      await _recordMovement(
        malzeme: malzeme,
        boyut: boyut,
        renk: renk,
        miktar: miktar,
        islemTuru: 'Fire Kaydı',
        aciklama:
            '$userRole atölyesinden ${_productServices.firstName.value} ${_productServices.lastName.value} Fire kaydı olarak $miktar adet $renk $boyut cm $malzeme düşümü yaptı!',
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
