// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:toyflow/services/user_services/get_data_table.dart';

import '../../../services/user_services/product_services.dart';
import '../../../services/user_component/cutom_loading_button.dart';
import '../../../services/user_component/dropdown_selector.dart';
import '../../../services/user_component/text_field_with_counter.dart';
import 'atolye_services/atolye_services.dart';

class AtolyeEditScreen extends StatefulWidget {
  const AtolyeEditScreen({super.key});

  @override
  State<AtolyeEditScreen> createState() => _AtolyeEditScreenState();
}

class _AtolyeEditScreenState extends State<AtolyeEditScreen> {
  bool isLoading = false;
  bool isLoading1 = false;
  bool isLoading2 = false;
  late String oncekiWorkshop;

  final ProductServices productServices = Get.find<ProductServices>();
  final AtolyeServices _atolyeServices = AtolyeServices();
  final DataTableService _dataTableService = DataTableService();

  //kullanılan stok
  final TextEditingController _miktarDusumController = TextEditingController();
  String? _selectedDusumMalzeme; // Seçilen ürün
  String? _selectedDusumRenk; // Seçilen renk
  String? _selectedDusumBoyut; // Seçilen Kumaş renk
  String? _selectedDusumGramaj; // Seçilen ürün
  String? _selectedDusumFine; // Seçilen renk
  String? _selectedDusumDenye; // Seçilen Kumaş renk
  //eklenecek stok

  final TextEditingController _miktarStokController = TextEditingController();

  String? _selectedStokMalzeme; // Seçilen ürün
  String? _selectedStokKumaslar; // Seçilen Kumaş renk
  String? _selectedStokBoyut; // Seçilen Kumaş renk
  String? _selectedStokAksesuar; // Seçilen Kumaş renk
  String? _selectedStokRenk; // Seçilen Kumaş renk
  String? _selectedStokFine; // Seçilen Kumaş renk
  String? _selectedStokGramaj; // Seçilen Kumaş renk

  //Fire stok
  final TextEditingController _fireMiktarController = TextEditingController();
  String? _selectedDusumFireMalzeme; // Seçilen ürün
  String? _selectedDusumFireRenk; // Seçilen renk
  String? _selectedDusumFireBoyut; // Seçilen Kumaş renk
  String? _selectedDusumFireGramaj; // Seçilen ürün
  String? _selectedDusumFireFine; // Seçilen renk
  String? _selectedDusumFireDenye; // Seçilen Kumaş renk

  List<String> _dusumUrunler = []; // Ürün listesi
  List<String> _dusumRenkler = []; // Renk listesi
  List<String> _dusumBoyutlar = []; // Renk listesi
  List<String> _dusumFine = []; // Renk listesi
  List<String> _dusumGramaj = []; // Renk listesi
  List<String> _dusumDenye = []; // Renk listesi

  int miktar = 0; // miktar listesi

  List<String> _stokKumaslar = [];
  List<String> _stokUrun = []; // Ürün listesi
  List<String> _stokBoyut = []; // Ürün listesi
  List<String> _stokRenk = []; // K
  List<String> _stokAksesuarlar = [];
  List<String> _stokGramajlar = [];
  List<String> _stokFineler = [];

  List<String> atolyeler = [];
  //String? collection = "";
  String? collectionWait = "";
  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await fetchOncekiWorkshop(productServices);
    await fetchAtolyelerWithOnceki();

    // fetchAtolyelerWithOncekiAndGetCollection ile collection değeri alınacak
    /*if (atolyeler.isNotEmpty) {
      collection =
          await fetchAtolyelerWithOncekiAndGetCollection(atolyeler.first) ?? "";
    }*/

    collectionWait=_atolyeServices.collectionWait;
    

    await Future.wait([
      if (collectionWait!.isNotEmpty) _fetchUrun(collectionWait!),
      _fetchKumasList(),
      _fetchUrunList(),
      _fetchRenkList(),
      _fetchAksesuarList(),
      _fetchBoyutList(),
      _fetchFineList(),
      _fetchGramajList(),
    ]);
  }

//----------------------------------------------------------//
//                Getirilen Veriler                         //
//----------------------------------------------------------//

  Future<void> _fetchKumasList() async {
    List<String> fetchedUrun =
        await _dataTableService.getCollectionData('kumas', 'kumas');
    setState(() {
      _stokKumaslar = fetchedUrun;
    });
  }

  Future<void> _fetchUrunList() async {
    List<String> fetchedUrun =
        await _dataTableService.getCollectionData('toy_name', 'name');
    setState(() {
      _stokUrun = fetchedUrun;
    });
  }

  Future<void> _fetchRenkList() async {
    List<String> fetchedUrun =
        await _dataTableService.getCollectionData('toy_renk', 'renk');
    setState(() {
      _stokRenk = fetchedUrun;
    });
  }

  Future<void> _fetchBoyutList() async {
    List<String> fetchedUrun =
        await _dataTableService.getCollectionData('toy_height', 'boyut');
    setState(() {
      _stokBoyut = fetchedUrun;
    });
  }

  Future<void> _fetchAksesuarList() async {
    List<String> fetchedUrun =
        await _dataTableService.getCollectionData('toy_aksesuar', 'aksesuar');
    setState(() {
      _stokAksesuarlar = fetchedUrun;
    });
  }

  Future<void> _fetchGramajList() async {
    List<String> fetchedUrun =
        await _dataTableService.getCollectionData('gramaj', 'gramaj');
    setState(() {
      _stokGramajlar = fetchedUrun;
    });
  }

  Future<void> _fetchFineList() async {
    List<String> fetchedUrun =
        await _dataTableService.getCollectionData('fine', 'fine');
    setState(() {
      _stokFineler = fetchedUrun;
    });
  }

//----------------------------------------------------------//
//                Filtreli Gelen Veriler                    //
//----------------------------------------------------------//

  Future<void> fetchOncekiWorkshop(ProductServices productServices) async {
    try {
      final workshopName = productServices.workshopName.value;

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('connected_work_shop')
          .where('rol', isEqualTo: workshopName)
          .get();

      if (querySnapshot.docs.isEmpty) {
        throw Exception("Workshop bulunamadı!");
      }

      oncekiWorkshop = querySnapshot.docs.first['onceki'] as String;
      print("Onceki Workshop: $oncekiWorkshop");
    } catch (e) {
      oncekiWorkshop = "VarsayılanAtölye"; // Varsayılan değer
      print("Hata: $e");
    }
  }

  Future<void> fetchAtolyelerWithOnceki() async {
    try {
      if (oncekiWorkshop.isEmpty) {
        throw Exception("Onceki Workshop değeri boş!");
      }
      print("sasaasa $oncekiWorkshop");
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('atolyeler')
          .where('nitelik', isEqualTo: oncekiWorkshop)
          .get();

      atolyeler.clear();
      atolyeler.addAll(querySnapshot.docs.map((doc) => doc['name'] as String));

      print("Atolyeler: $atolyeler");
    } catch (e) {
      // Hata durumunda log yazdır
      print("111 Hata: $e");
    }
  }

  Future<String?> fetchAtolyelerWithOncekiAndGetCollection(
      String selectedName) async {
    try {
      // Onceki Workshop değerinin dolu olduğundan emin olun
      if (oncekiWorkshop.isEmpty) {
        throw Exception("Onceki Workshop değeri boş!");
      }
      print("Onceki Workshop: $oncekiWorkshop");

      // atolyeler tablosunda nitelik alanına göre arama yap
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('atolyeler')
          .where('nitelik', isEqualTo: oncekiWorkshop)
          .get();

      for (var doc in querySnapshot.docs) {
        final name = doc['name'] as String; // Atölye adı
        final collection = doc['collection'] as String; // Koleksiyon adı

        // Seçilen `name` değerine göre `collection` döndürülür
        if (name == selectedName) {
          print("Seçilen Atölye: $name, Collection: $collection");
          return collection;
        }
      }

      // Eğer `selectedName` bulunamazsa null döndür
      print("Seçilen atölye bulunamadı!");
      return null;
    } catch (e) {
      // Hata durumunda log yazdır
      print("111 Hata: $e");
      return null;
    }
  }

  Future<void> _fetchUrun(String selectedCollection) async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection(selectedCollection).get();

      setState(() {
        _dusumUrunler = snapshot.docs
            .where((doc) => doc['miktar'] != 0)
            .map((doc) => doc['urun'] as String)
            .toSet()
            .toList();
      });
    } catch (e) {
      print("WVeriler alınırken hata oluştu: $e");
    }
  }

  Future<void> _fetchDenye(
      String selectedCollection, String selectedMalzeme) async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection(selectedCollection)
          .where('urun', isEqualTo: selectedMalzeme)
          .get();

      setState(() {
        _dusumDenye = snapshot.docs
            .where((doc) => doc['miktar'] != 0)
            .map((doc) => doc['denye'] as String)
            .toSet() // Aynı renklerin tekrarını önlemek için set kullanıyoruz
            .toList();
      });
    } catch (e) {
      print("Renk verileri alınırken hata oluştu: $e");
    }
  }

  Future<void> _fetchGramaj(
      String selectedCollection, String selectedMalzeme) async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection(selectedCollection)
          .where('urun', isEqualTo: selectedMalzeme)
          .get();

      setState(() {
        _dusumGramaj = snapshot.docs
            .where((doc) => doc['miktar'] != 0)
            .map((doc) => doc['gramaj'] as String)
            .toSet() // Aynı renklerin tekrarını önlemek için set kullanıyoruz
            .toList();
      });
    } catch (e) {
      print("Renk verileri alınırken hata oluştu: $e");
    }
  }

  Future<void> _fetchFine(String selectedCollection, String selectedMalzeme,
      String selectedGramaj) async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection(selectedCollection)
          .where('urun', isEqualTo: selectedMalzeme)
          .where('gramaj', isEqualTo: selectedGramaj)
          .get();

      setState(() {
        _dusumFine = snapshot.docs
            .where((doc) => doc['miktar'] != 0)
            .map((doc) => doc['fine'] as String)
            .toSet() // Aynı renklerin tekrarını önlemek için set kullanıyoruz
            .toList();
      });
    } catch (e) {
      print("Renk verileri alınırken hata oluştu: $e");
    }
  }

  Future<void> _fetchKesimRenk(
      String selectedCollection,
      String selectedMalzeme,
      String selectedGramaj,
      String selectedFine) async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection(selectedCollection)
          .where('urun', isEqualTo: selectedMalzeme)
          .where('gramaj', isEqualTo: selectedGramaj)
          .where('fine', isEqualTo: selectedFine)
          .get();

      setState(() {
        _dusumRenkler = snapshot.docs
            .where((doc) => doc['miktar'] != 0)
            .map((doc) => doc['renk'] as String)
            .toSet() // Aynı renklerin tekrarını önlemek için set kullanıyoruz
            .toList();
      });
    } catch (e) {
      print("Renk verileri alınırken hata oluştu: $e");
    }
  }

  Future<void> _fetchColors(
      String selectedCollection, String selectedMalzeme) async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection(selectedCollection)
          .where('urun', isEqualTo: selectedMalzeme)
          .get();

      setState(() {
        _dusumRenkler = snapshot.docs
            .where((doc) => doc['miktar'] != 0)
            .map((doc) => doc['renk'] as String)
            .toSet() // Aynı renklerin tekrarını önlemek için set kullanıyoruz
            .toList();
      });
    } catch (e) {
      print("Renk verileri alınırken hata oluştu: $e");
    }
  }

  Future<void> _fetchBoyut(String selectedCollection, String selectedMalzeme,
      String selectedRenk) async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection(selectedCollection)
          .where('urun', isEqualTo: selectedMalzeme)
          .where('renk', isEqualTo: selectedRenk)
          .get();

      setState(() {
        _dusumBoyutlar = snapshot.docs
            .where((doc) => doc['miktar'] != 0)
            .map((doc) => doc['boyut'] as String)
            .toSet() // Aynı renklerin tekrarını önlemek için set kullanıyoruz
            .toList();
      });
    } catch (e) {
      print("Renk verileri alınırken hata oluştu: $e");
    }
  }

  Future<void> _fetchAksesuar(String selectedCollection, String selectedMalzeme,
      String selectedRenk, String selectedBoyut) async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection(selectedCollection)
          .where('urun', isEqualTo: selectedMalzeme)
          .where('renk', isEqualTo: selectedRenk)
          .where('boyut', isEqualTo: selectedBoyut)
          .get();

      setState(() {
        _dusumBoyutlar = snapshot.docs
            .where((doc) => doc['miktar'] != 0)
            .map((doc) => doc['aksesuar'] as String)
            .toSet() // Aynı renklerin tekrarını önlemek için set kullanıyoruz
            .toList();
      });
    } catch (e) {
      print("Renk verileri alınırken hata oluştu: $e");
    }
  }

  Future<void> _fetchBoyutWithMiktar(String selectedCollection,
      String selectedUrun, String selectedRenk, String selectedBoyut) async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection(selectedCollection)
          .where('urun', isEqualTo: selectedUrun)
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

  Future<void> _fetchDenyeWithMiktar(String selectedCollection,
      String selectedUrun, String selectedDenye) async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection(selectedCollection)
          .where('urun', isEqualTo: selectedUrun)
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

  Future<void> _fetchKesimWithMiktar(
      String selectedCollection,
      String selectedUrun,
      String selectedGramaj,
      String selectedFine,
      String selectedRenk) async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection(selectedCollection)
          .where('urun', isEqualTo: selectedUrun)
          .where('gramaj', isEqualTo: selectedGramaj)
          .where('fine', isEqualTo: selectedFine)
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

  Future<void> _fetchFineWithMiktar(String selectedCollection,
      String selectedUrun, String selectedGramaj, String selectedFine) async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection(selectedCollection)
          .where('urun', isEqualTo: selectedUrun)
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

  Future<void> _fetchAksesuarWithMiktar(
      String selectedCollection,
      String selectedUrun,
      String selectedRenk,
      String selectedBoyut,
      String selectedAksesuar) async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection(selectedCollection)
          .where('urun', isEqualTo: selectedUrun)
          .where('renk', isEqualTo: selectedRenk)
          .where('boyut', isEqualTo: selectedBoyut)
          .where('aksesuar', isEqualTo: selectedAksesuar)
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

//----------------------------------------------------------//
//----------------------------------------------------------//
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Stok Düzenleme',
            style: TextStyle(fontSize: 15),
          ),
          bottom: TabBar(
            labelColor: Colors.black,
            indicatorColor: Colors.black,
            tabs: [
              Tab(
                  text: "Stok Ekle",
                  icon: Container(
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 2,
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(Icons.add_shopping_cart,
                              color: Colors.white)))),
              Tab(
                  text: "Düşüm Yap",
                  icon: Container(
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 2,
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(Icons.remove_shopping_cart,
                            color: Colors.white),
                      ))),
              Tab(
                  text: "Fire Ekle",
                  icon: Container(
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 2,
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(Icons.delete_outline,
                              color: Colors.white)))),
            ],
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: TabBarView(
            children: [
              _stokEkleTab(),
              _dusumYapTab(),
              _fireEkleTab(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stokEkleTab() {
    return SingleChildScrollView(
      child: Column(
        children: [

          // Ürün seçme dropdown
          if (productServices.role.value == "Dikim" ||
              productServices.role.value == "Kesim" ||
              productServices.role.value == "Transfer" ||
              productServices.role.value == "Dolum" ||
              productServices.role.value == "Paketleme")
            DropdownSelector(
              hintText: 'Dönüştürülen Ürün',
              items: _stokUrun,
              selectedValue: _selectedStokMalzeme,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedStokMalzeme = newValue;
                });
              },
              icon: Icons.arrow_drop_down,
            ),

          if (productServices.role.value == "Boyama" ||
              productServices.role.value == "Dokuma")
            DropdownSelector(
              
              hintText: 'Kumaş',
              items: _stokKumaslar,
              selectedValue: _selectedStokKumaslar,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedStokKumaslar = newValue;
                });
              },
              icon: Icons.arrow_drop_down,
            ),
          if (productServices.role.value == "Kesim" ||
              productServices.role.value == "Boyama" ||
              productServices.role.value == "Dikim" ||
              productServices.role.value == "Dolum" ||
              productServices.role.value == "Paketleme")
            // Renk seçme dropdown
            DropdownSelector(
              hintText: 'Renk',
              items: _stokRenk,
              selectedValue: _selectedStokRenk,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedStokRenk = newValue;
                });
              },
              icon: Icons.arrow_drop_down,
            ),

          if (productServices.role.value == "Dikim" ||
              productServices.role.value == "Kesim" ||
              productServices.role.value == "Transfer" ||
              productServices.role.value == "Dolum" ||
              productServices.role.value == "Paketleme")
            // boyut seçme dropdown
            DropdownSelector(
              hintText: ' Boyut',
              items: _stokBoyut,
              selectedValue: _selectedStokBoyut,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedStokBoyut = newValue;
                });
              },
              icon: Icons.arrow_drop_down,
            ),
          if (productServices.role.value == "Paketleme")
            DropdownSelector(
              hintText: "Aksesuar",
              items: _stokAksesuarlar,
              selectedValue: _selectedStokAksesuar,
              icon: Icons.arrow_drop_down,
              onChanged: (value) {
                setState(() {
                  _selectedStokAksesuar = value;
                });
              },
            ),

          if (productServices.role.value == "Boyama" ||
              productServices.role.value == "Dokuma")
            DropdownSelector(
              hintText: "Gramaj",
              items: _stokGramajlar,
              selectedValue: _selectedStokGramaj,
              icon: Icons.scale,
              onChanged: (value) {
                setState(() {
                  _selectedStokGramaj = value;
                });
              },
            ),
          if (productServices.role.value == "Boyama" ||
              productServices.role.value == "Dokuma")
            DropdownSelector(
              hintText: "Fine",
              items: _stokFineler,
              selectedValue: _selectedStokFine,
              icon: Icons.line_axis,
              onChanged: (value) {
                setState(() {
                  _selectedStokFine = value;
                });
              },
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // TextFieldWithCounter Widget
              Expanded(
                flex: 3, // Genişliği ayarlamak için
                child: TextFieldWithCounter(
                  controller: _miktarStokController,
                  hintText: 'Miktar',
                  icon: Icons.shopping_cart,
                ),
              ),
              const SizedBox(width: 10), // TextField ve Button arasında boşluk
              // ElevatedButton
              CustomLoadingButton(
                isLoading: isLoading1,
                onPressed: () async {
                  setState(() {
                    isLoading1 = true;
                  });

                  try {
                    if (productServices.role.value == "Kesim" ||
                        productServices.role.value == "Dikim" ||
                        productServices.role.value == "Dolum") {
                      if (_selectedStokMalzeme!.isEmpty ||
                          _selectedStokRenk!.isEmpty ||
                          _selectedStokBoyut!.isEmpty ||
                          _miktarStokController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Lütfen tüm alanları doldurun.")),
                        );
                      } else {
                        _atolyeServices.addOrUpdateUrunStock(
                          collections: _atolyeServices.collectionName,
                          context: context,
                          urun: _selectedStokMalzeme!,
                          renk: _selectedStokRenk!,
                          boyut: _selectedStokBoyut!,
                          miktar: int.parse(_miktarStokController.text),
                        );
                      }
                    }
                    if (productServices.role.value == "Paketleme") {
                      if (_selectedStokMalzeme!.isEmpty ||
                          _selectedStokRenk!.isEmpty ||
                          _selectedStokBoyut!.isEmpty ||
                          _selectedStokAksesuar!.isEmpty ||
                          _miktarStokController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Lütfen tüm alanları doldurun.")),
                        );
                      } else {
                        _atolyeServices.addOrUpdateUrunStock(
                          collections: _atolyeServices.collectionName,
                          context: context,
                          urun: _selectedStokMalzeme!,
                          renk: _selectedStokRenk!,
                          boyut: _selectedStokBoyut!,
                          aksesuar: _selectedStokAksesuar!,
                          miktar: int.parse(_miktarStokController.text),
                        );
                      }
                    }

                    if (productServices.role.value == "Dokuma") {
                      if (_selectedStokKumaslar!.isEmpty ||
                          _selectedStokGramaj!.isEmpty ||
                          _selectedStokFine!.isEmpty ||
                          _miktarStokController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Lütfen tüm alanları doldurun.")),
                        );
                      } else {
                        _atolyeServices.addOrUpdateUrunStock(
                          collections: _atolyeServices.collectionName,
                          context: context,
                          urun: _selectedStokKumaslar!,
                          gramaj: _selectedStokGramaj!,
                          fine: _selectedStokFine!,
                          miktar: int.parse(_miktarStokController.text),
                        );
                      }
                    }
                    if (productServices.role.value == "Boyama") {
                      if (_selectedStokKumaslar!.isEmpty ||
                          _selectedStokRenk!.isEmpty ||
                          _selectedStokGramaj!.isEmpty ||
                          _selectedStokFine!.isEmpty ||
                          _miktarStokController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Lütfen tüm alanları doldurun.")),
                        );
                      } else {
                        _atolyeServices.addOrUpdateUrunStock(
                          collections: _atolyeServices.collectionName,
                          context: context,
                          urun: _selectedStokKumaslar!,
                          renk: _selectedStokRenk,
                          gramaj: _selectedStokGramaj!,
                          fine: _selectedStokFine!,
                          miktar: int.parse(_miktarStokController.text),
                        );
                      }
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
        ],
      ),
    );
  }

  Widget _dusumYapTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // atolye seçme dropdown
         

          // Ürün seçme dropdown
          DropdownSelector(
            hintText: 'Kullanılan Ürün',
            items: _dusumUrunler,
            selectedValue: _selectedDusumMalzeme,
            onChanged: (String? newValue) {
              setState(() {
                _selectedDusumMalzeme = newValue;
                _selectedDusumDenye = null;
                _selectedDusumGramaj = null;
                _selectedDusumFine = null;
                _selectedDusumRenk = null; // Renk seçimini temizle
                _selectedDusumBoyut = null; // Boyut seçimini temizle
                _dusumGramaj.clear();
                _dusumFine.clear();
                _dusumDenye.clear(); // Renk listesini temizle
                _dusumRenkler.clear(); // Renk listesini temizle
                _dusumBoyutlar.clear(); // Boyut listesini temizle

                // Seçilen ürüne göre renkleri getir
                if (productServices.role.value == "Dikim" ||
                    productServices.role.value == "Transfer" ||
                    productServices.role.value == "Dolum" ||
                    productServices.role.value == "Paketleme") {
                  _fetchColors(collectionWait!, _selectedDusumMalzeme!);
                } else if (productServices.role.value == "Dokuma") {
                  _fetchDenye(collectionWait!, _selectedDusumMalzeme!);
                } else if (productServices.role.value == "Boyama" ||
                    productServices.role.value == "Kesim") {
                  _fetchGramaj(collectionWait!, _selectedDusumMalzeme!);
                }
              });
            },
            icon: Icons.arrow_drop_down,
          ),
          if (productServices.role.value == "Dokuma")
            // Renk seçme dropdown
            DropdownSelector(
              hintText: 'Denye',
              items: _dusumDenye,
              selectedValue: _selectedDusumDenye,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedDusumDenye = newValue;
                  // Seçilen renge göre boyutları getir
                  if (_selectedDusumDenye != null) {
                    _fetchDenyeWithMiktar(collectionWait!, _selectedDusumMalzeme!,
                        _selectedDusumDenye!);
                  }
                });
              },
              icon: Icons.arrow_drop_down,
            ),

          if (productServices.role.value == "Boyama" ||
              productServices.role.value == "Kesim")
            DropdownSelector(
              hintText: 'Gramaj',
              items: _dusumGramaj,
              selectedValue: _selectedDusumGramaj,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedDusumFine = null;

                  _selectedDusumRenk = null;
                  _dusumRenkler.clear();

                  _dusumFine.clear();
                  _selectedDusumGramaj = newValue;
                  // Seçilen renge göre boyutları getir
                  if (_selectedDusumGramaj != null) {
                    _fetchFine(collectionWait!, _selectedDusumMalzeme!,
                        _selectedDusumGramaj!);
                  }
                });
              },
              icon: Icons.arrow_drop_down,
            ),

          if (productServices.role.value == "Boyama" ||
              productServices.role.value == "Kesim")
            DropdownSelector(
              hintText: 'Fine',
              items: _dusumFine,
              selectedValue: _selectedDusumFine,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedDusumRenk = null;
                  _dusumRenkler.clear();
                  _selectedDusumFine = newValue;
                  // Seçilen renge göre boyutları getir

                  if (_selectedDusumFine != null) {
                    if (productServices.role.value == "Boyama") {
                      _fetchFineWithMiktar(collectionWait!, _selectedDusumMalzeme!,
                          _selectedDusumGramaj!, _selectedDusumFine!);
                    }
                    if (productServices.role.value == "Kesim") {
                      _fetchKesimRenk(collectionWait!, _selectedDusumMalzeme!,
                          _selectedDusumGramaj!, _selectedDusumFine!);
                    }
                  }
                });
              },
              icon: Icons.arrow_drop_down,
            ),

          if (productServices.role.value == "Dikim" ||
              productServices.role.value == "Kesim" ||
              productServices.role.value == "Transfer" ||
              productServices.role.value == "Dolum" ||
              productServices.role.value == "Paketleme")
            // Renk seçme dropdown
            DropdownSelector(
              hintText: 'Renk',
              items: _dusumRenkler,
              selectedValue: _selectedDusumRenk,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedDusumRenk = newValue;
                  _selectedDusumBoyut = null; // Boyut seçimini temizle
                  _dusumBoyutlar.clear(); // Boyut listesini temizle

                  // Seçilen renge göre boyutları getir
                  if (_selectedDusumRenk != null) {
                    if (productServices.role.value == "Kesim") {
                      _fetchKesimWithMiktar(
                          collectionWait!,
                          _selectedDusumMalzeme!,
                          _selectedDusumGramaj!,
                          _selectedDusumFine!,
                          _selectedDusumRenk!);
                    } else {
                      _fetchBoyut(collectionWait!, _selectedDusumMalzeme!,
                          _selectedDusumRenk!);
                    }
                  }
                });
              },
              icon: Icons.arrow_drop_down,
            ),

          if (productServices.role.value == "Dikim" ||
              productServices.role.value == "Transfer" ||
              productServices.role.value == "Dolum" ||
              productServices.role.value == "Paketleme")
            // Boyut seçme dropdown
            DropdownSelector(
              hintText: 'Boyut',
              items: _dusumBoyutlar,
              selectedValue: _selectedDusumBoyut,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedDusumBoyut = newValue;

                  // Ürün, renk ve boyuta göre miktarı getir
                  if (_selectedDusumMalzeme != null &&
                      _selectedDusumRenk != null &&
                      _selectedDusumBoyut != null) {
                    _fetchBoyutWithMiktar(collectionWait!, _selectedDusumMalzeme!,
                        _selectedDusumRenk!, _selectedDusumBoyut!);
                  }
                });
              },
              icon: Icons.arrow_drop_down,
            ),

          Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  left: 35.0,
                  top: 15,
                ),
                child: Text(
                  'Hazır Stok: $miktar adet', // Güncellenmiş miktarı gösterir
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w300),
                ),
              ),
            ],
          ),

          // Miktar girme
          Row(
            children: [
              Expanded(
                flex: 3,
                child: TextFieldWithCounter(
                  controller: _miktarDusumController,
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
                    if (productServices.role.value == "Paketleme" ||
                        productServices.role.value == "Dikim" ||
                        productServices.role.value == "Dolum") {
                      if (_selectedDusumMalzeme!.isEmpty ||
                          _selectedDusumBoyut!.isEmpty ||
                          _selectedDusumRenk!.isEmpty ||
                          _miktarDusumController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Lütfen tüm alanları doldurun.")),
                        );
                      } else {
                        _atolyeServices.decreaseStock(
                          context: context,
                          malzeme: _selectedDusumMalzeme!,
                          boyut: _selectedDusumBoyut!,
                          renk: _selectedDusumRenk!,
                          miktar: int.parse(_miktarDusumController.text),
                        );
                      }
                    }
                    if (productServices.role.value == "Dokuma") {
                      if (_selectedDusumMalzeme!.isEmpty ||
                          _selectedDusumDenye!.isEmpty ||
                          _miktarDusumController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Lütfen tüm alanları doldurun.")),
                        );
                      } else {
                        _atolyeServices.decreaseStock(
                          context: context,
                          malzeme: _selectedDusumMalzeme!,
                          denye: _selectedDusumDenye!,
                          miktar: int.parse(_miktarDusumController.text),
                        );
                      }
                    }
                    if (productServices.role.value == "Boyama") {
                      if (_selectedDusumMalzeme!.isEmpty ||
                          _selectedDusumGramaj!.isEmpty ||
                          _selectedDusumFine!.isEmpty ||
                          _miktarDusumController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Lütfen tüm alanları doldurun.")),
                        );
                      } else {
                        _atolyeServices.decreaseStock(
                          context: context,
                          malzeme: _selectedDusumMalzeme!,
                          gramaj: _selectedDusumGramaj!,
                          fine: _selectedDusumFine!,
                          miktar: int.parse(_miktarDusumController.text),
                        );
                      }
                    }
                    if (productServices.role.value == "Kesim") {
                      if (_selectedDusumMalzeme!.isEmpty ||
                          _selectedDusumRenk!.isEmpty ||
                          _selectedDusumGramaj!.isEmpty ||
                          _selectedDusumFine!.isEmpty ||
                          _miktarDusumController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Lütfen tüm alanları doldurun.")),
                        );
                      } else {
                        _atolyeServices.decreaseStock(
                          context: context,
                          malzeme: _selectedDusumMalzeme!,
                          renk: _selectedDusumRenk,
                          gramaj: _selectedDusumGramaj!,
                          fine: _selectedDusumFine!,
                          miktar: int.parse(_miktarDusumController.text),
                        );
                      }
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
        ],
      ),
    );
  }

  Widget _fireEkleTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          

          // Ürün seçme dropdown
          DropdownSelector(
            hintText: 'Fire Ürün',
            items: _dusumUrunler,
            selectedValue: _selectedDusumFireMalzeme,
            onChanged: (String? newValue) {
              setState(() {
                _selectedDusumFireMalzeme = newValue; 
                _selectedDusumFireDenye = null;
                _selectedDusumFireGramaj = null;
                _selectedDusumFireFine = null;
                _selectedDusumFireRenk = null; // Renk seçimini temizle
                _selectedDusumFireBoyut = null; // Boyut seçimini temizle
                _dusumGramaj.clear();
                _dusumFine.clear();
                _dusumDenye.clear(); // Renk listesini temizle
                _dusumRenkler.clear(); // Renk listesini temizle
                _dusumBoyutlar.clear(); // Boyut listesini temizle

                // Seçilen ürüne göre renkleri getir
                if (productServices.role.value == "Dikim" ||
                    productServices.role.value == "Transfer" ||
                    productServices.role.value == "Dolum" ||
                    productServices.role.value == "Paketleme") {
                  _fetchColors(collectionWait!, _selectedDusumFireMalzeme!);
                } else if (productServices.role.value == "Dokuma") {
                  _fetchDenye(collectionWait!, _selectedDusumFireMalzeme!);
                } else if (productServices.role.value == "Boyama" ||
                    productServices.role.value == "Kesim") {
                  _fetchGramaj(collectionWait!, _selectedDusumFireMalzeme!);
                }
              });
            },
            icon: Icons.arrow_drop_down,
          ),
          if (productServices.role.value == "Dokuma")
            // Renk seçme dropdown
            DropdownSelector(
              hintText: 'Denye',
              items: _dusumDenye,
              selectedValue: _selectedDusumFireDenye,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedDusumFireDenye = newValue;
                  // Seçilen renge göre boyutları getir
                  if (_selectedDusumFireDenye != null) {
                    _fetchDenyeWithMiktar(collectionWait!,
                        _selectedDusumFireMalzeme!, _selectedDusumFireDenye!);
                  }
                });
              },
              icon: Icons.arrow_drop_down,
            ),

          if (productServices.role.value == "Boyama" ||
              productServices.role.value == "Kesim")
            DropdownSelector(
              hintText: 'Gramaj',
              items: _dusumGramaj,
              selectedValue: _selectedDusumFireGramaj,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedDusumFireFine = null;

                  _selectedDusumFireRenk = null;
                  _dusumRenkler.clear();

                  _dusumFine.clear();
                  _selectedDusumFireGramaj = newValue;
                  // Seçilen renge göre boyutları getir
                  if (_selectedDusumFireGramaj != null) {
                    _fetchFine(collectionWait!, _selectedDusumFireMalzeme!,
                        _selectedDusumFireGramaj!);
                  }
                });
              },
              icon: Icons.arrow_drop_down,
            ),

          if (productServices.role.value == "Boyama" ||
              productServices.role.value == "Kesim")
            DropdownSelector(
              hintText: 'Fine',
              items: _dusumFine,
              selectedValue: _selectedDusumFireFine,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedDusumFireRenk = null;
                  _dusumRenkler.clear();
                  _selectedDusumFireFine = newValue;
                  // Seçilen renge göre boyutları getir

                  if (_selectedDusumFireFine != null) {
                    if (productServices.role.value == "Boyama") {
                      _fetchFineWithMiktar(
                          collectionWait!,
                          _selectedDusumFireMalzeme!,
                          _selectedDusumFireGramaj!,
                          _selectedDusumFireFine!);
                    }
                    if (productServices.role.value == "Kesim") {
                      _fetchKesimRenk(collectionWait!, _selectedDusumFireMalzeme!,
                          _selectedDusumFireGramaj!, _selectedDusumFireFine!);
                    }
                  }
                });
              },
              icon: Icons.arrow_drop_down,
            ),

          if (productServices.role.value == "Dikim" ||
              productServices.role.value == "Kesim" ||
              productServices.role.value == "Transfer" ||
              productServices.role.value == "Dolum" ||
              productServices.role.value == "Paketleme")
            // Renk seçme dropdown
            DropdownSelector(
              hintText: 'Renk',
              items: _dusumRenkler,
              selectedValue: _selectedDusumFireRenk,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedDusumFireRenk = newValue;
                  _selectedDusumFireBoyut = null; // Boyut seçimini temizle
                  _dusumBoyutlar.clear(); // Boyut listesini temizle

                  // Seçilen renge göre boyutları getir
                  if (_selectedDusumFireRenk != null) {
                    if (productServices.role.value == "Kesim") {
                      _fetchKesimWithMiktar(
                          collectionWait!,
                          _selectedDusumFireMalzeme!,
                          _selectedDusumFireGramaj!,
                          _selectedDusumFireFine!,
                          _selectedDusumFireRenk!);
                    } else {
                      _fetchBoyut(collectionWait!, _selectedDusumFireMalzeme!,
                          _selectedDusumFireRenk!);
                    }
                  }
                });
              },
              icon: Icons.arrow_drop_down,
            ),

          if (productServices.role.value == "Dikim" ||
              productServices.role.value == "Transfer" ||
              productServices.role.value == "Dolum" ||
              productServices.role.value == "Paketleme")
            // Boyut seçme dropdown
            DropdownSelector(
              hintText: 'Boyut',
              items: _dusumBoyutlar,
              selectedValue: _selectedDusumFireBoyut,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedDusumFireBoyut = newValue;

                  // Ürün, renk ve boyuta göre miktarı getir
                  if (_selectedDusumFireMalzeme != null &&
                      _selectedDusumFireRenk != null &&
                      _selectedDusumFireBoyut != null) {
                    _fetchBoyutWithMiktar(
                        collectionWait!,
                        _selectedDusumFireMalzeme!,
                        _selectedDusumFireRenk!,
                        _selectedDusumFireBoyut!);
                  }
                });
              },
              icon: Icons.arrow_drop_down,
            ),

          Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  left: 35.0,
                  top: 15,
                ),
                child: Text(
                  'Hazır Stok: $miktar adet', // Güncellenmiş miktarı gösterir
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w300),
                ),
              ),
            ],
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
                isLoading: isLoading,
                onPressed: () async {
                  setState(() {
                    isLoading = true;
                  });

                  try {
                    if (productServices.role.value == "Paketleme" ||
                        productServices.role.value == "Dikim" ||
                        productServices.role.value == "Dolum") {
                      if (_selectedDusumFireMalzeme!.isEmpty ||
                          _selectedDusumFireBoyut!.isEmpty ||
                          _selectedDusumFireRenk!.isEmpty ||
                          _fireMiktarController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Lütfen tüm alanları doldurun.")),
                        );
                      } else {
                        _atolyeServices.decreaseStock(
                          context: context,
                          malzeme: _selectedDusumFireMalzeme!,
                          boyut: _selectedDusumFireBoyut!,
                          renk: _selectedDusumFireRenk!,
                          miktar: int.parse(_fireMiktarController.text),
                        );
                        _atolyeServices.addFireEntry(
                            context: context,
                            malzeme: _selectedDusumFireMalzeme!,
                            boyut: _selectedDusumFireBoyut!,
                            renk: _selectedDusumFireRenk!,
                            miktar: int.parse(_fireMiktarController.text));
                      }
                    }
                    if (productServices.role.value == "Dokuma") {
                      if (_selectedDusumFireMalzeme!.isEmpty ||
                          _selectedDusumFireDenye!.isEmpty ||
                          _fireMiktarController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Lütfen tüm alanları doldurun.")),
                        );
                      } else {
                        _atolyeServices.decreaseStock(
                          context: context,
                          malzeme: _selectedDusumFireMalzeme!,
                          denye: _selectedDusumFireDenye!,
                          miktar: int.parse(_fireMiktarController.text),
                        );
                        _atolyeServices.addFireEntry(
                          context: context,
                          malzeme: _selectedDusumFireMalzeme!,
                          denye: _selectedDusumFireDenye!,
                          miktar: int.parse(_fireMiktarController.text),
                        );
                      }
                    }
                    if (productServices.role.value == "Boyama") {
                      if (_selectedDusumFireMalzeme!.isEmpty ||
                          _selectedDusumFireGramaj!.isEmpty ||
                          _selectedDusumFireFine!.isEmpty ||
                          _fireMiktarController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Lütfen tüm alanları doldurun.")),
                        );
                      } else {
                        _atolyeServices.decreaseStock(
                          context: context,
                          malzeme: _selectedDusumFireMalzeme!,
                          gramaj: _selectedDusumFireGramaj!,
                          fine: _selectedDusumFireFine!,
                          miktar: int.parse(_fireMiktarController.text),
                        );

                        _atolyeServices.addFireEntry(
                          context: context,
                          malzeme: _selectedDusumFireMalzeme!,
                          gramaj: _selectedDusumFireGramaj!,
                          fine: _selectedDusumFireFine!,
                          miktar: int.parse(_fireMiktarController.text),
                        );
                      }
                    }
                    if (productServices.role.value == "Kesim") {
                      if (_selectedDusumFireMalzeme!.isEmpty ||
                          _selectedDusumFireRenk!.isEmpty ||
                          _selectedDusumFireGramaj!.isEmpty ||
                          _selectedDusumFireFine!.isEmpty ||
                          _fireMiktarController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Lütfen tüm alanları doldurun.")),
                        );
                      } else {
                        _atolyeServices.decreaseStock(
                          context: context,
                          malzeme: _selectedDusumFireMalzeme!,
                          renk: _selectedDusumFireRenk,
                          gramaj: _selectedDusumFireGramaj!,
                          fine: _selectedDusumFireFine!,
                          miktar: int.parse(_fireMiktarController.text),
                        );

                        _atolyeServices.addFireEntry(
                          context: context,
                          malzeme: _selectedDusumFireMalzeme!,
                          renk: _selectedDusumFireRenk,
                          gramaj: _selectedDusumFireGramaj!,
                          fine: _selectedDusumFireFine!,
                          miktar: int.parse(_fireMiktarController.text),
                        );
                      }
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
                text: "Fire Ekle",
              ),
            ],
          ),
        ],
      ),
    );
  }
}


/*


// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:toyflow/services/user_services/get_data_table.dart';

import '../../../services/user_services/product_services.dart';
import '../../../services/user_component/cutom_loading_button.dart';
import '../../../services/user_component/dropdown_selector.dart';
import '../../../services/user_component/text_field_with_counter.dart';
import 'atolye_services/atolye_services.dart';

class AtolyeEditScreen extends StatefulWidget {
  const AtolyeEditScreen({super.key});

  @override
  State<AtolyeEditScreen> createState() => _AtolyeEditScreenState();
}

class _AtolyeEditScreenState extends State<AtolyeEditScreen> {
  bool isLoading = false;
  bool isLoading1 = false;
  bool isLoading2 = false;
  late String oncekiWorkshop;

  final ProductServices productServices = Get.find<ProductServices>();
  final AtolyeServices _atolyeServices = AtolyeServices();
  final DataTableService _dataTableService = DataTableService();

  //kullanılan stok
  final TextEditingController _miktarDusumController = TextEditingController();
  String? _selectedDusumAtolye; // Seçilen ürün
  String? _selectedDusumMalzeme; // Seçilen ürün
  String? _selectedDusumRenk; // Seçilen renk
  String? _selectedDusumBoyut; // Seçilen Kumaş renk
  String? _selectedDusumGramaj; // Seçilen ürün
  String? _selectedDusumFine; // Seçilen renk
  String? _selectedDusumDenye; // Seçilen Kumaş renk
  //eklenecek stok

  final TextEditingController _miktarStokController = TextEditingController();

  String? _selectedStokMalzeme; // Seçilen ürün
  String? _selectedStokKumaslar; // Seçilen Kumaş renk
  String? _selectedStokBoyut; // Seçilen Kumaş renk
  String? _selectedStokAksesuar; // Seçilen Kumaş renk
  String? _selectedStokRenk; // Seçilen Kumaş renk
  String? _selectedStokFine; // Seçilen Kumaş renk
  String? _selectedStokGramaj; // Seçilen Kumaş renk

  //Fire stok
  final TextEditingController _fireMiktarController = TextEditingController();
  String? _selectedDusumFireAtolye; // Seçilen ürün
  String? _selectedDusumFireMalzeme; // Seçilen ürün
  String? _selectedDusumFireRenk; // Seçilen renk
  String? _selectedDusumFireBoyut; // Seçilen Kumaş renk
  String? _selectedDusumFireGramaj; // Seçilen ürün
  String? _selectedDusumFireFine; // Seçilen renk
  String? _selectedDusumFireDenye; // Seçilen Kumaş renk

  List<String> _dusumUrunler = []; // Ürün listesi
  List<String> _dusumRenkler = []; // Renk listesi
  List<String> _dusumBoyutlar = []; // Renk listesi
  List<String> _dusumFine = []; // Renk listesi
  List<String> _dusumGramaj = []; // Renk listesi
  List<String> _dusumDenye = []; // Renk listesi

  int miktar = 0; // miktar listesi

  List<String> _stokKumaslar = [];
  List<String> _stokUrun = []; // Ürün listesi
  List<String> _stokBoyut = []; // Ürün listesi
  List<String> _stokRenk = []; // K
  List<String> _stokAksesuarlar = [];
  List<String> _stokGramajlar = [];
  List<String> _stokFineler = [];

  List<String> atolyeler = [];
  String? collection = "";
  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await fetchOncekiWorkshop(productServices);
    await fetchAtolyelerWithOnceki();

    // fetchAtolyelerWithOncekiAndGetCollection ile collection değeri alınacak
    if (atolyeler.isNotEmpty) {
      collection =
          await fetchAtolyelerWithOncekiAndGetCollection(atolyeler.first) ?? "";
    }

    await Future.wait([
      if (collection!.isNotEmpty) _fetchUrun(collection!),
      _fetchKumasList(),
      _fetchUrunList(),
      _fetchRenkList(),
      _fetchAksesuarList(),
      _fetchBoyutList(),
      _fetchFineList(),
      _fetchGramajList(),
    ]);
  }

//----------------------------------------------------------//
//                Getirilen Veriler                         //
//----------------------------------------------------------//

  Future<void> _fetchKumasList() async {
    List<String> fetchedUrun =
        await _dataTableService.getCollectionData('kumas', 'kumas');
    setState(() {
      _stokKumaslar = fetchedUrun;
    });
  }

  Future<void> _fetchUrunList() async {
    List<String> fetchedUrun =
        await _dataTableService.getCollectionData('toy_name', 'name');
    setState(() {
      _stokUrun = fetchedUrun;
    });
  }

  Future<void> _fetchRenkList() async {
    List<String> fetchedUrun =
        await _dataTableService.getCollectionData('toy_renk', 'renk');
    setState(() {
      _stokRenk = fetchedUrun;
    });
  }

  Future<void> _fetchBoyutList() async {
    List<String> fetchedUrun =
        await _dataTableService.getCollectionData('toy_height', 'boyut');
    setState(() {
      _stokBoyut = fetchedUrun;
    });
  }

  Future<void> _fetchAksesuarList() async {
    List<String> fetchedUrun =
        await _dataTableService.getCollectionData('toy_aksesuar', 'aksesuar');
    setState(() {
      _stokAksesuarlar = fetchedUrun;
    });
  }

  Future<void> _fetchGramajList() async {
    List<String> fetchedUrun =
        await _dataTableService.getCollectionData('gramaj', 'gramaj');
    setState(() {
      _stokGramajlar = fetchedUrun;
    });
  }

  Future<void> _fetchFineList() async {
    List<String> fetchedUrun =
        await _dataTableService.getCollectionData('fine', 'fine');
    setState(() {
      _stokFineler = fetchedUrun;
    });
  }

//----------------------------------------------------------//
//                Filtreli Gelen Veriler                    //
//----------------------------------------------------------//

  Future<void> fetchOncekiWorkshop(ProductServices productServices) async {
    try {
      final workshopName = productServices.workshopName.value;

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('connected_work_shop')
          .where('rol', isEqualTo: workshopName)
          .get();

      if (querySnapshot.docs.isEmpty) {
        throw Exception("Workshop bulunamadı!");
      }

      oncekiWorkshop = querySnapshot.docs.first['onceki'] as String;
      print("Onceki Workshop: $oncekiWorkshop");
    } catch (e) {
      oncekiWorkshop = "VarsayılanAtölye"; // Varsayılan değer
      print("Hata: $e");
    }
  }

  Future<void> fetchAtolyelerWithOnceki() async {
    try {
      if (oncekiWorkshop.isEmpty) {
        throw Exception("Onceki Workshop değeri boş!");
      }
      print("sasaasa $oncekiWorkshop");
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('atolyeler')
          .where('nitelik', isEqualTo: oncekiWorkshop)
          .get();

      atolyeler.clear();
      atolyeler.addAll(querySnapshot.docs.map((doc) => doc['name'] as String));

      print("Atolyeler: $atolyeler");
    } catch (e) {
      // Hata durumunda log yazdır
      print("111 Hata: $e");
    }
  }

  Future<String?> fetchAtolyelerWithOncekiAndGetCollection(
      String selectedName) async {
    try {
      // Onceki Workshop değerinin dolu olduğundan emin olun
      if (oncekiWorkshop.isEmpty) {
        throw Exception("Onceki Workshop değeri boş!");
      }
      print("Onceki Workshop: $oncekiWorkshop");

      // atolyeler tablosunda nitelik alanına göre arama yap
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('atolyeler')
          .where('nitelik', isEqualTo: oncekiWorkshop)
          .get();

      for (var doc in querySnapshot.docs) {
        final name = doc['name'] as String; // Atölye adı
        final collection = doc['collection'] as String; // Koleksiyon adı

        // Seçilen `name` değerine göre `collection` döndürülür
        if (name == selectedName) {
          print("Seçilen Atölye: $name, Collection: $collection");
          return collection;
        }
      }

      // Eğer `selectedName` bulunamazsa null döndür
      print("Seçilen atölye bulunamadı!");
      return null;
    } catch (e) {
      // Hata durumunda log yazdır
      print("111 Hata: $e");
      return null;
    }
  }

  Future<void> _fetchUrun(String selectedCollection) async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection(selectedCollection).get();

      setState(() {
        _dusumUrunler = snapshot.docs
            .where((doc) => doc['miktar'] != 0)
            .map((doc) => doc['urun'] as String)
            .toSet()
            .toList();
      });
    } catch (e) {
      print("WVeriler alınırken hata oluştu: $e");
    }
  }

  Future<void> _fetchDenye(
      String selectedCollection, String selectedMalzeme) async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection(selectedCollection)
          .where('urun', isEqualTo: selectedMalzeme)
          .get();

      setState(() {
        _dusumDenye = snapshot.docs
            .where((doc) => doc['miktar'] != 0)
            .map((doc) => doc['denye'] as String)
            .toSet() // Aynı renklerin tekrarını önlemek için set kullanıyoruz
            .toList();
      });
    } catch (e) {
      print("Renk verileri alınırken hata oluştu: $e");
    }
  }

  Future<void> _fetchGramaj(
      String selectedCollection, String selectedMalzeme) async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection(selectedCollection)
          .where('urun', isEqualTo: selectedMalzeme)
          .get();

      setState(() {
        _dusumGramaj = snapshot.docs
            .where((doc) => doc['miktar'] != 0)
            .map((doc) => doc['gramaj'] as String)
            .toSet() // Aynı renklerin tekrarını önlemek için set kullanıyoruz
            .toList();
      });
    } catch (e) {
      print("Renk verileri alınırken hata oluştu: $e");
    }
  }

  Future<void> _fetchFine(String selectedCollection, String selectedMalzeme,
      String selectedGramaj) async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection(selectedCollection)
          .where('urun', isEqualTo: selectedMalzeme)
          .where('gramaj', isEqualTo: selectedGramaj)
          .get();

      setState(() {
        _dusumFine = snapshot.docs
            .where((doc) => doc['miktar'] != 0)
            .map((doc) => doc['fine'] as String)
            .toSet() // Aynı renklerin tekrarını önlemek için set kullanıyoruz
            .toList();
      });
    } catch (e) {
      print("Renk verileri alınırken hata oluştu: $e");
    }
  }

  Future<void> _fetchKesimRenk(
      String selectedCollection,
      String selectedMalzeme,
      String selectedGramaj,
      String selectedFine) async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection(selectedCollection)
          .where('urun', isEqualTo: selectedMalzeme)
          .where('gramaj', isEqualTo: selectedGramaj)
          .where('fine', isEqualTo: selectedFine)
          .get();

      setState(() {
        _dusumRenkler = snapshot.docs
            .where((doc) => doc['miktar'] != 0)
            .map((doc) => doc['renk'] as String)
            .toSet() // Aynı renklerin tekrarını önlemek için set kullanıyoruz
            .toList();
      });
    } catch (e) {
      print("Renk verileri alınırken hata oluştu: $e");
    }
  }

  Future<void> _fetchColors(
      String selectedCollection, String selectedMalzeme) async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection(selectedCollection)
          .where('urun', isEqualTo: selectedMalzeme)
          .get();

      setState(() {
        _dusumRenkler = snapshot.docs
            .where((doc) => doc['miktar'] != 0)
            .map((doc) => doc['renk'] as String)
            .toSet() // Aynı renklerin tekrarını önlemek için set kullanıyoruz
            .toList();
      });
    } catch (e) {
      print("Renk verileri alınırken hata oluştu: $e");
    }
  }

  Future<void> _fetchBoyut(String selectedCollection, String selectedMalzeme,
      String selectedRenk) async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection(selectedCollection)
          .where('urun', isEqualTo: selectedMalzeme)
          .where('renk', isEqualTo: selectedRenk)
          .get();

      setState(() {
        _dusumBoyutlar = snapshot.docs
            .where((doc) => doc['miktar'] != 0)
            .map((doc) => doc['boyut'] as String)
            .toSet() // Aynı renklerin tekrarını önlemek için set kullanıyoruz
            .toList();
      });
    } catch (e) {
      print("Renk verileri alınırken hata oluştu: $e");
    }
  }

  Future<void> _fetchAksesuar(String selectedCollection, String selectedMalzeme,
      String selectedRenk, String selectedBoyut) async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection(selectedCollection)
          .where('urun', isEqualTo: selectedMalzeme)
          .where('renk', isEqualTo: selectedRenk)
          .where('boyut', isEqualTo: selectedBoyut)
          .get();

      setState(() {
        _dusumBoyutlar = snapshot.docs
            .where((doc) => doc['miktar'] != 0)
            .map((doc) => doc['aksesuar'] as String)
            .toSet() // Aynı renklerin tekrarını önlemek için set kullanıyoruz
            .toList();
      });
    } catch (e) {
      print("Renk verileri alınırken hata oluştu: $e");
    }
  }

  Future<void> _fetchBoyutWithMiktar(String selectedCollection,
      String selectedUrun, String selectedRenk, String selectedBoyut) async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection(selectedCollection)
          .where('urun', isEqualTo: selectedUrun)
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

  Future<void> _fetchDenyeWithMiktar(String selectedCollection,
      String selectedUrun, String selectedDenye) async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection(selectedCollection)
          .where('urun', isEqualTo: selectedUrun)
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

  Future<void> _fetchKesimWithMiktar(
      String selectedCollection,
      String selectedUrun,
      String selectedGramaj,
      String selectedFine,
      String selectedRenk) async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection(selectedCollection)
          .where('urun', isEqualTo: selectedUrun)
          .where('gramaj', isEqualTo: selectedGramaj)
          .where('fine', isEqualTo: selectedFine)
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

  Future<void> _fetchFineWithMiktar(String selectedCollection,
      String selectedUrun, String selectedGramaj, String selectedFine) async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection(selectedCollection)
          .where('urun', isEqualTo: selectedUrun)
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

  Future<void> _fetchAksesuarWithMiktar(
      String selectedCollection,
      String selectedUrun,
      String selectedRenk,
      String selectedBoyut,
      String selectedAksesuar) async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection(selectedCollection)
          .where('urun', isEqualTo: selectedUrun)
          .where('renk', isEqualTo: selectedRenk)
          .where('boyut', isEqualTo: selectedBoyut)
          .where('aksesuar', isEqualTo: selectedAksesuar)
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

//----------------------------------------------------------//
//----------------------------------------------------------//
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Stok Düzenleme',
            style: TextStyle(fontSize: 15),
          ),
          bottom: TabBar(
            labelColor: Colors.black,
            indicatorColor: Colors.black,
            tabs: [
              Tab(
                  text: "Stok Ekle",
                  icon: Container(
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 2,
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(Icons.add_shopping_cart,
                              color: Colors.white)))),
              Tab(
                  text: "Düşüm Yap",
                  icon: Container(
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 2,
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(Icons.remove_shopping_cart,
                            color: Colors.white),
                      ))),
              Tab(
                  text: "Fire Ekle",
                  icon: Container(
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 2,
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(Icons.delete_outline,
                              color: Colors.white)))),
            ],
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: TabBarView(
            children: [
              _stokEkleTab(),
              _dusumYapTab(),
              _fireEkleTab(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stokEkleTab() {
    return SingleChildScrollView(
      child: Column(
        children: [

          // Ürün seçme dropdown
          if (productServices.role.value == "Dikim" ||
              productServices.role.value == "Kesim" ||
              productServices.role.value == "Transfer" ||
              productServices.role.value == "Dolum" ||
              productServices.role.value == "Paketleme")
            DropdownSelector(
              hintText: 'Dönüştürülen Ürün',
              items: _stokUrun,
              selectedValue: _selectedStokMalzeme,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedStokMalzeme = newValue;
                });
              },
              icon: Icons.arrow_drop_down,
            ),

          if (productServices.role.value == "Boyama" ||
              productServices.role.value == "Dokuma")
            DropdownSelector(
              
              hintText: 'Kumaş',
              items: _stokKumaslar,
              selectedValue: _selectedStokKumaslar,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedStokKumaslar = newValue;
                });
              },
              icon: Icons.arrow_drop_down,
            ),
          if (productServices.role.value == "Kesim" ||
              productServices.role.value == "Boyama" ||
              productServices.role.value == "Dikim" ||
              productServices.role.value == "Dolum" ||
              productServices.role.value == "Paketleme")
            // Renk seçme dropdown
            DropdownSelector(
              hintText: 'Renk',
              items: _stokRenk,
              selectedValue: _selectedStokRenk,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedStokRenk = newValue;
                });
              },
              icon: Icons.arrow_drop_down,
            ),

          if (productServices.role.value == "Dikim" ||
              productServices.role.value == "Kesim" ||
              productServices.role.value == "Transfer" ||
              productServices.role.value == "Dolum" ||
              productServices.role.value == "Paketleme")
            // boyut seçme dropdown
            DropdownSelector(
              hintText: ' Boyut',
              items: _stokBoyut,
              selectedValue: _selectedStokBoyut,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedStokBoyut = newValue;
                });
              },
              icon: Icons.arrow_drop_down,
            ),
          if (productServices.role.value == "Paketleme")
            DropdownSelector(
              hintText: "Aksesuar",
              items: _stokAksesuarlar,
              selectedValue: _selectedStokAksesuar,
              icon: Icons.arrow_drop_down,
              onChanged: (value) {
                setState(() {
                  _selectedStokAksesuar = value;
                });
              },
            ),

          if (productServices.role.value == "Boyama" ||
              productServices.role.value == "Dokuma")
            DropdownSelector(
              hintText: "Gramaj",
              items: _stokGramajlar,
              selectedValue: _selectedStokGramaj,
              icon: Icons.scale,
              onChanged: (value) {
                setState(() {
                  _selectedStokGramaj = value;
                });
              },
            ),
          if (productServices.role.value == "Boyama" ||
              productServices.role.value == "Dokuma")
            DropdownSelector(
              hintText: "Fine",
              items: _stokFineler,
              selectedValue: _selectedStokFine,
              icon: Icons.line_axis,
              onChanged: (value) {
                setState(() {
                  _selectedStokFine = value;
                });
              },
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // TextFieldWithCounter Widget
              Expanded(
                flex: 3, // Genişliği ayarlamak için
                child: TextFieldWithCounter(
                  controller: _miktarStokController,
                  hintText: 'Miktar',
                  icon: Icons.shopping_cart,
                ),
              ),
              const SizedBox(width: 10), // TextField ve Button arasında boşluk
              // ElevatedButton
              CustomLoadingButton(
                isLoading: isLoading1,
                onPressed: () async {
                  setState(() {
                    isLoading1 = true;
                  });

                  try {
                    if (productServices.role.value == "Kesim" ||
                        productServices.role.value == "Dikim" ||
                        productServices.role.value == "Dolum") {
                      if (_selectedStokMalzeme!.isEmpty ||
                          _selectedStokRenk!.isEmpty ||
                          _selectedStokBoyut!.isEmpty ||
                          _miktarStokController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Lütfen tüm alanları doldurun.")),
                        );
                      } else {
                        _atolyeServices.addOrUpdateUrunStock(
                          context: context,
                          urun: _selectedStokMalzeme!,
                          renk: _selectedStokRenk!,
                          boyut: _selectedStokBoyut!,
                          miktar: int.parse(_miktarStokController.text),
                        );
                      }
                    }
                    if (productServices.role.value == "Paketleme") {
                      if (_selectedStokMalzeme!.isEmpty ||
                          _selectedStokRenk!.isEmpty ||
                          _selectedStokBoyut!.isEmpty ||
                          _selectedStokAksesuar!.isEmpty ||
                          _miktarStokController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Lütfen tüm alanları doldurun.")),
                        );
                      } else {
                        _atolyeServices.addOrUpdateUrunStock(
                          context: context,
                          urun: _selectedStokMalzeme!,
                          renk: _selectedStokRenk!,
                          boyut: _selectedStokBoyut!,
                          aksesuar: _selectedStokAksesuar!,
                          miktar: int.parse(_miktarStokController.text),
                        );
                      }
                    }

                    if (productServices.role.value == "Dokuma") {
                      if (_selectedStokKumaslar!.isEmpty ||
                          _selectedStokGramaj!.isEmpty ||
                          _selectedStokFine!.isEmpty ||
                          _miktarStokController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Lütfen tüm alanları doldurun.")),
                        );
                      } else {
                        _atolyeServices.addOrUpdateUrunStock(
                          context: context,
                          urun: _selectedStokKumaslar!,
                          gramaj: _selectedStokGramaj!,
                          fine: _selectedStokFine!,
                          miktar: int.parse(_miktarStokController.text),
                        );
                      }
                    }
                    if (productServices.role.value == "Boyama") {
                      if (_selectedStokKumaslar!.isEmpty ||
                          _selectedStokRenk!.isEmpty ||
                          _selectedStokGramaj!.isEmpty ||
                          _selectedStokFine!.isEmpty ||
                          _miktarStokController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Lütfen tüm alanları doldurun.")),
                        );
                      } else {
                        _atolyeServices.addOrUpdateUrunStock(
                          context: context,
                          urun: _selectedStokKumaslar!,
                          renk: _selectedStokRenk,
                          gramaj: _selectedStokGramaj!,
                          fine: _selectedStokFine!,
                          miktar: int.parse(_miktarStokController.text),
                        );
                      }
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
        ],
      ),
    );
  }

  Widget _dusumYapTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // atolye seçme dropdown
          DropdownSelector(
            hintText: 'Atölye',
            items: atolyeler,
            selectedValue: _selectedDusumAtolye,
            onChanged: (String? newValue) async {
              // async ekleniyor
              setState(() {
                _selectedDusumAtolye = newValue;
                _selectedDusumMalzeme = null; // Renk seçimini temizle
                _selectedDusumRenk = null; // Renk seçimini temizle
                _selectedDusumBoyut = null; // Boyut seçimini temizle
                _selectedDusumDenye = null;
                _dusumGramaj.clear();
                _dusumFine.clear();
                _selectedDusumGramaj = null;
                _selectedDusumFine = null;
                _dusumDenye.clear(); // Renk listesini temizle
                _dusumUrunler.clear(); // Boyut listesini temizle
                _dusumRenkler.clear(); // Renk listesini temizle
                _dusumBoyutlar.clear(); // Boyut listesini temizle
              });

              if (_selectedDusumAtolye != null) {
                try {
                  // Collection değerini getir
                  String? fetchedCollection =
                      await fetchAtolyelerWithOncekiAndGetCollection(
                          _selectedDusumAtolye!);

                  if (fetchedCollection != null) {
                    setState(() {
                      collection =
                          fetchedCollection; // collection değerini güncelle
                    });
                    print("$collection asdad");

                    // Collection değerine göre ürünleri getir
                    await _fetchUrun(collection!);
                    print(_dusumUrunler);
                  } else {
                    print("Collection bulunamadı!");
                  }
                } catch (e) {
                  print("Hata: $e");
                }
              }
            },
            icon: Icons.arrow_drop_down,
          ),

          // Ürün seçme dropdown
          DropdownSelector(
            hintText: 'Kullanılan Ürün',
            items: _dusumUrunler,
            selectedValue: _selectedDusumMalzeme,
            onChanged: (String? newValue) {
              setState(() {
                _selectedDusumMalzeme = newValue;
                _selectedDusumDenye = null;
                _selectedDusumGramaj = null;
                _selectedDusumFine = null;
                _selectedDusumRenk = null; // Renk seçimini temizle
                _selectedDusumBoyut = null; // Boyut seçimini temizle
                _dusumGramaj.clear();
                _dusumFine.clear();
                _dusumDenye.clear(); // Renk listesini temizle
                _dusumRenkler.clear(); // Renk listesini temizle
                _dusumBoyutlar.clear(); // Boyut listesini temizle

                // Seçilen ürüne göre renkleri getir
                if (productServices.role.value == "Dikim" ||
                    productServices.role.value == "Transfer" ||
                    productServices.role.value == "Dolum" ||
                    productServices.role.value == "Paketleme") {
                  _fetchColors(collection!, _selectedDusumMalzeme!);
                } else if (productServices.role.value == "Dokuma") {
                  _fetchDenye(collection!, _selectedDusumMalzeme!);
                } else if (productServices.role.value == "Boyama" ||
                    productServices.role.value == "Kesim") {
                  _fetchGramaj(collection!, _selectedDusumMalzeme!);
                }
              });
            },
            icon: Icons.arrow_drop_down,
          ),
          if (productServices.role.value == "Dokuma")
            // Renk seçme dropdown
            DropdownSelector(
              hintText: 'Denye',
              items: _dusumDenye,
              selectedValue: _selectedDusumDenye,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedDusumDenye = newValue;
                  // Seçilen renge göre boyutları getir
                  if (_selectedDusumDenye != null) {
                    _fetchDenyeWithMiktar(collection!, _selectedDusumMalzeme!,
                        _selectedDusumDenye!);
                  }
                });
              },
              icon: Icons.arrow_drop_down,
            ),

          if (productServices.role.value == "Boyama" ||
              productServices.role.value == "Kesim")
            DropdownSelector(
              hintText: 'Gramaj',
              items: _dusumGramaj,
              selectedValue: _selectedDusumGramaj,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedDusumFine = null;

                  _selectedDusumRenk = null;
                  _dusumRenkler.clear();

                  _dusumFine.clear();
                  _selectedDusumGramaj = newValue;
                  // Seçilen renge göre boyutları getir
                  if (_selectedDusumGramaj != null) {
                    _fetchFine(collection!, _selectedDusumMalzeme!,
                        _selectedDusumGramaj!);
                  }
                });
              },
              icon: Icons.arrow_drop_down,
            ),

          if (productServices.role.value == "Boyama" ||
              productServices.role.value == "Kesim")
            DropdownSelector(
              hintText: 'Fine',
              items: _dusumFine,
              selectedValue: _selectedDusumFine,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedDusumRenk = null;
                  _dusumRenkler.clear();
                  _selectedDusumFine = newValue;
                  // Seçilen renge göre boyutları getir

                  if (_selectedDusumFine != null) {
                    if (productServices.role.value == "Boyama") {
                      _fetchFineWithMiktar(collection!, _selectedDusumMalzeme!,
                          _selectedDusumGramaj!, _selectedDusumFine!);
                    }
                    if (productServices.role.value == "Kesim") {
                      _fetchKesimRenk(collection!, _selectedDusumMalzeme!,
                          _selectedDusumGramaj!, _selectedDusumFine!);
                    }
                  }
                });
              },
              icon: Icons.arrow_drop_down,
            ),

          if (productServices.role.value == "Dikim" ||
              productServices.role.value == "Kesim" ||
              productServices.role.value == "Transfer" ||
              productServices.role.value == "Dolum" ||
              productServices.role.value == "Paketleme")
            // Renk seçme dropdown
            DropdownSelector(
              hintText: 'Renk',
              items: _dusumRenkler,
              selectedValue: _selectedDusumRenk,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedDusumRenk = newValue;
                  _selectedDusumBoyut = null; // Boyut seçimini temizle
                  _dusumBoyutlar.clear(); // Boyut listesini temizle

                  // Seçilen renge göre boyutları getir
                  if (_selectedDusumRenk != null) {
                    if (productServices.role.value == "Kesim") {
                      _fetchKesimWithMiktar(
                          collection!,
                          _selectedDusumMalzeme!,
                          _selectedDusumGramaj!,
                          _selectedDusumFine!,
                          _selectedDusumRenk!);
                    } else {
                      _fetchBoyut(collection!, _selectedDusumMalzeme!,
                          _selectedDusumRenk!);
                    }
                  }
                });
              },
              icon: Icons.arrow_drop_down,
            ),

          if (productServices.role.value == "Dikim" ||
              productServices.role.value == "Transfer" ||
              productServices.role.value == "Dolum" ||
              productServices.role.value == "Paketleme")
            // Boyut seçme dropdown
            DropdownSelector(
              hintText: 'Boyut',
              items: _dusumBoyutlar,
              selectedValue: _selectedDusumBoyut,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedDusumBoyut = newValue;

                  // Ürün, renk ve boyuta göre miktarı getir
                  if (_selectedDusumMalzeme != null &&
                      _selectedDusumRenk != null &&
                      _selectedDusumBoyut != null) {
                    _fetchBoyutWithMiktar(collection!, _selectedDusumMalzeme!,
                        _selectedDusumRenk!, _selectedDusumBoyut!);
                  }
                });
              },
              icon: Icons.arrow_drop_down,
            ),

          Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  left: 35.0,
                  top: 15,
                ),
                child: Text(
                  'Hazır Stok: $miktar adet', // Güncellenmiş miktarı gösterir
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w300),
                ),
              ),
            ],
          ),

          // Miktar girme
          Row(
            children: [
              Expanded(
                flex: 3,
                child: TextFieldWithCounter(
                  controller: _miktarDusumController,
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
                    if (productServices.role.value == "Paketleme" ||
                        productServices.role.value == "Dikim" ||
                        productServices.role.value == "Dolum") {
                      if (_selectedDusumMalzeme!.isEmpty ||
                          _selectedDusumBoyut!.isEmpty ||
                          _selectedDusumRenk!.isEmpty ||
                          _miktarDusumController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Lütfen tüm alanları doldurun.")),
                        );
                      } else {
                        _atolyeServices.decreaseStock(
                          context: context,
                          collection: collection!,
                          malzeme: _selectedDusumMalzeme!,
                          boyut: _selectedDusumBoyut!,
                          renk: _selectedDusumRenk!,
                          miktar: int.parse(_miktarDusumController.text),
                        );
                      }
                    }
                    if (productServices.role.value == "Dokuma") {
                      if (_selectedDusumMalzeme!.isEmpty ||
                          _selectedDusumDenye!.isEmpty ||
                          _miktarDusumController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Lütfen tüm alanları doldurun.")),
                        );
                      } else {
                        _atolyeServices.decreaseStock(
                          context: context,
                          collection: collection!,
                          malzeme: _selectedDusumMalzeme!,
                          denye: _selectedDusumDenye!,
                          miktar: int.parse(_miktarDusumController.text),
                        );
                      }
                    }
                    if (productServices.role.value == "Boyama") {
                      if (_selectedDusumMalzeme!.isEmpty ||
                          _selectedDusumGramaj!.isEmpty ||
                          _selectedDusumFine!.isEmpty ||
                          _miktarDusumController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Lütfen tüm alanları doldurun.")),
                        );
                      } else {
                        _atolyeServices.decreaseStock(
                          context: context,
                          collection: collection!,
                          malzeme: _selectedDusumMalzeme!,
                          gramaj: _selectedDusumGramaj!,
                          fine: _selectedDusumFine!,
                          miktar: int.parse(_miktarDusumController.text),
                        );
                      }
                    }
                    if (productServices.role.value == "Kesim") {
                      if (_selectedDusumMalzeme!.isEmpty ||
                          _selectedDusumRenk!.isEmpty ||
                          _selectedDusumGramaj!.isEmpty ||
                          _selectedDusumFine!.isEmpty ||
                          _miktarDusumController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Lütfen tüm alanları doldurun.")),
                        );
                      } else {
                        _atolyeServices.decreaseStock(
                          context: context,
                          collection: collection!,
                          malzeme: _selectedDusumMalzeme!,
                          renk: _selectedDusumRenk,
                          gramaj: _selectedDusumGramaj!,
                          fine: _selectedDusumFine!,
                          miktar: int.parse(_miktarDusumController.text),
                        );
                      }
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
        ],
      ),
    );
  }

  Widget _fireEkleTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // atolye seçme dropdown
          DropdownSelector(
            hintText: 'Atölye',
            items: atolyeler,
            selectedValue: _selectedDusumFireAtolye,
            onChanged: (String? newValue) async {
              // async ekleniyor
              setState(() {
                _selectedDusumFireAtolye = newValue;
                _selectedDusumFireMalzeme = null; // Renk seçimini temizle
                _selectedDusumFireRenk = null; // Renk seçimini temizle
                _selectedDusumFireBoyut = null; // Boyut seçimini temizle
                _selectedDusumFireDenye = null;
                _dusumGramaj.clear();
                _dusumFine.clear();
                _selectedDusumFireGramaj = null;
                _selectedDusumFireFine = null;
                _dusumDenye.clear(); // Renk listesini temizle
                _dusumUrunler.clear(); // Boyut listesini temizle
                _dusumRenkler.clear(); // Renk listesini temizle
                _dusumBoyutlar.clear(); // Boyut listesini temizle
              });

              if (_selectedDusumFireAtolye != null) {
                try {
                  // Collection değerini getir
                  String? fetchedCollection =
                      await fetchAtolyelerWithOncekiAndGetCollection(
                          _selectedDusumFireAtolye!);

                  if (fetchedCollection != null) {
                    setState(() {
                      collection =
                          fetchedCollection; // collection değerini güncelle
                    });
                    print("$collection asdad");

                    // Collection değerine göre ürünleri getir
                    await _fetchUrun(collection!);
                    print(_dusumUrunler);
                  } else {
                    print("Collection bulunamadı!");
                  }
                } catch (e) {
                  print("Hata: $e");
                }
              }
            },
            icon: Icons.arrow_drop_down,
          ),

          // Ürün seçme dropdown
          DropdownSelector(
            hintText: 'Fire Ürün',
            items: _dusumUrunler,
            selectedValue: _selectedDusumFireMalzeme,
            onChanged: (String? newValue) {
              setState(() {
                _selectedDusumFireMalzeme = newValue;
                _selectedDusumFireDenye = null;
                _selectedDusumFireGramaj = null;
                _selectedDusumFireFine = null;
                _selectedDusumFireRenk = null; // Renk seçimini temizle
                _selectedDusumFireBoyut = null; // Boyut seçimini temizle
                _dusumGramaj.clear();
                _dusumFine.clear();
                _dusumDenye.clear(); // Renk listesini temizle
                _dusumRenkler.clear(); // Renk listesini temizle
                _dusumBoyutlar.clear(); // Boyut listesini temizle

                // Seçilen ürüne göre renkleri getir
                if (productServices.role.value == "Dikim" ||
                    productServices.role.value == "Transfer" ||
                    productServices.role.value == "Dolum" ||
                    productServices.role.value == "Paketleme") {
                  _fetchColors(collection!, _selectedDusumFireMalzeme!);
                } else if (productServices.role.value == "Dokuma") {
                  _fetchDenye(collection!, _selectedDusumFireMalzeme!);
                } else if (productServices.role.value == "Boyama" ||
                    productServices.role.value == "Kesim") {
                  _fetchGramaj(collection!, _selectedDusumFireMalzeme!);
                }
              });
            },
            icon: Icons.arrow_drop_down,
          ),
          if (productServices.role.value == "Dokuma")
            // Renk seçme dropdown
            DropdownSelector(
              hintText: 'Denye',
              items: _dusumDenye,
              selectedValue: _selectedDusumFireDenye,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedDusumFireDenye = newValue;
                  // Seçilen renge göre boyutları getir
                  if (_selectedDusumFireDenye != null) {
                    _fetchDenyeWithMiktar(collection!,
                        _selectedDusumFireMalzeme!, _selectedDusumFireDenye!);
                  }
                });
              },
              icon: Icons.arrow_drop_down,
            ),

          if (productServices.role.value == "Boyama" ||
              productServices.role.value == "Kesim")
            DropdownSelector(
              hintText: 'Gramaj',
              items: _dusumGramaj,
              selectedValue: _selectedDusumFireGramaj,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedDusumFireFine = null;

                  _selectedDusumFireRenk = null;
                  _dusumRenkler.clear();

                  _dusumFine.clear();
                  _selectedDusumFireGramaj = newValue;
                  // Seçilen renge göre boyutları getir
                  if (_selectedDusumFireGramaj != null) {
                    _fetchFine(collection!, _selectedDusumFireMalzeme!,
                        _selectedDusumFireGramaj!);
                  }
                });
              },
              icon: Icons.arrow_drop_down,
            ),

          if (productServices.role.value == "Boyama" ||
              productServices.role.value == "Kesim")
            DropdownSelector(
              hintText: 'Fine',
              items: _dusumFine,
              selectedValue: _selectedDusumFireFine,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedDusumFireRenk = null;
                  _dusumRenkler.clear();
                  _selectedDusumFireFine = newValue;
                  // Seçilen renge göre boyutları getir

                  if (_selectedDusumFireFine != null) {
                    if (productServices.role.value == "Boyama") {
                      _fetchFineWithMiktar(
                          collection!,
                          _selectedDusumFireMalzeme!,
                          _selectedDusumFireGramaj!,
                          _selectedDusumFireFine!);
                    }
                    if (productServices.role.value == "Kesim") {
                      _fetchKesimRenk(collection!, _selectedDusumFireMalzeme!,
                          _selectedDusumFireGramaj!, _selectedDusumFireFine!);
                    }
                  }
                });
              },
              icon: Icons.arrow_drop_down,
            ),

          if (productServices.role.value == "Dikim" ||
              productServices.role.value == "Kesim" ||
              productServices.role.value == "Transfer" ||
              productServices.role.value == "Dolum" ||
              productServices.role.value == "Paketleme")
            // Renk seçme dropdown
            DropdownSelector(
              hintText: 'Renk',
              items: _dusumRenkler,
              selectedValue: _selectedDusumFireRenk,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedDusumFireRenk = newValue;
                  _selectedDusumFireBoyut = null; // Boyut seçimini temizle
                  _dusumBoyutlar.clear(); // Boyut listesini temizle

                  // Seçilen renge göre boyutları getir
                  if (_selectedDusumFireRenk != null) {
                    if (productServices.role.value == "Kesim") {
                      _fetchKesimWithMiktar(
                          collection!,
                          _selectedDusumFireMalzeme!,
                          _selectedDusumFireGramaj!,
                          _selectedDusumFireFine!,
                          _selectedDusumFireRenk!);
                    } else {
                      _fetchBoyut(collection!, _selectedDusumFireMalzeme!,
                          _selectedDusumFireRenk!);
                    }
                  }
                });
              },
              icon: Icons.arrow_drop_down,
            ),

          if (productServices.role.value == "Dikim" ||
              productServices.role.value == "Transfer" ||
              productServices.role.value == "Dolum" ||
              productServices.role.value == "Paketleme")
            // Boyut seçme dropdown
            DropdownSelector(
              hintText: 'Boyut',
              items: _dusumBoyutlar,
              selectedValue: _selectedDusumFireBoyut,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedDusumFireBoyut = newValue;

                  // Ürün, renk ve boyuta göre miktarı getir
                  if (_selectedDusumFireMalzeme != null &&
                      _selectedDusumFireRenk != null &&
                      _selectedDusumFireBoyut != null) {
                    _fetchBoyutWithMiktar(
                        collection!,
                        _selectedDusumFireMalzeme!,
                        _selectedDusumFireRenk!,
                        _selectedDusumFireBoyut!);
                  }
                });
              },
              icon: Icons.arrow_drop_down,
            ),

          Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  left: 35.0,
                  top: 15,
                ),
                child: Text(
                  'Hazır Stok: $miktar adet', // Güncellenmiş miktarı gösterir
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w300),
                ),
              ),
            ],
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
                isLoading: isLoading,
                onPressed: () async {
                  setState(() {
                    isLoading = true;
                  });

                  try {
                    if (productServices.role.value == "Paketleme" ||
                        productServices.role.value == "Dikim" ||
                        productServices.role.value == "Dolum") {
                      if (_selectedDusumFireMalzeme!.isEmpty ||
                          _selectedDusumFireBoyut!.isEmpty ||
                          _selectedDusumFireRenk!.isEmpty ||
                          _fireMiktarController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Lütfen tüm alanları doldurun.")),
                        );
                      } else {
                        _atolyeServices.decreaseStock(
                          context: context,
                          collection: collection!,
                          malzeme: _selectedDusumFireMalzeme!,
                          boyut: _selectedDusumFireBoyut!,
                          renk: _selectedDusumFireRenk!,
                          miktar: int.parse(_fireMiktarController.text),
                        );
                        _atolyeServices.addFireEntry(
                            context: context,
                            malzeme: _selectedDusumFireMalzeme!,
                            boyut: _selectedDusumFireBoyut!,
                            renk: _selectedDusumFireRenk!,
                            miktar: int.parse(_fireMiktarController.text));
                      }
                    }
                    if (productServices.role.value == "Dokuma") {
                      if (_selectedDusumFireMalzeme!.isEmpty ||
                          _selectedDusumFireDenye!.isEmpty ||
                          _fireMiktarController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Lütfen tüm alanları doldurun.")),
                        );
                      } else {
                        _atolyeServices.decreaseStock(
                          context: context,
                          collection: collection!,
                          malzeme: _selectedDusumFireMalzeme!,
                          denye: _selectedDusumFireDenye!,
                          miktar: int.parse(_fireMiktarController.text),
                        );
                        _atolyeServices.addFireEntry(
                          context: context,
                          malzeme: _selectedDusumFireMalzeme!,
                          denye: _selectedDusumFireDenye!,
                          miktar: int.parse(_fireMiktarController.text),
                        );
                      }
                    }
                    if (productServices.role.value == "Boyama") {
                      if (_selectedDusumFireMalzeme!.isEmpty ||
                          _selectedDusumFireGramaj!.isEmpty ||
                          _selectedDusumFireFine!.isEmpty ||
                          _fireMiktarController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Lütfen tüm alanları doldurun.")),
                        );
                      } else {
                        _atolyeServices.decreaseStock(
                          context: context,
                          collection: collection!,
                          malzeme: _selectedDusumFireMalzeme!,
                          gramaj: _selectedDusumFireGramaj!,
                          fine: _selectedDusumFireFine!,
                          miktar: int.parse(_fireMiktarController.text),
                        );

                        _atolyeServices.addFireEntry(
                          context: context,
                          malzeme: _selectedDusumFireMalzeme!,
                          gramaj: _selectedDusumFireGramaj!,
                          fine: _selectedDusumFireFine!,
                          miktar: int.parse(_fireMiktarController.text),
                        );
                      }
                    }
                    if (productServices.role.value == "Kesim") {
                      if (_selectedDusumFireMalzeme!.isEmpty ||
                          _selectedDusumFireRenk!.isEmpty ||
                          _selectedDusumFireGramaj!.isEmpty ||
                          _selectedDusumFireFine!.isEmpty ||
                          _fireMiktarController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Lütfen tüm alanları doldurun.")),
                        );
                      } else {
                        _atolyeServices.decreaseStock(
                          context: context,
                          collection: collection!,
                          malzeme: _selectedDusumFireMalzeme!,
                          renk: _selectedDusumFireRenk,
                          gramaj: _selectedDusumFireGramaj!,
                          fine: _selectedDusumFireFine!,
                          miktar: int.parse(_fireMiktarController.text),
                        );

                        _atolyeServices.addFireEntry(
                          context: context,
                          malzeme: _selectedDusumFireMalzeme!,
                          renk: _selectedDusumFireRenk,
                          gramaj: _selectedDusumFireGramaj!,
                          fine: _selectedDusumFireFine!,
                          miktar: int.parse(_fireMiktarController.text),
                        );
                      }
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
                text: "Fire Ekle",
              ),
            ],
          ),
        ],
      ),
    );
  }
}

 */