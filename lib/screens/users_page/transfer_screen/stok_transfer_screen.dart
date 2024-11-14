// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../services/get_data_table.dart';
import '../../../services/user_services/dropdown_selector.dart';
import '../../../services/user_services/text_field_with_counter.dart';
import 'transfer_services/transfer_services.dart';

class StokTransfer extends StatefulWidget {
  const StokTransfer({super.key});

  @override
  State<StokTransfer> createState() => _StokTransferState();
}

class _StokTransferState extends State<StokTransfer> {
  final TransferServices _transferServices = TransferServices();
  final DataTableService _dataTableService =
      DataTableService(); // DataTableService örneği

  // Aktarılacak stok
  final TextEditingController _miktarController = TextEditingController();
  String? _selectedMalzeme; // Seçilen ürün
  String? _selectedRenk; // Seçilen renk
  String? _selectedBoyut; // Seçilen boyut
  String? _selectedAksesuar; // Seçilen aksesuar

  List<String> _urunler = []; // Ürün listesi
  List<String> _renkler = []; // Renk listesi
  List<String> _boyutlar = []; // Boyut listesi
  List<String> _aksesuarlar = []; // Aksesuar listesi

  String? _selectedDepo; // Seçilen renk

  String? _selectedGetDepo; // Seçilen renk

  List<String> _depolar = []; // Ürün listesi

  int miktar = 0; // Stok miktarı

  @override
  void initState() {
    super.initState();
    _fetchData(); // Verileri Firebase'den çek
    _fetchDepolar();
  }

// Dinamik olarak depoları Firestore'dan çeken fonksiyon
  Future<void> _fetchDepolar() async {
    final List<String> depolar =
        await _dataTableService.getCollectionData('depolar', 'title');
    setState(() {
      _depolar = depolar; // Çekilen depolar listesi
    });
  }

  // Firebase'den ürün listesini çekme
  Future<void> _fetchData() async {
    try {
      // _getDepoCollection ile dinamik olarak depo koleksiyonunu alıyoruz
      String collectionPath =
          await _transferServices.getDepoCollection(_selectedDepo ?? '');
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection(collectionPath).get();

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

// Firebase'den renk listesini çekme
  Future<void> _fetchColors(String selectedMalzeme) async {
    try {
      String collectionPath =
          await _transferServices.getDepoCollection(_selectedDepo ?? '');
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection(collectionPath)
          .where('urun', isEqualTo: selectedMalzeme)
          .get();

      setState(() {
        _renkler = snapshot.docs
            .where((doc) => doc['miktar'] != 0)
            .map((doc) => doc['renk'] as String)
            .toSet()
            .toList();
      });
    } catch (e) {
      print("Renk verileri alınırken hata oluştu: $e");
    }
  }

// Firebase'den boyut listesini çekme
  Future<void> _fetchBoyut(String selectedMalzeme, String selectedRenk) async {
    try {
      String collectionPath =
          await _transferServices.getDepoCollection(_selectedDepo ?? '');
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection(collectionPath)
          .where('urun', isEqualTo: selectedMalzeme)
          .where('renk', isEqualTo: selectedRenk)
          .get();

      setState(() {
        _boyutlar = snapshot.docs
            .where((doc) => doc['miktar'] != 0)
            .map((doc) => doc['boyut'] as String)
            .toSet()
            .toList();
      });
    } catch (e) {
      print("Boyut verileri alınırken hata oluştu: $e");
    }
  }

// Firebase'den aksesuar listesini çekme
  Future<void> _fetchAksesuar(
      String selectedMalzeme, String selectedRenk, String selectedBoyut) async {
    try {
      String collectionPath =
          await _transferServices.getDepoCollection(_selectedDepo ?? '');
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection(collectionPath)
          .where('urun', isEqualTo: selectedMalzeme)
          .where('renk', isEqualTo: selectedRenk)
          .where('boyut', isEqualTo: selectedBoyut)
          .get();

      setState(() {
        _aksesuarlar = snapshot.docs
            .where((doc) => doc['miktar'] != 0)
            .map((doc) => doc['aksesuar'] as String)
            .toSet()
            .toList();
      });
    } catch (e) {
      print("Aksesuar verileri alınırken hata oluştu: $e");
    }
  }

// Firebase'den miktar bilgisini çekme
  Future<void> _fetchMiktar(String selectedIplik, String selectedRenk,
      String selectedBoyut, String selectedAksesuar) async {
    try {
      String collectionPath =
          await _transferServices.getDepoCollection(_selectedDepo ?? '');
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection(collectionPath)
          .where('urun', isEqualTo: selectedIplik)
          .where('renk', isEqualTo: selectedRenk)
          .where('boyut', isEqualTo: selectedBoyut)
          .where('aksesuar', isEqualTo: selectedAksesuar)
          .get();

      setState(() {
        miktar =
            snapshot.docs.isNotEmpty ? snapshot.docs.first['miktar'] as int : 0;
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
            DropdownSelector(
              hintText: 'Ürün Alınacak Depo',
              items: _depolar,
              selectedValue: _selectedDepo,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedMalzeme = null;
                  _selectedRenk = null;
                  _selectedBoyut = null;
                  _selectedAksesuar = null;

                  _urunler.clear();
                  _renkler.clear();
                  _boyutlar.clear();
                  _aksesuarlar.clear();
                  _selectedDepo = newValue;
                  _fetchData(); // Seçilen depoya göre verileri Firebase'den çek
                });
              },
              icon: Icons.fire_truck,
            ),
            DropdownSelector(
              hintText: 'Ürün',
              items: _urunler,
              selectedValue: _selectedMalzeme,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedMalzeme = newValue;
                  _selectedRenk = null;
                  _selectedBoyut = null;
                  _selectedAksesuar = null;
                  _renkler.clear();
                  _boyutlar.clear();
                  _aksesuarlar.clear();

                  if (_selectedMalzeme != null) {
                    _fetchColors(_selectedMalzeme!);
                  }
                });
              },
              icon: Icons.arrow_drop_down,
            ),
            DropdownSelector(
              hintText: 'Renk',
              items: _renkler,
              selectedValue: _selectedRenk,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedRenk = newValue;
                  _selectedBoyut = null;
                  _selectedAksesuar = null;
                  _boyutlar.clear();
                  _aksesuarlar.clear();

                  if (_selectedMalzeme != null && _selectedRenk != null) {
                    _fetchBoyut(_selectedMalzeme!, _selectedRenk!);
                  }
                });
              },
              icon: Icons.arrow_drop_down,
            ),
            DropdownSelector(
              hintText: 'Boyut',
              items: _boyutlar,
              selectedValue: _selectedBoyut,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedBoyut = newValue;
                  _selectedAksesuar = null;
                  _aksesuarlar.clear();

                  if (_selectedMalzeme != null &&
                      _selectedRenk != null &&
                      _selectedBoyut != null) {
                    _fetchAksesuar(
                        _selectedMalzeme!, _selectedRenk!, _selectedBoyut!);
                  }
                });
              },
              icon: Icons.arrow_drop_down,
            ),
            DropdownSelector(
              hintText: 'Aksesuar',
              items: _aksesuarlar,
              selectedValue: _selectedAksesuar,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedAksesuar = newValue;

                  if (_selectedMalzeme != null &&
                      _selectedRenk != null &&
                      _selectedBoyut != null &&
                      _selectedAksesuar != null) {
                    _fetchMiktar(_selectedMalzeme!, _selectedRenk!,
                        _selectedBoyut!, _selectedAksesuar!);
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
                'Hazır Stok: $miktar adet',
                style:
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.w300),
              ),
            ),
            TextFieldWithCounter(
              controller: _miktarController,
              hintText: 'Miktar',
              icon: Icons.shopping_cart,
            ),
            DropdownSelector(
              hintText: 'Ürün Aktarılacak Depo',
              items: _depolar,
              selectedValue: _selectedGetDepo,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedGetDepo = newValue;
                  if (_selectedDepo == _selectedGetDepo) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Aynı Depoyu Seçemezsin")),
                    );
                  }
                });
              },
              icon: Icons.add_box,
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  if (_miktarController.text.isEmpty ||
                      _selectedAksesuar!.isEmpty ||
                      _selectedBoyut!.isEmpty ||
                      _selectedDepo!.isEmpty ||
                      _selectedGetDepo!.isEmpty ||
                      _selectedMalzeme!.isEmpty ||
                      _selectedRenk!.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text("Lütfen tüm alanları doldurun.")),
                    );
                  } else {
                    print(
                        "$_selectedDepo $_selectedGetDepo $_selectedMalzeme  $_selectedRenk $_selectedBoyut $_selectedAksesuar $_miktarController");
                    _transferServices.addOrUpdateUrunStock(
                      context: context,
                      addDepo: _selectedGetDepo!,
                      urun: _selectedMalzeme!,
                      boyut: _selectedBoyut!,
                      urunRenk: _selectedRenk!,
                      aksesuar: _selectedAksesuar!,
                      miktar: int.parse(_miktarController.text),
                    );
                    _transferServices.decreaseStock(
                      context: context,
                      downDepo: _selectedDepo!,
                      malzeme: _selectedMalzeme!,
                      boyut: _selectedBoyut!,
                      renk: _selectedRenk!,
                      aksesuar: _selectedAksesuar!,
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
                      'Aktar',
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
          ],
        ),
      ),
    );
  }
}
