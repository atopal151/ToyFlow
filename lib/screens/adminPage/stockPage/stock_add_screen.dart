// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class StockAddScreen extends StatefulWidget {
  const StockAddScreen({super.key});

  @override
  State<StockAddScreen> createState() => _StockAddScreenState();
}

class _StockAddScreenState extends State<StockAddScreen> {
  final TextEditingController _miktarController = TextEditingController();

  String? _selectedRenk; // Seçilen renk
  String? _selectedUrun; // Seçilen ürün

  final List<String> urun = [
    'Polyester iplik',
    'Akrilik iplik',
    'Naylon iplik',
    'Pamuk iplik',
    'Karışım İplik'
  ];
  final List<String> renk = [
    'Kırmızı',
    'Mavi',
    'Sarı',
    'Yeşil',
    'Pembe',
    'Mor',
    'Turuncu',
    'Kahverengi',
    'Beyaz',
    'Siyah',
    'Gri',
    'Lacivert'
  ];

  Future<void> _saveStock() async {
  // Ürün, renk ve miktar bilgilerini al
  String? urun = _selectedUrun; // Seçilen ürün
  String? renk = _selectedRenk; // Seçilen renk
  int? miktar = int.tryParse(_miktarController.text); // Girilen miktar

  // Eğer herhangi bir veri girilmediyse uyarı göster
  if (urun == null || renk == null || miktar == null || miktar <= 0) {
    _showAlert('Lütfen tüm alanları doldurun ve geçerli bir miktar girin!');
    return;
  }

  // Yükleme işlemini göster
  showDialog(
    context: context,
    barrierDismissible: false, // Kapatılamaz yapar
    builder: (BuildContext context) {
      return const Center(
        child: CircularProgressIndicator(), // Yükleme animasyonu
      );
    },
  );

  try {
    // Firestore'da aynı ürün ve renge sahip bir kayıt var mı kontrol et
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('dokuma_work')
        .where('urun', isEqualTo: urun)
        .where('renk', isEqualTo: renk)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      // Kayıt varsa miktarı güncelle
      DocumentSnapshot existingDoc = querySnapshot.docs.first;
      int existingMiktar = existingDoc['miktar'];

      // Yeni miktarı ekle ve güncelle
      int yeniMiktar = existingMiktar + miktar;
      await FirebaseFirestore.instance
          .collection('dokuma_work')
          .doc(existingDoc.id)
          .update({'miktar': yeniMiktar});

      // Başarılı mesajı göster
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Mevcut stoğa $miktar kilo eklendi!')),
      );
    } else {
      // Kayıt yoksa yeni bir kayıt oluştur
      await FirebaseFirestore.instance.collection('dokuma_work').add({
        'urun': urun,      // Ürün adı
        'renk': renk,      // Renk
        'miktar': miktar,  // Miktar
        'tarih': FieldValue.serverTimestamp(), // Kayıt tarihi
      });

      // Başarılı mesajı göster
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Yeni stok başarıyla kaydedildi!')),
      );
    }
  } catch (e) {
    // Hata durumunda kullanıcıya mesaj göster
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Stok kaydı sırasında hata oluştu: $e')),
    );
  }

  // Yükleme animasyonunu kapat
  Navigator.pop(context); // Yükleme animasyonunu kapat
  Navigator.pop(context); // Bir önceki sayfaya dön
}

// Uyarı mesajı gösteren fonksiyon
void _showAlert(String message) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Uyarı'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Uyarıyı kapat
            },
            child: const Text('Tamam'),
          ),
        ],
      );
    },
  );
}

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
                items: urun.map((String urun) {
                  return DropdownMenuItem<String>(
                    value: urun,
                    child: Text(urun),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedUrun = newValue;
                  });
                },
                decoration:
                    TextFieldStyles.defaultDecoration('Ürün', Icons.layers),
              ),
              const SizedBox(height: 15),
              DropdownButtonFormField<String>(
                value: _selectedRenk,
                hint: const Text('Renk Seçin'),
                items: renk.map((String renk) {
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
                decoration:
                    TextFieldStyles.defaultDecoration('Renk', Icons.color_lens),
              ),
              const SizedBox(height: 15),
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
                padding: const EdgeInsets.only(top: 16, bottom: 16),
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
      suffixIcon: Icon(icon, color: Colors.grey.shade500), // Sağ tarafa yaslı ikon
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
