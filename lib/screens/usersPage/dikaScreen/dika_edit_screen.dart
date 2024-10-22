// ignore_for_file: file_names

import 'package:flutter/material.dart';

class DikaEditScreen extends StatefulWidget {
  const DikaEditScreen({super.key});

  @override
  State<DikaEditScreen> createState() => _DikaEditScreenState();
}

class _DikaEditScreenState extends State<DikaEditScreen> {
  final TextEditingController _miktarController = TextEditingController();

  String? _selectedMalzeme; // Seçilen mal

  final List<String> item = ['item1', 'item2', 'item3', 'item4', 'item5'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 15.0, right: 15.0),
              child: DropdownButtonFormField<String>(
                value: _selectedMalzeme,
                hint: const Text('Kullanılacak Malzemeyi Seçin'),
                items: item.map((String items) {
                  return DropdownMenuItem<String>(
                    value: items,
                    child: Text(items),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedMalzeme = newValue; // Seçilen rolü güncelle
                  });
                },
                decoration:
                    TextFieldStyles.defaultDecoration('Malzeme', Icons.style),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 15.0, right: 15.0),
              child: Row(
                children: [
                  // Miktar TextField
                  Expanded(
                    child: TextField(
                      controller: _miktarController,
                      decoration: TextFieldStyles.defaultDecoration(
                        'Kullanılacak Miktar',
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
            ),
            const SizedBox(
              height: 20,
            ),
            const Divider(
              indent: 20,
              endIndent: 20,
            ),
            const SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 15.0, right: 15.0),
              child: DropdownButtonFormField<String>(
                value: _selectedMalzeme,
                hint: const Text('Dönüştürülen Ürünü Seçin'),
                items: item.map((String items) {
                  return DropdownMenuItem<String>(
                    value: items,
                    child: Text(items),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedMalzeme = newValue; // Seçilen rolü güncelle
                  });
                },
                decoration:
                    TextFieldStyles.defaultDecoration('Malzeme', Icons.cut),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 15.0, right: 15.0),
              child: Row(
                children: [
                  // Miktar TextField
                  Expanded(
                    child: TextField(
                      controller: _miktarController,
                      decoration: TextFieldStyles.defaultDecoration(
                        'Ürün Miktarı',
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
            ),
            const SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 15.0, right: 15.0),
              child: DropdownButtonFormField<String>(
                value: _selectedMalzeme,
                hint: const Text('Ürün Rengini Seçin'),
                items: item.map((String items) {
                  return DropdownMenuItem<String>(
                    value: items,
                    child: Text(items),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedMalzeme = newValue; // Seçilen rolü güncelle
                  });
                },
                decoration: TextFieldStyles.defaultDecoration(
                    'Malzeme', Icons.color_lens),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 15.0, right: 15.0),
              child: DropdownButtonFormField<String>(
                value: _selectedMalzeme,
                hint: const Text('Ürün Boyutunu Seçin'),
                items: item.map((String items) {
                  return DropdownMenuItem<String>(
                    value: items,
                    child: Text(items),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedMalzeme = newValue; // Seçilen rolü güncelle
                  });
                },
                decoration: TextFieldStyles.defaultDecoration(
                    'Malzeme', Icons.aspect_ratio),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            const Divider(
              indent: 20,
              endIndent: 20,
            ),
            const SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 15.0, right: 15.0),
              child: Row(
                children: [
                  // Miktar TextField
                  Expanded(
                    child: TextField(
                      controller: _miktarController,
                      decoration: TextFieldStyles.defaultDecoration(
                        'Fire Miktarı',
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
            ),
            const SizedBox(
              height: 20,
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
    );
  }
}

class TextFieldStyles {
  static InputDecoration defaultDecoration(String hintText, IconData icon) {
    return InputDecoration(
      hintText: hintText, 
      contentPadding: const EdgeInsets.symmetric(
          vertical: 0, horizontal: 20), 
      

      suffixIcon:
          Icon(icon, color: Colors.black, size: 18.0), 
      enabledBorder: const OutlineInputBorder(
        borderRadius:
            BorderRadius.all(Radius.circular(30.0)), 
        borderSide: BorderSide(
          color: Colors.grey,
          width: 0.9, 
        ),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(
            Radius.circular(30.0)), 
        borderSide: BorderSide(
          color: Colors.black,
          width: 0.9, 
        ),
      ),
      filled: true, 
      fillColor: Colors.white, 
    );
  }
}
