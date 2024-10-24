import 'package:flutter/material.dart';

class StockAddScreen extends StatefulWidget {
  const StockAddScreen({super.key});

  @override
  State<StockAddScreen> createState() => _StockAddScreenState();
}

class _StockAddScreenState extends State<StockAddScreen> {
  final TextEditingController _miktarController = TextEditingController();
  String? _selectedUrun; // Seçilen rol

  final List<String> urun = ['ürün1', 'ürün2', 'ürün3', 'ürün4', 'ürün5'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Stok Kayıt"),
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 10),
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                value: _selectedUrun,
                hint: const Text('Ürün Seçin'),
                items: urun.map((String role) {
                  return DropdownMenuItem<String>(
                    value: role,
                    child: Text(role),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedUrun = newValue;
                  });
                },
                decoration:
                    TextFieldStyles.defaultDecoration('Rol', Icons.layers),
              ),
              const SizedBox(
                height: 15,
              ),
              Row(
                children: [
                   Expanded(
                    child: TextField(
                      controller: _miktarController,
                      decoration: TextFieldStyles.defaultDecoration(
                        'Girilecek Miktar',
                        Icons.shopping_cart,
                      ),
                      keyboardType:
                          TextInputType.number, // Yalnızca sayı girişi
                    ),
                  ),
                  // Eksi butonu (-)
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: () {
                      int currentValue =
                          int.tryParse(_miktarController.text) ?? 0;
                      currentValue = currentValue > 0 ? currentValue - 1 : 0;
                      _miktarController.text = currentValue.toString();
                    },
                  ),

                  // Artı butonu (+)
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
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                 
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment:
                      MainAxisAlignment.center, 
                  children: [
                    Icon(
                      Icons.add, 
                      color: Colors.white, 
                    ),
                    SizedBox(width: 8), 
                    Text(
                      'Kaydet',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white, 
                      ),
                    ),
                  ],
                ),
              ),
            )
            ],
          ),
        ),
      ),
    );
  }
}

class TextFieldStyles {
  static InputDecoration defaultDecoration(String hintText, IconData icon) {
    return InputDecoration(
      hintText: hintText, // Placeholder metni
      contentPadding: const EdgeInsets.symmetric(
          vertical: 0, horizontal: 20), // İç boşluklar
      suffixIcon: Icon(icon, color: Colors.black), // Sağ tarafa yaslı ikon
      enabledBorder: const OutlineInputBorder(
        borderRadius:
            BorderRadius.all(Radius.circular(30.0)), // Tam daire border radius
        borderSide: BorderSide(
          color: Colors.grey,
          width: 0.3, // Dış kenar çizgisi genişliği
        ),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(
            Radius.circular(30.0)), // Odaklanmışken de dairesel köşeler
        borderSide: BorderSide(
          color: Colors.black,
          width: 0.9, // Odaklanmış durumdaki kenar çizgisi genişliği
        ),
      ),
      filled: true, // TextField dolu görünsün
      fillColor: Colors.grey[200], // Arka plan rengi
    );
  }
}
