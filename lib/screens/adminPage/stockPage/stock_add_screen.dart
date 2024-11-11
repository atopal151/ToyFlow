import 'package:flutter/material.dart';
import '../registerPage/registerServices/dropdown_style_file.dart';
import '../registerPage/registerServices/textbox_style_file.dart';
import 'stock_services/stock_services.dart';

class StockAddScreen extends StatefulWidget {
  const StockAddScreen({super.key});

  @override
  State<StockAddScreen> createState() => _StockAddScreenState();
}

class _StockAddScreenState extends State<StockAddScreen> {
  final TextEditingController _miktarController = TextEditingController();
  final StockService _stockService = StockService(); // StockService örneği

  String? _selectedUrun;

  final List<String> urun = [
    'Polyester iplik',
    'Akrilik iplik',
    'Naylon iplik',
    'Pamuk iplik',
    'Karışım İplik'
  ];

  void _saveStock() {
    String? urun = _selectedUrun;
    int? miktar = int.tryParse(_miktarController.text);

    if (urun != null  && miktar != null && miktar > 0) {
      _stockService.saveStock(
        urun: urun,
        miktar: miktar,
        context: context,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Boş alanlaır lütfen doldurun.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Stok Kayıt"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ürün Dropdown
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
              padding: const EdgeInsets.all(20),
              child: ElevatedButton(
                onPressed: () {
                  _saveStock(); // Kaydetme işlemi başlatılıyor
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
                    Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Kaydet',
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
      ),
    );
  }
}
