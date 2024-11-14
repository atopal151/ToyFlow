import 'package:flutter/material.dart';
import 'package:toyflow/services/get_data_table.dart';

import '../../../services/user_services/dropdown_selector.dart';

class ToyDetailScreen extends StatefulWidget {
  final String urun;
  final String? renk;
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
  });

  @override
  State<ToyDetailScreen> createState() => _ToyDetailScreenState();
}

class _ToyDetailScreenState extends State<ToyDetailScreen> {
  final DataTableService _dataTableService=DataTableService();
  String title = "";

  String? _selectedBoyut; // Seçilen  boyut
  String? _selectedRenk; // Seçilen  renk
  String? _selectedMalzeme; // Seçilen ürün
  String? _selectedAksesuar; // Seçilen aksesuar
  @override
  void initState() {
    super.initState();
    title = widget.urun;
    _selectedMalzeme == widget.urun;
    _selectedRenk == widget.renk;
    _selectedAksesuar == widget.aksesuar;
    _selectedBoyut == widget.boyut;

   _fetchUrunList();
    _fetchRenkList();
    _fetchBoyutList();
    _fetchAksesuarList();
  }

   List<String> _urun = [
  ]; // Ürün listesi

   List<String> _boyut = [
  ]; // Ürün listesi

   List<String> _renk = [
  ];
   List<String> _aksesuar = [
  ];

  

  Future<void> _fetchUrunList() async {
    // 'iplik' koleksiyonundan verileri çekiyoruz
    List<String> fetchedUrun =
        await _dataTableService.getCollectionData('toy_name', 'name');
    setState(() {
      _urun = fetchedUrun;
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
Future<void> _fetchAksesuarList() async {
    // 'iplik' koleksiyonundan verileri çekiyoruz
    List<String> fetchedUrun =
        await _dataTableService.getCollectionData('toy_aksesuar', 'aksesuar');
    setState(() {
      _aksesuar = fetchedUrun;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title), // Ürün adı başlık olarak gösteriliyor
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  'images/fullmov.webp',
                  width: 250,
                  height: 320,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Expanded(
              flex: 10,
              child: Column(
                children: [
                    DropdownSelector(
                      hintText: 'Ürün',
                      items: _urun,
                      selectedValue: _selectedMalzeme,
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedMalzeme = newValue;
                          title = _selectedMalzeme!;
                        });
                      },
                      icon: Icons.arrow_drop_down,
                    ),
                    // Renk seçme dropdown

                    DropdownSelector(
                      hintText: 'Renk',
                      items: _renk,
                      selectedValue: _selectedRenk,
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedRenk = newValue;
                        });
                      },
                      icon: Icons.arrow_drop_down,
                    ),
                    // boyut seçme dropdown
                    DropdownSelector(
                      hintText: 'Boyut',
                      items: _boyut,
                      selectedValue: _selectedBoyut,
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedBoyut = newValue;
                        });
                      },
                      icon: Icons.arrow_drop_down,
                    ),
                    //aksesuar
                    DropdownSelector(
                      hintText: 'Aksesuar',
                      items: _aksesuar,
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
                      onPressed: () {},
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
                  const Text("depo1"),
                  const Text("depo1")
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
