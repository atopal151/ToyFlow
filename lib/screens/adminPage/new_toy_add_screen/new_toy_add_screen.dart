import 'package:flutter/material.dart';
import 'package:toyflow/screens/adminPage/new_toy_add_screen/toy_services/toy_add_services.dart';
import '../register_screen/registerServices/textbox_style_file.dart';

class NewToyAddScreen extends StatefulWidget {
  const NewToyAddScreen({super.key});

  @override
  State<NewToyAddScreen> createState() => _NewToyAddScreenState();
}

class _NewToyAddScreenState extends State<NewToyAddScreen> {
  final TextEditingController _kumas = TextEditingController();
  final TextEditingController _iplik = TextEditingController();
  final TextEditingController _toyName = TextEditingController();
  final TextEditingController _toyRenk = TextEditingController();
  final TextEditingController _toyBoyut = TextEditingController();
  final TextEditingController _toyAksesuar = TextEditingController();

  final TextEditingController _denye = TextEditingController();
  final TextEditingController _gramaj = TextEditingController();
  final TextEditingController _fine = TextEditingController();
  final ToyAddServices _toyAddServices =
      ToyAddServices();  

  void _addFine() {
    String fine= _fine.text;

    if (fine.isNotEmpty) {
      _toyAddServices.addNewFine(
        fine: fine,
        context: context,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Boş alanları lütfen doldurun.')),
      );
    }
  }

  void _addGramaj() {
    String gramaj = _gramaj.text;

    if (gramaj.isNotEmpty) {
      _toyAddServices.addNewGramaj(
        gramaj: gramaj,
        context: context,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Boş alanları lütfen doldurun.')),
      );
    }
  }

  void _addDenye() {
    String denye = _denye.text;

    if (denye.isNotEmpty) {
      _toyAddServices.addNewDenye(
        denye: denye,
        context: context,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Boş alanları lütfen doldurun.')),
      );
    }
  }

  void _addKumas() {
    String kumas = _kumas.text;

    if (kumas.isNotEmpty) {
      _toyAddServices.addNewKumas(
        kumas: kumas,
        context: context,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Boş alanları lütfen doldurun.')),
      );
    }
  }

  void _addIp() {
    String iplik = _iplik.text;

    if (iplik.isNotEmpty) {
      _toyAddServices.addNewIp(
        iplik: iplik,
        context: context,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Boş alanları lütfen doldurun.')),
      );
    }
  }

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
                Padding(
                  padding: const EdgeInsets.only(right: 20, top: 15),
                  child: ElevatedButton(
                    onPressed: () {
                      _addName();  
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
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: TextFieldWithRegister(
                    controller: _toyRenk,
                    hintText: 'Yeni Renk',
                    icon: Icons.color_lens,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 20, top: 15),
                  child: ElevatedButton(
                    onPressed: () {
                      _addRenk();  
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
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: TextFieldWithRegister(
                    controller: _toyBoyut,
                    hintText: 'Yeni Boyut',
                    icon: Icons.height,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 20, top: 15),
                  child: ElevatedButton(
                    onPressed: () {
                      _addBoyut();  
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
                      ],
                    ),
                  ),
                ),
              ],
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
                Padding(
                  padding: const EdgeInsets.only(right: 20, top: 15),
                  child: ElevatedButton(
                    onPressed: () {
                      _addAksesuar();  
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
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            const Divider(),
            Row(
              children: [
                Expanded(
                  child: TextFieldWithRegister(
                    controller: _iplik,
                    hintText: 'Yeni İplik İsmi',
                    icon: Icons.style,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 20, top: 15),
                  child: ElevatedButton(
                    onPressed: () {
                      _addIp();  
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
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: TextFieldWithRegister(
                    controller: _denye,
                    hintText: 'Yeni Denye İsmi',
                    icon: Icons.style,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 20, top: 15),
                  child: ElevatedButton(
                    onPressed: () {
                      _addDenye(); 
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
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            const Divider(),
            Row(
              children: [
                Expanded(
                  child: TextFieldWithRegister(
                    controller: _kumas,
                    hintText: 'Yeni Kumaş İsmi',
                    icon: Icons.style,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 20, top: 15),
                  child: ElevatedButton(
                    onPressed: () {
                      _addKumas();  
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
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: TextFieldWithRegister(
                    controller: _gramaj,
                    hintText: 'Yeni Gramaj İsmi',
                    icon: Icons.style,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 20, top: 15),
                  child: ElevatedButton(
                    onPressed: () {
                      _addGramaj();  
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
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: TextFieldWithRegister(
                    controller: _fine,
                    hintText: 'Yeni Fine İsmi',
                    icon: Icons.style,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 20, top: 15),
                  child: ElevatedButton(
                    onPressed: () {
                      _addFine();  
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
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
