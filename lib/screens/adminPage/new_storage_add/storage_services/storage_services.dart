// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class StorageServices {
   final FirebaseFirestore _firestore = FirebaseFirestore.instance;


Future<void> addNewStorage({
    required String name,
    required String collectionName,
    required BuildContext context,
  }) async { 
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
      await _firestore.collection('depolar').add({
        'title': name,
        'collection':collectionName,
        'image':'images/depo.webp'
      }); 
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Depo başarıyla kaydedildi!')),
      );
    } catch (e) { 
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Stok kaydı sırasında hata oluştu: $e')),
      );
    } 
    Navigator.pop(context);
  }

}