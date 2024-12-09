import 'package:flutter/material.dart';
import 'package:toyflow/screens/admin/new_storage_add/storage_services/storage_services.dart';

import '../register_screen/registerServices/textbox_style_file.dart';

class StorageNewAdd extends StatefulWidget {
  const StorageNewAdd({super.key});

  @override
  State<StorageNewAdd> createState() => _StorageNewAddState();
}

class _StorageNewAddState extends State<StorageNewAdd> {
  final TextEditingController _title = TextEditingController();
  final TextEditingController _collection = TextEditingController();

  final StorageServices _storageServices=StorageServices();


void _addStorage() {
    String title = _title.text;
    String collection = _collection.text;

    if (title.isNotEmpty) {
      _storageServices.addNewStorage(
        name: title,
        collectionName: collection,
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
        title: const Text("Yeni Kalem Kayıt"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFieldWithRegister(
                    controller: _title,
                    hintText: 'Yeni Depo İsmi',
                    icon: Icons.style,
                  ),
                ),
              ],
            ),
             Row(
              children: [
                Expanded(
                  child: TextFieldWithRegister(
                    controller: _collection,
                    hintText: 'Veritabanı Tablo İsmi',
                    icon: Icons.style,
                  ),
                ),
              ],
            ),
            const Row(
              children: [
                Padding(
                  padding: EdgeInsets.only(left:30.0,top: 1),
                  child: Text("örn: denizli_depo",style: TextStyle(color: Colors.grey),),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: ElevatedButton(
                onPressed: () {
                  _addStorage(); // Kaydetme işlemi başlatılıyor
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
                      'Depo Ekle',
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
