import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DokaEditScreen extends StatefulWidget {
  const DokaEditScreen({super.key});

  @override
  State<DokaEditScreen> createState() => _DokaEditScreenState();
}

class _DokaEditScreenState extends State<DokaEditScreen> {
  final TextEditingController _miktarController = TextEditingController();
  String? _selectedMalzeme; // Seçilen ürün
  String? _selectedRenk; // Seçilen renk
  List<String> _urunler = []; // Ürün listesi
  List<String> _renkler = []; // Renk listesi

  @override
  void initState() {
    super.initState();
    _fetchData(); // Verileri Firebase'den çek
  }

  Future<void> _fetchData() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('ipler').get();

      setState(() {
        _urunler = snapshot.docs.map((doc) => doc['urun'] as String).toSet().toList();
        _renkler = snapshot.docs.map((doc) => doc['renk'] as String).toSet().toList();
      });
    } catch (e) {
      print("Veriler alınırken hata oluştu: $e");
    }
  }

  Future<void> _saveData() async {
    if (_selectedMalzeme == null || _selectedRenk == null || _miktarController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lütfen tüm alanları doldurun.")),
      );
      return;
    }

    int miktar = int.tryParse(_miktarController.text) ?? 0;

    try {
      // Seçilen ürün ve renkten veritabanında var mı kontrol et
      QuerySnapshot existingRecord = await FirebaseFirestore.instance
          .collection('ipler')
          .where('urun', isEqualTo: _selectedMalzeme)
          .where('renk', isEqualTo: _selectedRenk)
          .get();

      if (existingRecord.docs.isNotEmpty) {
        // Eğer ürün ve renk mevcutsa, miktardan düş
        DocumentSnapshot doc = existingRecord.docs.first;
        int currentMiktar = doc['miktar'] ?? 0;

        if (currentMiktar >= miktar) {
          await FirebaseFirestore.instance.collection('ipler').doc(doc.id).update({
            'miktar': currentMiktar - miktar,
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Stok güncellendi.")),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Yetersiz stok miktarı.")),
          );
        }
      } else {
        // Ürün ve renk mevcut değilse, kullanıcıya uyarı ver
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Böyle bir ürün bulunmamaktadır.")),
        );
      }
    } catch (e) {
      print("Kaydetme sırasında hata oluştu: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Kaydetme işlemi sırasında hata oluştu.")),
      );
    }
  }

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
            // Ürün seçme dropdown
            Padding(
              padding: const EdgeInsets.only(left: 15.0, right: 15.0),
              child: DropdownButtonFormField<String>(
                value: _selectedMalzeme,
                hint: const Text('Kullanılan Ürünü Seçin'),
                items: _urunler.map((String urun) {
                  return DropdownMenuItem<String>(
                    value: urun,
                    child: Text(urun),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedMalzeme = newValue;
                  });
                },
                decoration: TextFieldStyles.defaultDecoration('Malzeme', Icons.cut),
              ),
            ),
            const SizedBox(height: 20),
            // Renk seçme dropdown
            Padding(
              padding: const EdgeInsets.only(left: 15.0, right: 15.0),
              child: DropdownButtonFormField<String>(
                value: _selectedRenk,
                hint: const Text('Renk Seçin'),
                items: _renkler.map((String renk) {
                  return DropdownMenuItem<String>(
                    value: renk,
                    child: Text(renk),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedRenk = newValue;
                  });
                },
                decoration: TextFieldStyles.defaultDecoration('Renk', Icons.color_lens),
              ),
            ),
            const SizedBox(height: 20),
            // Miktar girme
            Padding(
              padding: const EdgeInsets.only(left: 15.0, right: 15.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _miktarController,
                      decoration: TextFieldStyles.defaultDecoration('Ürün Miktarı', Icons.shopping_cart),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: () {
                      int currentValue = int.tryParse(_miktarController.text) ?? 0;
                      currentValue = currentValue > 0 ? currentValue - 1 : 0;
                      _miktarController.text = currentValue.toString();
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      int currentValue = int.tryParse(_miktarController.text) ?? 0;
                      currentValue += 1;
                      _miktarController.text = currentValue.toString();
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: _saveData,
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
                      'Düşüm Yap',
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

class TextFieldStyles {
  static InputDecoration defaultDecoration(String hintText, IconData icon) {
    return InputDecoration(
      hintText: hintText,
      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
      suffixIcon: Icon(icon, color: Colors.black, size: 18.0),
      enabledBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(30.0)),
        borderSide: BorderSide(
          color: Colors.grey,
          width: 0.9,
        ),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(30.0)),
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
