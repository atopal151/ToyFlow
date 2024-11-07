import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'DokaServices/doka_services.dart';
import '../../../services/user_services/dropdown_selector.dart';
import '../../../services/user_services/text_field_with_counter.dart';

class DokaEditScreen extends StatefulWidget {
  const DokaEditScreen({super.key});

  @override
  State<DokaEditScreen> createState() => _DokaEditScreenState();
}

class _DokaEditScreenState extends State<DokaEditScreen> {
  final DokaServices _dokaServices = DokaServices();

  // kullanılan stok
  final TextEditingController _miktarController = TextEditingController();
  String? _selectedMalzeme; // Seçilen iplik
  String? _selectedRenk; // Seçilen iplik rengi

  // eklenecek kumaş stok
  final TextEditingController _miktarDonumController = TextEditingController();
  String? _selectedDonumRenk; // Seçilen kumaş rengi
  String? _selectedDonumMalzeme; // Seçilen kumaş

  // fire stok
  final TextEditingController _fireMiktarController = TextEditingController();
  String? _selectedFireMalzeme; // Seçilen fire ipliği
  String? _selectedFireRenk; // Seçilen fire rengi

  List<String> _urunler = []; // İplik listesi
  List<String> _renkler = []; // Renk listesi

  int miktar = 0; // miktar listesi

  final List<String> _kumaslar = [
    'Polar Fleece Kumaş',
    'Mikrofiber Peluş Kumaş',
    'Süet Kumaş',
    'Minky Kumaş',
    'Tüylü Kumaş',
    'Velboa Kumaş'
  ]; // Kumaş listesi

  final List<String> _renk = [
    'Kırmızı',
    'Siyah',
    'Beyaz',
    'Turuncu',
    'Pembe',
    'Gri'
  ]; // Kumaş listesi
  @override
  void initState() {
    super.initState();
    _fetchData(); // Verileri Firebase'den çek
  }

  // İplik verilerini Firebase'den çek
  Future<void> _fetchData() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('dokuma_work').get();

      setState(() {
        _urunler =
            snapshot.docs.map((doc) => doc['urun'] as String).toSet().toList();
      });
    } catch (e) {
      print("Veriler alınırken hata oluştu: $e");
    }
  }

  Future<void> _fetchColors(String selectedIplik) async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('dokuma_work')
          .where('urun', isEqualTo: selectedIplik)
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

  Future<void> _fetchMiktar(String selectedIplik, String selectedRenk) async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('dokuma_work')
          .where('urun', isEqualTo: selectedIplik)
          .where('renk', isEqualTo: selectedRenk)
          .get();

      setState(() {
        miktar = snapshot.docs.isNotEmpty
            ? snapshot.docs.first['miktar'] as int // İlk belge miktarını al
            : 0; // Eğer belge yoksa 0 olarak ayarla
      });
    } catch (e) {
      print("Miktar verileri alınırken hata oluştu: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /*---------------------------------------------------*/
            // Kullanılan iplik seçme dropdown
            // Ürün seçme dropdown
            DropdownSelector(
              hintText: 'Kullanılan Ürün',
              items: _urunler,
              selectedValue: _selectedMalzeme,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedMalzeme = newValue;
                  _selectedRenk = null; // Renk seçimini temizle
                  _renkler.clear(); // Renk listesini temizle

                  // Seçilen ürüne göre renkleri getir
                  if (_selectedMalzeme != null) {
                    _fetchColors(_selectedMalzeme!);
                  }
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

            Padding(
              padding: const EdgeInsets.only(
                left: 35.0,
                top: 15,
              ),
              child: Text(
                'Hazır Stok: $miktar adet', // Güncellenmiş miktarı gösterir
                style:
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.w300),
              ),
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
                   if (_miktarController.text == "" ||
                      _miktarController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text("Lütfen tüm alanları doldurun.")),
                    );
                  } else {
                  _dokaServices.decreaseStock(
                    context: context,
                    malzeme: _selectedMalzeme!,
                    renk: _selectedRenk!,
                    miktar: int.parse(_miktarController.text),
                  );}
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
            // Dönüştürülen kumaşı seç
            DropdownSelector(
              hintText: 'Dönüştürülen Ürün',
              items: _kumaslar,
              selectedValue: _selectedDonumMalzeme,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedDonumMalzeme = newValue;
                });
              },
              icon: Icons.cut,
            ),
            // Kumaş rengini seç
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
            // Miktar gir
            TextFieldWithCounter(
              controller: _miktarDonumController,
              hintText: 'Miktar',
              icon: Icons.shopping_cart,
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  if (_miktarDonumController.text == "" ||
                      _miktarDonumController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text("Lütfen tüm alanları doldurun.")),
                    );
                  } else {
                  _dokaServices.addOrUpdateKumasStock(
                    context: context,
                    kumas: _selectedDonumMalzeme!,
                    kumasRenk: _selectedDonumRenk!,
                    miktar: int.parse(_miktarDonumController.text),
                  );}
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
            // Fire düşülecek ipliği seç
            DropdownSelector(
              hintText: 'Fire Ürün',
              items: _urunler,
              selectedValue: _selectedFireMalzeme,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedFireMalzeme = newValue;
                  _fetchColors(
                      newValue!); // Fire ipliğine göre renkleri güncelle
                });
              },
              icon: Icons.cut,
            ),
            // Fire rengi seç
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
            // Miktar gir
            TextFieldWithCounter(
              controller: _fireMiktarController,
              hintText: 'Miktar',
              icon: Icons.shopping_cart,
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  if (_fireMiktarController.text == "" ||
                      _fireMiktarController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text("Lütfen tüm alanları doldurun.")),
                    );
                  } else {
                  _dokaServices.decreaseStock(
                    context: context,
                    malzeme: _selectedFireMalzeme!,
                    renk: _selectedFireRenk!,
                    miktar: int.parse(_fireMiktarController.text),
                  );
                  _dokaServices.addFireEntry(
                    malzeme: _selectedFireMalzeme!,
                    renk: _selectedFireRenk!,
                    miktar: int.parse(_fireMiktarController.text),
                  );}
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
