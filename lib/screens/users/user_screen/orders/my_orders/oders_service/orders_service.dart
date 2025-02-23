// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

Future<void> saveOrderToFirestore({
  String? atelye,
  String? atelyeCollection,
  String? atelyeNitelik,
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
  required BuildContext context,
}) async {
  try {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    await FirebaseFirestore.instance.collection('orders').add({
      'atelye': atelye ?? '',
      'atelyecollection':atelyeCollection ?? '',
      'atelyenitelik':atelyeNitelik ?? '',
      'urun': urun ?? '',
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
      "aciklama": aciklama,
      'status': status,
      'timestamp': FieldValue.serverTimestamp(),
    });

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Sipariş başarıyla kaydedildi."),
      ),
    );
  } catch (e) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Sipariş kaydedilirken bir hata oluştu: $e"),
        backgroundColor: Colors.red,
      ),
    );
  }
}
