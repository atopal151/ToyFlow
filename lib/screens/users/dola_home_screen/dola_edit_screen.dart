// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:toyflow/screens/users/dola_home_screen/dola_services/dola_services.dart';
import 'package:toyflow/services/get_data_table.dart';

import '../../../services/user_services/cutom_loading_button.dart';
import '../../../services/user_services/dropdown_selector.dart';
import '../../../services/user_services/text_field_with_counter.dart';

class DolaEditScreen extends StatefulWidget {
  const DolaEditScreen({super.key});

  @override
  State<DolaEditScreen> createState() => _DolaEditScreenState();
}

class _DolaEditScreenState extends State<DolaEditScreen> {
  bool isLoading = false;
  bool isLoading1 = false;
  bool isLoading2 = false;
  final DolaServices _dolaServices = DolaServices();
  final DataTableService _dataTableService = DataTableService();

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
          await FirebaseFirestore.instance.collection('dikim_stok').get();

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
          .collection('dikim_stok')
          .where('urun', isEqualTo: selectedMalzeme)
          .get();

      setState(() {
        _renkler = snapshot.docs
            .where((doc) => doc['miktar'] != 0)
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
            .where((doc) => doc['miktar'] != 0)
            .map((doc) => doc['boyut'] as String)
            .toSet() // Aynı renklerin tekrarını önlemek için set kullanıyoruz
            .toList();
      });
    } catch (e) {
      print("Renk verileri alınırken hata oluştu: $e");
    }
  }

  Future<void> _fetchMiktar(
      String selectedIplik, String selectedRenk, String selectedBoyut) async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('dikim_stok')
          .where('urun', isEqualTo: selectedIplik)
          .where('renk', isEqualTo: selectedRenk)
          .where('boyut', isEqualTo: selectedBoyut)
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
            // Ürün seçme dropdown
            DropdownSelector(
              hintText: 'Kullanılan Ürün',
              items: _urunler,
              selectedValue: _selectedMalzeme,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedMalzeme = newValue;
                  _selectedRenk = null; // Renk seçimini temizle
                  _selectedBoyut = null; // Boyut seçimini temizle
                  _renkler.clear(); // Renk listesini temizle
                  _boyutlar.clear(); // Boyut listesini temizle

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
                  _selectedBoyut = null; // Boyut seçimini temizle
                  _boyutlar.clear(); // Boyut listesini temizle

                  // Seçilen renge göre boyutları getir
                  if (_selectedMalzeme != null && _selectedRenk != null) {
                    _fetchBoyut(_selectedMalzeme!, _selectedRenk!);
                  }
                });
              },
              icon: Icons.arrow_drop_down,
            ),

// Boyut seçme dropdown
            DropdownSelector(
              hintText: 'Boyut',
              items: _boyutlar,
              selectedValue: _selectedBoyut,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedBoyut = newValue;

                  // Ürün, renk ve boyuta göre miktarı getir
                  if (_selectedMalzeme != null &&
                      _selectedRenk != null &&
                      _selectedBoyut != null) {
                    _fetchMiktar(
                        _selectedMalzeme!, _selectedRenk!, _selectedBoyut!);
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
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextFieldWithCounter(
                    controller: _miktarController,
                    hintText: 'Miktar',
                    icon: Icons.shopping_cart,
                  ),
                ),
                CustomLoadingButton(
                  isLoading: isLoading,
                  onPressed: () async {
                    setState(() {
                      isLoading = true;
                    });

                    try {
                      if (_selectedMalzeme!.isEmpty ||
                          _selectedBoyut!.isEmpty ||
                          _selectedRenk!.isEmpty ||
                          _miktarController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Lütfen tüm alanları doldurun.")),
                        );
                      } else {
                        _dolaServices.decreaseStock(
                          context: context,
                          malzeme: _selectedMalzeme!,
                          boyut: _selectedBoyut!,
                          renk: _selectedRenk!,
                          miktar: int.parse(_miktarController.text),
                        );
                      }
                      // Burada işlemlerini gerçekleştirebilirsin
                      await Future.delayed(
                          const Duration(seconds: 1)); // Örnek bir gecikme
                    } finally {
                      setState(() {
                        isLoading = false;
                      });
                    }
                  },
                  text: "Düşüm Yap ",
                ),
              ],
            ),

            const SizedBox(
              height: 20,
            ),
            const Divider(),
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
              hintText: ' Boyut',
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
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextFieldWithCounter(
                    controller: _miktarDonumController,
                    hintText: 'Miktar',
                    icon: Icons.shopping_cart,
                  ),
                ),
                CustomLoadingButton(
                  isLoading: isLoading1,
                  onPressed: () async {
                    setState(() {
                      isLoading1 = true;
                    });

                    try {
                      if (_selectedDonumMalzeme!.isEmpty ||
                          _selectedDonumRenk!.isEmpty ||
                          _selectedDonumBoyut!.isEmpty ||
                          _miktarDonumController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Lütfen tüm alanları doldurun.")),
                        );
                      } else {
                        _dolaServices.addOrUpdateUrunStock(
                          context: context,
                          urun: _selectedDonumMalzeme!,
                          urunRenk: _selectedDonumRenk!,
                          boyut: _selectedDonumBoyut!,
                          miktar: int.parse(_miktarDonumController.text),
                        );
                      }
                      // Burada işlemlerini gerçekleştirebilirsin
                      await Future.delayed(
                          const Duration(seconds: 1)); // Örnek bir gecikme
                    } finally {
                      setState(() {
                        isLoading1 = false;
                      });
                    }
                  },
                  text: "Stok Ekle",
                ),
              ],
            ),

            const SizedBox(
              height: 20,
            ),
            const Divider(),
            /*---------------------------------------------------*/
            const SizedBox(
              height: 20,
            ),
            DropdownSelector(
              hintText: 'Fire Ürün',
              items: _urunler,
              selectedValue: _selectedFireMalzeme,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedFireMalzeme = newValue;
                  _selectedFireRenk = null; // Renk seçimini temizle
                  _selectedFireBoyut = null; // Boyut seçimini temizle
                  _renkler.clear(); // Renk listesini temizle
                  _boyutlar.clear(); // Boyut listesini temizle

                  // Seçilen ürüne göre renkleri getir
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
                  _selectedFireBoyut = null; // Boyut seçimini temizle
                  _boyutlar.clear(); // Boyut listesini temizle

                  // Seçilen renge göre boyutları getir
                  if (_selectedFireMalzeme != null &&
                      _selectedFireRenk != null) {
                    _fetchBoyut(_selectedFireMalzeme!, _selectedFireRenk!);
                  }
                });
              },
              icon: Icons.arrow_drop_down,
            ),
// boyut seçme dropdown
            DropdownSelector(
              hintText: 'Boyut',
              items: _boyutlar,
              selectedValue: _selectedFireBoyut,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedFireBoyut = newValue;
                  // Ürün, renk ve boyuta göre miktarı getir
                  if (_selectedFireMalzeme != null &&
                      _selectedFireRenk != null &&
                      _selectedFireBoyut != null) {
                    _fetchMiktar(_selectedFireMalzeme!, _selectedFireRenk!,
                        _selectedFireBoyut!);
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
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextFieldWithCounter(
                    controller: _fireMiktarController,
                    hintText: 'Miktar',
                    icon: Icons.shopping_cart,
                  ),
                ),
                CustomLoadingButton(
                  isLoading: isLoading2,
                  onPressed: () async {
                    setState(() {
                      isLoading2 = true;
                    });

                    try {
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
                      } else {
                        _dolaServices.decreaseStock(
                          context: context,
                          malzeme: _selectedFireMalzeme!,
                          boyut: _selectedFireBoyut!,
                          renk: _selectedFireRenk!,
                          miktar: int.parse(_fireMiktarController.text),
                        );

                        _dolaServices.addFireEntry(
                          context: context,
                          malzeme: _selectedFireMalzeme!,
                          boyut: _selectedFireBoyut!,
                          renk: _selectedFireRenk!,
                          miktar: int.parse(_fireMiktarController.text),
                        );
                      }
                      // Burada işlemlerini gerçekleştirebilirsin
                      await Future.delayed(
                          const Duration(seconds: 1)); // Örnek bir gecikme
                    } finally {
                      setState(() {
                        isLoading2 = false;
                      });
                    }
                  },
                  text: "Fire Ekle ",
                ),
              ],
            ),

            /*---------------------------------------------------*/
          ],
        ),
      ),
    );
  }
}
