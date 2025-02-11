import 'package:flutter/material.dart';
import '../../../services/user_services/get_data_table.dart';
import '../../../services/user_component/cutom_loading_button.dart';
import '../../users/atolye_screen/atolye_services/atolye_services.dart';
import '../register_screen/registerServices/dropdown_style_file.dart';
import '../register_screen/registerServices/textbox_style_file.dart';
import 'stock_services/stock_services.dart';

class StockAddScreen extends StatefulWidget {
  const StockAddScreen({super.key});

  @override
  State<StockAddScreen> createState() => _StockAddScreenState();
}

class _StockAddScreenState extends State<StockAddScreen> {
  bool isLoading = false;
  final TextEditingController _miktarController = TextEditingController();
  final StockService _stockService = StockService();
  final DataTableService _dataService = DataTableService();
  final AtolyeServices atolyeServices = AtolyeServices();

  String? _selectedUrun;
  List<String> urun = [];

  String? _selectedDenye;
  List<String> denye = [];

  @override
  void initState() {
    super.initState();
    _fetchIplikList();
    _fetchDenyeList();
  }

  Future<void> _fetchIplikList() async { 
    List<String> fetchedUrun =
        await _dataService.getCollectionData('iplik', 'iplik');
    setState(() {
      urun = fetchedUrun;
    });
  }

  Future<void> _fetchDenyeList() async { 
    List<String> fetchedDenye =
        await _dataService.getCollectionData('denye', 'denye');
    setState(() {
      denye = fetchedDenye;
    });
  }

  void _saveStock() {
    String? urun = _selectedUrun;

    String? denye = _selectedDenye;
    int? miktar = int.tryParse(_miktarController.text);

    if (urun != null && miktar != null && denye != null && miktar > 0) {
      _stockService.saveStock(
        collections: "dokuma_work",
        urun: urun,
        denye: denye,
        miktar: miktar,
        context: context,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Boş alanları lütfen doldurun.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Stok Kayıt",
          style: TextStyle(fontSize: 15),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            DropdownRegisterSelector(
              hintText: 'Ürün Seç',
              items: urun,
              selectedValue: _selectedUrun,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedUrun = newValue;
                });
              },
              icon: Icons.arrow_drop_down,
            ),
            DropdownRegisterSelector(
              hintText: 'Denye Seç',
              items: denye,
              selectedValue: _selectedDenye,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedDenye = newValue;
                });
              },
              icon: Icons.arrow_drop_down,
            ),
            Row(
              children: [
                Expanded(
                  child: TextFieldWithRegister(
                    controller: _miktarController,
                    hintText: 'Girilecek miktar',
                    icon: Icons.shopping_cart,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: () {
                    int currentValue =
                        int.tryParse(_miktarController.text) ?? 0;
                    currentValue = currentValue > 0 ? currentValue - 1 : 0;
                    _miktarController.text = currentValue.toString();
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    int currentValue =
                        int.tryParse(_miktarController.text) ?? 0;
                    currentValue += 1;
                    _miktarController.text = currentValue.toString();
                  },
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(right:8.0,left: 22),
              child: CustomLoadingButton(
                isLoading: isLoading,
                onPressed: () async {
                  setState(() {
                    isLoading = true;
                  });
                  try {
                    _saveStock(); 
                    await Future.delayed(
                        const Duration(seconds: 1));  
                  } finally {
                    setState(() {
                      isLoading = false;
                    });
                  }
                },
                text: "Kaydet",
              ),
            ),
          ],
        ),
      ),
    );
  }
}
