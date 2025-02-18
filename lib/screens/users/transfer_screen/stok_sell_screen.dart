import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:toyflow/screens/users/transfer_screen/transfer_services/transfer_services.dart';
import 'package:toyflow/services/user_component/alert_dialog_service.dart';
import '../../../services/user_component/cutom_loading_button.dart';
import '../../../services/user_component/dropdown_selector.dart';
import '../../../services/user_component/text_field_with_counter.dart';

class StockSellScreen extends StatefulWidget {
  const StockSellScreen({super.key});

  @override
  State<StockSellScreen> createState() => _StockSellScreenState();
}

class _StockSellScreenState extends State<StockSellScreen> {
  bool isLoading = false;
  final TextEditingController _miktarController = TextEditingController();
  final TransferServices _transferServices = TransferServices();

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

  int miktar = 0;

  String? _currentDepoCollection;
  @override
  void initState() {
    super.initState();
    _fetchDepolar();
  }

  Map<String, String> _depoCollectionMap = {};

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
    debugPrint("Fetching renkler from collection: $depoCollection");
    final urunSnapshot =
        await FirebaseFirestore.instance.collection(depoCollection).get();
    setState(() {
      final urunSet =
          urunSnapshot.docs.map((doc) => doc['urun'] as String).toSet();
      _donusumUrun = urunSet.toList();
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
          miktar = 0;
        });
      }
    } catch (e) {
      debugPrint("Error fetching miktar: $e");
      setState(() {
        miktar = 0;
      });
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
                _currentDepoCollection = _depoCollectionMap[newValue!];
                if (_currentDepoCollection != null) {
                  _fetchUrunler(_currentDepoCollection!);
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
                if (newValue != null && _currentDepoCollection != null) {
                  _fetchRenkler(_currentDepoCollection!, _selectedMalzeme!);
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
                if (newValue != null && _currentDepoCollection != null) {
                  _fetchBoyutlar(
                      _currentDepoCollection!, _selectedMalzeme!, newValue);
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
                if (newValue != null && _currentDepoCollection != null) {
                  _fetchAksesuarlar(
                    _currentDepoCollection!,
                    _selectedMalzeme!,
                    _selectedRenk!,
                    newValue,
                  );
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
                if (newValue != null && _currentDepoCollection != null) {
                  _fetchMiktar(
                    _currentDepoCollection!,
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
                    final miktarGirdi = int.tryParse(_miktarController.text);
                    if (_selectedMalzeme == null ||
                        _selectedRenk == null ||
                        _selectedBoyut == null ||
                        _selectedAksesuar == null ||
                        miktarGirdi == null) {
                      showAlertDialog(context, "Lüften boş alanları doldur.");
                      return;
                    }
                    _transferServices.sellMiktar(
                        context,
                        _currentDepoCollection!,
                        _selectedMalzeme!,
                        _selectedRenk!,
                        _selectedBoyut!,
                        _selectedAksesuar!,
                        miktarGirdi);
                    await Future.delayed(const Duration(seconds: 1));
                  } finally {
                    setState(() {
                      isLoading = false;
                    });
                  }
                },
                text: "Satıldı",
              ),
            ],
          ),
        ],
      ),
    );
  }
}
