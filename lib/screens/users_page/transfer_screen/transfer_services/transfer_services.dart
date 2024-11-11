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

  // Depo koleksiyonunu seçen yardımcı fonksiyon
  String _getDepoCollection(String depo) {
    switch (depo) {
      case 'Paketleme Atölyesi':
        return 'paketleme_stok';
      case 'Denizli Ana Depo':
        return 'denizli_depo';
      case 'İstanbul Depo':
        return 'istanbul_depo';
      case 'Almanya Depo':
        return 'almanya_depo';
      default:
        return 'varsayilan_koleksiyon';
    }
  }

  // Hareket kaydı yapma
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

  // Stok ekleme veya güncelleme
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
      String collectionPath = _getDepoCollection(addDepo);
      QuerySnapshot querySnapshot = await _firestore
          .collection(collectionPath)
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
            .collection(collectionPath)
            .doc(existingDoc.id)
            .update({'miktar': yeniMiktar});

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  '$userRole ${_productServices.firstName.value} ${_productServices.lastName.value} $addDepo stoğuna $miktar adet ürün aktarıldı!')),
        );

        await _recordMovement(
          malzeme: urun,
          renk: urunRenk,
          boyut: boyut,
          aksesuar: aksesuar,
          miktar: miktar,
          islemTuru: 'Stok Güncelleme',
          aciklama:
              '$userRole ${_productServices.firstName.value} ${_productServices.lastName.value} $addDepo mevcut stoğuna $miktar adet $urunRenk $boyut $urun aktarıldı!',
        );
      } else {
        await _firestore.collection(collectionPath).add({
          'urun': urun,
          'renk': urunRenk,
          'boyut': boyut,
          'aksesuar': aksesuar,
          'miktar': miktar,
          'tarih': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$addDepo stoğuna ürün başarıyla aktarıldı!')),
        );

        await _recordMovement(
          malzeme: urun,
          renk: urunRenk,
          boyut: boyut,
          aksesuar: aksesuar,
          miktar: miktar,
          islemTuru: 'Stok Ekleme',
          aciklama:
              '$userRole ${_productServices.firstName.value} ${_productServices.lastName.value} $addDepo yeni stoğuna $miktar adet $urunRenk $boyut cm $urun ekledi!',
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

  // Stok düşümü yapma
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
  showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(child: CircularProgressIndicator());
      },
    );

    try {
      String collectionPath = _getDepoCollection(downDepo);
      QuerySnapshot existingRecord = await _firestore
          .collection(collectionPath)
          .where('urun', isEqualTo: malzeme)
          .where('boyut', isEqualTo: boyut)
          .where('renk', isEqualTo: renk)
          .where('aksesuar', isEqualTo: aksesuar)
          .get();

      print("Toplam bulunan belge sayısı: ${existingRecord.docs.length}");
      for (var doc in existingRecord.docs) {
        print("Bulunan belge: ${doc.data()}"); // Her belgenin içeriğini yazdır
      }
      for (var doc in existingRecord.docs) {
        print(doc.data()); // Her bir belgenin içeriğini yazdırır
      }

      if (existingRecord.docs.isNotEmpty) {
        DocumentSnapshot doc = existingRecord.docs.first;
        int currentMiktar = doc['miktar'] ?? 0;

        if (currentMiktar >= miktar) {
          await _firestore.collection(collectionPath).doc(doc.id).update({
            'miktar': currentMiktar - miktar,
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text("$downDepo stoğundan ürün düşümü başarıyla yapıldı.")),
          );

          await _recordMovement(
            malzeme: malzeme,
            boyut: boyut,
            renk: renk,
            miktar: miktar,
            aksesuar: aksesuar,
            islemTuru: 'Stok Düşümü',
            aciklama:
                '$userRole ${_productServices.firstName.value} ${_productServices.lastName.value} $downDepo $miktar adet $renk $boyut cm $malzeme düşüm yaptı.',
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
      print("Hata: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Kaydetme işlemi sırasında hata oluştu: $e")),
      );
    }
    finally{
      Navigator.pop(context);
    }
  }
}
