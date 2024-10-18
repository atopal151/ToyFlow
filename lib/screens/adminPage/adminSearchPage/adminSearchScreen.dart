import 'package:flutter/material.dart';

class AdminSearchScreen extends StatefulWidget {
  const AdminSearchScreen({super.key});

  @override
  State<AdminSearchScreen> createState() => _AdminSearchScreenState();
}

class _AdminSearchScreenState extends State<AdminSearchScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          title: const Text(
        "Ürünler",
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
      )),
      body: Center(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(
                  14.0), // TextField çevresinde boşluk bırak
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Ara', // Placeholder metni
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 0, horizontal: 20), // İç boşluklar
                  suffixIcon: InkWell(
                      onTap: () {},
                      child: const Icon(
                          Icons.search)), // Sağ tarafa yaslı arama ikonu
                  enabledBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                        Radius.circular(30.0)), // Tam daire border radius
                    borderSide: BorderSide(
                      color: Colors.grey,
                      width: 0.3, // Dış kenar çizgisi genişliği
                    ),
                  ),
                  filled: true, // TextField dolu görünsün
                  fillColor: Colors.grey[200], // Arka plan rengi
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
