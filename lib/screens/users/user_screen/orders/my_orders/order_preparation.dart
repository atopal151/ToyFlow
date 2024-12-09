// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toyflow/services/user_services/product_services.dart';
import 'package:toyflow/services/user_component/alert_dialog_service.dart';
import 'package:toyflow/services/user_component/dropdown_selector.dart';
import 'package:toyflow/services/user_component/text_field_with_counter.dart';

import '../../../../../services/user_services/get_data_table.dart';
import 'oders_service/orders_service.dart';

class OrderPreparation extends StatefulWidget {
  const OrderPreparation({super.key});

  @override
  State<OrderPreparation> createState() => _OrderPreparationState();
}

class _OrderPreparationState extends State<OrderPreparation> {
  // ProductServices'i GetX ile alıyoruz
  final ProductServices productServices = Get.find<ProductServices>();
  final DataTableService _dataTableService = DataTableService();
  final TextEditingController _miktarController = TextEditingController();
  final TextEditingController _aciklamaController = TextEditingController();

  String? _selectedUrun;
  String? _selectedIpler;
  String? _selectedKumas;
  String? _selectedRenk;
  String? _selectedBoyut;
  String? _selectedAksesuar;
  String? _selectedGramaj;
  String? _selectedFine;
  String? _selectedDenye;

  List<String> urunler = [];
  List<String> ipler = [];
  List<String> kumaslar = [];
  List<String> renkler = [];
  List<String> boyutlar = [];
  List<String> aksesuarlar = [];
  List<String> gramajlar = [];
  List<String> fineler = [];
  List<String> denyeler = [];

  @override
  void initState() {
    super.initState();
    // Sayfa yüklenmeden önce role sıfırlanıyor
    _fetchKumasList();
    _fetchIplikList();
    _fetchUrunList();
    _fetchRenkList();
    _fetchAksesuarList();
    _fetchBoyutList();
    _fetchDenyeList();
    _fetchFineList();
    _fetchGramajList();
  }

  Future<void> _fetchKumasList() async {
    // 'kumaslar' koleksiyonundan verileri çekiyoruz
    List<String> fetchedUrun =
        await _dataTableService.getCollectionData('kumas', 'kumas');
    setState(() {
      kumaslar = fetchedUrun;
    });
  }

  Future<void> _fetchIplikList() async {
    // 'iplik' koleksiyonundan verileri çekiyoruz
    List<String> fetchedUrun =
        await _dataTableService.getCollectionData('iplik', 'iplik');
    setState(() {
      ipler = fetchedUrun;
    });
  }

  Future<void> _fetchUrunList() async {
    // 'urunler' koleksiyonundan verileri çekiyoruz
    List<String> fetchedUrun =
        await _dataTableService.getCollectionData('toy_name', 'name');
    setState(() {
      urunler = fetchedUrun;
    });
  }

  Future<void> _fetchRenkList() async {
    // 'renkler' koleksiyonundan verileri çekiyoruz
    List<String> fetchedUrun =
        await _dataTableService.getCollectionData('toy_renk', 'renk');
    setState(() {
      renkler = fetchedUrun;
    });
  }

  Future<void> _fetchBoyutList() async {
    // 'boyutlar' koleksiyonundan verileri çekiyoruz
    List<String> fetchedUrun =
        await _dataTableService.getCollectionData('toy_height', 'boyut');
    setState(() {
      boyutlar = fetchedUrun;
    });
  }

  Future<void> _fetchAksesuarList() async {
    // 'aksesuarlar' koleksiyonundan verileri çekiyoruz
    List<String> fetchedUrun =
        await _dataTableService.getCollectionData('toy_aksesuar', 'aksesuar');
    setState(() {
      aksesuarlar = fetchedUrun;
    });
  }

  Future<void> _fetchGramajList() async {
    // 'aksesuarlar' koleksiyonundan verileri çekiyoruz
    List<String> fetchedUrun =
        await _dataTableService.getCollectionData('gramaj', 'gramaj');
    setState(() {
      gramajlar = fetchedUrun;
    });
  }

  Future<void> _fetchDenyeList() async {
    // 'aksesuarlar' koleksiyonundan verileri çekiyoruz
    List<String> fetchedUrun =
        await _dataTableService.getCollectionData('denye', 'denye');
    setState(() {
      denyeler = fetchedUrun;
    });
  }

  Future<void> _fetchFineList() async {
    // 'aksesuarlar' koleksiyonundan verileri çekiyoruz
    List<String> fetchedUrun =
        await _dataTableService.getCollectionData('fine', 'fine');
    setState(() {
      fineler = fetchedUrun;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sipariş Hazırlık"),
      ),
      body: Obx(() {
        // Eğer role boş ise yükleme göstergesi göster
        if (productServices.role.value.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        // Role doluysa asıl içerik
        return SingleChildScrollView(
          child: Column(
            children: [
              if (productServices.role.value == "Dikim" ||
                  productServices.role.value == "Transfer" ||
                  productServices.role.value == "Dolum" ||
                  productServices.role.value == "Paketleme")
                DropdownSelector(
                  hintText: "Ürün",
                  items: urunler,
                  selectedValue: _selectedUrun,
                  icon: Icons.production_quantity_limits,
                  onChanged: (value) {
                    setState(() {
                      _selectedUrun = value;
                    });
                  },
                ),
              if (productServices.role.value == "Dokuma")
                DropdownSelector(
                  hintText: "İpler",
                  items: ipler,
                  selectedValue: _selectedIpler,
                  icon: Icons.production_quantity_limits,
                  onChanged: (value) {
                    setState(() {
                      _selectedIpler = value;
                    });
                  },
                ),
              if (productServices.role.value == "Boyama" ||
                  productServices.role.value == "Kesim")
                DropdownSelector(
                  hintText: "Kumaş",
                  items: kumaslar,
                  selectedValue: _selectedKumas,
                  icon: Icons.production_quantity_limits,
                  onChanged: (value) {
                    setState(() {
                      _selectedKumas = value;
                    });
                  },
                ),
              if (productServices.role.value == "Kesim" ||
                  productServices.role.value == "Dikim" ||
                  productServices.role.value == "Dolum" ||
                  productServices.role.value == "Transfer" ||
                  productServices.role.value == "Paketleme")
                DropdownSelector(
                  hintText: "Renk",
                  items: renkler,
                  selectedValue: _selectedRenk,
                  icon: Icons.color_lens,
                  onChanged: (value) {
                    setState(() {
                      _selectedRenk = value;
                    });
                  },
                ),
              if (productServices.role.value == "Dikim" ||
                  productServices.role.value == "Transfer" ||
                  productServices.role.value == "Dolum" ||
                  productServices.role.value == "Paketleme")
                DropdownSelector(
                  hintText: "Boyut",
                  items: boyutlar,
                  selectedValue: _selectedBoyut,
                  icon: Icons.straighten,
                  onChanged: (value) {
                    setState(() {
                      _selectedBoyut = value;
                    });
                  },
                ),
              if (productServices.role.value == "Transfer")
                DropdownSelector(
                  hintText: "Aksesuar",
                  items: aksesuarlar,
                  selectedValue: _selectedAksesuar,
                  icon: Icons.accessibility,
                  onChanged: (value) {
                    setState(() {
                      _selectedAksesuar = value;
                    });
                  },
                ),
              if (productServices.role.value == "Boyama" ||
                  productServices.role.value == "Kesim")
                DropdownSelector(
                  hintText: "Gramaj",
                  items: gramajlar,
                  selectedValue: _selectedGramaj,
                  icon: Icons.scale,
                  onChanged: (value) {
                    setState(() {
                      _selectedGramaj = value;
                    });
                  },
                ),
              if (productServices.role.value == "Boyama" ||
                  productServices.role.value == "Kesim")
                DropdownSelector(
                  hintText: "Fine",
                  items: fineler,
                  selectedValue: _selectedFine,
                  icon: Icons.line_axis,
                  onChanged: (value) {
                    setState(() {
                      _selectedFine = value;
                    });
                  },
                ),
              if (productServices.role.value == "Dokuma")
                DropdownSelector(
                  hintText: "Denye",
                  items: denyeler,
                  selectedValue: _selectedDenye,
                  icon: Icons.linear_scale,
                  onChanged: (value) {
                    setState(() {
                      _selectedDenye = value;
                    });
                  },
                ),
              TextFieldWithCounter(
                controller: _aciklamaController,
                hintText: 'Açıklama',
                icon: Icons.description,
              ),
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: TextFieldWithCounter(
                      controller: _miktarController,
                      hintText: 'Miktar',
                      icon: Icons.pie_chart,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 12.0, right: 16),
                    child: ElevatedButton(
                      onPressed: () async {
                        {
                          if (productServices.role.value == "Dokuma") {
                            if ((_selectedIpler ?? '').isNotEmpty &&
                                (_selectedDenye ?? '').isNotEmpty &&
                                _miktarController.text.trim().isNotEmpty) {
                              await saveOrderToFirestore(
                                  context: context,
                                  iplik: _selectedIpler,
                                  denye: _selectedDenye,
                                  miktar: _miktarController.text,
                                  aciklama: _aciklamaController.text,
                                  status: "Bekliyor",
                                  role: productServices.role.value);

                              showAlertDialog(
                                  context, "Sipariş başarıyla kaydedildi.");
                            } else {
                              showAlertDialog(context, "Boş alanları doldurun");
                            }
                          }
                          if (productServices.role.value == "Boyama") {
                            if ((_selectedKumas ?? '').isNotEmpty &&
                                (_selectedFine ?? '').isNotEmpty &&
                                (_selectedGramaj ?? '').isNotEmpty &&
                                _miktarController.text.trim().isNotEmpty) {
                              await saveOrderToFirestore(
                                  context: context,
                                  kumas: _selectedKumas,
                                  gramaj: _selectedGramaj,
                                  fine: _selectedFine,
                                  miktar: _miktarController.text,
                                  aciklama: _aciklamaController.text,
                                  status: "Bekliyor",
                                  role: productServices.role.value);

                              showAlertDialog(
                                  context, "Sipariş başarıyla kaydedildi.");
                            }else {
                              showAlertDialog(context, "Boş alanları doldurun");
                            }
                          }
                          if (productServices.role.value == "Kesim") {
                            if ((_selectedKumas ?? '').isNotEmpty &&
                                (_selectedFine ?? '').isNotEmpty &&
                                (_selectedRenk ?? '').isNotEmpty &&
                                (_selectedGramaj ?? '').isNotEmpty &&
                                _miktarController.text.trim().isNotEmpty) {
// Firestore'a kaydetme işlemi
                              await saveOrderToFirestore(
                                  context: context,
                                  kumas: _selectedKumas,
                                  renk: _selectedRenk,
                                  gramaj: _selectedGramaj,
                                  fine: _selectedFine,
                                  miktar: _miktarController.text,
                                  aciklama: _aciklamaController.text,
                                  status: "Bekliyor",
                                  role: productServices.role.value);

                              showAlertDialog(
                                  context, "Sipariş başarıyla kaydedildi.");
                            } else {
                              showAlertDialog(context, "Boş alanları doldurun");
                            }
                          }
                          if (productServices.role.value == "Dikim") {
                            if ((_selectedUrun ?? '').isNotEmpty &&
                                (_selectedRenk ?? '').isNotEmpty &&
                                (_selectedBoyut ?? '').isNotEmpty &&
                                _miktarController.text.trim().isNotEmpty) {
// Firestore'a kaydetme işlemi
                              await saveOrderToFirestore(
                                  context: context,
                                  urun: _selectedUrun,
                                  renk: _selectedRenk,
                                  boyut: _selectedBoyut,
                                  miktar: _miktarController.text,
                                  aciklama: _aciklamaController.text,
                                  status: "Bekliyor",
                                  role: productServices.role.value);

                              showAlertDialog(
                                  context, "Sipariş başarıyla kaydedildi.");
                            } else {
                              showAlertDialog(context, "Boş alanları doldurun");
                            }
                          }
                          if (productServices.role.value == "Dolum") {
                            if ((_selectedUrun ?? '').isNotEmpty &&
                                (_selectedRenk ?? '').isNotEmpty &&
                                (_selectedBoyut ?? '').isNotEmpty &&
                                _miktarController.text.trim().isNotEmpty) {
// Firestore'a kaydetme işlemi
                              await saveOrderToFirestore(
                                  context: context,
                                  urun: _selectedUrun,
                                  renk: _selectedRenk,
                                  boyut: _selectedBoyut,
                                  miktar: _miktarController.text,
                                  aciklama: _aciklamaController.text,
                                  status: "Bekliyor",
                                  role: productServices.role.value);

                              showAlertDialog(
                                  context, "Sipariş başarıyla kaydedildi.");
                            } else {
                              showAlertDialog(context, "Boş alanları doldurun");
                            }
                          }
                          if (productServices.role.value == "Paketleme") {
                            if ((_selectedUrun ?? '').isNotEmpty &&
                                (_selectedRenk ?? '').isNotEmpty &&
                                (_selectedBoyut ?? '').isNotEmpty &&
                                _miktarController.text.trim().isNotEmpty) {
// Firestore'a kaydetme işlemi
                              await saveOrderToFirestore(
                                  context: context,
                                  urun: _selectedUrun,
                                  renk: _selectedRenk,
                                  boyut: _selectedBoyut,
                                  miktar: _miktarController.text,
                                  aciklama: _aciklamaController.text,
                                  status: "Bekliyor",
                                  role: productServices.role.value);

                              showAlertDialog(
                                  context, "Sipariş başarıyla kaydedildi.");
                            } else {
                              showAlertDialog(context, "Boş alanları doldurun");
                            }
                          }
                          if (productServices.role.value == "Transfer") {
                            if ((_selectedUrun ?? '').isNotEmpty &&
                                (_selectedRenk ?? '').isNotEmpty &&
                                (_selectedBoyut ?? '').isNotEmpty &&
                                (_selectedAksesuar ?? '').isNotEmpty &&
                                _miktarController.text.trim().isNotEmpty) {
// Firestore'a kaydetme işlemi
                              await saveOrderToFirestore(
                                  context: context,
                                  urun: _selectedUrun,
                                  renk: _selectedRenk,
                                  boyut: _selectedBoyut,
                                  aksesuar: _selectedAksesuar,
                                  miktar: _miktarController.text,
                                  aciklama: _aciklamaController.text,
                                  status: "Bekliyor",
                                  role: productServices.role.value);

                              showAlertDialog(
                                  context, "Sipariş başarıyla kaydedildi.");
                            } else {
                              showAlertDialog(context, "Boş alanları doldurun");
                            }
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
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
                            'Sipariş Ver',
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
            ],
          ),
        );
      }),
    );
  }
}
