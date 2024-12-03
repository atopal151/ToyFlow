import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:toyflow/services/get_data_table.dart';

import '../../../services/user_services/cutom_loading_button.dart';
import 'boya_services/boya_services.dart';
import '../../../services/user_services/dropdown_selector.dart';
import '../../../services/user_services/text_field_with_counter.dart';

class BoyaEditScreen extends StatefulWidget {
  const BoyaEditScreen({super.key});

  @override
  State<BoyaEditScreen> createState() => _BoyaEditScreenState();
}

class _BoyaEditScreenState extends State<BoyaEditScreen> {
  bool isLoading = false;
  bool isLoading1 = false;
  bool isLoading2 = false;

  final BoyaServices _dokaServices = BoyaServices();
  final DataTableService _dataTableService = DataTableService();

  // kullanılan stok
  final TextEditingController _miktarController = TextEditingController();
  String? _selectedMalzeme; // Seçilen kumaş
  String? _selectedGramaj; // Seçilen gramaj
  String? _selectedFine; // Seçilen fine

  // eklenecek kumaş stok
  final TextEditingController _miktarDonumController = TextEditingController();
  String? _selectedDonumRenk; // Seçilen kumaş rengi
  String? _selectedDonumMalzeme; // Seçilen kumaş
  String? _selectedDonumGramaj; // Seçilen gramaj
  String? _selectedDonumFine; // Seçilen fine

  // fire stok
  final TextEditingController _fireMiktarController = TextEditingController();
  String? _selectedFireMalzeme; // Seçilen fire kumaş
  String? _selectedfireGramaj; // Seçilen fire gramaj
  String? _selectedFireFine; // Seçilen fire fine

  List<String> _urunler = []; // kumaş listesi
  List<String> _gramaj = []; // Kumaş listesi
  List<String> _fine = []; // Kumaş listesi
  int miktar = 0; // miktar listesi

  List<String> _kumaslar = []; // Kumaş listesi
  List<String> _renk = []; // Kumaş listesi
  List<String> _gramajlar = []; // Kumaş listesi
  List<String> _finelar = []; // Kumaş listesi

  @override
  void initState() {
    super.initState();
    _fetchData(); // Verileri Firebase'den çek
    _fetchKumasList();
    _fetchRenkList();
    _fetchGramajList();
    _fetchFineList();
  }

  Future<void> _fetchKumasList() async {
    // 'iplik' koleksiyonundan verileri çekiyoruz
    List<String> fetchedUrun =
        await _dataTableService.getCollectionData('kumas', 'kumas');
    setState(() {
      _kumaslar = fetchedUrun;
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

  Future<void> _fetchGramajList() async {
    // 'iplik' koleksiyonundan verileri çekiyoruz
    List<String> fetchedGramaj =
        await _dataTableService.getCollectionData('gramaj', 'gramaj');
    setState(() {
      _gramajlar = fetchedGramaj;
    });
  }

  Future<void> _fetchFineList() async {
    // 'iplik' koleksiyonundan verileri çekiyoruz
    List<String> fetchedFine =
        await _dataTableService.getCollectionData('fine', 'fine');
    setState(() {
      _finelar = fetchedFine;
    });
  }

  // İplik verilerini Firebase'den çek
  Future<void> _fetchData() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('dokuma_stok').get();

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

  Future<void> _fetchGramaj(String selectedMalzeme) async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('dokuma_stok')
          .where('urun', isEqualTo: selectedMalzeme)
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

  Future<void> _fetchFine(String selectedMalzeme, String selectedGramaj) async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('dokuma_stok')
          .where('urun', isEqualTo: selectedMalzeme)
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

  Future<void> _fetchMiktar(
    String selectedMalzeme,
    String selectedGramaj,
    String selectedFine,
  ) async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('dokuma_stok')
          .where('urun', isEqualTo: selectedMalzeme)
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
            // Kullanılan iplik seçme dropdown
            // Ürün seçme dropdown
            DropdownSelector(
              hintText: 'Kullanılan Ürün',
              items: _urunler,
              selectedValue: _selectedMalzeme,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedMalzeme = newValue;
                  _selectedGramaj = null;
                  _selectedFine = null;
                  // Seçilen ürüne göre renkleri getir
                  if (_selectedMalzeme != null) {
                    _fetchGramaj(_selectedMalzeme!);
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
                  // Seçilen ürüne göre renkleri getir
                  if (_selectedMalzeme != null || _selectedGramaj != null) {
                    _fetchFine(_selectedMalzeme!, _selectedGramaj!);
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
                      _selectedGramaj != null ||
                      _selectedFine != null) {
                    _fetchMiktar(
                        _selectedMalzeme!, _selectedGramaj!, _selectedFine!);
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
                          _selectedGramaj!.isEmpty ||
                          _selectedFine!.isEmpty ||
                          _miktarController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Lütfen tüm alanları doldurun.")),
                        );
                      } else {
                        _dokaServices.decreaseStock(
                          context: context,
                          malzeme: _selectedMalzeme!,
                          gramaj: _selectedGramaj!,
                          fine: _selectedFine!,
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
                  text: "Düşüm Yap",
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
              icon: Icons.arrow_drop_down,
            ),
            // Kumaş rengini seç
            DropdownSelector(
              hintText: 'Gramaj',
              items: _gramajlar,
              selectedValue: _selectedDonumGramaj,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedDonumGramaj = newValue;
                });
              },
              icon: Icons.color_lens,
            ),
            DropdownSelector(
              hintText: 'Fine',
              items: _finelar,
              selectedValue: _selectedDonumFine,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedDonumFine = newValue;
                });
              },
              icon: Icons.color_lens,
            ),
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
                          _selectedDonumGramaj!.isEmpty ||
                          _selectedDonumFine!.isEmpty ||
                          _selectedDonumRenk!.isEmpty ||
                          _miktarDonumController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Lütfen tüm alanları doldurun.")),
                        );
                      } else {
                        _dokaServices.addOrUpdateKumasStock(
                          context: context,
                          kumas: _selectedDonumMalzeme!,
                          gramaj: _selectedDonumGramaj!,
                          fine: _selectedDonumFine!,
                          kumasRenk: _selectedDonumRenk!,
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

            // Fire düşülecek ipliği seç
            DropdownSelector(
              hintText: 'Fire Ürün',
              items: _urunler,
              selectedValue: _selectedFireMalzeme,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedFireMalzeme = newValue;
                  _selectedfireGramaj = null;
                  _selectedFireFine = null;
                  // Seçilen ürüne göre renkleri getir
                  if (_selectedFireMalzeme != null) {
                    _fetchGramaj(_selectedFireMalzeme!);
                  }
                });
              },
              icon: Icons.arrow_drop_down,
            ),
            DropdownSelector(
              hintText: 'Gramaj',
              items: _gramaj,
              selectedValue: _selectedfireGramaj,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedfireGramaj = newValue;
                  _selectedFireFine = null;
                  // Seçilen ürüne göre renkleri getir
                  if (_selectedFireMalzeme != null ||
                      _selectedfireGramaj != null) {
                    _fetchFine(_selectedFireMalzeme!, _selectedfireGramaj!);
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

                  // Seçilen ürüne göre renkleri getir
                  if (_selectedFireMalzeme != null ||
                      _selectedfireGramaj != null ||
                      _selectedFireFine != null) {
                    _fetchMiktar(_selectedFireMalzeme!, _selectedfireGramaj!,
                        _selectedFireFine!);
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

            // Miktar gir
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
                      if (_selectedFireMalzeme!.isEmpty ||
                          _selectedFireFine!.isEmpty ||
                          _selectedfireGramaj!.isEmpty ||
                          _fireMiktarController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Lütfen tüm alanları doldurun.")),
                        );
                      } else {
                        _dokaServices.decreaseStock(
                          context: context,
                          malzeme: _selectedFireMalzeme!,
                          gramaj: _selectedfireGramaj!,
                          fine: _selectedFireFine!,
                          miktar: int.parse(_fireMiktarController.text),
                        );
                        _dokaServices.addFireEntry(
                          context: context,
                          malzeme: _selectedFireMalzeme!,
                          gramaj: _selectedfireGramaj!,
                          fine: _selectedFireFine!,
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
                  text: "Fire Ekle",
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
