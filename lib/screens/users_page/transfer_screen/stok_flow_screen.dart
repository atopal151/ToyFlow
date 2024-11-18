import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../services/user_services/dropdown_selector.dart';
import '../../../services/user_services/text_field_with_counter.dart';

class StockFlowScreen extends StatefulWidget {
  const StockFlowScreen({super.key});

  @override
  State<StockFlowScreen> createState() => _StockFlowScreenState();
}

class _StockFlowScreenState extends State<StockFlowScreen> {
  final TextEditingController _miktarController = TextEditingController();

  String? _selectedDepo;
  String? _selectedMalzeme;
  String? _selectedRenk;
  String? _selectedBoyut;
  String? _selectedAksesuar;

  List<String> _depolar = [];
  List<String> _donusumUrun = [];
  List<String> _renk = [];
  List<String> _boyut = [];
  List<String> _aksesuar = [];

  int miktar = 0; // Güncel stok miktarı

  @override
  void initState() {
    super.initState();
    _fetchDepolar();
  }

  Map<String, String> _depoCollectionMap =
      {}; // Depo adı ile koleksiyon ismini eşleştirmek için

  Future<void> _fetchDepolar() async {
    final depolarSnapshot =
        await FirebaseFirestore.instance.collection('depolar').get();
    setState(() {
      _depoCollectionMap = {
        for (var doc in depolarSnapshot.docs)
          doc['title'] as String: doc['collection'] as String
      };
      _depolar = _depoCollectionMap.keys.toList();
      print(_depoCollectionMap);
      print("depooooooooo");
    });
  }

  Future<void> _fetchUrunler(String depoCollection) async {
    final urunSnapshot =
        await FirebaseFirestore.instance.collection(depoCollection).get();
    setState(() {
      // Tekrar eden ürünleri önlemek için bir Set kullanıyoruz.
      final urunSet =
          urunSnapshot.docs.map((doc) => doc['urun'] as String).toSet();
      _donusumUrun = urunSet.toList(); // Set'i listeye dönüştürüyoruz.
    });
  }

  Future<void> _fetchRenkler(String depoCollection, String urun) async {
    try {
      print(depoCollection);
      debugPrint(
          "Fetching renkler from collection: $depoCollection with urun: $urun");

      final renkSnapshot = await FirebaseFirestore.instance
          .collection(depoCollection)
          .where('urun', isEqualTo: urun)
          .get();

      if (renkSnapshot.docs.isEmpty) {
        debugPrint(
            "No renk found for urun: $urun in collection: $depoCollection");
        setState(() {
          _renk = [];
        });
        return;
      }

      setState(() {
        final renkSet =
            renkSnapshot.docs.map((doc) => doc['renk'] as String).toSet();
        _renk = renkSet.toList();
      });

      debugPrint("Fetched renkler: $_renk");
    } catch (e) {
      debugPrint("Error fetching renkler: $e");
    }
  }

  Future<void> _fetchBoyutlar(
      String depoCollection, String urun, String renk) async {
    try {
      final boyutSnapshot = await FirebaseFirestore.instance
          .collection(depoCollection)
          .where('urun', isEqualTo: urun)
          .where('renk', isEqualTo: renk)
          .get();
      setState(() {
        // Tekrar eden boyutları önlemek için Set kullanıyoruz.
        final boyutSet =
            boyutSnapshot.docs.map((doc) => doc['boyut'] as String).toSet();
        _boyut = boyutSet.toList();
      });
    } catch (e) {
      debugPrint("Error fetching boyutlar: $e");
    }
  }

  Future<void> _fetchAksesuarlar(
      String depoCollection, String urun, String renk, String boyut) async {
    try {
      final aksesuarSnapshot = await FirebaseFirestore.instance
          .collection(depoCollection)
          .where('urun', isEqualTo: urun)
          .where('renk', isEqualTo: renk)
          .where('boyut', isEqualTo: boyut)
          .get();
      setState(() {
        // Tekrar eden aksesuarları önlemek için Set kullanıyoruz.
        final aksesuarSet = aksesuarSnapshot.docs
            .map((doc) => doc['aksesuar'] as String)
            .toSet();
        _aksesuar = aksesuarSet.toList();
      });
    } catch (e) {
      debugPrint("Error fetching aksesuarlar: $e");
    }
  }

  Future<void> _fetchMiktar(String depoCollection, String urun, String renk,
      String boyut, String aksesuar) async {
    try {
      final miktarSnapshot = await FirebaseFirestore.instance
          .collection(depoCollection)
          .where('urun', isEqualTo: urun)
          .where('renk', isEqualTo: renk)
          .where('boyut', isEqualTo: boyut)
          .where('aksesuar', isEqualTo: aksesuar)
          .get();
      if (miktarSnapshot.docs.isNotEmpty) {
        setState(() {
          miktar = miktarSnapshot.docs.first['miktar'] as int;
        });
      } else {
        setState(() {
          miktar = 0; // Eğer veri bulunamazsa stok 0 olarak ayarlanır.
        });
      }
    } catch (e) {
      debugPrint("Error fetching miktar: $e");
      setState(() {
        miktar = 0; // Hata durumunda stok 0 olarak ayarlanır.
      });
    }
  }

  Future<void> _updateMiktar(String depoCollection, String urun, String renk,
      String boyut, String aksesuar, int miktarGirdi) async {
    final docSnapshot = await FirebaseFirestore.instance
        .collection(depoCollection)
        .where('urun', isEqualTo: urun)
        .where('renk', isEqualTo: renk)
        .where('boyut', isEqualTo: boyut)
        .where('aksesuar', isEqualTo: aksesuar)
        .get();

    if (docSnapshot.docs.isNotEmpty) {
      final docId = docSnapshot.docs.first.id;
      final mevcutMiktar = docSnapshot.docs.first['miktar'] as int;

      await FirebaseFirestore.instance
          .collection(depoCollection)
          .doc(docId)
          .update({'miktar': mevcutMiktar - miktarGirdi});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Satılan Ürün Kayıt Ekranı",
          style: TextStyle(fontSize: 15),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          
          DropdownSelector(
            hintText: 'Depo',
            items: _depolar,
            selectedValue: _selectedDepo,
            onChanged: (String? newValue) {
              setState(() {
                _selectedDepo = newValue;
                final depoCollection =
                    _depoCollectionMap[newValue!]; // Depoya ait koleksiyon ismi
                if (depoCollection != null) {
                  _fetchUrunler(depoCollection);
                  // Alt alanları sıfırla
                  _selectedMalzeme = null;
                  _selectedRenk = null;
                  _selectedBoyut = null;
                  _selectedAksesuar = null;
                  _renk = [];
                  _boyut = [];
                  _aksesuar = [];
                  miktar = 0;
                }
              });
            },
            icon: Icons.arrow_drop_down,
          ),
          DropdownSelector(
            hintText: 'Ürün',
            items: _donusumUrun,
            selectedValue: _selectedMalzeme,
            onChanged: (String? newValue) {
              setState(() {
                _selectedMalzeme = newValue;
                if (newValue != null) {
                  _fetchRenkler(_selectedDepo!, newValue);
                  // Alt alanları sıfırla
                  _selectedRenk = null;
                  _selectedBoyut = null;
                  _selectedAksesuar = null;
                  _boyut = [];
                  _aksesuar = [];
                  miktar = 0;
                }
              });
            },
            icon: Icons.arrow_drop_down,
          ),
          DropdownSelector(
            hintText: 'Renk',
            items: _renk,
            selectedValue: _selectedRenk,
            onChanged: (String? newValue) {
              setState(() {
                _selectedRenk = newValue;
                if (newValue != null) {
                  _fetchBoyutlar(_selectedDepo!, _selectedMalzeme!, newValue);
                  // Alt alanları sıfırla
                  _selectedBoyut = null;
                  _selectedAksesuar = null;
                  _aksesuar = [];
                  miktar = 0;
                }
              });
            },
            icon: Icons.arrow_drop_down,
          ),
          DropdownSelector(
            hintText: 'Boyut',
            items: _boyut,
            selectedValue: _selectedBoyut,
            onChanged: (String? newValue) {
              setState(() {
                _selectedBoyut = newValue;
                if (newValue != null) {
                  _fetchAksesuarlar(
                    _selectedDepo!,
                    _selectedMalzeme!,
                    _selectedRenk!,
                    newValue,
                  );
                  // Aksesuarları sıfırla
                  _selectedAksesuar = null;
                  miktar = 0;
                }
              });
            },
            icon: Icons.arrow_drop_down,
          ),
          DropdownSelector(
            hintText: 'Aksesuar',
            items: _aksesuar,
            selectedValue: _selectedAksesuar,
            onChanged: (String? newValue) {
              setState(() {
                _selectedAksesuar = newValue;
                if (newValue != null) {
                  _fetchMiktar(
                    _selectedDepo!,
                    _selectedMalzeme!,
                    _selectedRenk!,
                    _selectedBoyut!,
                    newValue,
                  );
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
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w300),
            ),
          ),
          TextFieldWithCounter(
            controller: _miktarController,
            hintText: 'Miktar',
            icon: Icons.shopping_cart,
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                final miktarGirdi = int.tryParse(_miktarController.text);
                if (_selectedMalzeme == null ||
                    _selectedRenk == null ||
                    _selectedBoyut == null ||
                    _selectedAksesuar == null ||
                    miktarGirdi == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("Lütfen tüm alanları doldurun.")),
                  );
                  return;
                }

                _updateMiktar(_selectedDepo!, _selectedMalzeme!, _selectedRenk!,
                    _selectedBoyut!, _selectedAksesuar!, miktarGirdi);
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
                    'Satıldı',
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
    );
  }
}
