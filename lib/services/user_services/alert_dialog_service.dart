import 'package:flutter/material.dart';

void showAlertDialog(BuildContext context, String message) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Uyarı"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Dialog'u kapat
            },
            child: const Text("Tamam"),
          ),
        ],
      );
    },
  );
}
