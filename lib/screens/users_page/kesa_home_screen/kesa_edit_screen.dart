// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:toyflow/services/get_data_table.dart';

import '../../../services/user_services/dropdown_selector.dart';
import '../../../services/user_services/text_field_with_counter.dart';
import 'kesa_services/kesa_services.dart';

class KesaEditScreen extends StatefulWidget {
  const KesaEditScreen({super.key});

  @override
  State<KesaEditScreen> createState() => _KesaEditScreenState();
}

class _KesaEditScreenState extends State<KesaEditScreen> {
  final KesaServices _kesaServices = KesaServices();
  final DataTableService _dataTableService = DataTableService();

  //kullanılan stok
  final TextEditingController _miktarController = TextEditingController();
  String? _selectedMalzeme; // Seçilen ürün
  String? _selectedRenk; // Seçilen renk
  String? _selectedGramaj; // Seçilen ürün
  String? _selectedFine; // Seçilen ürün
  //eklenecek stok
  final TextEditingController _miktarDonumController = TextEditingController();

  String? _selectedDonumBoyut; // Seçilen Kumaş renk
  String? _selectedDonumRenk; // Seçilen Kumaş renk
  String? _selectedDonumMalzeme; // Seçilen ürün
  //Fire stok
  final TextEditingController _fireMiktarController = TextEditingController();
  String? _selectedFireMalzeme; // Seçilen ürün
  String? _selectedFireRenk; // Seçilen renk
  String? _selectedFireGramaj; // Seçilen renk
  String? _selectedFireFine; // Seçilen renk

  List<String> _urunler = []; // Ürün listesi
  List<String> _renkler = []; // Renk listesi
  List<String> _gramaj = []; // gramaj listesi
  List<String> _fine = []; // fine listesi

  int miktar = 0; // miktar listesi

  List<String> _donusumUrun = []; // Ürün listesi
  List<String> _boyut = []; // Ürün listesi
  List<String> _renk = []; // K

  @override
  void initState() {
    super.initState();
    _fetchData(); // Verileri Firebase'den çek
    _fetchUrunList();
    _fetchRenkList();
    _fetchBoyutList();
  }

  Future<void> _fetchUrunList() async {
    // 'iplik' koleksiyonundan verileri çekiyoruz
    List<String> fetchedUrun =
        await _dataTableService.getCollectionData('toy_name', 'name');
    setState(() {
      _donusumUrun = fetchedUrun;
    });
  }

  Future<void> _fetchRenkList() async {
    // 'iplik' koleksiyonundan verileri çekiyoruz
    List<String> fetchedUrun =
        await _dataTableService.getCollectionData('toy_renk', 'renk');
    setState(() {
      _renk = fetchedUrun;
    });
  }

  Future<void> _fetchBoyutList() async {
    // 'iplik' koleksiyonundan verileri çekiyoruz
    List<String> fetchedUrun =
        await _dataTableService.getCollectionData('toy_height', 'boyut');
    setState(() {
      _boyut = fetchedUrun;
    });
  }

  Future<void> _fetchData() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('boyama_stok').get();

      setState(() {
        _urunler = snapshot.docs
            .where((doc) => doc['miktar'] != 0)
            .map((doc) => doc['urun'] as String)
            .toSet()
            .toList();
      });
    } catch (e) {
      print("Veriler alınırken hata oluştu: $e");
    }
  }

  Future<void> _fetchColors(String selectedMalzeme) async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('boyama_stok')
          .where('urun', isEqualTo: selectedMalzeme)
          .get();

      setState(() {
        _renkler = snapshot.docs
            .where((doc) =>
                doc['miktar'] != 0) // miktar alanı 0 olmayanları filtreliyoruz
            .map((doc) => doc['renk'] as String)
            .toSet() // Aynı renklerin tekrarını önlemek için set kullanıyoruz
            .toList();
      });
    } catch (e) {
      print("Renk verileri alınırken hata oluştu: $e");
    }
  }

  Future<void> _fetchGramaj(String selectedMalzeme, String selectedRenk) async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('boyama_stok')
          .where('urun', isEqualTo: selectedMalzeme)
          .where('renk', isEqualTo: selectedRenk)
          .get();

      setState(() {
        _gramaj = snapshot.docs
            .where((doc) =>
                doc['miktar'] != 0) // miktar alanı 0 olmayanları filtreliyoruz
            .map((doc) => doc['gramaj'] as String)
            .toSet() // Aynı renklerin tekrarını önlemek için set kullanıyoruz
            .toList();
      });
    } catch (e) {
      print("Renk verileri alınırken hata oluştu: $e");
    }
  }

  Future<void> _fetchFine(String selectedMalzeme, String selectedRenk,
      String selectedGramaj) async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('boyama_stok')
          .where('urun', isEqualTo: selectedMalzeme)
          .where('renk', isEqualTo: selectedRenk)
          .where('gramaj', isEqualTo: selectedGramaj)
          .get();

      setState(() {
        _fine = snapshot.docs
            .where((doc) =>
                doc['miktar'] != 0) // miktar alanı 0 olmayanları filtreliyoruz
            .map((doc) => doc['fine'] as String)
            .toSet() // Aynı renklerin tekrarını önlemek için set kullanıyoruz
            .toList();
      });
    } catch (e) {
      print("Renk verileri alınırken hata oluştu: $e");
    }
  }

  Future<void> _fetchMiktar(String selectedIplik, String selectedRenk,
      String selectedGramaj, String selectedFine) async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('boyama_stok')
          .where('urun', isEqualTo: selectedIplik)
          .where('renk', isEqualTo: selectedRenk)
          .where('gramaj', isEqualTo: selectedGramaj)
          .where('fine', isEqualTo: selectedFine)
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
            // Ürün seçme dropdown
            DropdownSelector(
              hintText: 'Kullanılan Ürün',
              items: _urunler,
              selectedValue: _selectedMalzeme,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedMalzeme = newValue;
                  _selectedRenk = null; // Renk seçimini temizle
                  _selectedFine = null; // Renk seçimini temizle
                  _selectedGramaj = null; // Renk seçimini temizle
                  _renkler.clear(); // Renk listesini temizle
                  _gramaj.clear();
                  _fine.clear();

                  // Seçilen ürüne göre renkleri getir
                  if (_selectedMalzeme != null) {
                    _fetchColors(_selectedMalzeme!);
                  }
                });
              },
              icon: Icons.arrow_drop_down,
            ),
            // Renk seçme dropdown
            DropdownSelector(
              hintText: 'Renk',
              items: _renkler,
              selectedValue: _selectedRenk,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedRenk = newValue;
                  _selectedFine = null;
                  _selectedGramaj = null;
                  _gramaj.clear();
                  _fine.clear();
                  // Seçilen ürüne göre renkleri getir
                  if (_selectedMalzeme != null || _selectedRenk != null) {
                    _fetchGramaj(_selectedMalzeme!, _selectedRenk!);
                  }
                });
              },
              icon: Icons.arrow_drop_down,
            ),
            DropdownSelector(
              hintText: 'Gramaj',
              items: _gramaj,
              selectedValue: _selectedGramaj,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedGramaj = newValue;
                  _selectedFine = null;
                  _fine.clear();
                  // Seçilen ürüne göre renkleri getir
                  if (_selectedMalzeme != null ||
                      _selectedRenk != null ||
                      _selectedGramaj != null) {
                    _fetchFine(
                        _selectedMalzeme!, _selectedRenk!, _selectedGramaj!);
                  }
                });
              },
              icon: Icons.arrow_drop_down,
            ),
            DropdownSelector(
              hintText: 'Fine',
              items: _fine,
              selectedValue: _selectedFine,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedFine = newValue;
                  // Seçilen ürüne göre renkleri getir
                  if (_selectedMalzeme != null ||
                      _selectedRenk != null ||
                      _selectedFine != null ||
                      _selectedGramaj != null) {
                    _fetchMiktar(_selectedMalzeme!, _selectedRenk!,
                        _selectedGramaj!, _selectedFine!);
                  }
                });
              },
              icon: Icons.arrow_drop_down,
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
                  if (_selectedMalzeme!.isEmpty ||
                      _selectedRenk!.isEmpty ||
                      _miktarController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text("Lütfen tüm alanları doldurun.")),
                    );
                  } else {
                    _kesaServices.decreaseStock(
                      context: context,
                      malzeme: _selectedMalzeme!,
                      renk: _selectedRenk!,
                      gramaj: _selectedGramaj!,
                      fine: _selectedFine!,
                      miktar: int.parse(_miktarController.text),
                    );
                  }
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
              icon: Icons.arrow_drop_down,
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
              icon: Icons.arrow_drop_down,
            ),
            // boyut seçme dropdown
            DropdownSelector(
              hintText: 'Boyut',
              items: _boyut,
              selectedValue: _selectedDonumBoyut,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedDonumBoyut = newValue;
                });
              },
              icon: Icons.arrow_drop_down,
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
                  if (_selectedDonumMalzeme!.isEmpty ||
                      _selectedDonumRenk!.isEmpty ||
                      _selectedDonumBoyut!.isEmpty ||
                      _miktarDonumController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text("Lütfen tüm alanları doldurun.")),
                    );
                  } else {
                    _kesaServices.addOrUpdateUrunStock(
                      context: context,
                      urun: _selectedDonumMalzeme!,
                      urunRenk: _selectedDonumRenk!,
                      boyut: _selectedDonumBoyut!,
                      miktar: int.parse(_miktarDonumController.text),
                    );
                  }
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
                  _selectedFireRenk = null;
                  _selectedFireFine=null;
                  _selectedFireGramaj=null;
                  _renkler.clear(); // Renk listesini temizle
                  _gramaj.clear();
                  _fine.clear();
                  if (_selectedFireMalzeme != null) {
                    _fetchColors(_selectedFireMalzeme!);
                  }
                });
              },
              icon: Icons.arrow_drop_down,
            ),
            // Renk seçme dropdown

            DropdownSelector(
              hintText: 'Renk',
              items: _renkler,
              selectedValue: _selectedFireRenk,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedFireRenk = newValue;
                  _selectedFireFine=null;
                  _selectedFireGramaj=null;
                  _gramaj.clear();
                  _fine.clear();
                  if (_selectedFireRenk != null||_selectedFireMalzeme != null) {
                    _fetchGramaj(_selectedFireMalzeme!, _selectedFireRenk!);
                  }
                });
              },
              icon: Icons.arrow_drop_down,
            ),
            DropdownSelector(
              hintText: 'Gramaj',
              items: _gramaj,
              selectedValue: _selectedFireGramaj,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedFireGramaj = newValue;
                  _selectedFireFine=null;
                  _fine.clear();
                  if (_selectedFireGramaj != null) {
                    _fetchFine(_selectedFireMalzeme!, _selectedFireRenk!,
                        _selectedFireGramaj!);
                  }
                });
              },
              icon: Icons.arrow_drop_down,
            ),
            DropdownSelector(
              hintText: 'Fine',
              items: _fine,
              selectedValue: _selectedFireFine,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedFireFine = newValue;
                  if (_selectedFireFine != null||_selectedFireRenk != null||_selectedFireMalzeme != null) {
                    _fetchMiktar(_selectedFireMalzeme!, _selectedFireRenk!,
                        _selectedFireGramaj!, _selectedFireFine!);
                  }
                });
              },
              icon: Icons.arrow_drop_down,
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
              controller: _fireMiktarController,
              hintText: 'Miktar',
              icon: Icons.shopping_cart,
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  if (_selectedFireMalzeme!.isEmpty ||
                      _selectedFireRenk!.isEmpty ||
                      _fireMiktarController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text("Lütfen tüm alanları doldurun.")),
                    );
                  } else {
                    _kesaServices.decreaseStock(
                      context: context,
                      malzeme: _selectedFireMalzeme!,
                      renk: _selectedFireRenk!,
                      gramaj: _selectedFireGramaj!,
                      fine: _selectedFireFine!,
                      miktar: int.parse(_fireMiktarController.text),
                    );
                    _kesaServices.addFireEntry(
                      context: context,
                      malzeme: _selectedFireMalzeme!,
                      renk: _selectedFireRenk!,
                      miktar: int.parse(_fireMiktarController.text),
                    );
                  }
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
