// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

Future<void> saveOrderToFirestore({
   String? urun,
   String? iplik,
   String? kumas,
   String? renk,
   String? boyut,
   String? aksesuar,
   String? gramaj,
   String? fine,
   String? denye,
  required String miktar,
  required String role,
  String? aciklama,
  required String status,
  required BuildContext context, // Context ekliyoruz
}) async {
  try {
    // Loading dialog gösteriliyor
    showDialog(
      context: context,
      barrierDismissible: false, // Kullanıcı dışına tıklayarak kapatamaz
      builder: (BuildContext context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    // Firestore'daki 'orders' koleksiyonuna veri ekleme
    await FirebaseFirestore.instance.collection('orders').add({
      'urun': urun ?? '', // Seçilmemişse boş bırak
      'iplik': iplik ?? '',
      'kumas': kumas ?? '',
      'renk': renk ?? '',
      'boyut': boyut ?? '',
      'aksesuar': aksesuar ?? '',
      'gramaj': gramaj ?? '',
      'fine': fine ?? '',
      'denye': denye ?? '',
      'miktar': miktar,
      'role': role,
      "aciklama":aciklama,
      'status':status,
      'timestamp': FieldValue.serverTimestamp(), // Sipariş zamanı
    });

    // Başarılı işlem sonrası loading dialog kapatılıyor
    Navigator.pop(context); // Dialog'u kapat
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Sipariş başarıyla kaydedildi."),
      ),
    );
  } catch (e) {
    // Hata durumunda loading dialog kapatılıyor ve hata gösteriliyor
    Navigator.pop(context); // Dialog'u kapat
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Sipariş kaydedilirken bir hata oluştu: $e"),
        backgroundColor: Colors.red,
      ),
    );
  }
}
