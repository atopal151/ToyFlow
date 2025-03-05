// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toyflow/services/user_services/auth_service.dart';
import 'package:toyflow/services/user_services/product_services.dart';
import 'package:toyflow/services/user_services/record_services.dart';

import '../../../../services/user_component/alert_dialog_service.dart';

class AtolyeServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ProductServices _productServices = Get.find();
  final RecordServices _recordServices = Get.find();
  final AuthService _authService = Get.find();
  User? user = FirebaseAuth.instance.currentUser;
  String? userRole;
  late String collectionName;

  late String collectionWait;

  AtolyeServices() {
    _initializeUserRole();
    _intializeUserCollectionName();
    _intializeUserCollectionWait();
  }

  Future<void> _intializeUserCollectionWait() async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('atolyeler')
        .where('name', isEqualTo: _productServices.workshopName.value)
        .get();

    if (querySnapshot.docs.isEmpty) {
      throw Exception('Atölye bulunamadı!');
    }

    // İlk belgeyi al ve 'collectionWait' alanını oku
    collectionWait = querySnapshot.docs.first.data()['collectionWait'];

    print(collectionWait);
  }

  Future<void> _intializeUserCollectionName() async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('atolyeler')
        .where('name', isEqualTo: _productServices.workshopName.value)
        .get();

    if (querySnapshot.docs.isEmpty) {
      throw Exception('Atölye bulunamadı!');
    }

    // İlk belgeyi al ve 'collection' alanını oku
    collectionName = querySnapshot.docs.first.data()['collection'];

    print(collectionName);
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
    String? renk,
    String? boyut,
    String? gramaj,
    String? fine,
    String? denye,
    String? aksesuar,
    required int miktar,
    required String islemTuru,
    required String aciklama,
  }) async {
    if (userRole != null) {
      await _recordServices.movementRecord(
        malzeme: malzeme,
        renk: renk,
        gramaj: gramaj,
        fine: fine,
        denye: denye,
        aksesuar: aksesuar,
        miktar: miktar,
        islemTuru: islemTuru,
        atelye: collectionName,
        aciklama: aciklama,
      );
    } else {
      print("Kullanıcı oturumu açık değil veya rol alınamadı.");
    }
  }

  //--------Bekleyen kayıt ekleme -----------
  Future<void> addOrUpdateUrunWaitStock({
    required BuildContext context,
    required String urun,
    required String collectionsWait,
    String? gramaj,
    String? boyut,
    String? fine,
    String? denye,
    String? aksesuar,
    String? renk,
    required int miktar,
  }) async {
    //-------------------------------------------------------------------------------------//
    if (userRole == "Dokuma") {
      if (urun.isEmpty || denye!.isEmpty || miktar <= 0) {
        showAlertDialog(context, "Gerekli Alanları Doldur!!");
        return;
      }
      print(collectionsWait);
      try {
        QuerySnapshot querySnapshot = await _firestore
            .collection(collectionsWait)
            .where('urun', isEqualTo: urun)
            .where('denye', isEqualTo: denye)
            .get();
        if (querySnapshot.docs.isNotEmpty) {
          DocumentSnapshot existingDoc = querySnapshot.docs.first;
          int existingMiktar = existingDoc['miktar'];
          int yeniMiktar = existingMiktar + miktar;
          await _firestore.collection(collectionsWait).doc(existingDoc.id).update(
              {'miktar': yeniMiktar, 'tarih': FieldValue.serverTimestamp()});
          showAlertDialog(context, "Bekleyen Stok Başarı ile Güncellendi.");
          await _recordMovement(
            malzeme: urun,
            denye: denye,
            miktar: miktar,
            islemTuru: 'Stok Ekleme',
            aciklama:
                '${_productServices.workshopName.value}`nden ${_productServices.firstName.value} ${_productServices.lastName.value} Bekleyen stoğa $miktar adet denye:$denye $urun ekledi!',
          );
        } else {
          await _firestore.collection(collectionsWait).add({
            'urun': urun,
            'fine': fine,
            'gramaj': gramaj,
            'miktar': miktar,
            'tarih': FieldValue.serverTimestamp(),
          });
          showAlertDialog(context, "Bekleyen Yeni Stok Başarı ile Kaydedildi.");
          await _recordMovement(
            malzeme: urun,
            denye:denye,
            miktar: miktar,
            islemTuru: 'Stok Ekleme',
            aciklama:
                '${_productServices.workshopName.value}`nden ${_productServices.firstName.value} ${_productServices.lastName.value}  Bekleyen stoğa $miktar adet denye:$denye $urun ekledi!',
          );
        }
      } catch (e) {
        showAlertDialog(context, "Hata $e");
      }
    } //-------------------------------------------------------------------------------------//
    if (userRole == "Boyama") {
      if (urun.isEmpty || fine!.isEmpty || gramaj!.isEmpty || miktar <= 0) {
        showAlertDialog(context, "Gerekli Alanları Doldur!!");
        return;
      }
      print(collectionsWait);
      try {
        QuerySnapshot querySnapshot = await _firestore
            .collection(collectionsWait)
            .where('urun', isEqualTo: urun)
            .where('fine', isEqualTo: fine)
            .where('gramaj', isEqualTo: gramaj)
            .get();
        if (querySnapshot.docs.isNotEmpty) {
          DocumentSnapshot existingDoc = querySnapshot.docs.first;
          int existingMiktar = existingDoc['miktar'];
          int yeniMiktar = existingMiktar + miktar;
          await _firestore.collection(collectionsWait).doc(existingDoc.id).update(
              {'miktar': yeniMiktar, 'tarih': FieldValue.serverTimestamp()});
          showAlertDialog(context, "Bekleyen Stok Başarı ile Güncellendi.");
          await _recordMovement(
            malzeme: urun,
            fine: fine,
            gramaj: gramaj,
            miktar: miktar,
            islemTuru: 'Stok Ekleme',
            aciklama:
                '${_productServices.workshopName.value}`nden ${_productServices.firstName.value} ${_productServices.lastName.value} Bekleyen stoğa $miktar adet fine:$fine gramaj:$gramaj $urun ekledi!',
          );
        } else {
          await _firestore.collection(collectionsWait).add({
            'urun': urun,
            'fine': fine,
            'gramaj': gramaj,
            'miktar': miktar,
            'tarih': FieldValue.serverTimestamp(),
          });
          showAlertDialog(context, "Bekleyen Yeni Stok Başarı ile Kaydedildi.");
          await _recordMovement(
            malzeme: urun,
            fine: fine,
            gramaj: gramaj,
            miktar: miktar,
            islemTuru: 'Stok Ekleme',
            aciklama:
                '${_productServices.workshopName.value}`nden ${_productServices.firstName.value} ${_productServices.lastName.value}  Yeni stoğa $miktar adet fine:$fine gramaj:$gramaj $urun ekledi!',
          );
        }
      } catch (e) {
        showAlertDialog(context, "Hata $e");
      }
    }
    //-------------------------------------------------------------------------------------//
   if (userRole == "Kesim") {
      if (urun.isEmpty || fine!.isEmpty || gramaj!.isEmpty ||renk!.isEmpty || miktar <= 0) {
        showAlertDialog(context, "Gerekli Alanları Doldur!!");
        return;
      }
      print(collectionsWait);
      try {
        QuerySnapshot querySnapshot = await _firestore
            .collection(collectionsWait)
            .where('urun', isEqualTo: urun)
            .where('fine', isEqualTo: fine)
            .where('gramaj', isEqualTo: gramaj)
            .where('renk', isEqualTo: renk)
            .get();
        if (querySnapshot.docs.isNotEmpty) {
          DocumentSnapshot existingDoc = querySnapshot.docs.first;
          int existingMiktar = existingDoc['miktar'];
          int yeniMiktar = existingMiktar + miktar;
          await _firestore.collection(collectionsWait).doc(existingDoc.id).update(
              {'miktar': yeniMiktar, 'tarih': FieldValue.serverTimestamp()});
          showAlertDialog(context, "Bekleyen Stok Başarı ile Güncellendi.");
          await _recordMovement(
            malzeme: urun,
            fine: fine,
            gramaj: gramaj,
            miktar: miktar,
            renk:renk,
            islemTuru: 'Stok Ekleme',
            aciklama:
                '${_productServices.workshopName.value}`nden ${_productServices.firstName.value} ${_productServices.lastName.value} Bekleyen stoğa $miktar adet fine:$fine gramaj:$gramaj $renk $urun ekledi!',
          );
        } else {
          await _firestore.collection(collectionsWait).add({
            'urun': urun,
            'fine': fine,
            'gramaj': gramaj,
            'renk':renk,
            'miktar': miktar,
            'tarih': FieldValue.serverTimestamp(),
          });
          showAlertDialog(context, "Bekleyen Yeni Stok Başarı ile Kaydedildi.");
          await _recordMovement(
            malzeme: urun,
            fine: fine,
            gramaj: gramaj,
            miktar: miktar, 
            renk:renk,
            islemTuru: 'Stok Ekleme',
            aciklama:
                '${_productServices.workshopName.value}`nden ${_productServices.firstName.value} ${_productServices.lastName.value}  Bekleyen Yeni stoğa $miktar adet fine:$fine gramaj:$gramaj $renk $urun ekledi!',
          );
        }
      } catch (e) {
        showAlertDialog(context, "Hata $e");
      }
    }

    //-------------------------------------------------------------------------------------//
    if (userRole == "Dikim") {
      if (urun.isEmpty || renk!.isEmpty || boyut!.isEmpty || miktar <= 0) {
        showAlertDialog(context, "Gerekli Alanları Doldur!!");
        return;
      }

      print(collectionsWait);
      try {
        QuerySnapshot querySnapshot = await _firestore
            .collection(collectionsWait)
            .where('urun', isEqualTo: urun)
            .where('renk', isEqualTo: renk)
            .where('boyut', isEqualTo: boyut)
            .get();
        if (querySnapshot.docs.isNotEmpty) {
          DocumentSnapshot existingDoc = querySnapshot.docs.first;
          int existingMiktar = existingDoc['miktar'];
          int yeniMiktar = existingMiktar + miktar;
          await _firestore.collection(collectionsWait).doc(existingDoc.id).update(
              {'miktar': yeniMiktar, 'tarih': FieldValue.serverTimestamp()});
          showAlertDialog(context, "Mevcut Stok Başarı ile Güncellendi.");
          await _recordMovement(
            malzeme: urun,
            renk: renk,
            boyut: boyut,
            miktar: miktar,
            islemTuru: 'Stok Ekleme',
            aciklama:
                '${_productServices.workshopName.value}`nden ${_productServices.firstName.value} ${_productServices.lastName.value} Bekleyen stoğa $miktar adet renk:$renk boyut:$boyut $urun ekledi!',
          );
        } else {
          await _firestore.collection(collectionsWait).add({
            'urun': urun,
            'renk': renk,
            'boyut': boyut,
            'miktar': miktar,
            'tarih': FieldValue.serverTimestamp(),
          });
          showAlertDialog(context, "Bekleyen Yeni Stok Başarı ile Kaydedildi.");
          await _recordMovement(
            malzeme: urun,
            renk: renk,
            boyut: boyut,
            miktar: miktar,
            islemTuru: 'Stok Ekleme',
            aciklama:
                '$userRole atölyesinden ${_productServices.firstName.value} ${_productServices.lastName.value}  Bekleyen Yeni stoğa $miktar adet renk:$renk boyut:$boyut $urun ekledi!',
          );
        }
      } catch (e) {
        showAlertDialog(context, "Hata $e");
      }
    }
    //-------------------------------------------------------------------------------------//
    if (userRole == "Dolum") {
      if (urun.isEmpty || renk!.isEmpty || boyut!.isEmpty || miktar <= 0) {
        showAlertDialog(context, "Gerekli Alanları Doldur!!");
        return;
      }
      print(collectionsWait);
      try {
        QuerySnapshot querySnapshot = await _firestore
            .collection(collectionsWait)
            .where('urun', isEqualTo: urun)
            .where('renk', isEqualTo: renk)
            .where('boyut', isEqualTo: boyut)
            .get();
        if (querySnapshot.docs.isNotEmpty) {
          DocumentSnapshot existingDoc = querySnapshot.docs.first;
          int existingMiktar = existingDoc['miktar'];
          int yeniMiktar = existingMiktar + miktar;
          await _firestore.collection(collectionsWait).doc(existingDoc.id).update(
              {'miktar': yeniMiktar, 'tarih': FieldValue.serverTimestamp()});
          showAlertDialog(context, "Bekleyen Mevcut Stok Başarı ile Güncellendi.");
          await _recordMovement(
            malzeme: urun,
            renk: renk,
            boyut: boyut,
            miktar: miktar,
            islemTuru: 'Stok Ekleme',
            aciklama:
                '${_productServices.workshopName.value}`nden ${_productServices.firstName.value} ${_productServices.lastName.value} Bekleyen Mevcut stoğa $miktar adet renk:$renk boyut:$boyut $urun ekledi!',
          );
        } else {
          await _firestore.collection(collectionsWait).add({
            'urun': urun,
            'renk': renk,
            'boyut': boyut,
            'miktar': miktar,
            'tarih': FieldValue.serverTimestamp(),
          });
          showAlertDialog(context, "Bekleyen Yeni Stok Başarı ile Kaydedildi.");
          await _recordMovement(
            malzeme: urun,
            renk: renk,
            boyut: boyut,
            miktar: miktar,
            islemTuru: 'Stok Ekleme',
            aciklama:
                '${_productServices.workshopName.value}`nden ${_productServices.firstName.value} ${_productServices.lastName.value}  Bekleyen Yeni stoğa $miktar adet renk:$renk boyut:$boyut $urun ekledi!',
          );
        }
      } catch (e) {
        showAlertDialog(context, "Hata $e");
      }
    } //-------------------------------------------------------------------------------------//
    if (userRole == "Paketleme") {
      if (urun.isEmpty ||
          renk!.isEmpty ||
          boyut!.isEmpty ||
          miktar <= 0) {
        showAlertDialog(context, "Gerekli Alanları Doldur!!");
        return;
      }

      print(collectionsWait);
      try {
        QuerySnapshot querySnapshot = await _firestore
            .collection(collectionsWait)
            .where('urun', isEqualTo: urun)
            .where('renk', isEqualTo: renk)
            .where('boyut', isEqualTo: boyut)
            .get();
        if (querySnapshot.docs.isNotEmpty) {
          DocumentSnapshot existingDoc = querySnapshot.docs.first;
          int existingMiktar = existingDoc['miktar'];
          int yeniMiktar = existingMiktar + miktar;
          await _firestore.collection(collectionsWait).doc(existingDoc.id).update(
              {'miktar': yeniMiktar, 'tarih': FieldValue.serverTimestamp()});
          showAlertDialog(context, "Mevcut Stok Başarı ile Güncellendi.");
          await _recordMovement(
            malzeme: urun,
            renk: renk,
            boyut: boyut,
            miktar: miktar,
            islemTuru: 'Stok Ekleme',
            aciklama:
                '${_productServices.workshopName.value}`nden ${_productServices.firstName.value} ${_productServices.lastName.value} Mevcut stoğa $miktar adet renk:$renk boyut:$boyut $urun ekledi!',
          );
        } else {
          await _firestore.collection(collectionsWait).add({
            'urun': urun,
            'renk': renk,
            'boyut': boyut,
            'miktar': miktar,
            'tarih': FieldValue.serverTimestamp(),
          });
          showAlertDialog(context, "Yeni Stok Başarı ile Kaydedildi.");
          await _recordMovement(
            malzeme: urun,
            renk: renk,
            boyut: boyut,
            miktar: miktar,
            islemTuru: 'Stok Ekleme',
            aciklama:
                '${_productServices.workshopName.value}`nden ${_productServices.firstName.value} ${_productServices.lastName.value}  Yeni stoğa $miktar adet renk:$renk boyut:$boyut $urun ekledi!',
          );
        }
      } catch (e) {
        showAlertDialog(context, "Hata $e");
      }
    }
    //-------------------------------------------------------------------------------------//
     if (userRole == "Transfer") {
      if (urun.isEmpty ||
          renk!.isEmpty ||
          boyut!.isEmpty ||
          aksesuar!.isEmpty||
          miktar <= 0) {
        showAlertDialog(context, "Gerekli Alanları Doldur!!");
        return;
      }

      print(collectionsWait);
      try {
        QuerySnapshot querySnapshot = await _firestore
            .collection(collectionsWait)
            .where('urun', isEqualTo: urun)
            .where('renk', isEqualTo: renk)
            .where('boyut', isEqualTo: boyut)
            .where('aksesuar', isEqualTo: aksesuar)
            .get();
        if (querySnapshot.docs.isNotEmpty) {
          DocumentSnapshot existingDoc = querySnapshot.docs.first;
          int existingMiktar = existingDoc['miktar'];
          int yeniMiktar = existingMiktar + miktar;
          await _firestore.collection(collectionsWait).doc(existingDoc.id).update(
              {'miktar': yeniMiktar, 'tarih': FieldValue.serverTimestamp()});
          showAlertDialog(context, "Mevcut Stok Başarı ile Güncellendi.");
          await _recordMovement(
            malzeme: urun,
            renk: renk,
            boyut: boyut,
            aksesuar: aksesuar,
            miktar: miktar,
            islemTuru: 'Stok Ekleme',
            aciklama:
                '${_productServices.workshopName.value}`nden ${_productServices.firstName.value} ${_productServices.lastName.value} Mevcut stoğa $miktar adet renk:$renk boyut:$boyut $aksesuar $urun ekledi!',
          );
        } else {
          await _firestore.collection(collectionsWait).add({
            'urun': urun,
            'renk': renk,
            'boyut': boyut,
            'aksesuar':aksesuar,
            'miktar': miktar,
            'tarih': FieldValue.serverTimestamp(),
          });
          showAlertDialog(context, "Yeni Stok Başarı ile Kaydedildi.");
          await _recordMovement(
            malzeme: urun,
            renk: renk,
            boyut: boyut,
            aksesuar: aksesuar,
            miktar: miktar,
            islemTuru: 'Stok Ekleme',
            aciklama:
                '${_productServices.workshopName.value}`nden ${_productServices.firstName.value} ${_productServices.lastName.value}  Yeni stoğa $miktar adet renk:$renk boyut:$boyut $aksesuar $urun ekledi!',
          );
        }
      } catch (e) {
        showAlertDialog(context, "Hata $e");
      }
    }
  }

  //--------kayıt ekleme -----------
  Future<void> addOrUpdateUrunStock({
    required BuildContext context,
    required String urun,
    required String collections,
    String? gramaj,
    String? boyut,
    String? fine,
    String? denye,
    String? aksesuar,
    String? renk,
    required int miktar,
  }) async {
    //-------------------------------------------------------------------------------------//
    if (userRole == "Dokuma") {
      if (urun.isEmpty || fine!.isEmpty || gramaj!.isEmpty || miktar <= 0) {
        showAlertDialog(context, "Gerekli Alanları Doldur!!");
        return;
      }
      print(collections);
      try {
        QuerySnapshot querySnapshot = await _firestore
            .collection(collections)
            .where('urun', isEqualTo: urun)
            .where('fine', isEqualTo: fine)
            .where('gramaj', isEqualTo: gramaj)
            .get();
        if (querySnapshot.docs.isNotEmpty) {
          DocumentSnapshot existingDoc = querySnapshot.docs.first;
          int existingMiktar = existingDoc['miktar'];
          int yeniMiktar = existingMiktar + miktar;
          await _firestore.collection(collections).doc(existingDoc.id).update(
              {'miktar': yeniMiktar, 'tarih': FieldValue.serverTimestamp()});
          showAlertDialog(context, "Mevcut Stok Başarı ile Güncellendi.");
          await _recordMovement(
            malzeme: urun,
            fine: fine,
            gramaj: gramaj,
            miktar: miktar,
            islemTuru: 'Stok Ekleme',
            aciklama:
                '${_productServices.workshopName.value}`nden ${_productServices.firstName.value} ${_productServices.lastName.value} Mevcut stoğa $miktar adet fine:$fine gramaj:$gramaj $urun ekledi!',
          );
        } else {
          await _firestore.collection(collections).add({
            'urun': urun,
            'fine': fine,
            'gramaj': gramaj,
            'miktar': miktar,
            'tarih': FieldValue.serverTimestamp(),
          });
          showAlertDialog(context, "Yeni Stok Başarı ile Kaydedildi.");
          await _recordMovement(
            malzeme: urun,
            fine: fine,
            gramaj: gramaj,
            miktar: miktar,
            islemTuru: 'Stok Ekleme',
            aciklama:
                '${_productServices.workshopName.value}`nden ${_productServices.firstName.value} ${_productServices.lastName.value}  Yeni stoğa $miktar adet fine:$fine gramaj:$gramaj cm $urun ekledi!',
          );
        }
      } catch (e) {
        showAlertDialog(context, "Hata $e");
      }
    } //-------------------------------------------------------------------------------------//
    if (userRole == "Boyama") {
      if (urun.isEmpty ||
          renk!.isEmpty ||
          fine!.isEmpty ||
          gramaj!.isEmpty ||
          miktar <= 0) {
        showAlertDialog(context, "Gerekli Alanları Doldur!!");
        return;
      }
      print(collections);
      try {
        QuerySnapshot querySnapshot = await _firestore
            .collection(collections)
            .where('urun', isEqualTo: urun)
            .where('fine', isEqualTo: fine)
            .where('gramaj', isEqualTo: gramaj)
            .where('renk', isEqualTo: renk)
            .get();
        if (querySnapshot.docs.isNotEmpty) {
          DocumentSnapshot existingDoc = querySnapshot.docs.first;
          int existingMiktar = existingDoc['miktar'];
          int yeniMiktar = existingMiktar + miktar;
          await _firestore.collection(collections).doc(existingDoc.id).update(
              {'miktar': yeniMiktar, 'tarih': FieldValue.serverTimestamp()});
          showAlertDialog(context, "Mevcut Stok Başarı ile Güncellendi.");
          await _recordMovement(
            malzeme: urun,
            fine: fine,
            gramaj: gramaj,
            renk: renk,
            miktar: miktar,
            islemTuru: 'Stok Ekleme',
            aciklama:
                '${_productServices.workshopName.value}`nden ${_productServices.firstName.value} ${_productServices.lastName.value} Mevcut stoğa $miktar adet fine:$fine gramaj:$gramaj $renk $urun ekledi!',
          );
        } else {
          await _firestore.collection(collections).add({
            'urun': urun,
            'fine': fine,
            'gramaj': gramaj,
            'renk': renk,
            'miktar': miktar,
            'tarih': FieldValue.serverTimestamp(),
          });
          showAlertDialog(context, "Yeni Stok Başarı ile Kaydedildi.");
          await _recordMovement(
            malzeme: urun,
            fine: fine,
            gramaj: gramaj,
            renk: renk,
            miktar: miktar,
            islemTuru: 'Stok Ekleme',
            aciklama:
                '${_productServices.workshopName.value}`nden ${_productServices.firstName.value} ${_productServices.lastName.value}  Yeni stoğa $miktar adet fine:$fine gramaj:$gramaj $renk $urun ekledi!',
          );
        }
      } catch (e) {
        showAlertDialog(context, "Hata $e");
      }
    }
    //-------------------------------------------------------------------------------------//

    if (userRole == "Kesim") {
      if (urun.isEmpty || renk!.isEmpty || boyut!.isEmpty || miktar <= 0) {
        showAlertDialog(context, "Gerekli Alanları Doldur!!");
        return;
      }

      print(collections);
      try {
        QuerySnapshot querySnapshot = await _firestore
            .collection(collections)
            .where('urun', isEqualTo: urun)
            .where('renk', isEqualTo: renk)
            .where('boyut', isEqualTo: boyut)
            .get();
        if (querySnapshot.docs.isNotEmpty) {
          DocumentSnapshot existingDoc = querySnapshot.docs.first;
          int existingMiktar = existingDoc['miktar'];
          int yeniMiktar = existingMiktar + miktar;
          await _firestore.collection(collections).doc(existingDoc.id).update(
              {'miktar': yeniMiktar, 'tarih': FieldValue.serverTimestamp()});
          showAlertDialog(context, "Mevcut Stok Başarı ile Güncellendi.");
          await _recordMovement(
            malzeme: urun,
            renk: renk,
            boyut: boyut,
            miktar: miktar,
            islemTuru: 'Stok Ekleme',
            aciklama:
                '${_productServices.workshopName.value}`nden ${_productServices.firstName.value} ${_productServices.lastName.value} Mevcut stoğa $miktar adet renk:$renk boyut:$boyut $urun ekledi!',
          );
        } else {
          await _firestore.collection(collections).add({
            'urun': urun,
            'renk': renk,
            'boyut': boyut,
            'miktar': miktar,
            'tarih': FieldValue.serverTimestamp(),
          });
          showAlertDialog(context, "Yeni Stok Başarı ile Kaydedildi.");
          await _recordMovement(
            malzeme: urun,
            renk: renk,
            boyut: boyut,
            miktar: miktar,
            islemTuru: 'Stok Ekleme',
            aciklama:
                '${_productServices.workshopName.value}`nden ${_productServices.firstName.value} ${_productServices.lastName.value}  Yeni stoğa $miktar adet renk:$renk boyut:$boyut $urun ekledi!',
          );
        }
      } catch (e) {
        showAlertDialog(context, "Hata $e");
      }
    }

    //-------------------------------------------------------------------------------------//
    if (userRole == "Dikim") {
      if (urun.isEmpty || renk!.isEmpty || boyut!.isEmpty || miktar <= 0) {
        showAlertDialog(context, "Gerekli Alanları Doldur!!");
        return;
      }

      print(collections);
      try {
        QuerySnapshot querySnapshot = await _firestore
            .collection(collections)
            .where('urun', isEqualTo: urun)
            .where('renk', isEqualTo: renk)
            .where('boyut', isEqualTo: boyut)
            .get();
        if (querySnapshot.docs.isNotEmpty) {
          DocumentSnapshot existingDoc = querySnapshot.docs.first;
          int existingMiktar = existingDoc['miktar'];
          int yeniMiktar = existingMiktar + miktar;
          await _firestore.collection(collections).doc(existingDoc.id).update(
              {'miktar': yeniMiktar, 'tarih': FieldValue.serverTimestamp()});
          showAlertDialog(context, "Mevcut Stok Başarı ile Güncellendi.");
          await _recordMovement(
            malzeme: urun,
            renk: renk,
            boyut: boyut,
            miktar: miktar,
            islemTuru: 'Stok Ekleme',
            aciklama:
                '${_productServices.workshopName.value}`nden ${_productServices.firstName.value} ${_productServices.lastName.value} Mevcut stoğa $miktar adet renk:$renk boyut:$boyut $urun ekledi!',
          );
        } else {
          await _firestore.collection(collections).add({
            'urun': urun,
            'renk': renk,
            'boyut': boyut,
            'miktar': miktar,
            'tarih': FieldValue.serverTimestamp(),
          });
          showAlertDialog(context, "Yeni Stok Başarı ile Kaydedildi.");
          await _recordMovement(
            malzeme: urun,
            renk: renk,
            boyut: boyut,
            miktar: miktar,
            islemTuru: 'Stok Ekleme',
            aciklama:
                '$userRole atölyesinden ${_productServices.firstName.value} ${_productServices.lastName.value}  Yeni stoğa $miktar adet renk:$renk boyut:$boyut $urun ekledi!',
          );
        }
      } catch (e) {
        showAlertDialog(context, "Hata $e");
      }
    }
    //-------------------------------------------------------------------------------------//
    if (userRole == "Dolum") {
      if (urun.isEmpty || renk!.isEmpty || boyut!.isEmpty || miktar <= 0) {
        showAlertDialog(context, "Gerekli Alanları Doldur!!");
        return;
      }

      print(collections);
      try {
        QuerySnapshot querySnapshot = await _firestore
            .collection(collections)
            .where('urun', isEqualTo: urun)
            .where('renk', isEqualTo: renk)
            .where('boyut', isEqualTo: boyut)
            .get();
        if (querySnapshot.docs.isNotEmpty) {
          DocumentSnapshot existingDoc = querySnapshot.docs.first;
          int existingMiktar = existingDoc['miktar'];
          int yeniMiktar = existingMiktar + miktar;
          await _firestore.collection(collections).doc(existingDoc.id).update(
              {'miktar': yeniMiktar, 'tarih': FieldValue.serverTimestamp()});
          showAlertDialog(context, "Mevcut Stok Başarı ile Güncellendi.");
          await _recordMovement(
            malzeme: urun,
            renk: renk,
            boyut: boyut,
            miktar: miktar,
            islemTuru: 'Stok Ekleme',
            aciklama:
                '${_productServices.workshopName.value}`nden ${_productServices.firstName.value} ${_productServices.lastName.value} Mevcut stoğa $miktar adet renk:$renk boyut:$boyut $urun ekledi!',
          );
        } else {
          await _firestore.collection(collections).add({
            'urun': urun,
            'renk': renk,
            'boyut': boyut,
            'miktar': miktar,
            'tarih': FieldValue.serverTimestamp(),
          });
          showAlertDialog(context, "Yeni Stok Başarı ile Kaydedildi.");
          await _recordMovement(
            malzeme: urun,
            renk: renk,
            boyut: boyut,
            miktar: miktar,
            islemTuru: 'Stok Ekleme',
            aciklama:
                '${_productServices.workshopName.value}`nden ${_productServices.firstName.value} ${_productServices.lastName.value}  Yeni stoğa $miktar adet renk:$renk boyut:$boyut $urun ekledi!',
          );
        }
      } catch (e) {
        showAlertDialog(context, "Hata $e");
      }
    } //-------------------------------------------------------------------------------------//
    if (userRole == "Paketleme") {
      if (urun.isEmpty ||
          renk!.isEmpty ||
          boyut!.isEmpty ||
          aksesuar!.isEmpty ||
          miktar <= 0) {
        showAlertDialog(context, "Gerekli Alanları Doldur!!");
        return;
      }

      print(collections);
      try {
        QuerySnapshot querySnapshot = await _firestore
            .collection(collections)
            .where('urun', isEqualTo: urun)
            .where('renk', isEqualTo: renk)
            .where('boyut', isEqualTo: boyut)
            .where('aksesuar', isEqualTo: aksesuar)
            .get();
        if (querySnapshot.docs.isNotEmpty) {
          DocumentSnapshot existingDoc = querySnapshot.docs.first;
          int existingMiktar = existingDoc['miktar'];
          int yeniMiktar = existingMiktar + miktar;
          await _firestore.collection(collections).doc(existingDoc.id).update(
              {'miktar': yeniMiktar, 'tarih': FieldValue.serverTimestamp()});
          showAlertDialog(context, "Mevcut Stok Başarı ile Güncellendi.");
          await _recordMovement(
            malzeme: urun,
            renk: renk,
            boyut: boyut,
            aksesuar: aksesuar,
            miktar: miktar,
            islemTuru: 'Stok Ekleme',
            aciklama:
                '${_productServices.workshopName.value}`nden ${_productServices.firstName.value} ${_productServices.lastName.value} Mevcut stoğa $miktar adet renk:$renk boyut:$boyut $aksesuar $urun ekledi!',
          );
        } else {
          await _firestore.collection(collections).add({
            'urun': urun,
            'renk': renk,
            'boyut': boyut,
            'aksesuar': aksesuar,
            'miktar': miktar,
            'tarih': FieldValue.serverTimestamp(),
          });
          showAlertDialog(context, "Yeni Stok Başarı ile Kaydedildi.");
          await _recordMovement(
            malzeme: urun,
            renk: renk,
            boyut: boyut,
            aksesuar: aksesuar,
            miktar: miktar,
            islemTuru: 'Stok Ekleme',
            aciklama:
                '${_productServices.workshopName.value}`nden ${_productServices.firstName.value} ${_productServices.lastName.value}  Yeni stoğa $miktar adet renk:$renk boyut:$boyut $aksesuar $urun ekledi!',
          );
        }
      } catch (e) {
        showAlertDialog(context, "Hata $e");
      }
    }
    //-------------------------------------------------------------------------------------//
  }


//-----stok düşümü-------
  Future<String> decreaseOrdersStock({
    required BuildContext context,
    required String malzeme,
    required String collection,
    String? denye,
    String? gramaj,
    String? fine,
    String? renk,
    String? boyut,
    String? aksesuar,
    required int miktar,
  }) async {
    if (_productServices.role.value == "Dokuma") {
      if (collection.isEmpty ||
          malzeme.isEmpty ||
          denye!.isEmpty ||
          miktar <= 0) {
        showAlertDialog(context, "Lütfen tüm alanları doldurun.");
        return "eksik bilgi";
      }

      try {
        QuerySnapshot existingRecord = await _firestore
            .collection(collection)
            .where('urun', isEqualTo: malzeme)
            .where('denye', isEqualTo: denye)
            .get();

        if (existingRecord.docs.isNotEmpty) {
          DocumentSnapshot doc = existingRecord.docs.first;
          int currentMiktar = doc['miktar'] ?? 0;

          if (currentMiktar >= miktar) {
            await _firestore.collection(collection).doc(doc.id).update({
              'miktar': currentMiktar - miktar,
            });

            showAlertDialog(context, "Stok başarı ile güncellendi.");
            
            await _recordMovement(
              malzeme: malzeme,
              denye: denye,
              miktar: miktar,
              islemTuru: 'Stok Düşümü',
              aciklama:
                  '${_productServices.workshopName.value}`nden ${_productServices.firstName.value} ${_productServices.lastName.value} Siparişten $miktar kilo  denye: $denye  $malzeme düşümü yaptı.',
            );
            return "başarılı";
          } else {
            showAlertDialog(context, "Yetersiz stok miktarı.");
            return "yetersiz";
          }
        } else {
          showAlertDialog(context, "Böyle bir ürün bulunmamaktadır.");
          return "urun_bulunamadi";
        }
      } catch (e) {
        showAlertDialog(context, "Kaydetme işlemi sırasında hata oluştu: $e");
        return "hata";
      } 
    }

    if (_productServices.role.value == "Boyama") {
      if (collection.isEmpty ||
          malzeme.isEmpty ||
          gramaj!.isEmpty ||
          fine!.isEmpty ||
          miktar <= 0) {
        showAlertDialog(context, "Lütfen tüm alanları doldurun.");
        return "eksik bilgi";
      }

      try {
        QuerySnapshot existingRecord = await _firestore
            .collection(collection)
            .where('urun', isEqualTo: malzeme)
            .where('gramaj', isEqualTo: gramaj)
            .where('fine', isEqualTo: fine)
            .get();

        if (existingRecord.docs.isNotEmpty) {
          DocumentSnapshot doc = existingRecord.docs.first;
          int currentMiktar = doc['miktar'] ?? 0;

          if (currentMiktar >= miktar) {
            await _firestore.collection(collection).doc(doc.id).update({
              'miktar': currentMiktar - miktar,
            });

            showAlertDialog(context, "Stok başarı ile güncellendi.");

            await _recordMovement(
              malzeme: malzeme,
              gramaj: gramaj,
              fine: fine,
              miktar: miktar,
              islemTuru: 'Stok Düşümü',
              aciklama:
                  '${_productServices.workshopName.value}`nden ${_productServices.firstName.value} ${_productServices.lastName.value} Siparişten $miktar kilo  gramaj: $gramaj fine: $fine  $malzeme düşümü yaptı.',
            );
            return "başarılı";
          } else {
            showAlertDialog(context, "Yetersiz stok miktarı.");
            return "yetersiz";
          }
        } else {
          showAlertDialog(context, "Böyle bir ürün bulunmamaktadır.");
          return "urun_bulunamadi";
        }
      } catch (e) {
        showAlertDialog(context, "Kaydetme işlemi sırasında hata oluştu: $e");
        return "hata";
      } 
    }

    if (_productServices.role.value == "Kesim") {
      if (collection.isEmpty ||
          malzeme.isEmpty ||
          gramaj!.isEmpty ||
          fine!.isEmpty ||
          renk!.isEmpty ||
          miktar <= 0) {
        showAlertDialog(context, "Lütfen tüm alanları doldurun.");
        return "eksik bilgi";
      }

      try {
        QuerySnapshot existingRecord = await _firestore
            .collection(collection)
            .where('urun', isEqualTo: malzeme)
            .where('gramaj', isEqualTo: gramaj)
            .where('fine', isEqualTo: fine)
            .where('renk', isEqualTo: renk)
            .get();

        if (existingRecord.docs.isNotEmpty) {
          DocumentSnapshot doc = existingRecord.docs.first;
          int currentMiktar = doc['miktar'] ?? 0;

          if (currentMiktar >= miktar) {
            await _firestore.collection(collection).doc(doc.id).update({
              'miktar': currentMiktar - miktar,
            });

            showAlertDialog(context, "Stok başarı ile güncellendi.");

            await _recordMovement(
              malzeme: malzeme,
              gramaj: gramaj,
              fine: fine,
              renk: renk,
              miktar: miktar,
              islemTuru: 'Stok Düşümü',
              aciklama:
                  '${_productServices.workshopName.value}`nden ${_productServices.firstName.value} ${_productServices.lastName.value} Siparişten $miktar kilo  gramaj: $gramaj fine: $fine $renk $malzeme düşümü yaptı.',
            );
            return "başarılı";
          } else {
            showAlertDialog(context, "Yetersiz stok miktarı.");
            return "yetersiz";
          }
        } else {
          showAlertDialog(context, "Böyle bir ürün bulunmamaktadır.");
          return "urun_bulunamadi";
        }
      } catch (e) {
        showAlertDialog(context, "Kaydetme işlemi sırasında hata oluştu: $e");
        return "hata";
      } 
    }

    if (_productServices.role.value == "Dikim" ||
        _productServices.role.value == "Dolum" ||
        _productServices.role.value == "Paketleme") {
      if (collection.isEmpty ||
          malzeme.isEmpty ||
          boyut!.isEmpty ||
          renk!.isEmpty ||
          miktar <= 0) {
        showAlertDialog(context, "Lütfen tüm alanları doldurun.");
        return "eksik bilgi";
      }

      try {
        QuerySnapshot existingRecord = await _firestore
            .collection(collection)
            .where('urun', isEqualTo: malzeme)
            .where('renk', isEqualTo: renk)
            .where('boyut', isEqualTo: boyut)
            .get();

        if (existingRecord.docs.isNotEmpty) {
          DocumentSnapshot doc = existingRecord.docs.first;
          int currentMiktar = doc['miktar'] ?? 0;

          if (currentMiktar >= miktar) {
            await _firestore.collection(collection).doc(doc.id).update({
              'miktar': currentMiktar - miktar,
            });

            showAlertDialog(context, "Stok başarı ile güncellendi.");

            await _recordMovement(
              malzeme: malzeme,
              renk: renk,
              boyut: boyut,
              miktar: miktar,
              islemTuru: 'Stok Düşümü',
              aciklama:
                  '${_productServices.workshopName.value}`nden ${_productServices.firstName.value} ${_productServices.lastName.value} Siparişten $miktar adet $boyut $renk $malzeme düşümü yaptı.',
            );
            return "başarılı";
          } else {
            showAlertDialog(context, "Yetersiz stok miktarı.");
            return "yetersiz";
          }
        } else {
          showAlertDialog(context, "Böyle bir ürün bulunmamaktadır.");
          return "urun_bulunamadi";
        }
      } catch (e) {
        showAlertDialog(context, "Kaydetme işlemi sırasında hata oluştu: $e");
        return "hata";
      } 
    }
     if (_productServices.role.value == "Transfer" ) {
      if (collection.isEmpty ||
          malzeme.isEmpty ||
          boyut!.isEmpty ||
          renk!.isEmpty ||
          aksesuar!.isEmpty||
          miktar <= 0) {
        showAlertDialog(context, "Lütfen tüm alanları doldurun.");
        return "eksik bilgi";
      }

      try {
        QuerySnapshot existingRecord = await _firestore
            .collection(collection)
            .where('urun', isEqualTo: malzeme)
            .where('renk', isEqualTo: renk)
            .where('boyut', isEqualTo: boyut)
            .where('aksesuar', isEqualTo: aksesuar)
            .get();

        if (existingRecord.docs.isNotEmpty) {
          DocumentSnapshot doc = existingRecord.docs.first;
          int currentMiktar = doc['miktar'] ?? 0;

          if (currentMiktar >= miktar) {
            await _firestore.collection(collection).doc(doc.id).update({
              'miktar': currentMiktar - miktar,
            });

            showAlertDialog(context, "Stok başarı ile güncellendi.");

            await _recordMovement(
              malzeme: malzeme,
              renk: renk,
              boyut: boyut,
              miktar: miktar,
              islemTuru: 'Stok Düşümü',
              aciklama:
                  '${_productServices.workshopName.value}`nden ${_productServices.firstName.value} ${_productServices.lastName.value} Siparişten $miktar adet $boyut $renk $aksesuar $malzeme düşümü yaptı.',
            );
            return "başarılı";
          } else {
            showAlertDialog(context, "Yetersiz stok miktarı.");
            return "yetersiz";
          }
        } else {
          showAlertDialog(context, "Böyle bir ürün bulunmamaktadır.");
          return "urun_bulunamadi";
        }
      } catch (e) {
        showAlertDialog(context, "Kaydetme işlemi sırasında hata oluştu: $e");
        return "hata";
      } 
    }
    return "geçersiz rol";
  }


//-----stok düşümü-------
  Future<void> decreaseStock({
    required BuildContext context,
    required String malzeme,
    //required String collection,
    String? denye,
    String? gramaj,
    String? fine,
    String? renk,
    String? boyut,
    String? aksesuar,
    required int miktar,
  }) async {
    if (_productServices.role.value == "Dokuma") {
      if (collectionWait.isEmpty ||
          malzeme.isEmpty ||
          denye!.isEmpty ||
          miktar <= 0) {
        showAlertDialog(context, "Lütfen tüm alanları doldurun.");
        return;
      }

      try {
        QuerySnapshot existingRecord = await _firestore
            .collection(collectionWait)
            .where('urun', isEqualTo: malzeme)
            .where('denye', isEqualTo: denye)
            .get();

        if (existingRecord.docs.isNotEmpty) {
          DocumentSnapshot doc = existingRecord.docs.first;
          int currentMiktar = doc['miktar'] ?? 0;

          if (currentMiktar >= miktar) {
            await _firestore.collection(collectionWait).doc(doc.id).update({
              'miktar': currentMiktar - miktar,
            });

            showAlertDialog(context, "Stok başarı ile güncellendi.");

            await _recordMovement(
              malzeme: malzeme,
              denye: denye,
              miktar: miktar,
              islemTuru: 'Stok Düşümü',
              aciklama:
                  '${_productServices.workshopName.value}`nden ${_productServices.firstName.value} ${_productServices.lastName.value} Stoktan $miktar kilo  denye: $denye  $malzeme düşümü yaptı.',
            );
          } else {
            showAlertDialog(context, "Yetersiz stok miktarı.");
          }
        } else {
          showAlertDialog(context, "Böyle bir ürün bulunmamaktadır.");
        }
      } catch (e) {
        showAlertDialog(context, "Kaydetme işlemi sırasında hata oluştu: $e");
      } finally {}
    }

    if (_productServices.role.value == "Boyama") {
      if (collectionWait.isEmpty ||
          malzeme.isEmpty ||
          gramaj!.isEmpty ||
          fine!.isEmpty ||
          miktar <= 0) {
        showAlertDialog(context, "Lütfen tüm alanları doldurun.");
        return;
      }

      try {
        QuerySnapshot existingRecord = await _firestore
            .collection(collectionWait)
            .where('urun', isEqualTo: malzeme)
            .where('gramaj', isEqualTo: gramaj)
            .where('fine', isEqualTo: fine)
            .get();

        if (existingRecord.docs.isNotEmpty) {
          DocumentSnapshot doc = existingRecord.docs.first;
          int currentMiktar = doc['miktar'] ?? 0;

          if (currentMiktar >= miktar) {
            await _firestore.collection(collectionWait).doc(doc.id).update({
              'miktar': currentMiktar - miktar,
            });

            showAlertDialog(context, "Stok başarı ile güncellendi.");

            await _recordMovement(
              malzeme: malzeme,
              gramaj: gramaj,
              fine: fine,
              miktar: miktar,
              islemTuru: 'Stok Düşümü',
              aciklama:
                  '${_productServices.workshopName.value}`nden ${_productServices.firstName.value} ${_productServices.lastName.value} Stoktan $miktar kilo  gramaj: $gramaj fine: $fine  $malzeme düşümü yaptı.',
            );
          } else {
            showAlertDialog(context, "Yetersiz stok miktarı.");
          }
        } else {
          showAlertDialog(context, "Böyle bir ürün bulunmamaktadır.");
        }
      } catch (e) {
        showAlertDialog(context, "Kaydetme işlemi sırasında hata oluştu: $e");
      } finally {}
    }

    if (_productServices.role.value == "Kesim") {
      if (collectionWait.isEmpty ||
          malzeme.isEmpty ||
          gramaj!.isEmpty ||
          fine!.isEmpty ||
          renk!.isEmpty ||
          miktar <= 0) {
        showAlertDialog(context, "Lütfen tüm alanları doldurun.");
        return;
      }

      try {
        QuerySnapshot existingRecord = await _firestore
            .collection(collectionWait)
            .where('urun', isEqualTo: malzeme)
            .where('gramaj', isEqualTo: gramaj)
            .where('fine', isEqualTo: fine)
            .where('renk', isEqualTo: renk)
            .get();

        if (existingRecord.docs.isNotEmpty) {
          DocumentSnapshot doc = existingRecord.docs.first;
          int currentMiktar = doc['miktar'] ?? 0;

          if (currentMiktar >= miktar) {
            await _firestore.collection(collectionWait).doc(doc.id).update({
              'miktar': currentMiktar - miktar,
            });

            showAlertDialog(context, "Stok başarı ile güncellendi.");

            await _recordMovement(
              malzeme: malzeme,
              gramaj: gramaj,
              fine: fine,
              renk: renk,
              miktar: miktar,
              islemTuru: 'Stok Düşümü',
              aciklama:
                  '${_productServices.workshopName.value}`nden ${_productServices.firstName.value} ${_productServices.lastName.value} Stoktan $miktar kilo  gramaj: $gramaj fine: $fine $renk $malzeme düşümü yaptı.',
            );
          } else {
            showAlertDialog(context, "Yetersiz stok miktarı.");
          }
        } else {
          showAlertDialog(context, "Böyle bir ürün bulunmamaktadır.");
        }
      } catch (e) {
        showAlertDialog(context, "Kaydetme işlemi sırasında hata oluştu: $e");
      } finally {}
    }

    if (_productServices.role.value == "Dikim" ||
        _productServices.role.value == "Dolum" ||
        _productServices.role.value == "Paketleme") {
      if (collectionWait.isEmpty ||
          malzeme.isEmpty ||
          boyut!.isEmpty ||
          renk!.isEmpty ||
          miktar <= 0) {
        showAlertDialog(context, "Lütfen tüm alanları doldurun.");
        return;
      }

      try {
        QuerySnapshot existingRecord = await _firestore
            .collection(collectionWait)
            .where('urun', isEqualTo: malzeme)
            .where('renk', isEqualTo: renk)
            .where('boyut', isEqualTo: boyut)
            .get();

        if (existingRecord.docs.isNotEmpty) {
          DocumentSnapshot doc = existingRecord.docs.first;
          int currentMiktar = doc['miktar'] ?? 0;

          if (currentMiktar >= miktar) {
            await _firestore.collection(collectionWait).doc(doc.id).update({
              'miktar': currentMiktar - miktar,
            });

            showAlertDialog(context, "Stok başarı ile güncellendi.");

            await _recordMovement(
              malzeme: malzeme,
              renk: renk,
              boyut: boyut,
              miktar: miktar,
              islemTuru: 'Stok Düşümü',
              aciklama:
                  '${_productServices.workshopName.value}`nden ${_productServices.firstName.value} ${_productServices.lastName.value} Stoktan $miktar adet $boyut $renk $malzeme düşümü yaptı.',
            );
          } else {
            showAlertDialog(context, "Yetersiz stok miktarı.");
          }
        } else {
          showAlertDialog(context, "Böyle bir ürün bulunmamaktadır.");
        }
      } catch (e) {
        showAlertDialog(context, "Kaydetme işlemi sırasında hata oluştu: $e");
      } finally {}
    }
  }

//----fire kayıt alanı-----
  Future<void> addFireEntry({
    required BuildContext context,
    required String malzeme,
    String? denye,
    String? gramaj,
    String? fine,
    String? boyut,
    String? aksesuar,
    String? renk,
    required int miktar,
  }) async {
    try {
      if (_productServices.role.value == "Dokuma") {
        await _firestore.collection('fireler').add({
          "atolye": _productServices.workshopName.value,
          'urun': malzeme,
          'denye': denye,
          'miktar': miktar,
          'tarih': FieldValue.serverTimestamp(),
        });

        await _recordMovement(
          malzeme: malzeme,
          denye: denye,
          miktar: miktar,
          islemTuru: 'Fire Kaydı',
          aciklama:
              '${_productServices.workshopName.value}`nden ${_productServices.firstName.value} ${_productServices.lastName.value} Fire kaydı olarak $miktar adet $denye $malzeme düşümü yaptı!',
        );
      }

      if (_productServices.role.value == "Boyama") {
        await _firestore.collection('fireler').add({
          "atolye": _productServices.workshopName.value,
          'urun': malzeme,
          'gramaj': gramaj,
          'fine': fine,
          'miktar': miktar,
          'tarih': FieldValue.serverTimestamp(),
        });

        await _recordMovement(
          malzeme: malzeme,
          gramaj: gramaj,
          fine: fine,
          miktar: miktar,
          islemTuru: 'Fire Kaydı',
          aciklama:
              '${_productServices.workshopName.value}`nden ${_productServices.firstName.value} ${_productServices.lastName.value} Fire kaydı olarak $miktar adet $gramaj $fine $malzeme düşümü yaptı!',
        );
      }

      if (_productServices.role.value == "Kesim") {
        await _firestore.collection('fireler').add({
          "atolye": _productServices.workshopName.value,
          'urun': malzeme,
          'gramaj': gramaj,
          'fine': fine,
          'renk': renk,
          'miktar': miktar,
          'tarih': FieldValue.serverTimestamp(),
        });

        await _recordMovement(
          malzeme: malzeme,
          gramaj: gramaj,
          fine: fine,
          renk: renk,
          miktar: miktar,
          islemTuru: 'Fire Kaydı',
          aciklama:
              '${_productServices.workshopName.value}`nden ${_productServices.firstName.value} ${_productServices.lastName.value} Fire kaydı olarak $miktar adet denyesi: $gramaj $fine $renk $malzeme düşümü yaptı!',
        );
      }
      if (_productServices.role.value == "Dikim" ||
          _productServices.role.value == "Dolum" ||
          _productServices.role.value == "Paketleme") {
        await _firestore.collection('fireler').add({
          "atolye": _productServices.workshopName.value,
          'urun': malzeme,
          'renk': renk,
          'boyut': boyut,
          'miktar': miktar,
          'tarih': FieldValue.serverTimestamp(),
        });

        await _recordMovement(
          malzeme: malzeme,
          renk: renk,
          boyut: boyut,
          miktar: miktar,
          islemTuru: 'Fire Kaydı',
          aciklama:
              '${_productServices.workshopName.value}`nden ${_productServices.firstName.value} ${_productServices.lastName.value} Fire kaydı olarak $miktar adet denyesi: $boyut $renk $malzeme düşümü yaptı!',
        );
      }

      print("Fire kaydı başarıyla eklendi.");
    } catch (e) {
      print("Fire kaydı sırasında hata oluştu: $e");
      rethrow;
    } finally {}
  }
}
