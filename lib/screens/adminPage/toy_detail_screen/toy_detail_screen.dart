import 'package:flutter/material.dart';
import 'package:toyflow/services/get_data_table.dart';
import '../../../services/user_services/dropdown_selector.dart';
import 'toy_detail_services/toy_detail_services.dart';

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
  final DataTableService _dataTableService = DataTableService();
  final ToyDetailServices _toyDetailServices = ToyDetailServices(); // ToyDetailServices örneği
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
  }

  Future<void> _fetchUrunList() async {
    List<String> fetchedUrun = await _dataTableService.getCollectionData('toy_name', 'name');
    setState(() {
      _urun = fetchedUrun;
    });
  }

  Future<void> _fetchRenkList() async {
    List<String> fetchedRenk = await _dataTableService.getCollectionData('toy_renk', 'renk');
    setState(() {
      _renk = fetchedRenk;
    });
  }

  Future<void> _fetchBoyutList() async {
    List<String> fetchedBoyut = await _dataTableService.getCollectionData('toy_height', 'boyut');
    setState(() {
      _boyut = fetchedBoyut;
    });
  }

  Future<void> _fetchAksesuarList() async {
    List<String> fetchedAksesuar = await _dataTableService.getCollectionData('toy_aksesuar', 'aksesuar');
    setState(() {
      _aksesuar = fetchedAksesuar;
    });
  }

  Future<void> _getDepoDetails() async {
    List<Map<String, dynamic>> fetchedDetails = await _toyDetailServices.listToys(
      malzeme: _selectedMalzeme ?? widget.urun,
      renk: _selectedRenk ?? widget.renk ?? '',
      boyut: _selectedBoyut,
      aksesuar: _selectedAksesuar,
    );

    setState(() {
      _depoDetails = fetchedDetails;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
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
            const SizedBox(height: 10),
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
                      onPressed: () => _getDepoDetails(),
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
                  Expanded(
                    child: ListView.builder(
                      itemCount: _depoDetails.length,
                      itemBuilder: (context, index) {
                        final depo = _depoDetails[index];
                        return ListTile(
                          title: Text('${depo['depo']}'),
                          subtitle: Text('Miktar: ${depo['miktar']}'),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
