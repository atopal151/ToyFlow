// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../services/user_services/dropdown_selector.dart';
import '../../../services/user_services/text_field_with_counter.dart';
import 'KesaServices/kesa_services.dart';

class KesaEditScreen extends StatefulWidget {
  const KesaEditScreen({super.key});

  @override
  State<KesaEditScreen> createState() => _KesaEditScreenState();
}

class _KesaEditScreenState extends State<KesaEditScreen> {
  final KesaServices _kesaServices = KesaServices();

  //kullanılan stok
  final TextEditingController _miktarController = TextEditingController();
  String? _selectedMalzeme; // Seçilen ürün
  String? _selectedRenk; // Seçilen renk
  //eklenecek stok
  final TextEditingController _miktarKumasController = TextEditingController();

  String? _selectedBoyut; // Seçilen Kumaş renk
  String? _selectedKumasRenk; // Seçilen Kumaş renk
  String? _selectedDonumMalzeme; // Seçilen ürün
  //Fire stok
  final TextEditingController _fireMiktarController = TextEditingController();
  String? _selectedFireMalzeme; // Seçilen ürün
  String? _selectedFireRenk; // Seçilen renk

  List<String> _urunler = []; // Ürün listesi
  List<String> _renkler = []; // Renk listesi

  final List<String> _donusumUrun = [
    'Çilek Tavşan',
    'Havuç Tavşan',
    'Kapşonlu Panda',
    'Su Samuru',
    'Bambu Panda',
    'Peluş Ayı'
  ]; // Ürün listesi

  final List<String> _boyut = [
    '30',
    '40',
    '50',
    '60',
    '70',
    '80',
    '90',
    '100'
  ]; // Ürün listesi

  @override
  void initState() {
    super.initState();
    _fetchData(); // Verileri Firebase'den çek
  }

  Future<void> _fetchData() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('dokuma_stok').get();

      setState(() {
        _urunler =
            snapshot.docs.map((doc) => doc['urun'] as String).toSet().toList();
        _renkler =
            snapshot.docs.map((doc) => doc['renk'] as String).toSet().toList();
      });
    } catch (e) {
      print("Veriler alınırken hata oluştu: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            /*---------------------------------------------------*/
            // Ürün seçme dropdown
            DropdownSelector(
              hintText: 'Kullanılan ürünü seç',
              items: _urunler,
              selectedValue: _selectedMalzeme,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedMalzeme = newValue;
                });
              },
              icon: Icons.cut,
            ),
            // Renk seçme dropdown
            DropdownSelector(
              hintText: 'Ürün rengini seç',
              items: _renkler,
              selectedValue: _selectedRenk,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedRenk = newValue;
                });
              },
              icon: Icons.color_lens,
            ),
            // Miktar girme
            TextFieldWithCounter(
              controller: _miktarController,
              hintText: 'Miktar Gir',
              icon: Icons.shopping_cart,
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  _kesaServices.decreaseStock(
                    context: context,
                    malzeme: _selectedMalzeme!,
                    renk: _selectedRenk!,
                    miktar: int.parse(_miktarController.text),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 86, 157, 185),
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(width: 8),
                    Text(
                      'Düşüm Yap',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            /*---------------------------------------------------*/

            const SizedBox(
              height: 20,
            ),
            // Ürün seçme dropdown
            DropdownSelector(
              hintText: 'Dönüştürülen ürünü seç',
              items: _donusumUrun,
              selectedValue: _selectedDonumMalzeme,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedDonumMalzeme = newValue;
                });
              },
              icon: Icons.cut,
            ),
            // Renk seçme dropdown
            DropdownSelector(
              hintText: 'Ürün rengini seç',
              items: _renkler,
              selectedValue: _selectedKumasRenk,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedKumasRenk = newValue;
                });
              },
              icon: Icons.color_lens,
            ),
             // boyut seçme dropdown
            DropdownSelector(
              hintText: ' Ürünün boyutunu seç',
              items: _boyut,
              selectedValue: _selectedBoyut,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedBoyut = newValue;
                });
              },
              icon: Icons.height,
            ),
            // Miktar girme
            TextFieldWithCounter(
              controller: _miktarKumasController,
              hintText: 'Miktar Gir',
              icon: Icons.shopping_cart,
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  _kesaServices.addOrUpdateUrunStock(
                    context: context,
                    urun: _selectedDonumMalzeme!,
                    urunRenk: _selectedKumasRenk!,
                    boyut: _selectedBoyut!,
                    miktar: int.parse(_miktarKumasController.text),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 111, 183, 117),
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(width: 8),
                    Text(
                      'Stok kaydı gir',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(
              height: 20,
            ),

            /*---------------------------------------------------*/
            // Ürün seçme dropdown

            DropdownSelector(
              hintText: 'Fire düşülecek ürünü seç',
              items: _urunler,
              selectedValue: _selectedFireMalzeme,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedFireMalzeme = newValue;
                });
              },
              icon: Icons.cut,
            ),
            // Renk seçme dropdown

            DropdownSelector(
              hintText: 'Ürün rengini seç',
              items: _renkler,
              selectedValue: _selectedFireRenk,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedFireRenk = newValue;
                });
              },
              icon: Icons.color_lens,
            ),

            // Miktar girme
            TextFieldWithCounter(
              controller: _fireMiktarController,
              hintText: 'Miktar Gir',
              icon: Icons.shopping_cart,
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  _kesaServices.decreaseStock(
                    context: context,
                    malzeme: _selectedFireMalzeme!,
                    renk: _selectedFireRenk!,
                    miktar: int.parse(_fireMiktarController.text),
                  );
                  _kesaServices.addFireEntry(
                    malzeme: _selectedFireMalzeme!,
                    renk: _selectedFireRenk!,
                    miktar: int.parse(_fireMiktarController.text),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 223, 99, 90),
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(width: 8),
                    Text(
                      'Fire kaydı gir',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            /*---------------------------------------------------*/
          ],
        ),
      ),
    );
  }
}