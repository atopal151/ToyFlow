import 'package:flutter/material.dart';
import 'package:toyflow/services/get_data_table.dart';
import '../../../services/user_services/dropdown_selector.dart';
import 'toy_detail_services/toy_detail_services.dart';

class ToyDetailScreen extends StatefulWidget {
  final String urun;
  final String? renk;
  final String? fine;
  final String? gramaj;
  final String? boyut;
  final String? aksesuar;
  final String? atolye;

  const ToyDetailScreen({
    super.key,
    required this.urun,
    this.renk,
    this.boyut,
    this.aksesuar,
    this.atolye,
    this.fine,
    this.gramaj,
  });

  @override
  State<ToyDetailScreen> createState() => _ToyDetailScreenState();
}

class _ToyDetailScreenState extends State<ToyDetailScreen> {
  final DataTableService _dataTableService = DataTableService();
  final ToyDetailServices _toyDetailServices =
      ToyDetailServices(); // ToyDetailServices örneği
  String title = "";

  String? _selectedBoyut;
  String? _selectedRenk;
  String? _selectedMalzeme;
  String? _selectedAksesuar;

  List<String> _urun = [];
  List<String> _boyut = [];
  List<String> _renk = [];
  List<String> _aksesuar = [];

  List<Map<String, dynamic>> _depoDetails = []; // Depo detaylarını tutan liste

  @override
  void initState() {
    super.initState();

    title = widget.urun;
    _selectedMalzeme = widget.urun;
    _selectedRenk = widget.renk;
    _selectedAksesuar = widget.aksesuar;
    _selectedBoyut = widget.boyut;

    _fetchUrunList();
    _fetchRenkList();
    _fetchBoyutList();
    _fetchAksesuarList();
    _getDepoDetails();
  }

  Future<void> _fetchUrunList() async {
    List<String> fetchedUrun =
        await _dataTableService.getCollectionData('toy_name', 'name');
    if (mounted) {
      setState(() {
        _urun = fetchedUrun.toSet().toList();
      });
    }
  }

  Future<void> _fetchRenkList() async {
    List<String> fetchedRenk =
        await _dataTableService.getCollectionData('toy_renk', 'renk');
    if (mounted) {
      setState(() {
        _renk = fetchedRenk.toSet().toList();
      });
    }
  }

  Future<void> _fetchBoyutList() async {
    List<String> fetchedBoyut =
        await _dataTableService.getCollectionData('toy_height', 'boyut');
    if (mounted) {
      setState(() {
        _boyut = fetchedBoyut.toSet().toList();
      });
    }
  }

  Future<void> _fetchAksesuarList() async {
    List<String> fetchedAksesuar =
        await _dataTableService.getCollectionData('toy_aksesuar', 'aksesuar');
    if (mounted) {
      setState(() {
        _aksesuar = fetchedAksesuar.toSet().toList();
      });
    }
  }

  Future<void> _getDepoDetails() async {
    List<Map<String, dynamic>> fetchedDetails =
        await _toyDetailServices.listToys(
      malzeme: _selectedMalzeme ?? widget.urun,
      renk: _selectedRenk ?? widget.renk ?? '',
      boyut: _selectedBoyut,
      aksesuar: _selectedAksesuar,
    );
    if (mounted) {
      setState(() {
        _depoDetails = fetchedDetails;
      });
    }
  }

  @override
  void dispose() {
    // Asenkron işlemleri iptal etmeniz gerekirse burada yapabilirsiniz.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 10),
              Column(
                children: [
                  DropdownSelector(
                    hintText: 'Ürün',
                    items: _urun
                        .toSet()
                        .toList(), // Benzersiz elemanlar için Set kullanımı
                    selectedValue: _selectedMalzeme,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedMalzeme = newValue;
                        title = _selectedMalzeme!;
                      });
                    },
                    icon: Icons.arrow_drop_down,
                  ),
                  DropdownSelector(
                    hintText: 'Renk',
                    items: _renk
                        .toSet()
                        .toList(), // Benzersiz elemanlar için Set kullanımı
                    selectedValue: _selectedRenk,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedRenk = newValue;
                      });
                    },
                    icon: Icons.arrow_drop_down,
                  ),
                  DropdownSelector(
                    hintText: 'Boyut',
                    items: _boyut
                        .toSet()
                        .toList(), // Benzersiz elemanlar için Set kullanımı
                    selectedValue: _selectedBoyut,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedBoyut = newValue;
                      });
                    },
                    icon: Icons.arrow_drop_down,
                  ),
                  DropdownSelector(
                    hintText: 'Aksesuar',
                    items: _aksesuar
                        .toSet()
                        .toList(), // Benzersiz elemanlar için Set kullanımı
                    selectedValue: _selectedAksesuar,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedAksesuar = newValue;
                      });
                    },
                    icon: Icons.arrow_drop_down,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ElevatedButton(
                      onPressed: _getDepoDetails,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 8, 8, 8),
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
                            'Getir',
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
                  SizedBox(
                    height: 300, // ListView'in yüksekliğini sınırlayın
                    child: ListView.builder(
                      itemCount: _depoDetails.length,
                      itemBuilder: (context, index) {
                        final depo = _depoDetails[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.asset(
                                    'images/box.webp', // Varsayılan bir depo ikonu
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${depo['depo']}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                        softWrap: true,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        'Miktar: ${depo['miktar']}',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
