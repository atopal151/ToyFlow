// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../../../services/user_component/cutom_loading_button.dart';
import '../../../services/user_services/get_data_table.dart';
import '../../../services/user_component/dropdown_selector.dart';
import '../../../services/user_component/text_field_with_counter.dart';
import 'transfer_services/transfer_services.dart';

class StokTransfer extends StatefulWidget {
  const StokTransfer({super.key});

  @override
  State<StokTransfer> createState() => _StokTransferState();
}

class _StokTransferState extends State<StokTransfer> {
  final TransferServices _transferServices = TransferServices();
  final DataTableService _dataTableService = DataTableService();

  bool isLoading = false;
  final TextEditingController _miktarController = TextEditingController();
  String? _selectedMalzeme;
  String? _selectedRenk;
  String? _selectedBoyut;
  String? _selectedAksesuar;

  List<String> _urunler = [];
  List<String> _renkler = [];
  List<String> _boyutlar = [];
  List<String> _aksesuarlar = [];

  String? _selectedDepo;
  String? _selectedGetDepo;
  List<String> _depolar = [];

  int miktar = 0;

  @override
  void initState() {
    super.initState();
    _fetchData();
    _fetchDepolar();
  }

  Future<void> _fetchDepolar() async {
    final List<String> depolar =
        await _dataTableService.getCollectionData('depolar', 'title');
    setState(() {
      _depolar = depolar;
    });
  }

  Future<void> _fetchData() async {
    try {
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
      appBar: AppBar(
        title: Text("Tranfer Ekranı"),
      ),
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
                  _fetchData();
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
            Center(
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 16.0,
                ),
                child: CustomLoadingButton(
                  isLoading: isLoading,
                  onPressed: () async {
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
                      setState(() {
                        isLoading = true; // Loading başlatılıyor
                      });

                      // Kullanıcıya loading gösterebilmek için 1 saniyelik gecikme ekliyoruz
                      await Future.delayed(const Duration(seconds: 1));
                      print(
                          "$_selectedDepo $_selectedGetDepo $_selectedMalzeme $_selectedRenk $_selectedBoyut $_selectedAksesuar $_miktarController");

                      // Ürün ekleme işlemini başlatıyoruz
                      Future.wait([
                        _transferServices.addOrUpdateUrunStock(
                          context: context,
                          addDepo: _selectedGetDepo!,
                          urun: _selectedMalzeme!,
                          boyut: _selectedBoyut!,
                          urunRenk: _selectedRenk!,
                          aksesuar: _selectedAksesuar!,
                          miktar: int.parse(_miktarController.text),
                        ),
                        _transferServices.decreaseStock(
                          context: context,
                          downDepo: _selectedDepo!,
                          malzeme: _selectedMalzeme!,
                          boyut: _selectedBoyut!,
                          renk: _selectedRenk!,
                          aksesuar: _selectedAksesuar!,
                          miktar: int.parse(_miktarController.text),
                        ),
                      ]).then((results) {
                        // Eğer tüm işlemler başarılıysa kullanıcıya mesaj göster
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("İşlem başarıyla tamamlandı!")),
                        );
                        // Gerekirse formu sıfırla
                        _miktarController.clear();
                        _selectedAksesuar = null;
                        _selectedBoyut = null;
                        _selectedDepo = null;
                        _selectedGetDepo = null;
                        _selectedMalzeme = null;
                        _selectedRenk = null;
                        setState(() {
                          isLoading = true;
                          Get.back();
                        });
                      }).catchError((error) {
                        // Eğer bir hata oluşursa kullanıcıya mesaj göster
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Hata oluştu: $error")),
                        );
                      });
                    }
                  },
                  text: "Aktar",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
