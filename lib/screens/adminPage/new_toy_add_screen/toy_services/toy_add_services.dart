// services/stock_services.dart
// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ToyAddServices { 
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;


Future<void> addNewDenye({
    required String denye,
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
      await _firestore.collection('denye').add({
        'denye': denye,
      }); 
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Denye başarıyla kaydedildi!')),
      );
    } catch (e) { 
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Stok kaydı sırasında hata oluştu: $e')),
      );
    } 
    Navigator.pop(context);
  }


Future<void> addNewFine({
    required String fine,
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
      await _firestore.collection('fine').add({
        'fine': fine,
      }); 
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fine başarıyla kaydedildi!')),
      );
    } catch (e) { 
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Stok kaydı sırasında hata oluştu: $e')),
      );
    } 
    Navigator.pop(context);
  }



Future<void> addNewGramaj({
    required String gramaj,
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
      await _firestore.collection('gramaj').add({
        'gramaj': gramaj,
      }); 
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gramaj başarıyla kaydedildi!')),
      );
    } catch (e) { 
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Stok kaydı sırasında hata oluştu: $e')),
      );
    } 
    Navigator.pop(context);
  }


Future<void> addNewKumas({
    required String kumas,
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
      await _firestore.collection('kumas').add({
        'kumas': kumas,
      }); 
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kumaş başarıyla kaydedildi!')),
      );
    } catch (e) { 
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Stok kaydı sırasında hata oluştu: $e')),
      );
    } 
    Navigator.pop(context);
  }


Future<void> addNewIp({
    required String iplik,
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
      await _firestore.collection('iplik').add({
        'iplik': iplik,
      }); 
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('İplik başarıyla kaydedildi!')),
      );
    } catch (e) { 
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Stok kaydı sırasında hata oluştu: $e')),
      );
    } 
    Navigator.pop(context);
  }


  Future<void> addNewToy({
    required String urun,
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
      await _firestore.collection('toy_name').add({
        'name': urun,
      }); 
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Oyuncak başarıyla kaydedildi!')),
      );
    } catch (e) { 
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Stok kaydı sırasında hata oluştu: $e')),
      );
    } 
    Navigator.pop(context);
  }

Future<void> addNewAksesuar({
    required String aksesuar,
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
      await _firestore.collection('toy_aksesuar').add({
        'aksesuar': aksesuar,
      }); 
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aksesuar başarıyla kaydedildi!')),
      );
    } catch (e) { 
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Stok kaydı sırasında hata oluştu: $e')),
      );
    }
 
    Navigator.pop(context);
  }



 Future<void> addNewColor({
    required String renk,
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
      await _firestore.collection('toy_renk').add({
        'renk': renk,
      });
 
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Renk başarıyla kaydedildi!')),
      );
    } catch (e) { 
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Stok kaydı sırasında hata oluştu: $e')),
      );
    }
  
    Navigator.pop(context);
  }



 Future<void> addNewHeight({
    required String boyut,
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
      await _firestore.collection('toy_height').add({
        'boyut': boyut,
      }); 
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Boyut başarıyla kaydedildi!')),
      );
    } catch (e) { 
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Stok kaydı sırasında hata oluştu: $e')),
      );
    } 
    Navigator.pop(context);
  }
 
  void _showAlert(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Uyarı'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Tamam'),
            ),
          ],
        );
      },
    );
  }
}
