import 'package:flutter/material.dart';
import 'package:toyflow/screens/adminPage/new_work_shop/work_shop_services/work_shop_services.dart';

import '../register_screen/registerServices/dropdown_style_file.dart';
import '../register_screen/registerServices/textbox_style_file.dart';

class WorkShopNewAdd extends StatefulWidget {
  const WorkShopNewAdd({super.key});

  @override
  State<WorkShopNewAdd> createState() => _WorkShopNewAddState();
}

class _WorkShopNewAddState extends State<WorkShopNewAdd> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _collection = TextEditingController();
  String? _nitelik; // Seçilen rol
  String? _oncekiBirim; // Seçilen rol
  String? _sonrakiBirim; // Seçilen rol
  final WorkShopServices _workShopServices = WorkShopServices();

  // Rol ve atölye listeleri
  final List<String> roles = [
    'admin',
    'Dokuma',
    'Boyama',
    'Kesim',
    'Dikim',
    'Dolum',
    'Paketleme',
    'Transfer',
    'Depo'
  ];

  void _addWorkShop() {
    String name = _name.text;
    String nitelik = _nitelik!;
    String oncekiBirim = _oncekiBirim!;
    String sonrakiBirim = _sonrakiBirim!;
    String collection = _collection.text;

    if (name.isNotEmpty && nitelik.isNotEmpty && collection.isNotEmpty) {
      _workShopServices.addNewWorkShop(
        name: name,
        nitelik: nitelik,
        collectionName: collection,
        context: context,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Boş alanları lütfen doldurun.')),
      );
    }
  }

  void _connected() {
    String name = _name.text;
    String oncekiBirim = _oncekiBirim!;
    String sonrakiBirim = _sonrakiBirim!;

    if (oncekiBirim.isNotEmpty && name.isNotEmpty && sonrakiBirim.isNotEmpty) {
      _workShopServices.connectedWorkShop(
        oncekiBirim: oncekiBirim,
        rol: name,
        sonrakiBirim: sonrakiBirim,
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
        title: const Text("Yeni Atölye Kayıt"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFieldWithRegister(
                    controller: _name,
                    hintText: 'Yeni Atölye İsmi',
                    icon: Icons.style,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: DropdownRegisterSelector(
                    hintText: 'Rol Seç',
                    items: roles,
                    selectedValue: _nitelik,
                    onChanged: (String? newValue) {
                      setState(() {
                        _nitelik = newValue;
                      });
                    },
                    icon: Icons.arrow_drop_down,
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
                  padding: EdgeInsets.only(left: 30.0, top: 5),
                  child: Text(
                    "örn: fabrika_dikim_atolyesi",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: DropdownRegisterSelector(
                    hintText: 'Bağlı Olduğu Önceki Birim',
                    items: roles,
                    selectedValue: _oncekiBirim,
                    onChanged: (String? newValue) {
                      setState(() {
                        _oncekiBirim = newValue;
                      });
                    },
                    icon: Icons.arrow_drop_down,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: DropdownRegisterSelector(
                    hintText: 'Bağlı Olduğu Sonraki Birim',
                    items: roles,
                    selectedValue: _sonrakiBirim,
                    onChanged: (String? newValue) {
                      setState(() {
                        _sonrakiBirim = newValue;
                      });
                    },
                    icon: Icons.arrow_drop_down,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: ElevatedButton(
                onPressed: () {
                  _addWorkShop(); // Kaydetme işlemi başlatılıyor
                  _connected();
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
                      'Atolye Ekle',
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
