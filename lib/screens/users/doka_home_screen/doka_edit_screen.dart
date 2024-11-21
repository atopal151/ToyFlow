import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:toyflow/services/get_data_table.dart';

import 'doka_services/doka_services.dart';
import '../../../services/user_services/dropdown_selector.dart';
import '../../../services/user_services/text_field_with_counter.dart';

class DokaEditScreen extends StatefulWidget {
  const DokaEditScreen({super.key});

  @override
  State<DokaEditScreen> createState() => _DokaEditScreenState();
}

class _DokaEditScreenState extends State<DokaEditScreen> {
  final DokaServices _dokaServices = DokaServices();
  final DataTableService _dataTableService = DataTableService();

  // kullanılan stok
  final TextEditingController _miktarController = TextEditingController();
  String? _selectedMalzeme; // Seçilen iplik

  // eklenecek kumaş stok
  final TextEditingController _miktarDonumController = TextEditingController();
  String? _selectedDonumMalzeme; // Seçilen kumaş
  String? _selectedDonumGramaj; // Seçilen gramaj
  String? _selectedDonumFine; // Seçilen fine

  // fire stok
  final TextEditingController _fireMiktarController = TextEditingController();
  String? _selectedFireMalzeme; // Seçilen fire ipliği
  String? _selectedFireDenye; // Seçilen fire ipliği

  List<String> _urunler = []; // İplik listesi

  String? _selectedDenye; // Seçilen fire ipliği
  List<String> _denye = []; // denye listesi

  int miktar = 0; // miktar listesi

  List<String> _kumaslar = []; // Kumaş listesi
  List<String> _gramaj = []; // Kumaş listesi
  List<String> _fine = []; // Kumaş listesi

  @override
  void initState() {
    super.initState();
    _fetchData(); // Verileri Firebase'den çek
    _fetchKumasList();
    _fetchGramajList();
    _fetchfineList();
  }

  Future<void> _fetchKumasList() async {
    // 'iplik' koleksiyonundan verileri çekiyoruz
    List<String> fetchedUrun =
        await _dataTableService.getCollectionData('kumas', 'kumas');
    setState(() {
      _kumaslar = fetchedUrun;
    });
  }

  Future<void> _fetchGramajList() async {
    // 'iplik' koleksiyonundan verileri çekiyoruz
    List<String> fetchedGramaj =
        await _dataTableService.getCollectionData('gramaj', 'gramaj');
    setState(() {
      _gramaj = fetchedGramaj;
    });
  }

  Future<void> _fetchfineList() async {
    // 'iplik' koleksiyonundan verileri çekiyoruz
    List<String> fetchedFine =
        await _dataTableService.getCollectionData('fine', 'fine');
    setState(() {
      _fine = fetchedFine;
    });
  }

  // İplik verilerini Firebase'den çek
  Future<void> _fetchData() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('dokuma_work').get();

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

  Future<void> _fetchDenye(String selectedDenye) async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('dokuma_work')
          .where('urun', isEqualTo: selectedDenye)
          .get();

      setState(() {
        _denye = snapshot.docs
            .where((doc) =>
                doc['miktar'] != 0) // miktar alanı 0 olmayanları filtreliyoruz
            .map((doc) => doc['denye'] as String)
            .toSet() // Aynı renklerin tekrarını önlemek için set kullanıyoruz
            .toList();
      });
    } catch (e) {
      print("Renk verileri alınırken hata oluştu: $e");
    }
  }

  Future<void> _fetchMiktar(String selectedIplik, String selectedDenye) async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('dokuma_work')
          .where('urun', isEqualTo: selectedIplik)
          .where('denye', isEqualTo: selectedDenye)
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
                  // Seçilen ürüne göre renkleri getir
                  if (_selectedMalzeme != null) {
                    _fetchDenye(_selectedMalzeme!);
                  }
                });
              },
              icon: Icons.arrow_drop_down,
            ),
            DropdownSelector(
              hintText: 'Denye',
              items: _denye,
              selectedValue: _selectedDenye,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedDenye = newValue;
                  // Seçilen ürüne göre renkleri getir
                  if (_selectedDenye != null) {
                    _fetchMiktar(_selectedMalzeme!, _selectedDenye!);
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
                'Hazır Stok: $miktar kg', // Güncellenmiş miktarı gösterir
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
                Padding(
                  padding: const EdgeInsets.only(top: 12.0, right: 16),
                  child: ElevatedButton(
                    onPressed: () {
                      if (_selectedMalzeme!.isEmpty ||
                          _miktarController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Lütfen tüm alanları doldurun.")),
                        );
                      } else {
                        _dokaServices.decreaseStock(
                          context: context,
                          malzeme: _selectedMalzeme!,
                          denye: _selectedDenye!,
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
            DropdownSelector(
              hintText: 'Gramaj',
              items: _gramaj,
              selectedValue: _selectedDonumGramaj,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedDonumGramaj = newValue;
                });
              },
              icon: Icons.arrow_drop_down,
            ),
            DropdownSelector(
              hintText: 'Fine',
              items: _fine,
              selectedValue: _selectedDonumFine,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedDonumFine = newValue;
                });
              },
              icon: Icons.arrow_drop_down,
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
                Padding(
                  padding: const EdgeInsets.only(top: 12.0, right: 16),
                  child: ElevatedButton(
                    onPressed: () {
                      if (_selectedDonumMalzeme!.isEmpty ||
                          _selectedDonumGramaj!.isEmpty ||
                          _selectedDonumFine!.isEmpty ||
                          _miktarDonumController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Lütfen tüm alanları doldurun.")),
                        );
                      } else {
                        _dokaServices.addOrUpdateKumasStock(
                          context: context,
                          gramaj: _selectedDonumGramaj!,
                          fine: _selectedDonumFine!,
                          kumas: _selectedDonumMalzeme!,
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
                  if (_selectedFireMalzeme != null) {
                    _fetchDenye(_selectedFireMalzeme!);
                  }
                });
              },
              icon: Icons.arrow_drop_down,
            ),
            DropdownSelector(
              hintText: 'Denye',
              items: _denye,
              selectedValue: _selectedFireDenye,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedFireDenye = newValue;
                  // Seçilen ürüne göre renkleri getir
                  if (_selectedFireDenye != null) {
                    _fetchMiktar(_selectedFireMalzeme!, _selectedFireDenye!);
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
                'Hazır Stok: $miktar kg', // Güncellenmiş miktarı gösterir
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
                Padding(
                  padding: const EdgeInsets.only(top: 12.0, right: 16),
                  child: ElevatedButton(
                    onPressed: () {
                      if (_selectedFireMalzeme!.isEmpty ||
                          _fireMiktarController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Lütfen tüm alanları doldurun.")),
                        );
                      } else {
                        _dokaServices.decreaseStock(
                          context: context,
                          malzeme: _selectedFireMalzeme!,
                          denye: _selectedFireDenye!,
                          miktar: int.parse(_fireMiktarController.text),
                        );
                        _dokaServices.addFireEntry(
                          context: context,
                          malzeme: _selectedFireMalzeme!,
                          denye: _selectedFireDenye!,
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
              ],
            ),

            /*---------------------------------------------------*/
          ],
        ),
      ),
    );
  }
}
