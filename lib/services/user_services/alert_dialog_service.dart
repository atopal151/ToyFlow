import 'package:flutter/material.dart';

void showAlertDialog(BuildContext context, String message) {
  // Context'in geçerli olup olmadığını kontrol eder
  if (!context.mounted) return;

  // SnackBar'ı gösterir
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 3), // Görüntüleme süresi
      behavior: SnackBarBehavior.floating, // Ekranda yukarıda konumlanır
      margin: const EdgeInsets.all(16), // Kenar boşlukları
    ),
  );
}