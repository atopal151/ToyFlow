// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:toyflow/screens/usersPage/dolaHomeScreen/dola_services/dola_services.dart';

import '../../../services/user_services/dropdown_selector.dart';
import '../../../services/user_services/text_field_with_counter.dart';

class DolaEditScreen extends StatefulWidget {
  const DolaEditScreen({super.key});

  @override
  State<DolaEditScreen> createState() => _DolaEditScreenState();
}

class _DolaEditScreenState extends State<DolaEditScreen> {
  final DolaServices _dolaServices = DolaServices();

  //kullanılan stok
  final TextEditingController _miktarController = TextEditingController();
  String? _selectedMalzeme; // Seçilen ürün
  String? _selectedRenk; // Seçilen renk
  String? _selectedBoyut; // Seçilen Kumaş renk
  //eklenecek stok
  final TextEditingController _miktarDonumController = TextEditingController();

  String? _selectedDonumBoyut; // Seçilen Kumaş renk
  String? _selectedDonumRenk; // Seçilen Kumaş renk
  String? _selectedDonumMalzeme; // Seçilen ürün
  //Fire stok
  final TextEditingController _fireMiktarController = TextEditingController();
  String? _selectedFireMalzeme; // Seçilen ürün
  String? _selectedFireBoyut; // Seçilen ürün
  String? _selectedFireRenk; // Seçilen renk

  List<String> _urunler = []; // Ürün listesi
  List<String> _renkler = []; // Renk listesi
  List<String> _boyutlar = []; // Renk listesi

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

  final List<String> _renk = [
    'Kırmızı',
    'Siyah',
    'Beyaz',
    'Turuncu',
    'Pembe',
    'Gri'
  ]; // K

  @override
  void initState() {
    super.initState();
    _fetchData(); // Verileri Firebase'den çek
  }

  Future<void> _fetchData() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('dikim_stok').get();

      setState(() {
        _urunler =
            snapshot.docs.map((doc) => doc['urun'] as String).toSet().toList();
        _boyutlar =
            snapshot.docs.map((doc) => doc['boyut'] as String).toSet().toList();
        _renkler =
            snapshot.docs.map((doc) => doc['renk'] as String).toSet().toList();
      });
    } catch (e) {
      print("Veriler alınırken hata oluştu: $e");
    }
  }

  Future<void> _fetchColors(String selectedMalzeme) async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('dikim_stok')
          .where('urun', isEqualTo: selectedMalzeme)
          .get();

      setState(() {
        _renkler = snapshot.docs
            .map((doc) => doc['renk'] as String)
            .toSet() // Aynı renklerin tekrarını önlemek için set kullanıyoruz
            .toList();
      });
    } catch (e) {
      print("Renk verileri alınırken hata oluştu: $e");
    }
  }

  Future<void> _fetchBoyut(String selectedMalzeme, String selectedRenk) async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('dikim_stok')
          .where('urun', isEqualTo: selectedMalzeme)
          .where('renk', isEqualTo: selectedRenk)
          .get();

      setState(() {
        _boyutlar = snapshot.docs
            .map((doc) => doc['boyut'] as String)
            .toSet() // Aynı renklerin tekrarını önlemek için set kullanıyoruz
            .toList();
      });
    } catch (e) {
      print("Renk verileri alınırken hata oluştu: $e");
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
              hintText: 'Kullanılan Ürün',
              items: _urunler,
              selectedValue: _selectedMalzeme,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedMalzeme = newValue;
                  _fetchColors(
                      newValue!); // Seçilen ipliğe göre renkleri güncelle
                });
              },
              icon: Icons.cut,
            ),

            // Renk seçme dropdown
            DropdownSelector(
              hintText: 'Renk',
              items: _renkler,
              selectedValue: _selectedRenk,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedRenk = newValue;
                });
              },
              icon: Icons.color_lens,
            ),
            // boyut seçme dropdown
            DropdownSelector(
              hintText: 'Boyut',
              items: _boyutlar,
              selectedValue: _selectedBoyut,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedBoyut = newValue;
                  if (_selectedMalzeme != null && _selectedRenk != null) {
                    _fetchBoyut(_selectedMalzeme!,
                        _selectedRenk!); // Ürün ve renge göre boyutları getir
                  }
                });
              },
              icon: Icons.height,
            ),
            // Miktar girme
            TextFieldWithCounter(
              controller: _miktarController,
              hintText: 'Miktar',
              icon: Icons.shopping_cart,
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  _dolaServices.decreaseStock(
                    context: context,
                    malzeme: _selectedMalzeme!,
                    boyut: _selectedBoyut!,
                    renk: _selectedRenk!,
                    miktar: int.parse(_miktarController.text),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 49, 51, 52),
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
              hintText: 'Dönüştürülen Ürün',
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
              hintText: 'Renk',
              items: _renk,
              selectedValue: _selectedDonumRenk,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedDonumRenk = newValue;
                });
              },
              icon: Icons.color_lens,
            ),
            // boyut seçme dropdown
            DropdownSelector(
              hintText: ' Boyut',
              items: _boyut,
              selectedValue: _selectedDonumBoyut,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedDonumBoyut = newValue;
                });
              },
              icon: Icons.height,
            ),
            // Miktar girme
            TextFieldWithCounter(
              controller: _miktarDonumController,
              hintText: 'Miktar',
              icon: Icons.shopping_cart,
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  _dolaServices.addOrUpdateUrunStock(
                    context: context,
                    urun: _selectedDonumMalzeme!,
                    urunRenk: _selectedDonumRenk!,
                    boyut: _selectedDonumBoyut!,
                    miktar: int.parse(_miktarDonumController.text),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 49, 51, 52),
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
                      'Stok Ekle',
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
              hintText: 'Fire Ürün',
              items: _urunler,
              selectedValue: _selectedFireMalzeme,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedFireMalzeme = newValue;
                  _fetchColors(
                      newValue!); // Seçilen ipliğe göre renkleri güncelle
                });
              },
              icon: Icons.cut,
            ),

            // Renk seçme dropdown

            DropdownSelector(
              hintText: 'Renk',
              items: _renkler,
              selectedValue: _selectedFireRenk,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedFireRenk = newValue;
                });
              },
              icon: Icons.color_lens,
            ),
// boyut seçme dropdown
            DropdownSelector(
              hintText: 'Boyut',
              items: _boyutlar,
              selectedValue: _selectedFireBoyut,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedFireBoyut = newValue;
                });
              },
              icon: Icons.height,
            ),
            // Miktar girme
            TextFieldWithCounter(
              controller: _fireMiktarController,
              hintText: 'Miktar',
              icon: Icons.shopping_cart,
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  // Null kontrolü
                  if (_selectedFireMalzeme == null ||
                      _selectedFireBoyut == null ||
                      _selectedFireRenk == null ||
                      _fireMiktarController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Lütfen tüm alanları doldurun')),
                    );
                    return;
                  }

                  _dolaServices.decreaseStock(
                    context: context,
                    malzeme: _selectedFireMalzeme!,
                    boyut: _selectedFireBoyut!,
                    renk: _selectedFireRenk!,
                    miktar: int.parse(_fireMiktarController.text),
                  );

                  _dolaServices.addFireEntry(
                    malzeme: _selectedFireMalzeme!,
                    boyut: _selectedFireBoyut!,
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
                      'Fire Ekle',
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
