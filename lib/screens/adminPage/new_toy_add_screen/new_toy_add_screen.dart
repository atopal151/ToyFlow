import 'package:flutter/material.dart';
import 'package:toyflow/screens/adminPage/new_toy_add_screen/toy_services/toy_add_services.dart';
import '../register_screen/registerServices/textbox_style_file.dart';

class NewToyAddScreen extends StatefulWidget {
  const NewToyAddScreen({super.key});

  @override
  State<NewToyAddScreen> createState() => _NewToyAddScreenState();
}

class _NewToyAddScreenState extends State<NewToyAddScreen> {
  final TextEditingController _toyName = TextEditingController();
  final TextEditingController _toyRenk = TextEditingController();
  final TextEditingController _toyBoyut = TextEditingController();
  final TextEditingController _toyAksesuar = TextEditingController();
  final ToyAddServices _toyAddServices =
      ToyAddServices(); // ToyAddServices örneği

  void _addName() {
    String name = _toyName.text;

    if (name.isNotEmpty) {
      _toyAddServices.addNewToy(
        urun: name,
        context: context,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Boş alanları lütfen doldurun.')),
      );
    }
  }

  void _addRenk() {
    String renk = _toyRenk.text;

    if (renk.isNotEmpty) {
      _toyAddServices.addNewColor(
        renk: renk,
        context: context,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Boş alanları lütfen doldurun.')),
      );
    }
  }

  void _addBoyut() {
    String boyut = _toyBoyut.text;

    if (boyut.isNotEmpty) {
      _toyAddServices.addNewHeight(
        boyut: boyut,
        context: context,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Boş alanları lütfen doldurun.')),
      );
    }
  }

  void _addAksesuar() {
    String aksesuar = _toyAksesuar.text;

    if (aksesuar.isNotEmpty) {
      _toyAddServices.addNewAksesuar(
        aksesuar: aksesuar,
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
                    controller: _toyName,
                    hintText: 'Yeni Oyuncak İsmi',
                    icon: Icons.style,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: ElevatedButton(
                onPressed: () {
                  _addName(); // Kaydetme işlemi başlatılıyor
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
                      'Oyuncak İsmi Ekle',
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
            Row(
              children: [
                Expanded(
                  child: TextFieldWithRegister(
                    controller: _toyRenk,
                    hintText: 'Yeni Renk',
                    icon: Icons.style,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: ElevatedButton(
                onPressed: () {
                  _addRenk(); // Kaydetme işlemi başlatılıyor
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
                      'Renk Ekle',
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
            Row(
              children: [
                Expanded(
                  child: TextFieldWithRegister(
                    controller: _toyBoyut,
                    hintText: 'Yeni Boyut',
                    icon: Icons.style,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: ElevatedButton(
                onPressed: () {
                  _addBoyut(); // Kaydetme işlemi başlatılıyor
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
                      'Boyut Ekle',
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
            Row(
              children: [
                Expanded(
                  child: TextFieldWithRegister(
                    controller: _toyAksesuar,
                    hintText: 'Yeni Aksesuar',
                    icon: Icons.style,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: ElevatedButton(
                onPressed: () {
                  _addAksesuar(); // Kaydetme işlemi başlatılıyor
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
                      'Aksesuar Ekle',
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
