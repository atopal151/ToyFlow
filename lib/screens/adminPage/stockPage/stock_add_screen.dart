// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:toyflow/services/record_services.dart'; // RecordServices sınıfını import edin

import '../registerPage/registerServices/dropdown_style_file.dart';
import '../registerPage/registerServices/textbox_style_file.dart';

class StockAddScreen extends StatefulWidget {
  const StockAddScreen({super.key});

  @override
  State<StockAddScreen> createState() => _StockAddScreenState();
}

class _StockAddScreenState extends State<StockAddScreen> {
  final TextEditingController _miktarController = TextEditingController();
  final RecordServices _recordServices = RecordServices(); // RecordServices örneği

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

        // Kayıt oluşturmak için RecordServices'i çağırıyoruz
        await _recordServices.movementRecord(
          malzeme: urun,
          renk: renk,
          miktar: miktar,
          islemTuru: 'Stok Güncelleme',
          atelye: 'dokuma', // İlgili atölyeyi belirtin
          aciklama: 'Mevcut stoğa $miktar kilo $renk $urun eklendi!',
        );
      } else {
        // Kayıt yoksa yeni bir kayıt oluştur
        await FirebaseFirestore.instance.collection('dokuma_work').add({
          'urun': urun, // Ürün adı
          'renk': renk, // Renk
          'miktar': miktar, // Miktar
          'tarih': FieldValue.serverTimestamp(), // Kayıt tarihi
        });

        // Başarılı mesajı göster
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Yeni stok başarıyla kaydedildi!')),
        );

        // Kayıt oluşturmak için RecordServices'i çağırıyoruz
        await _recordServices.movementRecord(
          malzeme: urun,
          renk: renk,
          miktar: miktar,
          islemTuru: 'Stok Ekleme',
          atelye: 'dokuma', // İlgili atölyeyi belirtin
          aciklama: 'Yeni stoğa $miktar kilo $renk $urun eklendi!',
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
              icon: Icons.layers,
            ),
            DropdownRegisterSelector(
              hintText: 'Renk Seç',
              items: renk,
              selectedValue: _selectedRenk,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedRenk = newValue;
                });
              },
              icon: Icons.color_lens,
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
